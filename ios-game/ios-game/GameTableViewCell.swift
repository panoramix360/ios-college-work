//
//  GameTableViewCell.swift
//  ios-game
//
//  Created by Lucas de Oliveira Reis on 20/09/17.
//  Copyright © 2017 Lucas de Oliveira Reis. All rights reserved.
//

import UIKit

class GameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var userRequesting: UILabel!
    @IBOutlet weak var userChallenging: UILabel!
    
    @IBAction func enterGame(_ sender: Any) {
        self.window?.rootViewController?.performSegue(withIdentifier: "listToDetailSegue", sender: Any?)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
