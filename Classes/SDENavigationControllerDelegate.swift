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
    var isPush = false
    var animationController: UIViewControllerAnimatedTransitioning!
    var interactionController: UIPercentDrivenInteractiveTransition?

    //MARK: UINavigationControllerDelegate
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        animationController = SDEPushAndPopAnimationController(operation: operation)
        isPush = (operation == .Push)
        return animationController
    }

    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        if interactive{
            interactionController = UIPercentDrivenInteractiveTransition()
            return interactionController
        }

        return nil
    }

}

