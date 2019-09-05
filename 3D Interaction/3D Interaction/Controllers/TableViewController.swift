//
//  TableViewController.swift
//  3D Interaction
//
//  Created by Yuseok on 03/09/2019.
//  Copyright © 2019 Yuseok. All rights reserved.
//

import UIKit
import SwipeCellKit
import RealmSwift

class TableViewController: SwipeTableViewController {
    
    var rooms: Results<roomInfo>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        //tableView.separatorStyle = .none
    }


    // MARK: - Button Manipulation
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Create New Room", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        let action = UIAlertAction(title: "Create room", style: .default) { (action) in
            if let text: String = textField.text {
                if text == "" { return }
                let newRoom = roomInfo()
                newRoom.title = text
                
                self.saveData(newRoom)
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New AR Interaction Room"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms?.count ?? 1
    }
    
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        if let room = rooms?[indexPath.row] {
            cell.textLabel?.text = room.title
        } else {
            cell.textLabel?.text = "No Available Rooms"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToCamera", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedRoom = rooms?[indexPath.row]
            //destinationVC.roomTitle = rooms?[indexPath.row].title ?? ""
        }
    }

    // MARK: - Data Manipulating Methods
    func saveData(_ roomInfo: roomInfo) {
        do {
            try realm.write {
                realm.add(roomInfo)
            }
        } catch {
            print("Error saving context: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadData() {
        rooms = realm.objects(roomInfo.self)
        tableView.reloadData()
    }

    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        
        if let roomToDelete = self.rooms?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(roomToDelete)
                }
            } catch {
                print("Error occured Deleting Data: \(error)")
            }
        }
    }
}
