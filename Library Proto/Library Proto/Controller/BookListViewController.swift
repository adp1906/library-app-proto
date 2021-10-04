//
//  ViewController.swift
//  Library Proto
//
//  Created by Aaron Peterson on 9/5/21.
//

import UIKit
import CoreData

class BookListViewController: UIViewController {
    
    var tableView = UITableView()
    let reuseIdentifier = "BookCell"
    var books: [Book] = []
    var context: NSManagedObjectContext?
    
    enum Section {
        case main
    }
    
    typealias DataSource = UITableViewDiffableDataSource<Section, NSManagedObjectID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, NSManagedObjectID>
    
    private lazy var fetchedResultController: NSFetchedResultsController<Book> = {
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
                
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context!, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        return frc
    }()
    
    lazy var dataSource: DataSource = {
        let dataSource = DataSource(tableView: tableView) { tableView, indexPath, objectID in
            guard let book = try? self.context?.existingObject(with: objectID) as? Book else {
                return nil
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! BookCell
            
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
        
        configureTableView()
        
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
    
    func setupSnapshot() {
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
    
    func configureTableView() {
        view.addSubview(tableView)
        
        tableView.rowHeight = view.frame.height *  0.15
        tableView.delegate = self
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
        
        //let newRowIndex = books.count
        //let indexPath = IndexPath(row: newRowIndex, section: 0)
        //let indexPaths = [indexPath]
        
        let newTitle = book.volumeInfo.title
        let newAuthors = book.volumeInfo.authors.joined(separator: ", ")
        guard let newImage = cache.object(forKey: key) else { return }
        guard let context = self.context else { return }
        
        let newBook = Book(context: context)
        //let newAuthors = authors
        newBook.authors = newAuthors
        newBook.title = newTitle
        newBook.image = newImage.pngData() as NSData?
        //let newBook = Book(image: newImage, title: newTitle, authors: newAuthors)
        books.append(newBook)
        
        do {
            try context.save()
        } catch {
            fatalError("Core Data Save Error")
        }
        
        //tableView.insertRows(at: indexPaths, with: .automatic)
        navigationController?.popViewController(animated: true)
        
    }
    
    
}

