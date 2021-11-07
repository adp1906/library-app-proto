//
//  Item.swift
//  Library Proto
//
//  Created by Aaron Peterson on 11/3/21.
//

import Foundation

class Item: Codable, Hashable {
    var id = UUID()
    var volumeInfo: SearchResult
    
    enum CodingKeys: String, CodingKey {
        case volumeInfo
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
}
