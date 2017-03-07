//
//  ToDoListCell.swift
//  To-Do List
//
//  Created by Stefan Pel on 03-03-17.
//  Copyright © 2017 Stefan Pel. All rights reserved.
//

import UIKit

class ToDoListCell: UITableViewCell {

    @IBOutlet weak var toDoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
