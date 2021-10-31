//
//  UIImageView+DownloadImage.swift
//  Library Proto
//
//  Created by Aaron Peterson on 9/18/21.
//

import UIKit

extension UIImageView {
    
    func loadImage(url: URL) -> URLSessionDownloadTask {

        let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] url, response, error in
            
            let code = (response as? HTTPURLResponse)?.statusCode
            
            switch (url, code, error) {
            case (let url?, 200, nil):
                guard let data = try? Data(contentsOf: url),
                      let image = UIImage(data: data)
                else { return }
                DispatchQueue.main.async {
                    self?.image = image
                }
            case (_, 404, nil):
                fatalError("File not found")
            case (_, 500, nil):
                fatalError("Server error")
            case (_, let c?, nil):
                fatalError("Unhandled error \(c)")
            case (_, nil, _):
                fatalError("Invalid response")
            case (_, _, let error?):
                fatalError(error.localizedDescription)
            }
        }
        downloadTask.resume()
        return downloadTask
    }
    
}
