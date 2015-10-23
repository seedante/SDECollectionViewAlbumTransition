//
//  SDETransitionAnimator.swift
//  CustomCollectionViewTransition
//
//  Created by seedante on 15/7/11.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class SDEPushAndPopAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let coverEdgeInSets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    let coverViewBackgroundColor = UIColor.darkGrayColor()
    let horizontalCount = 5
    var verticalCount = 1
    var horizontalGap: CGFloat = 0
    var verticalGap: CGFloat = 0

    private let kAnimationDuration: Double = 1.0
    private let kCellAnimationSmallDelta: Double = 0.01
    private let kCellAnimationBigDelta: Double = 0.03

    private var operation: UINavigationControllerOperation

    init(operation: UINavigationControllerOperation){
        self.operation = operation
        super.init()
    }

    //MARK: Protocol Method
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return kAnimationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let containerView = transitionContext.containerView()
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? UICollectionViewController
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? UICollectionViewController
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
        let duration = transitionDuration(transitionContext)

        switch operation{
        case .Push:
            let selectedCell = fromVC?.collectionView?.cellForItemAtIndexPath(fromVC!.selectedIndexPath)
            selectedCell?.hidden = true

            let layoutAttributes = fromVC!.collectionView?.layoutAttributesForItemAtIndexPath(fromVC!.selectedIndexPath)
            let areaRect = fromVC!.collectionView?.convertRect(layoutAttributes!.frame, toView: fromVC!.collectionView?.superview)
            toVC!.coverRectInSuperview = areaRect!

            //key code, the most important code here. without this line, you can't get visibleCells from UICollectionView.
            //And, there are other ways, Just make view redraw.
            toVC?.view.layoutIfNeeded()
            setupVisibleCellsBeforePushToVC(toVC!)
            containerView?.addSubview(toView!)

            let fakeCoverView = createAndSetupFakeCoverView(fromVC!, toVC: toVC!)

            UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut)
            let options: UIViewKeyframeAnimationOptions = [.BeginFromCurrentState, .OverrideInheritedDuration, .CalculationModeCubic, .CalculationModeLinear]
            UIView.animateKeyframesWithDuration(duration, delay: 0, options: options, animations: {

                self.addkeyFrameAnimationForBackgroundColorInPush(fromVC!, toVC: toVC!)
                self.addKeyFrameAnimationInPushForFakeCoverView(fakeCoverView)
                self.addKeyFrameAnimationOnVisibleCellsInPushToVC(toVC!)

                }, completion: { finished in

                    let isCancelled = transitionContext.transitionWasCancelled()
                    if isCancelled{
                        selectedCell?.hidden = false
                    }
                    transitionContext.completeTransition(!isCancelled)
            })


        case .Pop:
            containerView?.insertSubview(toView!, belowSubview: fromView!)

            let coverView = fromView?.viewWithTag(1000)
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
            UIView.animateKeyframesWithDuration(duration, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
                self.addkeyFrameAnimationForBackgroundColorInPop(fromVC!)
                self.addKeyFrameAnimationInPopForFakeCoverView(coverView)
                self.addKeyFrameAnimationOnVisibleCellsInPopFromVC(fromVC!)

                }, completion: { finished in

                    let selectedCell = toVC?.collectionView?.cellForItemAtIndexPath(toVC!.selectedIndexPath)
                    selectedCell?.hidden = false
                    let isCancelled = transitionContext.transitionWasCancelled()
                    transitionContext.completeTransition(!isCancelled)
            })

        default:
            print("No Operation")
        }
    }

    //MARK: Push Transition Helper Method
    func createAndSetupFakeCoverView(fromVC: UICollectionViewController, toVC: UICollectionViewController) -> UIView?{
        let selectedCell = fromVC.collectionView?.cellForItemAtIndexPath(fromVC.selectedIndexPath)
        let snapshotCellView = selectedCell!.snapshotViewAfterScreenUpdates(false)
        snapshotCellView.tag = 10

        let coverContainerView = UIView(frame: snapshotCellView.frame)
        coverContainerView.backgroundColor = coverViewBackgroundColor
        coverContainerView.addSubview(snapshotCellView)
        coverContainerView.tag = 1000

        toVC.view.addSubview(coverContainerView)
        coverContainerView.frame = toVC.coverRectInSuperview

        let frame = coverContainerView.frame
        coverContainerView.layer.anchorPoint = CGPointMake(0, 0.5)
        coverContainerView.frame = frame

        return coverContainerView
    }

    func addKeyFrameAnimationInPushForFakeCoverView(coverView: UIView?){
        UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.5, animations: {
            var flipLeftTransform = CATransform3DIdentity
            flipLeftTransform.m34 = -1.0 / 500.0
            flipLeftTransform = CATransform3DRotate(flipLeftTransform, CGFloat(-M_PI), 0.0, 1.0, 0.0)
            coverView?.layer.transform = flipLeftTransform
        })

        UIView.addKeyframeWithRelativeStartTime(0.45, relativeDuration: 0.05, animations: {
            coverView?.alpha = 0
        })

        //fix Transparent Background In Flip Animation
        let snapshotView = coverView?.viewWithTag(10)
        UIView.addKeyframeWithRelativeStartTime(0.25, relativeDuration: 0.01, animations: {
            snapshotView?.alpha = 0
        })

    }

    func addkeyFrameAnimationForBackgroundColorInPush(fromVC: UICollectionViewController, toVC: UICollectionViewController){
        UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1.0, animations: {
            let toCollectionViewBackgroundColor = fromVC.collectionView?.backgroundColor
            toVC.collectionView?.backgroundColor = toCollectionViewBackgroundColor
        })
    }


    private func addKeyFrameAnimationOnVisibleCellsInPushToVC(toVC: UICollectionViewController){
        let collectionView = toVC.collectionView!
        for cell in collectionView.visibleCells(){
            let indexPath = collectionView.indexPathForCell(cell)!
            let layoutAttributes = collectionView.layoutAttributesForItemAtIndexPath(indexPath)
            var column = indexPath.row / horizontalCount
            let row = indexPath.row % horizontalCount
            if (column + 1) * (row + 1) > horizontalCount * verticalCount{
                column = ((column + 1) * (row + 1)) % (horizontalCount * verticalCount) / horizontalCount
            }

            let columns = verticalCount

            let relativeStartTime = (self.kCellAnimationBigDelta * Double(indexPath.row % columns))
            var relativeDuration = 0.5 - (self.kCellAnimationSmallDelta * Double(indexPath.row))
            if (relativeStartTime + relativeDuration) > 0.5 {
                relativeDuration = 0.5 - relativeStartTime
            }

            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.7, animations: {
                cell.alpha = 1
            })

            UIView.addKeyframeWithRelativeStartTime(0.5 + relativeStartTime, relativeDuration: 0.3, animations: {
                cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)
            })

            UIView.addKeyframeWithRelativeStartTime(0.5 + relativeStartTime, relativeDuration: 0.3, animations: {
                cell.center = layoutAttributes!.center
            })


        }

    }


    func setupVisibleCellsBeforePushToVC(toVC:UICollectionViewController){
        if toVC.collectionView?.visibleCells().count > 0{

            let areaRect = toVC.collectionView!.convertRect(toVC.coverRectInSuperview, fromView: toVC.collectionView!.superview)
            let cellsAreaRect = UIEdgeInsetsInsetRect(areaRect, coverEdgeInSets)

            let cellWidth = (cellsAreaRect.width - CGFloat(horizontalCount - 1) * horizontalGap) / CGFloat(horizontalCount)
            let cellHeight = cellWidth
            verticalCount = Int((cellsAreaRect.height + verticalGap) / (cellHeight + verticalGap))

            for cell in toVC.collectionView!.visibleCells(){
                let indexPath = toVC.collectionView!.indexPathForCell(cell)
                var column = indexPath!.row / horizontalCount
                let row = indexPath!.row % horizontalCount
                if (column + 1) * (row + 1) > horizontalCount * verticalCount{
                    column = ((column + 1) * (row + 1)) % (horizontalCount * verticalCount) / horizontalCount
                }

                let centerY: CGFloat = cellsAreaRect.origin.y + cellHeight / 2 + CGFloat(column) * (cellHeight + verticalGap)
                let centerX = cellsAreaRect.origin.x + cellWidth / 2 + CGFloat(row) * (cellWidth + horizontalGap)
                cell.center = CGPoint(x: centerX, y: centerY)

                let widthScale = cellWidth / cell.frame.width
                let heightScale = cellHeight / cell.frame.height
                cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, widthScale, heightScale)

                cell.alpha = 0
                cell.layer.zPosition = CGFloat(100 - indexPath!.row)
            }
        }
    }

    //MARK: Pop Transition Helper Method
    func addkeyFrameAnimationForBackgroundColorInPop(fromVC: UICollectionViewController){
        UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.5, animations: {
            fromVC.collectionView?.backgroundColor = UIColor.clearColor()
        })
    }

    func addKeyFrameAnimationInPopForFakeCoverView(coverView: UIView?){
        UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.1, animations: {
            coverView?.alpha = 1
        })


        UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: {
            coverView?.layer.transform = CATransform3DIdentity
        })

        //fix Transparent Background In Flip Animation
        let snapshotView = coverView?.viewWithTag(10)
        UIView.addKeyframeWithRelativeStartTime(0.75, relativeDuration: 0.01, animations: {
            snapshotView?.alpha = 1
        })
    }

    func addKeyFrameAnimationOnVisibleCellsInPopFromVC(fromVC: UICollectionViewController) {
        
        let visibleCellIndexPaths = fromVC.collectionView?.indexPathsForVisibleItems()
        if visibleCellIndexPaths?.count > 0{
            //find minimal indexpath's row
            let rows = visibleCellIndexPaths!.map({$0.row})
            let minimalRow = rows.reduce(Int.max, combine: { $0 < $1 ? $0 : $1 })

            let collectionView = fromVC.collectionView!
            let areaRect = collectionView.convertRect(fromVC.coverRectInSuperview, fromView: fromVC.collectionView!.superview)
            let cellsAreaRect = UIEdgeInsetsInsetRect(areaRect, coverEdgeInSets)

            let cellWidth = (cellsAreaRect.width - CGFloat(horizontalCount - 1) * horizontalGap) / CGFloat(horizontalCount)
            let cellHeight = cellWidth
            verticalCount = Int((cellsAreaRect.height + verticalGap) / (cellHeight + verticalGap))

            for indexPath in visibleCellIndexPaths!{
                let relativeRow = indexPath.row - minimalRow
                var column = relativeRow / horizontalCount
                let row = relativeRow % horizontalCount
                if (column + 1) * (row + 1) > horizontalCount * verticalCount{
                    column = ((column + 1) * (row + 1)) % (horizontalCount * verticalCount) / horizontalCount
                }

                let centerY: CGFloat = cellsAreaRect.origin.y + cellHeight / 2 + CGFloat(column) * (cellHeight + verticalGap)
                let centerX = cellsAreaRect.origin.x + cellWidth / 2 + CGFloat(row) * (cellWidth + horizontalGap)

                let cell = collectionView.cellForItemAtIndexPath(indexPath)!
                let widthScale = cellWidth / cell.frame.width
                let heightScale = cellHeight / cell.frame.height

                let relativeStartTime = (self.kCellAnimationBigDelta * Double(relativeRow % verticalCount))
                var relativeDuration = 0.5 - (self.kCellAnimationSmallDelta * Double(relativeRow))
                if (relativeStartTime + relativeDuration) > 0.5 {
                    relativeDuration = 0.5 - relativeStartTime
                }

                UIView.addKeyframeWithRelativeStartTime(relativeStartTime, relativeDuration: relativeDuration, animations: {
                    cell.center = CGPoint(x: centerX, y: centerY)
                    cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, widthScale, heightScale)
                })
            }
        }
    }



}
