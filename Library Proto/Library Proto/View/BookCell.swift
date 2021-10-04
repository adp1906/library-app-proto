//
//  BookCell.swift
//  Library Proto
//
//  Created by Aaron Peterson on 9/5/21.
//

import UIKit

class BookCell: UITableViewCell {
    
    var downloadTask: URLSessionDownloadTask?
    var stackView = UIStackView()
    
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
        
        return title
    }()
    
    let bookAuthorLabel: UILabel = {
        let author = UILabel()
        author.numberOfLines = 0
        author.font = UIFont.systemFont(ofSize: 15)
        author.adjustsFontSizeToFitWidth = true
        
        return author
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(bookImageView)
        //addSubview(bookTitleLabel)
        //addSubview(bookAuthorLabel)
        
        configureStackView()
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
        
        if let smallImgURL = URL(string: result.volumeInfo.imageLinks["smallThumbnail"]!) {
            downloadTask = bookImageView.loadImage(url: smallImgURL)
        }
        
    }
    
    func configureStackView() {
        stackView.axis = .vertical
        
        addSubview(stackView)
        stackView.addArrangedSubview(bookTitleLabel)
        stackView.addArrangedSubview(bookAuthorLabel)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: bookImageView.trailingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7).isActive = true
        stackView.topAnchor.constraint(equalTo: bookImageView.topAnchor, constant: 10).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bookImageView.bottomAnchor, constant: -10).isActive = true
        
        bookTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        bookTitleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 5).isActive = true
        bookTitleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -5).isActive = true
        bookTitleLabel.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 10).isActive = true
        bookTitleLabel.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.25).isActive = true

        bookAuthorLabel.translatesAutoresizingMaskIntoConstraints = false
        bookAuthorLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 5).isActive = true
        bookAuthorLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -5).isActive = true
        bookAuthorLabel.topAnchor.constraint(equalTo: bookTitleLabel.bottomAnchor).isActive = true
    }
    
    func setupConstraints() {
        bookImageView.translatesAutoresizingMaskIntoConstraints = false
        bookImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        bookImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        bookImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        bookImageView.widthAnchor.constraint(equalTo: bookImageView.heightAnchor).isActive = true
        
    }

}
