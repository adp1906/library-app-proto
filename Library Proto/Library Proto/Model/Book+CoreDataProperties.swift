//
//  Book+CoreDataProperties.swift
//  Library Proto
//
//  Created by Aaron Peterson on 10/3/21.
//

import CoreData
import UIKit

extension Book {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
      return NSFetchRequest<Book>(entityName: "Book")
    }
    
    @NSManaged public var title: String
    @NSManaged public var image: NSData?
    @NSManaged public var authors: String
}
