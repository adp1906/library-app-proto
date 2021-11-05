//
//  ViewController.swift
//  Library Proto
//
//  Created by Aaron Peterson on 9/5/21.
//

import UIKit
import CoreData

class BookListViewController: UIViewController {
    
    private var tableView = UITableView()
    private let reuseIdentifier = "BookCell"
    private var books: [Book] = []
    var context: NSManagedObjectContext?
    
    enum Section {
        case main
    }
    
    typealias DataSource = UITableViewDiffableDataSource<Section, NSManagedObjectID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, NSManagedObjectID>
    
    private lazy var fetchedResultController: NSFetchedResultsController<Book> = {
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        var bookContext = NSManagedObjectContext()
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if context != nil {
            bookContext = context!
        }
                
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: bookContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        
        return frc
    }()
    
    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(tableView: tableView) { tableView, indexPath, objectID in
            guard let book = try? self.context?.existingObject(with: objectID) as? Book else {
                return nil
            }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier,
                                                           for: indexPath) as? BookCell else { return nil }
            
            cell.bookAuthorLabel.text = book.authors
            cell.bookTitleLabel.text = book.title
            if let data = book.image as Data? {
                cell.bookImageView.image = UIImage(data: data)
            }
            
            return cell
        }
        tableView.dataSource = dataSource
        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Library"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                           target: self,
                                                           action: #selector(addTapped))
        
        setupConstraints()
        setupTableView()
        
        do {
            try fetchedResultController.performFetch()
            tableView.reloadData()
        } catch {
            fatalError("Core Data Fetch Error")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        setupSnapshot()
    }
    
    private func setupSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([Section.main])
        var fetchedObjectIDs:[NSManagedObjectID] = []
        guard let fetchedObjects = fetchedResultController.fetchedObjects else { return }
        for bookObject in fetchedObjects {
            let objectID = bookObject.objectID
            fetchedObjectIDs.append(objectID)
        }
                
        snapshot.appendItems(fetchedObjectIDs)
        dataSource.apply(snapshot)
    }
    
    private func setupConstraints() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.rowHeight = view.frame.height *  0.15
        tableView.delegate = self
        tableView.register(BookCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func createBookObject(in context: NSManagedObjectContext,
                                  title: String,
                                  authors: String,
                                  image: UIImage) -> Book {
        let book = Book(context: context)
        book.authors = authors
        book.title = title
        book.image = image.pngData() as NSData?
        
        return book
    }
    
    @objc func addTapped() {
        let searchVC = SearchResultsViewController()
        navigationController?.pushViewController(searchVC, animated: true)
        
        searchVC.delegate = self
    }


}


// MARK:- Table View Controller Delegate & Data Source Methods

extension BookListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { contextualAction, view, completionHandler in
            
            let book = self.fetchedResultController.object(at: indexPath)
            self.context?.delete(book)
            self.setupSnapshot()
            try? self.context?.save()
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Fetched Results Controller Delegate

extension BookListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

}


// MARK: - Add Book Delegate

extension BookListViewController: AddBookDelegate {
    
    func addBook(from controller: SearchResultsViewController, book: Item, from cache: NSCache<NSNumber, UIImage>, of key: NSNumber) {
        
        let newTitle = book.volumeInfo.title
        let newAuthors = book.volumeInfo.authors.joined(separator: ", ")
        guard let newImage = cache.object(forKey: key) else { return }
        guard let context = self.context else { return }
        
        let newBook = createBookObject(in: context, title: newTitle, authors: newAuthors, image: newImage)
        books.append(newBook)
        
        do {
            try context.save()
        } catch {
            fatalError("Core Data Save Error")
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    
}

