//
//  UIImageView+DownloadImage.swift
//  Library Proto
//
//  Created by Aaron Peterson on 9/18/21.
//

import UIKit

extension UIImageView: AcceptImage {
    func takeImage(_ image: UIImage) {
        self.image = image
    }
    
    func failedToLoadImage(error: Error) {
        image = UIImage(systemName: "book.closed.fill")
    }

}
