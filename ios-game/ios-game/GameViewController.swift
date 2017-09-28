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

    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let gamesDb = Database.database().reference(withPath: "games")
    let cardsDb = Database.database().reference(withPath: "cards")
    
    var allCards = [Card]()
    var game: Game?
    
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var userRequesting: UILabel!
    @IBOutlet weak var userChallenging: UILabel!
    
    @IBOutlet weak var gameStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameName.text = self.game?.name
        
        if self.game?.userChallenging != "" {
            self.getAllCards()
        }
    
        self.observeCurrentGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.game != nil {
            if self.game?.userRequesting == self.appDelegate.user?.displayName {
                self.gamesDb.child(self.game?.id as! String).removeValue()
            } else {
                self.game?.userChallenging = ""
                self.game?.deckUserRequesting = []
                self.game?.deckUserChallenging = []
                self.updateGame()
            }
        }
    }
    
    func updateGame() {
        self.gamesDb.child((self.game?.id)!).updateChildValues(self.game?.toAnyObject() as! [AnyHashable : Any])
    }
    
    func getAllCards() {
        // preenchendo todas as cartas
        self.cardsDb.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.allCards.removeAll()
                for item in snapshot.children {
                    let cardItem = Card(snapshot: item as! DataSnapshot)
                    self.allCards.append(cardItem)
                }
                
                self.drawCardsForPlayers()
                self.updateGame()
            }
        })
    }
    
    func observeCurrentGame() {
        // observer do jogo para ver se alguem entrou
        self.gamesDb.child(self.game?.id as! String).observe(.value, with: { snapshot in
            if snapshot.childrenCount > 0 {
                let gameItem = Game(snapshot: snapshot as! DataSnapshot)
                if self.game?.userChallenging == "" && gameItem.userChallenging != "" {
                    self.gameStatus.text = "Jogo irá começar..."
                } else if self.game?.userChallenging != "" && gameItem.userChallenging == "" {
                    self.gameStatus.text = "Desafiante saiu da sala..."
                }
                
                self.game = gameItem
                self.userRequesting.text = (self.game?.userRequesting)!
                self.userChallenging.text = (self.game?.userChallenging)!
            } else {
                self.game = nil
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    func drawCardsForPlayers() {
        let cardsPerPlayer: Int = self.allCards.count / 2
        
        self.allCards.shuffle()
        
        for index in 0...self.allCards.count - 1 {
            if index < cardsPerPlayer {
                self.game?.deckUserRequesting.append(self.allCards[index])
            } else {
                self.game?.deckUserChallenging.append(self.allCards[index])
            }
        }
    }
    
    
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let test = "teste"
    }
     */
}
