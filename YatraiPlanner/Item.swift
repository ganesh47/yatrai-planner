//
//  Item.swift
//  YatraiPlanner
//
//  Created by Ganesh Raman on 17/01/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
