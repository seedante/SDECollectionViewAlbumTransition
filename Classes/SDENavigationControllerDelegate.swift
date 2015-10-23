//
//  SDENavigationDelegate.swift
//  SDEAlbumTransition
//
//  Created by seedante on 15/10/15.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit


class SDENavigationControllerDelegate: NSObject, UINavigationControllerDelegate {

    var interactive = false
    private (set) var animationController: UIViewControllerAnimatedTransitioning!
    private (set) var interactionController: UIPercentDrivenInteractiveTransition?

    //MARK: UINavigationControllerDelegate
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        animationController = SDEPushAndPopAnimationController(operation: operation)
        if operation == .Push{
            if let toCollectionVC = toVC as? UICollectionViewController{
                interactionController =  SDEPopPinchInteractionController(toVC: toCollectionVC, holder: self)
            }
        }

        return animationController
    }

    //If you want a interaction transition, you must implement this method.
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        // interactive can only update in gesture action
        if interactive{
            return interactionController
        }

        return nil
    }

}

