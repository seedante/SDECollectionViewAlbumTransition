//
//  SDENavigationDelegate.swift
//  SDEAlbumTransition
//
//  Created by seedante on 15/10/15.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class SDENavigationDelegate: NSObject, UINavigationControllerDelegate {

    //MARK: UINavigationControllerDelegate
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        let animator = SDETransitionAnimator(operation: operation)
        return animator
    }

}
