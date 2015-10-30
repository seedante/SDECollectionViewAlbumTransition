//
//  UICollectionViewExtension.swift
//  CKWaveCollectionViewTransition
//
//  Created by Salvation on 7/21/15.
//  Modified by seedante.
//  Copyright (c) 2015 CezaryKopacz. All rights reserved.
//

import UIKit
import ObjectiveC

private var selectedIndexPathAssociationKey: UInt8 = 0
private var coverRectInSuperviewKey: UInt8 = 1

extension UICollectionViewController {
    
    var selectedIndexPath: NSIndexPath! {
        get {
            return objc_getAssociatedObject(self, &selectedIndexPathAssociationKey) as? NSIndexPath
        }
        set(newValue) {
            objc_setAssociatedObject(self, &selectedIndexPathAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    var coverRectInSuperview: CGRect! {
        get {
            let value = objc_getAssociatedObject(self, &coverRectInSuperviewKey) as? NSValue
            return value?.CGRectValue()
        }

        set(newValue){
            if newValue != nil{
                let value = NSValue(CGRect: newValue)
                objc_setAssociatedObject(self, &coverRectInSuperviewKey, value, .OBJC_ASSOCIATION_RETAIN)
            }
        }
    }
    
}
