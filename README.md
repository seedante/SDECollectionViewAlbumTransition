# SDECollectionViewAlbumTransition
UICollectionViewController Transition like open and close an album.

![AlbumTransition](https://raw.githubusercontent.com/seedante/SDECollectionViewAlbumTransition/PinchPopTransition/AlbumTransition.gif)


## Installtion

Drag files in "Classes" folder into your project.

## Usage

- In your storyboard, drag a object to your navigation controller, and set its custom class to "SDENavigationControllerDelegate"

![drag an Object and set the custom class](https://raw.githubusercontent.com/seedante/SDECollectionViewAlbumTransition/PinchPopTransition/Config1.png)

- Set this object to be your navigation controller's delegate.

![set the delegate](https://raw.githubusercontent.com/seedante/SDECollectionViewAlbumTransition/PinchPopTransition/Config2.png)


- At the last, add a line code in your UICollectionView's delegate:

        override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            self.selectedIndexPath = indexPath
            ...
        }
        
**Now your project supports to pinch to pop.**


## Requirements

- iOS 7.0+

Thanks for [@CezaryKopacz](https://github.com/CezaryKopacz/CKWaveCollectionViewTransition), [@ColinEberhardt](https://github.com/ColinEberhardt/VCTransitionsLibrary). I learn a lot from their repo.
And thanks for [ Vincent Ngo](http://www.raywenderlich.com/94565/how-to-create-an-ios-book-open-animation-part-1) very much, I find the key to resolve the problem of pinching to push.
There is a little problem with time delta algorithm, I will update if I find the way to improvement. 

## Pinch to push?

Pinching to push is a little complex. 

If you want to support pinch to push, switch to the branch "Pinch-Push-Pop-Transition", drag files in "Classes" folder in this branch into your project, 
there is a little difference between "Pinch-Push-Pop-Transition" branch with other branches.

Add the below properties to your UICollectionViewController child class:

    var transitionDelegate: SDENavigationControllerDelegate?
    var pinchGestureRecognizer: UIPinchGestureRecognizer?{
        didSet(newValue){
            collectionView?.addGestureRecognizer(pinchGestureRecognizer!)
        }
    }

    override viewDidLoad(){
        ...
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
    }
    
    deinit{
        if pinchGestureRecognizer != nil{
            collectionView?.removeGestureRecognizer(pinchGestureRecognizer!)
        }
    }

    //MARK: Pinch Push and Pop
    func getIndexPathForGesture(gesture: UIPinchGestureRecognizer) -> NSIndexPath?{
        let location0 = gesture.locationOfTouch(0, inView: gesture.view)
        let location1 = gesture.locationOfTouch(1, inView: gesture.view)
        let middleLocation = CGPointMake((location0.x + location1.x)/2, (location0.y + location1.y)/2)
        let indexPath = collectionView?.indexPathForItemAtPoint(middleLocation)
        return indexPath
    }

    func handlePinch(gesture: UIPinchGestureRecognizer){
        switch gesture.state{
        case .Began:
            if gesture.scale >= 1.0{
                guard let indexPath = getIndexPathForGesture(gesture) else{
                    return
                }

                self.selectedIndexPath = indexPath
                let layoutAttributes = collectionView!.layoutAttributesForItemAtIndexPath(indexPath)
                let areaRect = collectionView!.convertRect(layoutAttributes!.frame, toView: collectionView?.superview)

                if let toVC = ...{
                    toVC.coverRectInSuperview = areaRect

                    transitionDelegate = navigationController?.delegate as? SDENavigationControllerDelegate
                    transitionDelegate?.interactive = true
                    navigationController?.pushViewController(toVC, animated: true)
                }

            }else{
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
