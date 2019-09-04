//
//  SwipeTableViewController.swift
//  3D Interaction
//
//  Created by Yuseok on 04/09/2019.
//  Copyright © 2019 Yuseok. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    var cell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 60
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {return nil}
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete room
            self.updateModel(at: indexPath)
        }
        
        if let img = UIImage(named: "trash-circle") {
            let render = UIGraphicsImageRenderer(size: CGSize(width: 33, height: 33))
            deleteAction.image = render.image { (context) in
                img.draw(in: CGRect(origin: .zero, size: CGSize(width: 33, height: 33)))
            }
        }
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    func updateModel(at indexPath: IndexPath) {
        print("Data Deleted")
    }
}
