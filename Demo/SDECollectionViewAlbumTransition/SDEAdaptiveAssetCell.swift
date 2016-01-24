//
//  SDEAdaptiveAssetCell.swift
//  Albums
//
//  Created by seedante on 15/7/8.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit
import Photos

class SDEAdaptiveAssetCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoLogo: UIImageView!//(20, 20)
    @IBOutlet weak var durationLabel: UILabel!//(50, 14)

    var asset: PHAsset?{
        willSet{
            durationLabel.text = newValue?.duration.humanOutput
            adjustLogoAndDurationLocation()
        }
    }
    
    func adjustLogoAndDurationLocation(){
        dispatch_async(dispatch_get_main_queue()){
            let cellWidth = self.frame.size.width
            let cellHeight = self.frame.size.height
            let imageWidth = self.imageView.image!.size.width
            let imageHeight = self.imageView.image!.size.height
            
            if self.imageView.image?.size.width > self.imageView.image?.size.height{
                let resizedImageHeight = (cellWidth / imageWidth) * imageHeight
                let imageBottonHeight = cellHeight / 2.0 + resizedImageHeight / 2.0
                self.videoLogo.center = CGPointMake(15.0, imageBottonHeight - 15)
                self.durationLabel.center = CGPointMake(cellWidth - 30, imageBottonHeight - 15)
            }else{
                let resizedImageWidth = (cellHeight / imageHeight) * imageWidth
                let imageLeftX = (cellWidth - resizedImageWidth) / 2.0
                let imageRightX = cellWidth - imageLeftX
                self.videoLogo.center = CGPointMake(imageLeftX + 15, cellHeight - 15)
                self.durationLabel.center = CGPointMake(imageRightX - 30, cellHeight - 15)
            }
        }


    }
}
