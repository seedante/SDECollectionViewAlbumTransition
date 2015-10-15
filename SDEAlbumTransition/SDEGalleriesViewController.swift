//
//  SDEGalleriesViewController.swift
//  Albums
//
//  Created by seedante on 15/7/6.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit
import Foundation
import Photos

private let reuseIdentifier = "Cell"
private let headerReuseIdentifier = "Header"

class SDEGalleriesViewController: UICollectionViewController, PHPhotoLibraryChangeObserver {
    
    var dataSource = [[PHAssetCollection]]()
    var headerDataSource = [String]()
    
    let fetchOptions = PHFetchOptions()
    
    var localAlbumsDataSource = [PHAssetCollection]()
    var filteredLocalAlbumsDataSource = [PHAssetCollection]()
    let localSubTypes = [PHAssetCollectionSubtype](arrayLiteral:
        .SmartAlbumUserLibrary,
        .SmartAlbumVideos,
        .SmartAlbumSlomoVideos,
        .SmartAlbumTimelapses,
        .SmartAlbumPanoramas,
        .SmartAlbumGeneric,
        .SmartAlbumBursts
    )
    
    
    var specialAlbumsDataSource = [PHAssetCollection]()
    var filteredSpecialAlbumsDataSource = [PHAssetCollection]()
    let specialSubTypes = [PHAssetCollectionSubtype](arrayLiteral:
        .SmartAlbumFavorites,
        .SmartAlbumAllHidden
    )
    
    var syncedAlbumsDataSource = [PHAssetCollection]()
    var filterdSyncedAlbumsDataSource = [PHAssetCollection]()
    let syncedSubTypes = [PHAssetCollectionSubtype](arrayLiteral:
        .AlbumSyncedEvent,
        .AlbumSyncedAlbum,
        .AlbumImported
    )
    
    var openAlbumStyle:Int = 0
    var albumImageView: UIImageView?
    
    //MARK: View Life Circle
    override func awakeFromNib() {
        fetchOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0", argumentArray: nil)
        
        for subType in localSubTypes{
            let fetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: subType, options: nil)
            fetchResult.enumerateObjectsUsingBlock({
                (item, index, stop) in
                self.localAlbumsDataSource.append(item as! PHAssetCollection)
            })
        }
        
        
        for subType in specialSubTypes{
            let fetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: subType, options: nil)
            fetchResult.enumerateObjectsUsingBlock({
                (item, index, stop) in
                self.specialAlbumsDataSource.append(item as! PHAssetCollection)
            })
        }
        
        for subType in syncedSubTypes{
            let fetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: subType, options: nil)
            fetchResult.enumerateObjectsUsingBlock({
                (item, index, stop) in
                self.syncedAlbumsDataSource.append(item as! PHAssetCollection)
            })
        }
        
        fetchData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapDetected:")
        self.view.addGestureRecognizer(tapGesture)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "Galleries"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if albumImageView != nil{
            albumImageView?.alpha = 1.0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    func fetchData(){
        if headerDataSource.count > 0{
            headerDataSource.removeAll()
        }
        
        if dataSource.count > 0{
            dataSource.removeAll()
        }
        
        
        filteredLocalAlbumsDataSource = localAlbumsDataSource.filter({PHAsset.fetchAssetsInAssetCollection($0, options: nil).count > 0})
        filteredSpecialAlbumsDataSource = specialAlbumsDataSource.filter({PHAsset.fetchAssetsInAssetCollection($0, options: nil).count > 0})
        filterdSyncedAlbumsDataSource = syncedAlbumsDataSource.filter({$0.estimatedAssetCount > 0})
        
        if filteredLocalAlbumsDataSource.count > 0{
            headerDataSource.append("Albums")
            dataSource.append(filteredLocalAlbumsDataSource)
        }
        
        if filteredSpecialAlbumsDataSource.count > 0{
            headerDataSource.append("SpecialAlbums")
            dataSource.append(filteredSpecialAlbumsDataSource)
        }
        
        if filterdSyncedAlbumsDataSource.count > 0{
            headerDataSource.append("SyncedAlbums")
            dataSource.append(filterdSyncedAlbumsDataSource)
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataSource.count
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = dataSource[section]
        return sectionInfo.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        // Configure the cell
        if let imageView = cell.viewWithTag(-10) as? UIImageView{
            imageView.layer.borderColor = UIColor.whiteColor().CGColor
            imageView.layer.borderWidth = 10.0
            
            let assetCollectionArray = dataSource[indexPath.section]
            let assetCollection = assetCollectionArray[indexPath.row]
            if let titleLabel = cell.viewWithTag(-20) as? UILabel{
                let titleText = NSAttributedString(string: assetCollection.localizedTitle!)
                let count = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil).count
                let countText = NSAttributedString(string: " \(count)", attributes: [NSForegroundColorAttributeName: UIColor.grayColor(), NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 15.0)!])
                let cellTitle = NSMutableAttributedString(attributedString: titleText)
                cellTitle.appendAttributedString(countText)
                titleLabel.attributedText = cellTitle
            }

            PHFetchResult.fetchPosterImageForAssetCollection(assetCollection, imageView: imageView, targetSize: CGSizeMake(170, 170))
        }        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier, forIndexPath: indexPath)
        if let titleLabel = headerView.viewWithTag(-10) as? UILabel{
            titleLabel.text = headerDataSource[indexPath.section]
        }
        return headerView
    }

    //MARK: PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(changeInstance: PHChange) {
        let localAlbumsCopy = localAlbumsDataSource
        for assetCollection in localAlbumsCopy{
            if let changeDetail = changeInstance.changeDetailsForObject(assetCollection){
                let index = localAlbumsDataSource.indexOf(assetCollection)
                let newAssetCollection = changeDetail.objectAfterChanges as! PHAssetCollection
                localAlbumsDataSource[index!] = newAssetCollection
            }

        }
        
        let specialAlbumsCopy = specialAlbumsDataSource
        for assetCollection in specialAlbumsCopy{
            if let changeDetail = changeInstance.changeDetailsForObject(assetCollection){
                let index = specialAlbumsDataSource.indexOf(assetCollection)
                let newAssetCollection = changeDetail.objectAfterChanges as! PHAssetCollection
                specialAlbumsDataSource[index!] = newAssetCollection
            }
        }
        
        let syncedAlbumsCopy = syncedAlbumsDataSource
        for assetCollection in syncedAlbumsCopy{
            if let changeDetail = changeInstance.changeDetailsForObject(assetCollection){
                let index = syncedAlbumsDataSource.indexOf(assetCollection)
                let newAssetCollection = changeDetail.objectAfterChanges as! PHAssetCollection
                syncedAlbumsDataSource[index!] = newAssetCollection
            }
        }
        
        fetchData()
    }
    
    //MARK: Prepare for Transition
    func tapDetected(sender: UITapGestureRecognizer){
        let point = sender.locationInView(self.view)
        let pointInCollectionView = self.view.convertPoint(point, toView: self.collectionView)
        if let indexPath = self.collectionView?.indexPathForItemAtPoint(pointInCollectionView){
            let cell = self.collectionView?.cellForItemAtIndexPath(indexPath)
            if let rectInCollectionView = cell?.convertRect(CGRectMake(10, 10, 150, 150), toView: self.collectionView){
                if rectInCollectionView.contains(pointInCollectionView){
                    let circleView = UIView(frame: CGRectMake(point.x, point.y, 30.0, 30.0))
                    circleView.layer.cornerRadius = 15.0
                    circleView.backgroundColor = UIColor.blueColor()
                    self.view.addSubview(circleView)
                    
                    UIView.animateKeyframesWithDuration(0.3, delay: 0, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: {
                        circleView.transform = CGAffineTransformMakeScale(2, 2)
                        circleView.alpha = 0
                        }, completion: {
                            finish in
                            circleView.removeFromSuperview()
                            self.prepareForSelectCellAtIndexPath(indexPath)
                    })
                    
                }
            }
        }
    }
    
    func prepareForSelectCellAtIndexPath(indexPath: NSIndexPath){
        let cell = self.collectionView!.cellForItemAtIndexPath(indexPath)
        
        let titleLabel = cell?.viewWithTag(-20) as! UILabel
        albumImageView = cell?.viewWithTag(-10) as? UIImageView
        UIView.animateWithDuration(0.1, animations: {
            titleLabel.transform = CGAffineTransformMakeTranslation(0, 30)
            self.albumImageView?.alpha = 0
            }, completion: {
                finish in
                
                UIView.animateWithDuration(0.1, delay: 1.5, options: .AllowUserInteraction, animations: {
                    titleLabel.transform = CGAffineTransformIdentity
                    }, completion: nil)
                
        })
        
        let cellReferencePoint = cell?.convertPoint(CGPointMake(10, 10), toView: self.collectionView!)
        print("appearCenter: \(cellReferencePoint)")
        
        let layoutAttributes = self.collectionView!.layoutAttributesForItemAtIndexPath(indexPath)
        let imageOriginInSuperView = self.collectionView!.convertPoint((layoutAttributes?.frame.origin)!, toView: self.collectionView!.superview)
        //let imageOriginInSuperView = CGPointMake(originInSuperView.x + 10, originInSuperView.y + 10)
        print("origin in superView: \(imageOriginInSuperView)")
        
        if let albumVC = self.storyboard?.instantiateViewControllerWithIdentifier("AlbumVC") as? SDEAlbumViewController{
            self.navigationController?.delegate = SDENavigationDelegate()
            let assetCollection = self.dataSource[indexPath.section][indexPath.row]
            albumVC.animationStyle = AlbumOpenStyle(rawValue: openAlbumStyle)
            albumVC.assetCollection = assetCollection
            albumVC.cellReferencePoint = cellReferencePoint
            albumVC.imageViewOrigin = imageOriginInSuperView
            let imageView = cell?.viewWithTag(-10) as! UIImageView
            albumVC.maskImageView.image = imageView.image
            print("ready for Push")
            self.navigationController?.pushViewController(albumVC, animated: true)
            print("Did push")
            
            if openAlbumStyle == 3{
                openAlbumStyle = 0
            }else{
                openAlbumStyle += 1
            }
        }
    }
    


}
