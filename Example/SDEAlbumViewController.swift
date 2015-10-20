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

class SDEAlbumViewController: UICollectionViewController {

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

    var transitionDelegate: SDENavigationControllerDelegate?
    var pinchGestureRecognizer: UIPinchGestureRecognizer?{
        didSet{
            collectionView?.addGestureRecognizer(pinchGestureRecognizer!)
        }
    }

    //MARK: Life circle
    override func viewDidLoad() {
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
    }

    deinit{
        if pinchGestureRecognizer != nil{
            collectionView?.removeGestureRecognizer(pinchGestureRecognizer!)
        }
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
        let asset = fetchResult?.getAssetAtIndex(indexPath.row)
        switch asset!.mediaType{
        case .Image:
            identifier = ImageIdentifier
        case .Video:
            identifier = VideoIdentifier
        default:
            identifier = ImageIdentifier
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)
        
        if let imageView = cell.viewWithTag(-10) as? UIImageView{
            fetchResult?.fetchImageAtIndex(indexPath.row, imageView: imageView, targetSize: CGSizeMake(150, 150))
        }
        
        if let timeLabel = cell.viewWithTag(-30) as? UILabel{
            timeLabel.text = asset!.duration.humanOutput
        }
        
        if identifier == VideoIdentifier{
            let adaptiveCell = cell as! SDEAdaptiveAssetCell
            adaptiveCell.adjustLogoAndDurationLocation()
        }

        return cell
    }

    //MARK: Pinch Pop
    //There is not next level view controller, so just hanle pop. You can find how to handle puch in SDEGalleriesViewController.swift
    func handlePinch(gesture: UIPinchGestureRecognizer){
        switch gesture.state{
        case .Began:
            if gesture.scale < 1.0{
                //after view controller is poped, UIViewController.navigationController is nil. So you need to keep it somewhere before pop
                transitionDelegate = self.navigationController?.delegate as? SDENavigationControllerDelegate
                transitionDelegate?.interactive = true
                self.navigationController?.popViewControllerAnimated(true)
            }

        case .Changed:
            guard transitionDelegate != nil else{
                return
            }

            guard let interactionController = transitionDelegate?.interactionController else{
                return
            }

            var progress = gesture.scale
            if transitionDelegate!.isPush{
                progress = gesture.scale - 1.0 >= 0.9 ? 0.9 : gesture.scale - 1.0
            }else{
                progress = 1.0 - gesture.scale
            }

            interactionController.updateInteractiveTransition(progress)

        case .Ended, .Cancelled:
            guard transitionDelegate != nil else{
                return
            }

            guard let interactionController = transitionDelegate?.interactionController else{
                return
            }

            var progress = gesture.scale
            if transitionDelegate!.isPush{
                progress = gesture.scale - 1.0 >= 0.9 ? 0.9 : gesture.scale - 1.0
            }else{
                progress = 1.0 - gesture.scale
            }

            if progress >= 0.4{
                interactionController.finishInteractiveTransition()
            }else{
                interactionController.cancelInteractiveTransition()
            }
            transitionDelegate?.interactive = false
            
        default:
            guard transitionDelegate != nil else{
                return
            }
            transitionDelegate?.interactive = false
        }
    }
}
