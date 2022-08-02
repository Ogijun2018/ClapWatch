//
//  RecordModel.swift
//  ClapWatch
//
//  Created by jun.ogino on 2021/06/09.
//

import Foundation
import RealmSwift

class RecordModel: Object {
    @objc dynamic var date: Date? = nil
    @objc dynamic var totalTime: String? = nil
    var laps = List<Lap>()
}

class Lap: Object {
    @objc dynamic var time: String? = nil
}
