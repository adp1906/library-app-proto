//
//  BookCell.swift
//  Library Proto
//
//  Created by Aaron Peterson on 9/5/21.
//

import UIKit

class BookCell: UITableViewCell {
    
    private lazy var bookImageLoader = ImageLoader(acceptor: bookImageView)
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.addArrangedSubview(bookTitleLabel)
        sv.addArrangedSubview(bookAuthorLabel)
        
        return sv
    }()
    
    let bookImageView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.layer.masksToBounds = true
        img.contentMode = .scaleAspectFit
        
        return img
    }()
    
    let bookTitleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 0
        title.font = UIFont.systemFont(ofSize: 18)
        title.adjustsFontSizeToFitWidth = true
        
        return title
    }()
    
    let bookAuthorLabel: UILabel = {
        let author = UILabel()
        author.translatesAutoresizingMaskIntoConstraints = false
        author.numberOfLines = 0
        author.font = UIFont.systemFont(ofSize: 15)
        author.adjustsFontSizeToFitWidth = true
        
        return author
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Helper Methods
    private func setupConstraints() {
        addSubview(bookImageView)
        
        NSLayoutConstraint.activate([
            bookImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            bookImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            bookImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            bookImageView.widthAnchor.constraint(equalTo: bookImageView.heightAnchor),
            stackView.leadingAnchor.constraint(equalTo: bookImageView.trailingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            bookTitleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 5),
            bookTitleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -5),
            bookTitleLabel.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 10),
            bookAuthorLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 5),
            bookAuthorLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -5),
            bookAuthorLabel.topAnchor.constraint(equalTo: bookTitleLabel.bottomAnchor)
        ])
    }

}
