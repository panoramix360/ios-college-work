//
//  GameViewController.swift
//  ios-game
//
//  Created by Lucas de Oliveira Reis on 24/09/17.
//  Copyright © 2017 Lucas de Oliveira Reis. All rights reserved.
//

import UIKit
import FirebaseDatabase

class GameViewController: UIViewController {

    let gamesDb = Database.database().reference(withPath: "games")
    let cardsDb = Database.database().reference(withPath: "cards")
    
    var game: Game?
    
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var userRequesting: UILabel!
    @IBOutlet weak var userChallenging: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameName.text = game?.name
        self.userRequesting.text = self.userRequesting.text! + (game?.userRequesting)!
        self.userChallenging.text = self.userRequesting.text! + (game?.userChallenging)!
        // Do any additional setup after loading the view.
        
        self.cardsDb.observe(.value, with: { snapshot in
            if snapshot.childrenCount > 0 {
                for item in snapshot.children {
                    print(item as! DataSnapshot)
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeGame()
    }
    
    func removeGame() {
        self.gamesDb.child(game?.id as! String).removeValue()
    }
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let test = "teste"
    }
     */

}
