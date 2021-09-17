//
//  SearchResult.swift
//  Library Proto
//
//  Created by Aaron Peterson on 9/12/21.
//

import Foundation

class ResultArray: Codable {
    var totalItems: Int
    var items: [Item]
}

class Item: Codable {
    var volumeInfo: SearchResult
}

class Image: Codable {
    var smallThumbnail: String
    var thumbnail: String
}

class SearchResult: Codable, CustomStringConvertible {
    
    var title = ""
    var authors: [String] = []
    var imageLinks: [String: String]

    var description: String {
        return "\nResult - Title: \(title), Author: \(authors), Image Link: \(imageLinks)"
    }

}
