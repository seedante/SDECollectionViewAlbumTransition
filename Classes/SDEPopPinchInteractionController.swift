//
//  SDEPushAndPopInteractionController.swift
//  SDECollectionViewAlbumTransition
//
//  Created by seedante on 15/10/19.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class SDEPopPinchInteractionController: UIPercentDrivenInteractiveTransition {
    private var pinchGesture = UIPinchGestureRecognizer()
    private var topVC: UICollectionViewController
    private unowned var holder: SDENavigationControllerDelegate

    init(toVC topVC: UICollectionViewController, holder: SDENavigationControllerDelegate) {
        self.topVC = topVC
        self.holder = holder
        super.init()
        addPinchGestureOnView(self.topVC.view)
    }

    private func addPinchGestureOnView(view: UIView){
        pinchGesture.addTarget(self, action: "sde_handlePinch:")
        view.addGestureRecognizer(pinchGesture)
    }

    internal func sde_handlePinch(gesture: UIPinchGestureRecognizer){
        switch gesture.state{
        case .Began:
            if gesture.scale < 1.0{
                holder.interactive = true
                topVC.navigationController?.popViewControllerAnimated(true)
            }
        case .Changed:
            if gesture.scale < 1.0{
                let progress = 1.0 - gesture.scale
                self.updateInteractiveTransition(progress)
            }
        case .Ended:
            if gesture.scale < 1.0{
                let progress = 1.0 - gesture.scale
                if progress > 0.4{
                    self.finishInteractiveTransition()
                }else{
                    self.cancelInteractiveTransition()
                }
                holder.interactive = false
            }
        default:
            holder.interactive = false
        }
    }

    deinit{
        pinchGesture.view?.removeGestureRecognizer(pinchGesture)
    }
}
