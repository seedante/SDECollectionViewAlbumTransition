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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
}
