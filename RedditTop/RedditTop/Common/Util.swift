//
//  Util.swift
//  RedditTop
//
//  Created by Alexander Grischenko on 3/29/18.
//  Copyright © 2018 grider. All rights reserved.
//

import Foundation

class Util {
    
    class func timeAgo(since timestamp: Double) -> String {
        let timestampDate = Date(timeIntervalSince1970: timestamp)
        let delta = fabs(timestampDate.timeIntervalSinceNow) as Double
        
        let value: Int
        let unit: String
        
        if delta < 60 {
            value = Int(delta)
            unit = "seconds"
        } else if delta < 60 * 60 {
            value = lround(delta/60)
            unit = "minutes"
        } else if delta < 24 * 60 * 60 {
            value = lround(delta/60/60)
            unit = "hours"
        } else if delta < 7 * 24 * 60 * 60 {
            value = lround(delta/60/60/24)
            unit = "days"
        } else if delta < 30.4 * 24 * 60 * 60 {
            value = lround(delta/60/60/24/7)
            unit = "weeks"
        } else if delta < 365.25 * 24 * 60 * 60 {
            value = lround(delta/60/60/24/30.4)
            unit = "months"
        } else {
            value = lround(delta/60/60/24/365.25)
            unit = "years"
        }
        return String(format: NSLocalizedString("%d \(unit) ago", comment: ""), value)
    }
    
}
