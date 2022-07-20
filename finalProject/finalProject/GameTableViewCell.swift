//
//  GameTableViewCell.swift
//  finalProject
//
//  Created by Shakthi  Prashanth champaka on 16/5/2022.
//

import UIKit

class GameTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var myView: UIView!
    
    @IBOutlet weak var gameDate: UILabel!
     
    @IBOutlet weak var gameName: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
