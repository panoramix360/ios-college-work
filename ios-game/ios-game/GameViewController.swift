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
    
    @IBOutlet weak var myName: UILabel!
    @IBOutlet weak var opponentName: UILabel!
    
    @IBOutlet weak var round: UILabel!
    @IBOutlet weak var scoreUserRequesting: UILabel!
    @IBOutlet weak var scoreUserChallenging: UILabel!
    
    @IBOutlet weak var myImageCard: UIImageView!
    @IBOutlet weak var opponentImageCard: UIImageView!
    
    @IBOutlet weak var gameStatus: UILabel!
    
    @IBOutlet weak var strengthBtn: UIButton!
    @IBOutlet weak var velocityBtn: UIButton!
    @IBOutlet weak var habilityBtn: UIButton!
    @IBOutlet weak var equipamentBtn: UIButton!
    @IBOutlet weak var intelligenceBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.game?.name
        
        if self.game?.userChallenging != "" {
            self.getAllCards()
        } else {
            self.hideAllAttributes(hidden: true)
            self.observeCurrentGame()
        }
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
    
    func updateGameOutlets() {
        if self.game?.userRequesting == self.appDelegate.user?.displayName {
            self.myName.text = (self.game?.userRequesting)
            self.opponentName.text = (self.game?.userChallenging)
        } else {
            self.myName.text = (self.game?.userChallenging)
            self.opponentName.text = (self.game?.userRequesting)
        }
        self.round.text = String((self.game?.round)! + 1)
        self.scoreUserRequesting.text = String(describing: self.game?.scoreUserRequesting)
        self.scoreUserChallenging.text = String(describing: self.game?.scoreUserChallenging)
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
                self.sortFirstPlayer()
                self.updateGame()
                self.startGame()
                self.observeCurrentGame()
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
                    if gameItem.userChallenging != self.appDelegate.user?.displayName {
                        self.startGame()
                    }
                } else if self.game?.userChallenging != "" && gameItem.userChallenging == "" {
                    self.gameStatus.text = "Desafiante saiu da sala..."
                }
                
                self.game = gameItem
                self.updateGameOutlets()
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
    
    func sortFirstPlayer() {
        self.game?.roundUser = Int(arc4random_uniform(2))
    }
    
    func startGame() {
        if self.game?.userRequesting == self.appDelegate.user?.displayName {
            self.myName.text = (self.game?.userRequesting)
            self.opponentName.text = (self.game?.userChallenging)
            loadImage(imageUrlString: (self.game?.deckUserRequesting[(self.game?.round)!].imageUrl)!, view: self.myImageCard)
            loadImage(imageUrlString: Constants.urlBlankCard, view: self.opponentImageCard)
        } else {
            self.myName.text = (self.game?.userChallenging)
            self.opponentName.text = (self.game?.userRequesting)
            loadImage(imageUrlString: (self.game?.deckUserChallenging[(self.game?.round)!].imageUrl)!, view: self.myImageCard)
            loadImage(imageUrlString: Constants.urlBlankCard, view: self.opponentImageCard)
        }
        
        showTurn()
    }
    
    func showTurn() {
        if self.game?.roundUser == 0 {
            self.gameStatus.text = "É a vez do " + (self.game?.userRequesting)!
        } else {
            self.gameStatus.text = "É a vez do " + (self.game?.userChallenging)!
        }
        
        if (self.game?.userRequesting == self.appDelegate.user?.displayName && self.game?.roundUser == 0)
            || (self.game?.userChallenging == self.appDelegate.user?.displayName && self.game?.roundUser == 1) {
            self.hideAllAttributes(hidden: false)
        } else {
            self.hideAllAttributes(hidden: true)
        }
    }
    
    func loadImage(imageUrlString: String, view: UIImageView) {
        let url = URL(string: imageUrlString)
        
        let task = URLSession.shared.dataTask(with: url!) {responseData,response,error in
            if error == nil {
                if let data = responseData {
                    DispatchQueue.main.async {
                        view.image = UIImage(data: data)
                    }
                } else {
                    print("no data")
                }
            } else {
                print(error)
            }
        }
        
        task.resume()
    }
    
    @IBAction func chooseStrenght(_ sender: Any) {
        self.attributeChoosed(attribute: AttributeEnum.strenght)
    }
    
    @IBAction func chooseVelocity(_ sender: Any) {
        self.attributeChoosed(attribute: AttributeEnum.velocity)
    }
    
    @IBAction func chooseHability(_ sender: Any) {
        self.attributeChoosed(attribute: AttributeEnum.hability)
    }
    
    @IBAction func chooseEquipament(_ sender: Any) {
        self.attributeChoosed(attribute: AttributeEnum.equipament)
    }
    
    @IBAction func chooseIntelligence(_ sender: Any) {
        self.attributeChoosed(attribute: AttributeEnum.intelligence)
    }
    
    func attributeChoosed(attribute: AttributeEnum) {
        // delay
        
        if self.game?.userRequesting == self.appDelegate.user?.displayName {
            loadImage(imageUrlString: (self.game?.deckUserChallenging[(self.game?.round)!].imageUrl)!, view: self.opponentImageCard)
        } else {
            loadImage(imageUrlString: (self.game?.deckUserRequesting[(self.game?.round)!].imageUrl)!, view: self.opponentImageCard)
        }
    }
    
    func hideAllAttributes(hidden: Bool) {
        self.strengthBtn.isHidden = hidden
        self.velocityBtn.isHidden = hidden
        self.habilityBtn.isHidden = hidden
        self.equipamentBtn.isHidden = hidden
        self.intelligenceBtn.isHidden = hidden
    }
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let test = "teste"
    }
     */
}
