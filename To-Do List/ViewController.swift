//
//  ViewController.swift
//  To-Do List
//
//  Created by Stefan Pel on 01-03-17.
//  Copyright © 2017 Stefan Pel. All rights reserved.
//

import UIKit
import SQLite

// MARK: Alert user.
extension UIViewController {
    func show(errorMessage: String) {
        let viewController = UIAlertController(title: "Something went wrong", message: errorMessage, preferredStyle: .alert)
        viewController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(viewController, animated: true, completion: nil)
    }
}

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // Array for todo's.
    var toDos: [(id: Int64, text: String)] = []
    
    // MARK: Outlets
    @IBOutlet weak var textInputField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // func search all
    func searchAll() {
        toDos.removeAll()
        guard let results = try? database?.prepare(todolist) else { return }
        for item in results! {
            if item[todoitem].isEmpty != true {
                toDos.append((id: item[id], text: item[todoitem]))
            }
        }
    }
    
    // MARK: Setting up SQlite database.
    var database: Connection?
    let todolist = Table("todolist")
    let id = Expression<Int64>("id")
    let todoitem = Expression<String>("todoitem")
    
    // Setting up database.
    private func setupDatabase() {
        defer {
            if self.database == nil {
                self.show(errorMessage: "Could not create database.")
            }
        }
        
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return
        }
        
        do {
            database = try Connection("\(path)/db.sqlite3")
            createTable()
        } catch let error {
            self.show(errorMessage: error.localizedDescription)
        }
        
    }
    // Create todolist table.
    private func createTable() {
        do {
            try database?.run(todolist.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(todoitem)
            })
        } catch let error {
            self.show(errorMessage: error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard self.database == nil else { return }
        setupDatabase()
        createTable()
        searchAll()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Putting textfield text in database.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return false
        }
        
        let insertToDo = todolist.insert(todoitem <- text)
        
        do {
            try database?.run(insertToDo)
        }
        catch let error {
            self.show(errorMessage: error.localizedDescription)
        }
        searchAll()
        self.tableView.reloadData()
        textInputField.text = ""
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: tableview.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDos.count
    }
    
    // Filling in the cells.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ToDoListCell
        
        cell.toDoLabel.text = toDos[indexPath.row].text
        
        return cell
    }
    
    // MARK: To delete and check off To-DO's.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexpath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let itemToDelete = todolist.filter(id == toDos[indexpath.row].id)
            do {
                try database!.run(itemToDelete.delete())
                searchAll()
            }
            catch {
                self.show(errorMessage: "Could not delete this item, try again")
            }
        }
        tableView.deleteRows(at: [indexpath], with: .fade)
    }
    
    // Let the user check off items.
    var ticked = Bool()
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !ticked {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            ticked = true
        }
        else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            ticked = false
        }
    }
    

}
