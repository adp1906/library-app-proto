//
//  ImageLoader.swift
//  Library Proto
//
//  Created by Aaron Peterson on 11/3/21.
//

import Foundation
import UIKit

protocol AcceptImage {
    func takeImage(_ image: UIImage)
    func failedToLoadImage(error: Error)
}

class ImageLoader {
    
    enum loadingError: Error {
        case imageNotFound
    }
    
    private let acceptor: AcceptImage
    
    init(acceptor: AcceptImage) {
        self.acceptor = acceptor
    }
    
    func load(url: URL) {
        URLSession.shared.downloadTask(with: url) { url, _, error in
            switch (url, error) {
            case (let url?, nil):
                do {
                    if let image = try UIImage(data: Data(contentsOf: url)) {
                        DispatchQueue.main.async {
                            self.acceptor.takeImage(image)
                        }
                    } else {
                        throw loadingError.imageNotFound
                    }
                } catch {
                    self.acceptor.failedToLoadImage(error: error)
                }
            case (nil, let e?):
                self.acceptor.failedToLoadImage(error: e)
            case (nil, nil), (_?, _?):
                fatalError("Error loading image")
            }
        }.resume()
    }
}
