//
//  WatchTime.swift
//  ClapWatch
//
//  Created by Jun Ogino on 2023/09/16.
//

import Foundation

struct WatchTime {
    var minute: Int = 0 {
        didSet {
            stringMinute = String(format:"%02d", minute)
        }
    }
    var second: Int = 0 {
        didSet {
            stringSecond = String(format: "%02d", second)
        }
    }
    var milliSecond: Int = 0 {
        didSet {
            stringMilliSecond = String(format: "%02d", milliSecond)
        }
    }

    var stringMinute: String = "00"
    var stringSecond: String = "00"
    var stringMilliSecond: String = "00"

    init(minute: Int = 0, second: Int = 0, milliSecond: Int = 0) {
        self.minute = minute
        self.second = second
        self.milliSecond = milliSecond
    }
}
