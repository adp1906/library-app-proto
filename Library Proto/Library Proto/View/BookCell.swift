//
//  BookCell.swift
//  Library Proto
//
//  Created by Aaron Peterson on 9/5/21.
//

import UIKit

class BookCell: UITableViewCell {
    
    var downloadTask: URLSessionDownloadTask?
    
    let bookImageView: UIImageView = {
        let img = UIImageView()
        img.layer.masksToBounds = true
        img.contentMode = .scaleAspectFit
        
        return img
    }()
    
    let bookTitleLabel: UILabel = {
        let title = UILabel()
        title.numberOfLines = 0
        title.font = UIFont.systemFont(ofSize: 18)
        title.adjustsFontSizeToFitWidth = true
        //title.backgroundColor = .lightGray
        
        return title
    }()
    
    let bookAuthorLabel: UILabel = {
        let author = UILabel()
        author.numberOfLines = 0
        author.font = UIFont.systemFont(ofSize: 15)
        author.adjustsFontSizeToFitWidth = true
        //author.backgroundColor = .lightGray
        
        return author
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(bookImageView)
        addSubview(bookTitleLabel)
        addSubview(bookAuthorLabel)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    // MARK: - Helper Methods
    func configure(for result: Item) {
        bookTitleLabel.text = result.volumeInfo.title
        bookAuthorLabel.text = result.volumeInfo.authors.joined(separator: ", ")
        
        //var smallURL = URL(string: "")
        
        //bookImageView.image = UIImage(systemName: "book.closed.fill")
        if let smallImgURL = URL(string: result.volumeInfo.imageLinks["smallThumbnail"]!) {
            downloadTask = bookImageView.loadImage(url: smallImgURL)
            //smallURL = smallImgURL
        }
        
        //guard let data = try? Data(contentsOf: smallURL!) else { return UIImage(systemName: "book.closed.fill")! }
        //return UIImage(data: data)!
    }
    
    func setupConstraints() {
        bookImageView.translatesAutoresizingMaskIntoConstraints = false
        bookImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        bookImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        bookImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        bookImageView.widthAnchor.constraint(equalTo: bookImageView.heightAnchor).isActive = true
        
        bookTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        bookTitleLabel.leadingAnchor.constraint(equalTo: bookImageView.trailingAnchor, constant: 10).isActive = true
        bookTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        bookTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        bookTitleLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.25).isActive = true
        
        bookAuthorLabel.translatesAutoresizingMaskIntoConstraints = false
        bookAuthorLabel.leadingAnchor.constraint(equalTo: bookImageView.trailingAnchor, constant: 10).isActive = true
        bookAuthorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        bookAuthorLabel.topAnchor.constraint(equalTo: bookTitleLabel.bottomAnchor, constant: 15).isActive = true
        bookAuthorLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2).isActive = true
    }

}
