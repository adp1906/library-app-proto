//
//  SearchViewController.swift
//  Library Proto
//
//  Created by Aaron Peterson on 9/10/21.
//

import UIKit

protocol AddBookDelegate: AnyObject {
    
    func addBook(from controller: SearchResultsViewController, book: Item, from cache: NSCache<NSNumber, UIImage>, of key: NSNumber)
}

class SearchResultsViewController: UIViewController {
    
    let reuseIdentifier = "ResultCell"
    var tableView = UITableView()
    var searchResults = [Item]()
    var hasSearched = false
    var dataTask: URLSessionDataTask?
    let cache = NSCache<NSNumber, UIImage>()
    let utilityQueue = DispatchQueue.global(qos: .utility)
    
    weak var delegate: AddBookDelegate?
    
    let searchBar: UISearchBar = {
        let seabar = UISearchBar()
        
        return seabar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        title = "Search"
        
        
        //navigationItem.searchController = searchController
        searchBar.delegate = self
        
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        configureTableView()
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        
        tableView.rowHeight = view.frame.height *  0.1
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(BookCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    // MARK: - Helper Methods
    
    func googleBooksURL(searchText: String)-> URL {
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let urlString = String(format: "https://www.googleapis.com/books/v1/volumes?q=%@", encodedText)
        
        let url = URL(string: urlString)
        
        return url!
    }
    
    func parse(data: Data) -> [Item] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.items
        } catch {
            print("JSON Error: \(error)")
            return []
        }
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing Google Books." + " Please try again.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

}

// MARK: - Search Bar Delegate

extension SearchResultsViewController: UISearchBarDelegate {
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print(searchText)
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            dataTask?.cancel()
            hasSearched = true
            searchResults = []
            
            let url = googleBooksURL(searchText: searchBar.text!)
            let session = URLSession.shared
            dataTask = session.dataTask(with: url) { data, response, error in
                if let error = error as NSError?, error.code == -999 {
                    print("Failure! \(error.localizedDescription)")
                    return
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let data = data {
                        self.searchResults = self.parse(data: data)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        return
                    }
                } else {
                    print("Failure! \(response!)")
                }
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.showNetworkError()
                }
            }
            
            dataTask?.resume()
            
        }
        
    }
    
}

// MARK: - Table View Delegate and Data Source

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! BookCell
        
        if searchResults.count == 0 {
            cell.bookTitleLabel.text = "(Nothing found)"
            cell.bookAuthorLabel.text = ""
        } else {
            let searchResult = searchResults[indexPath.row]
            cell.configure(for: searchResult)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let book = searchResults[indexPath.row]
        let itemNumber = NSNumber(value: indexPath.row)
        var smallURL = URL(string: "")
        
        if let imgURL = URL(string: book.volumeInfo.imageLinks["smallThumbnail"]!) {
            smallURL = imgURL
        }
        
        guard let data = try? Data(contentsOf: smallURL!) else { return }
        
        let img =  UIImage(data: data)!
        
        cache.setObject(img, forKey: itemNumber)
        
        delegate?.addBook(from: self, book: book, from: cache, of: itemNumber)
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
}
