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
    
    private let reuseIdentifier = "ResultCell"
    private var tableView = UITableView()
    private var searchResults = [Item]()
    private var hasSearched = false
    private var dataTask: URLSessionDataTask?
    private let cache = NSCache<NSNumber, UIImage>()
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    
    weak var delegate: AddBookDelegate?
    
    enum Section {
        case main
    }
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(tableView: tableView) { tableView, indexPath, objectID in
            if indexPath.row >= 0 {
                let searchResult = self.searchResults[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! BookCell
                cell.bookAuthorLabel.text = searchResult.volumeInfo.authors.joined(separator: ", ")
                cell.bookTitleLabel.text = searchResult.volumeInfo.title
                guard let smallURLString = searchResult.volumeInfo.imageLinks["smallThumbnail"] else { return nil }
                guard let smallImgURL = URL(string: smallURLString) else { return nil }
                let bookImageLoader = ImageLoader(acceptor: cell.bookImageView)
                bookImageLoader.load(url: smallImgURL)
                
                return cell
            } else {
                return nil
            }
        }
        tableView.dataSource = dataSource
        return dataSource
    }()
    
    private let searchBar: UISearchBar = {
        let seabar = UISearchBar()
        
        return seabar
    }()
    
    private let noSearchResultsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        title = "Search"
        
        setupConstraints()
        setupTableView()
        setupSearchBar()
    }
    
    private func setupConstraints() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(noSearchResultsLabel)
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 56),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            noSearchResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noSearchResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.rowHeight = view.frame.height *  0.1
        tableView.delegate = self
        tableView.register(BookCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Helper Methods
    private func setupSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([Section.main])
        snapshot.appendItems(searchResults)
        dataSource.apply(snapshot)
    }
    
    private func googleBooksURL(searchText: String)-> URL? {
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://www.googleapis.com/books/v1/volumes?q=%@", encodedText)
        guard let url = URL(string: urlString) else { return nil }
        
        return url
    }
    
    private func parse(data: Data) -> [Item] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            DispatchQueue.main.async {
                self.setupSnapshot()
            }
            return result.items
        } catch {
            print("JSON Error: \(error)")
            DispatchQueue.main.async {
                self.noSearchResultsLabel.text = "No Results Found"
            }
            return []
        }
    }
    
    private func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing Google Books." + " Please try again.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func downloadImage(from: Item) -> UIImage? {
        if let smallURLString = from.volumeInfo.imageLinks["smallThumbnail"] {
            guard let imgURL = URL(string: smallURLString) else { return nil }
            guard let data = try? Data(contentsOf: imgURL) else { return nil }
            guard let img =  UIImage(data: data) else { return nil }
            
            return img
        } else {
            return nil
        }
    }
    
    private func cacheAndAdd(book: Item, image: UIImage, at: IndexPath) {
        let itemNumber = NSNumber(value: at.row)
        
        cache.setObject(image, forKey: itemNumber)
        delegate?.addBook(from: self, book: book, from: cache, of: itemNumber)
    }

}

// MARK: - Search Bar Delegate

extension SearchResultsViewController: UISearchBarDelegate {
        
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        guard let url = googleBooksURL(searchText: searchText) else { return }
        
        searchBar.resignFirstResponder()
        
        dataTask?.cancel()
        hasSearched = true
        noSearchResultsLabel.text = ""
        searchResults = []
        
        dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            
            let code = (response as? HTTPURLResponse)?.statusCode
            
            switch (data, code, error) {
            case (let data?, 200, nil):
                self.searchResults = self.parse(data: data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case (_, 404, nil):
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.showNetworkError()
                }
            case (_, 500, nil):
                fatalError("Server error")
            case (_, let c?, nil):
                fatalError("Unhandled error \(c)")
            case (_, nil, _):
                fatalError("Invalid response")
            case (_, _, let error?):
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.showNetworkError()
                }
                print(error.localizedDescription)
            }
        }
        dataTask?.resume()
        
    }
    
}

// MARK: - Table View Delegate and Data Source

extension SearchResultsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedBook = searchResults[indexPath.row]
        guard let selectedVolumeImage = downloadImage(from: selectedBook) else { return }
        cacheAndAdd(book: selectedBook, image: selectedVolumeImage, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
}
