//
//  TimeIntervalOutputExtension.swift
//  Albums
//
//  Created by seedante on 15/7/8.
//  Copyright © 2015年 seedante. All rights reserved.
//

import Foundation

extension NSTimeInterval{
    public var humanOutput: String{
        if self < 60{
            if self < 1{
                return "00:01"
            }else{
                let int = Int(self)
                let outputString = int < 10 ? "00:0\(int)" : "00:\(int)"
                return outputString
            }
        }else if self < 3600{
            let int = Int(self)
            let minute = int / 60
            let minuteString = minute < 10 ? "0\(minute):" : "\(minute):"
            let second = int % 60
            let secondString = second < 10 ? "0\(second)" : "\(second)"
            
            return minuteString + secondString
        }else if self < 360000{
            let int = Int(self)
            let hour = int / 3600
            let hourString = hour < 10 ? "0\(hour):" : "\(hour):"
            let minute = (int % 3600) / 60
            let minuteString = minute < 10 ? "0\(minute):" : "\(minute):"
            let second = (int % 3600) % 60
            let secondString = second < 10 ? "0\(second)" : "\(second)"
            
            return hourString + minuteString + secondString
        }else{
            return "> 100 Hours"
        }
    }
}