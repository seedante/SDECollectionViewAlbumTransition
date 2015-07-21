//
//  SDEAlbumViewController.swift
//  Albums
//
//  Created by seedante on 15/7/8.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit
import Photos

private let ImageIdentifier = "ImageCell"
private let VideoIdentifier = "VideoCell"

private let maskViewAnimationDuration = 0.4
private let backgroundColorAnimationDuration = 0.5
private let backgroundColorAnimationDelay = 0.1
private let cellAnimationDurationOne = 0.35
private let cellAnimationDurationTwo = 0.25

enum AlbumOpenStyle: Int{
    case CurlUp = 0, FlipUp, FlyOut, QuickTransition
}

class SDEAlbumViewController: UICollectionViewController {

    var fliped = false
    var imageViewOrigin: CGPoint?{
        willSet{
            maskImageView.frame.origin = newValue!
        }
    }
    
    var animationStyle: AlbumOpenStyle?
    var cellReferencePoint: CGPoint?
    
    var maskImageView = UIImageView(frame: CGRectMake(0, 0, 170, 170))
    var assetCollection:PHAssetCollection?{
        willSet{
            self.navigationItem.title = newValue!.localizedTitle
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchResult = PHAsset.fetchAssetsInAssetCollection(newValue!, options: fetchOptions)
        }
    }
    var fetchResult:PHFetchResult?{
        didSet{
            self.collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        //animationStyle = AlbumOpenStyle(rawValue: arc4random_uniform(4))
        
        maskImageView.contentMode = .ScaleAspectFill
        maskImageView.clipsToBounds = true
        maskImageView.backgroundColor = UIColor.whiteColor()
        maskImageView.layer.borderColor = UIColor.whiteColor().CGColor
        maskImageView.layer.borderWidth = 10.0
        self.view.addSubview(maskImageView)
        
        dispatch_async(dispatch_get_main_queue(), {
            UIView.animateWithDuration(0.1, animations: {
                self.maskImageView.frame.size = CGSizeMake(170, 190)
                }, completion: {
                    finish in
                    
                    switch self.animationStyle!{
                    case .CurlUp:
                        UIView.transitionWithView(self.maskImageView, duration: maskViewAnimationDuration, options: [.TransitionCurlUp, .ShowHideTransitionViews], animations: {
                            self.maskImageView.image = nil
                        }, completion: {
                            finish in
                            self.maskImageView.alpha = 0
                            UIView.animateWithDuration(backgroundColorAnimationDuration, delay: backgroundColorAnimationDelay, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                                self.view.backgroundColor = UIColor.whiteColor()
                            }, completion: nil)
                        })
                    case .FlipUp:
                        self.maskImageView.layer.anchorPoint = CGPointMake(0.5, 0)
                        self.maskImageView.center = CGPointMake(self.imageViewOrigin!.x + 85, self.imageViewOrigin!.y)
                        var perspective = CATransform3DIdentity
                        perspective.m34 = -1.0 / 500.0
                        let flipUpTransition = CATransform3DRotate(perspective, CGFloat(M_PI_2), 1.0, 0.0, 0.0)
                        
                        UIView.animateWithDuration(maskViewAnimationDuration, animations: {
                            self.maskImageView.layer.transform = flipUpTransition
                            }, completion: {
                                finish in
                                
                                self.maskImageView.alpha = 0
                                UIView.animateWithDuration(backgroundColorAnimationDuration, delay: backgroundColorAnimationDelay, options: .BeginFromCurrentState , animations: {
                                    self.view.backgroundColor = UIColor.whiteColor()
                                    }, completion: nil)
                        })

                    case .FlyOut:
                        self.maskImageView.layer.anchorPoint = CGPointMake(0, 0.5)
                        self.maskImageView.center = CGPointMake(self.imageViewOrigin!.x, self.imageViewOrigin!.y + 85)
                        var perspective = CATransform3DIdentity
                        perspective.m34 = -1.0 / 500.0
                        let flipRightTransition = CATransform3DRotate(perspective, CGFloat(-M_PI) * 3 / 4, 0.0, 1.0, 0.0)
                        
                        UIView.animateWithDuration(maskViewAnimationDuration, animations: {
                            self.maskImageView.layer.transform = flipRightTransition
                            self.maskImageView.alpha = 0
                            }, completion: {
                                finish in
                                
                                self.maskImageView.alpha = 0
                                UIView.animateWithDuration(backgroundColorAnimationDuration, delay: backgroundColorAnimationDelay, options: .BeginFromCurrentState , animations: {
                                    self.view.backgroundColor = UIColor.whiteColor()
                                    }, completion: nil)
                        })
                        
                    case .QuickTransition:
                        UIView.animateKeyframesWithDuration(maskViewAnimationDuration, delay: 0, options: .CalculationModeCubic, animations: {
                            self.maskImageView.transform = CGAffineTransformMakeScale(1.5, 1.5)
                            self.maskImageView.alpha = 0
                            }, completion: {
                                finish in
                                
                                self.maskImageView.alpha = 0
                                UIView.animateWithDuration(backgroundColorAnimationDuration, delay: backgroundColorAnimationDelay, options: .BeginFromCurrentState , animations: {
                                    self.view.backgroundColor = UIColor.whiteColor()
                                    }, completion: nil)
                                
                        })
                    }

            })
            
        })

    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fliped = true
        print("viewDidAppear")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.maskImageView.frame.size = CGSizeMake(170, 170)
        self.maskImageView.center = CGPointMake(self.imageViewOrigin!.x, self.imageViewOrigin!.y + 85)
        self.maskImageView.layer.anchorPoint = CGPointMake(0, 0.5)
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 500.0
        let flipBackTransition = CATransform3DRotate(perspective, CGFloat(-M_PI) * 3 / 4, 0.0, 1.0, 0.0)
        self.maskImageView.layer.transform = flipBackTransition
        UIView.animateWithDuration(0.1, animations: {
            self.maskImageView.alpha = 1.0
            }, completion: {
                finish in
                UIView.animateWithDuration(0.4, delay: 0.1, options: .BeginFromCurrentState, animations: {
                    self.maskImageView.layer.transform = CATransform3DIdentity
                    }, completion: nil)
        })
        

        if self.collectionView?.numberOfItemsInSection(0) > 0{
            for cell in self.collectionView!.visibleCells(){
                let initialCenter = cell.center
                let middleCenter = CGPointMake(cellReferencePoint!.x + 75, cellReferencePoint!.y + 75)
                let finalCenter = CGPointMake((cellReferencePoint?.x)! + CGFloat( 25 * (arc4random_uniform(5) + 1)), (cellReferencePoint?.y)! + CGFloat(25 * (arc4random_uniform(5) + 1)))
                
                cell.transform = CGAffineTransformMakeScale(0.1, 0.1)
                cell.center = finalCenter
                
                let scaleAnimation = CAKeyframeAnimation(keyPath: "transform")
                scaleAnimation.values = [NSValue.init(CATransform3D: CATransform3DMakeScale(1, 1, 1)), NSValue.init(CATransform3D: CATransform3DMakeScale(0.2, 0.2, 1)), NSValue.init(CATransform3D: CATransform3DMakeScale(0.1, 0.1, 0.1))]
                scaleAnimation.keyTimes = [0, 0.3, 1]
                scaleAnimation.calculationMode = kCAAnimationCubic
                scaleAnimation.duration = 0.5
                cell.layer.addAnimation(scaleAnimation, forKey: "scaleBack")
                
                let moveAnimation = CAKeyframeAnimation(keyPath: "position")
                moveAnimation.values = [NSValue.init(CGPoint: initialCenter), NSValue.init(CGPoint: middleCenter), NSValue.init(CGPoint: finalCenter)]
                moveAnimation.keyTimes = [0, 0.3, 1]
                moveAnimation.calculationMode = kCAAnimationCubic
                moveAnimation.duration = 0.5
                cell.layer.addAnimation(moveAnimation, forKey: "moveBack")
                
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if fetchResult != nil{
            return fetchResult!.count
        }
        return 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var identifier = ImageIdentifier
        let asset = SDEFetchResult.fetchAssetFrom(fetchResult!, index: indexPath.row, includeHidden: true)!
        switch asset.mediaType{
        case .Image:
            identifier = ImageIdentifier
        case .Video:
            identifier = VideoIdentifier
        default:
            identifier = ImageIdentifier
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)
        
        if let imageView = cell.viewWithTag(-10) as? UIImageView{
            SDEFetchResult.fetchImageForImageView(imageView, assetsFetchResult: fetchResult!, index: indexPath.row, imageSize: CGSizeMake(150, 150))
        }
        
        if let timeLabel = cell.viewWithTag(-30) as? UILabel{
            timeLabel.text = asset.duration.humanOutput
        }
        
        if identifier == VideoIdentifier{
            let adaptiveCell = cell as! SDEAdaptiveAssetCell
            adaptiveCell.adjustLogoAndDurationLocation()
        }
        
        if fliped != true{
            let initialCenter = CGPointMake(cellReferencePoint!.x + 75, cellReferencePoint!.y + 75)
            let finalCenter = cell.center
            
            var baseTime: NSTimeInterval = maskViewAnimationDuration
            if let nearestIndexPath = self.collectionView?.indexPathForItemAtPoint(initialCenter){
                let delta = nearestIndexPath.row > indexPath.row ? nearestIndexPath.row - indexPath.row : indexPath.row - nearestIndexPath.row
                let count = self.collectionView?.numberOfItemsInSection(0) > 30 ? 30 : self.collectionView?.numberOfItemsInSection(0)
                baseTime = maskViewAnimationDuration + Double(count! - delta) * 0.00033
            }
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(baseTime * Double(NSEC_PER_SEC)))
            
            cell.layer.zPosition = CGFloat(-indexPath.row)
            
            switch self.animationStyle!{
            case .CurlUp:
                cell.center = initialCenter
                let imageView = cell.viewWithTag(-10) as! UIImageView
                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    UIView.transitionWithView(cell, duration: cellAnimationDurationOne, options: UIViewAnimationOptions.TransitionCurlUp, animations: {
                        imageView.image = nil
                        }, completion: {
                            finish in
                            
                            SDEFetchResult.fetchImageForImageView(imageView, assetsFetchResult: self.fetchResult!, index: indexPath.row, imageSize: CGSizeMake(150, 150))
                            UIView.animateWithDuration(cellAnimationDurationTwo, delay: 0, options: [.CurveEaseOut, .BeginFromCurrentState], animations: {
                                cell.center = finalCenter
                                }, completion: nil)
                    })
                })
            case .FlipUp:
                var perspective = CATransform3DIdentity
                perspective.m34 = -1.0 / 500.0
                let flipUpTransition = CATransform3DRotate(perspective, CGFloat(M_PI_2), 1.0, 0.0, 0.0)
                cell.layer.anchorPoint = CGPointMake(0.5, 0)
                cell.center = CGPointMake(cellReferencePoint!.x + 75, cellReferencePoint!.y)

                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    UIView.animateWithDuration(cellAnimationDurationOne, animations: {
                        cell.layer.transform = flipUpTransition
                        }, completion: {
                            finish in
                            
                            UIView.animateWithDuration(cellAnimationDurationTwo, delay: 0, options: [.CurveEaseOut, .BeginFromCurrentState], animations: {
                                cell.layer.anchorPoint = CGPointMake(0.5, 0.5)
                                cell.layer.transform = CATransform3DIdentity
                                cell.center = finalCenter
                                }, completion: nil)
                    })
                })

            case .FlyOut:
                let randomInitialCenter = CGPointMake((cellReferencePoint?.x)! + CGFloat( 25 * (arc4random_uniform(5) + 1)), (cellReferencePoint?.y)! + CGFloat(25 * (arc4random_uniform(5) + 1)))
                cell.center = randomInitialCenter
                cell.transform = CGAffineTransformMakeScale(0.01, 0.01)

                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    CATransaction.begin()
                    
                    CATransaction.setCompletionBlock({
                        cell.transform = CGAffineTransformIdentity
                        cell.center = finalCenter
                    })
                    
                    let scaleAnimation = CAKeyframeAnimation(keyPath: "transform")
                    scaleAnimation.values = [NSValue.init(CATransform3D: CATransform3DMakeScale(0.01, 0.01, 1)), NSValue.init(CATransform3D: CATransform3DMakeScale(0.2, 0.2, 1)), NSValue.init(CATransform3D: CATransform3DMakeScale(1, 1, 1))]
                    scaleAnimation.keyTimes = [0, 0.7, 1]
                    scaleAnimation.calculationMode = kCAAnimationCubic
                    scaleAnimation.duration = 0.6
                    scaleAnimation.removedOnCompletion = true
                    cell.layer.addAnimation(scaleAnimation, forKey: "scale")
                    
                    let moveAnimation = CAKeyframeAnimation(keyPath: "position")
                    moveAnimation.values = [NSValue.init(CGPoint: randomInitialCenter), NSValue.init(CGPoint: initialCenter), NSValue.init(CGPoint: finalCenter)]
                    moveAnimation.keyTimes = [0, 0.7, 1]
                    moveAnimation.calculationMode = kCAAnimationCubic
                    moveAnimation.duration = 0.6
                    scaleAnimation.removedOnCompletion = true
                    cell.layer.addAnimation(moveAnimation, forKey: "move")
                    
                    CATransaction.commit()

                })

            case .QuickTransition:
                cell.layer.zPosition = CGFloat(indexPath.row)
                cell.transform = CGAffineTransformMakeScale(0.01, 0.01)
                cell.center = initialCenter
                let imageView = cell.viewWithTag(-10) as! UIImageView
                imageView.contentMode = .ScaleAspectFit
                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    UIView.animateWithDuration(cellAnimationDurationOne, animations: {
                        cell.transform = CGAffineTransformMakeScale(0.8, 0.8)
                        
                        }, completion: {
                            finish in
                            
                            cell.alpha = 0
                            cell.hidden = true
                            
                            UIView.animateWithDuration(cellAnimationDurationTwo, animations: {
                                cell.center = finalCenter
                                cell.transform = CGAffineTransformIdentity
                                cell.alpha = 1
                                cell.hidden = false
                                imageView.contentMode = .ScaleAspectFill
                            })

                    })
                })
            }

        }
        
        return cell
    }

}
