//
//  ViewController.swift
//  Library Proto
//
//  Created by Aaron Peterson on 9/5/21.
//

import UIKit

class BookListViewController: UIViewController {
    
    var tableView = UITableView()
    let reuseIdentifier = "BookCell"
    let books: [Book] = [
        Book(imageName: "Win Friends", title: "How to Win Friends & Influence People", author: "Dale Carnegie"),
        Book(imageName: "48 Laws", title: "The 48 Laws of Power", author: "Robert Greene"),
        Book(imageName: "The Outsiders", title: "The Outsiders", author: "S. E. Hinton"),
        Book(imageName: "Between the World", title: "Between the World and Me", author: "Ta-Nehisi Coates"),
        Book(imageName: "Shining", title: "The Shining", author: "Stephen King"),
        Book(imageName: "Dance with Dragons", title: "A Dance with Dragons", author: "George R. R. Martin"),
        Book(imageName: "Queen of Damned", title: "The Queen of the Damned", author: "Anne Rice"),
        Book(imageName: "Harry Potter", title: "Harry Potter and the Goblet of Fire", author: "J. K. Rowling"),
        Book(imageName: "Never Eat Alone", title: "Never Eat Alone", author: "Keith Ferrazzi"),
        Book(imageName: "Hunger Games", title: "The Hunger Games", author: "Suzanne Collins"),
        Book(imageName: "Misery", title: "Misery", author: "Stephen King"),
        Book(imageName: "Interview With Vampire", title: "Interview with the Vampire", author: "Anne Rice"),
        Book(imageName: "It", title: "It", author: "Stephen King")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Library"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                           target: self,
                                                           action: #selector(addTapped))
        
        configureTableView()
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        
        tableView.rowHeight = view.frame.height *  0.15
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(BookCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc func addTapped() {
        let searchVC = SearchResultsViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }


}


// MARK:- Table View Controller Delegate & Data Source Methods

extension BookListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! BookCell
        
        let book = books[indexPath.row]
        cell.bookImageView.image = UIImage(named: book.imageName)
        cell.bookTitleLabel.text = book.title
        cell.bookAuthorLabel.text = book.author
        
        return cell
    }
}

