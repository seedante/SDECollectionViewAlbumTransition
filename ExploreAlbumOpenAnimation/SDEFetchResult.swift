//
//  SDEFetchResult.swift
//  Albums
//
//  Created by seedante on 15/6/8.
//  Copyright (c) 2015年 seedante. All rights reserved.
//

import Photos

class SDEFetchResult: NSObject {
    static let fetchOption = PHFetchOptions()
    class func fetchPosterImageForImageView(imageView:UIImageView, assetCollection: PHAssetCollection, imageSize: CGSize){
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: fetchOptions)
        
        fetchResult.enumerateObjectsAtIndexes(NSIndexSet(index: 0), options: NSEnumerationOptions.Concurrent){
            (assetItem: AnyObject!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            PHImageManager.defaultManager().requestImageForAsset(assetItem as! PHAsset, targetSize: imageSize, contentMode: .AspectFill, options: nil, resultHandler:{
                (image: UIImage?, info: [NSObject: AnyObject]?) -> Void in
                imageView.image = image
            })
        }

    }
    
    
    class func fetchAssetFrom(assetsFetchResult: PHFetchResult, index: Int, includeHidden:Bool) -> PHAsset?{
        var asset: PHAsset?
        
        assetsFetchResult.enumerateObjectsAtIndexes(NSIndexSet(index: index), options: NSEnumerationOptions.Concurrent, usingBlock: {
            (assetItem, specialIndex, stop) in
            asset = assetItem as? PHAsset
        })
        
        return asset
    }
    
    class func fetchImageForImageView(imageView: UIImageView, asset: PHAsset, imageSize: CGSize){
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: imageSize, contentMode: .AspectFill, options: nil){
            (image: UIImage?, info: [NSObject : AnyObject]?) in
            imageView.image = image
        }

    }
    
    class func fetchImageForImageView(imageView: UIImageView, assetCollection: PHAssetCollection, index: Int, imageSize: CGSize){
        let fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)
        if fetchResult.count > index{
            fetchResult.enumerateObjectsAtIndexes(NSIndexSet(index: index), options: NSEnumerationOptions.Concurrent){
                (assetItem: AnyObject!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                PHImageManager.defaultManager().requestImageForAsset(assetItem as! PHAsset, targetSize: imageSize, contentMode: .AspectFill, options: nil){
                    (image: UIImage?, info: [NSObject : AnyObject]?) in
                    imageView.image = image
                }
            }
        }
    }
    
    class func fetchImageForImageView(imageView: UIImageView, assetsFetchResult: PHFetchResult, index: Int, imageSize: CGSize){
        if assetsFetchResult.count > 0{
            assetsFetchResult.enumerateObjectsAtIndexes(NSIndexSet(index: index), options: NSEnumerationOptions.Concurrent){
                (assetItem, index, stop) -> Void in
                PHImageManager.defaultManager().requestImageForAsset(assetItem as! PHAsset, targetSize: imageSize, contentMode: .AspectFill, options: nil, resultHandler: {
                    (image, info) in
                    imageView.image = image
                })
            }
        }
    }
    
    class func fetchImageForImageView(imageView: UIImageView, assetCollectionFetchResult: PHFetchResult, index: Int, imageSize: CGSize){
        if assetCollectionFetchResult.count > 0{
            assetCollectionFetchResult.enumerateObjectsAtIndexes(NSIndexSet(index: index), options: NSEnumerationOptions.Concurrent, usingBlock: {
                (assetCollectionItem, index, stop) in
                let assetCollection = assetCollectionItem as! PHAssetCollection
                self.fetchImageForImageView(imageView, assetCollection: assetCollection, index: index, imageSize: imageSize)
            })
        }
    }
    
}
