//
//  PHFetchResultExtension.swift
//  SDEAlbumTransition
//
//  Created by seedante on 15/10/15.
//  Copyright © 2015年 seedante. All rights reserved.
//

import Photos

extension PHFetchResult{
    class func fetchPosterImageForAssetCollection(assetCollection: PHAssetCollection, targetSize: CGSize) -> UIImage?{

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: fetchOptions)

        var posterImage: UIImage?
        fetchResult.enumerateObjectsAtIndexes(NSIndexSet(index: 0), options: NSEnumerationOptions.Concurrent){
            (assetItem: AnyObject!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in

            let requestOptions = PHImageRequestOptions()
            requestOptions.synchronous = true
            PHImageManager.defaultManager().requestImageForAsset(assetItem as! PHAsset, targetSize: targetSize, contentMode: .AspectFill, options: requestOptions, resultHandler:{
                (image: UIImage?, info: [NSObject: AnyObject]?) -> Void in
                posterImage = image
            })
        }

        return posterImage
    }

    class func fetchPosterImageForAssetCollection(assetCollection: PHAssetCollection, imageView: UIImageView, targetSize: CGSize){
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: fetchOptions)

        fetchResult.enumerateObjectsAtIndexes(NSIndexSet(index: 0), options: NSEnumerationOptions.Concurrent){
            (assetItem: AnyObject!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in

            PHImageManager.defaultManager().requestImageForAsset(assetItem as! PHAsset, targetSize: targetSize, contentMode: .AspectFill, options: nil, resultHandler:{
                (image, info) -> Void in
                imageView.image = image
            })
        }
    }

    func fetchImageAtIndex(index: Int, targetSize: CGSize) -> UIImage?{
        if self.count > index{
            var fetchedImage: UIImage?
            self.enumerateObjectsAtIndexes(NSIndexSet(index: index), options: NSEnumerationOptions.Concurrent){
                (assetItem, index, stop) -> Void in

                if let asset = assetItem as? PHAsset{
                    let requestOptions = PHImageRequestOptions()
                    requestOptions.synchronous = true

                    PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFill, options: requestOptions, resultHandler: {
                        (image, info) in
                        fetchedImage = image
                    })
                }

            }
            return fetchedImage
        }

        return nil
    }

    func fetchImageAtIndex(index: Int, imageView:UIImageView, targetSize: CGSize){
        if self.count > index{
            self.enumerateObjectsAtIndexes(NSIndexSet(index: index), options: NSEnumerationOptions.Concurrent){
                (assetItem, index, stop) -> Void in

                if let asset = assetItem as? PHAsset{
                    PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFill, options: nil, resultHandler: {
                        (image, info) in
                        imageView.image = image
                    })
                }
            }
        }
    }

    func getAssetAtIndex(index: Int) -> PHAsset?{
        if self.count > index{
            var asset: PHAsset?
            self.enumerateObjectsAtIndexes(NSIndexSet(index: index), options: NSEnumerationOptions.Concurrent, usingBlock: {
                (assetItem, _, _) in

                asset = assetItem as? PHAsset
            })

            return asset
        }

        return nil
    }
}
