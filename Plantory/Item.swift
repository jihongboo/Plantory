//
//  Item.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/3/11.
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
