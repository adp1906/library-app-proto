//
//  SearchResult.swift
//  Library Proto
//
//  Created by Aaron Peterson on 9/12/21.
//

import Foundation

class SearchResult: Codable {
    var title = ""
    var authors: [String] = []
    var imageLinks: [String: String]
}
