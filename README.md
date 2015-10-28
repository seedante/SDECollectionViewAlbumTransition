# SDECollectionViewAlbumTransition
UICollectionViewController Transition like open and close an album. Blog for this: [Part I](http://www.jianshu.com/p/7a35ee30e90c), [Part II](http://www.jianshu.com/p/2cdf0729934f)

![AlbumTransition](https://raw.githubusercontent.com/seedante/SDECollectionViewAlbumTransition/PinchPopTransition/AlbumTransition.gif)


## Installtion 添加到你的工程

Drag files in "Classes" folder into your project.
将 Classes 里的文件拖到你的工程中即可。

## Usage 使用方法

- In your storyboard, drag a Object to your navigation controller, and set its custom class to "SDENavigationControllerDelegate"
- 在你的 storyboard 里，拖一个 Object 到你的 navigation controller 上面，并将这个 Object 的类设置为「SDENavigationControllerDelegate」

![drag an Object and set the custom class](https://raw.githubusercontent.com/seedante/SDECollectionViewAlbumTransition/PinchPopTransition/Config1.png)

- Set this object to be your navigation controller's delegate.
- 将这个 Object 设置为 navigation controller 的 delegate。

![set the delegate](https://raw.githubusercontent.com/seedante/SDECollectionViewAlbumTransition/PinchPopTransition/Config2.png)


- At the last, add one line code in your UICollectionView's delegate:
- 最后要做的一件事是，在下面的方法中添加一行代码：

        override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            self.selectedIndexPath = indexPath
            ...
        }
        
**Now the collectionView supports to pinch to pop.**
**现在当前的这个 collectionView 已经支持使用 pinch 手势来执行 pop 了。**


## Requirements 使用条件

- iOS 8.0+
- Swift 2.0

Thanks for [@CezaryKopacz](https://github.com/CezaryKopacz/CKWaveCollectionViewTransition), [@ColinEberhardt](https://github.com/ColinEberhardt/VCTransitionsLibrary). I learn a lot from their repo.
And thanks for [ Vincent Ngo](http://www.raywenderlich.com/94565/how-to-create-an-ios-book-open-animation-part-1) very much, I find the key to resolve the problem of pinching to push.
There is a little problem with time delta algorithm, I will update if I find the way to improvement. 

## Pinch to push? 使用 Pinch 手势支持 push？

Pinching to push is a little complex. ViewController to push must be created before push, and init a ViewController is complex than do something to a existed ViewController, so this is why most of libraries do not support pinch to push. 
使用 pinch 手势来支持 push 操作有点麻烦.在 push 一个视图控制器前必然要生成一个实例，但这个类别是未知的，需要你来决定，这就是为什么很多库只支持 pinch push 的原因，pop 前视图控制器已经存在了，就不存在这个困扰。

If you want to use pinch to support push and pop both, switch to the branch "Pinch-Push-Pop-Transition", drag files in "Classes" folder in this branch into your project, 
there is a little difference between "Pinch-Push-Pop-Transition" branch with other branches.
如果你想使用 pinch 手势同时支持 push 和 pop 操作，那么当前的分支的模式就不能用了，请切换到「Pinch-Push-Pop-Transition」分支。同样地，将 Classes 文件夹里的文件拖到你的工程里。

Add the below properties to your UICollectionViewController child class:
在你的 UICollectionViewController 子类添加以下属性和方法：

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

                if let toVC = ...{
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
