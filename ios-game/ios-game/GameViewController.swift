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
    @IBOutlet weak var round: UILabel!
    @IBOutlet weak var scoreUserRequesting: UILabel!
    @IBOutlet weak var scoreUserChallenging: UILabel!
    
    @IBOutlet weak var userRequestingImageCard: UIImageView!
    @IBOutlet weak var userChallengingImageCard: UIImageView!
    
    @IBOutlet weak var gameStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.game?.name
        
        if self.game?.userChallenging != "" {
            self.getAllCards(game: self.game!)
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
                self.updateGame(game: self.game!)
            }
        }
    }
    
    func updateGame(game: Game) {
        self.gamesDb.child((game.id)).updateChildValues(game.toAnyObject() as! [AnyHashable : Any])
    }
    
    func updateGameOutlets(game: Game) {
        self.userRequesting.text = (game.userRequesting)
        self.userChallenging.text = (game.userChallenging)
        self.round.text = String(game.round)
        self.scoreUserRequesting.text = String(game.scoreUserRequesting)
        self.scoreUserChallenging.text = String(game.scoreUserChallenging)
    }
    
    func getAllCards(game: Game) {
        // preenchendo todas as cartas
        self.cardsDb.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.allCards.removeAll()
                for item in snapshot.children {
                    let cardItem = Card(snapshot: item as! DataSnapshot)
                    self.allCards.append(cardItem)
                }
                
                self.drawCardsForPlayers(game: game)
                self.sortFirstPlayer(game: game)
                self.updateGame(game: game)
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
                    self.startGame()
                } else if self.game?.userChallenging != "" && gameItem.userChallenging == "" {
                    self.gameStatus.text = "Desafiante saiu da sala..."
                }
                
                self.game = gameItem
                self.updateGameOutlets(game: self.game!)
            } else {
                self.game = nil
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    func drawCardsForPlayers(game: Game) {
        let cardsPerPlayer: Int = self.allCards.count / 2
        
        self.allCards.shuffle()
        
        for index in 0...self.allCards.count - 1 {
            if index < cardsPerPlayer {
                game.deckUserRequesting.append(self.allCards[index])
            } else {
                game.deckUserChallenging.append(self.allCards[index])
            }
        }
    }
    
    func sortFirstPlayer(game: Game) {
        game.roundUser = Int(arc4random_uniform(1))
    }
    
    func startGame() {
        loadImage(imageUrlString: Constants.urlBlankCard, view: self.userRequestingImageCard)
        loadImage(imageUrlString: Constants.urlBlankCard, view: self.userChallengingImageCard)
    }
    
    func loadImage(imageUrlString: String, view: UIImageView) {
        let url = URL(string: imageUrlString)
        
        let task = URLSession.shared.dataTask(with: url!) {responseData,response,error in
            if error == nil{
                if let data = responseData {
                    
                    DispatchQueue.main.async {
                        view.image = UIImage(data: data)
                    }
                }else {
                    print("no data")
                }
            }else{
                print(error)
            }
        }
        
        task.resume()
    }
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let test = "teste"
    }
     */
}
