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
    var lastRoundMine: Bool = false
    
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
        self.hideAllAttributes(hidden: true)
        
        if self.game?.userChallenging != "" {
            self.getAllCards()
        } else {
            self.observeCurrentGame()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.exitGame()
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
        self.scoreUserRequesting.text = String((self.game?.scoreUserRequesting)!)
        self.scoreUserChallenging.text = String((self.game?.scoreUserChallenging)!)
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
                self.game?.round = 0
                self.game?.scoreUserChallenging = 0
                self.game?.scoreUserRequesting = 0
                self.updateGame()
                self.startGame(game: self.game!)
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
                        self.startGame(game: gameItem)
                    }
                } else if self.game?.userChallenging != "" && gameItem.userChallenging == "" {
                    self.gameStatus.text = "Desafiante saiu da sala..."
                } else if (self.game?.round)! < gameItem.round || self.lastRoundMine {
                    self.startGame(game: gameItem)
                    self.lastRoundMine = false
                } else if self.game?.opponentHasPlayed == false && gameItem.opponentHasPlayed {
                    if self.game?.userRequesting == self.appDelegate.user?.displayName {
                        self.loadImage(imageUrlString: (self.game?.deckUserChallenging[(self.game?.round)!].url)!, view: self.opponentImageCard)
                    } else {
                        self.loadImage(imageUrlString: (self.game?.deckUserRequesting[(self.game?.round)!].url)!, view: self.opponentImageCard)
                    }
                    if (self.game?.scoreUserRequesting)! < gameItem.scoreUserRequesting {
                        self.gameStatus.text = (self.game?.userRequesting)! + " ganhou!"
                    } else if (self.game?.scoreUserChallenging)! < gameItem.scoreUserChallenging {
                        self.gameStatus.text = (self.game?.userChallenging)! + " ganhou!"
                    } else {
                        self.gameStatus.text = "empate!"
                    }
                    gameItem.opponentHasPlayed = false
                } else if(self.game?.roundUser != gameItem.roundUser ) {
                    self.startGame(game: gameItem)
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
    
    func startGame(game: Game) {
        
        let endGmae = checkEndGame(game: game)
        if !endGmae {
            if game.userRequesting == self.appDelegate.user?.displayName {
                self.myName.text = (game.userRequesting)
                self.opponentName.text = (game.userChallenging)
                loadImage(imageUrlString: game.deckUserRequesting[game.round].url, view: self.myImageCard)
                loadImage(imageUrlString: Constants.urlBlankCard, view: self.opponentImageCard)
            } else {
                self.myName.text = (game.userChallenging)
                self.opponentName.text = (game.userRequesting)
                loadImage(imageUrlString: game.deckUserChallenging[game.round].url, view: self.myImageCard)
                loadImage(imageUrlString: Constants.urlBlankCard, view: self.opponentImageCard)
            }
            
            showTurn(game: game)
        }
        
    }
    
    func showTurn(game: Game) {
        if game.roundUser == 0 {
            self.gameStatus.text = "É a vez do " + game.userRequesting
        } else {
            self.gameStatus.text = "É a vez do " + game.userChallenging
        }
        
        if (game.userRequesting == self.appDelegate.user?.displayName && game.roundUser == 0)
            || (game.userChallenging == self.appDelegate.user?.displayName && game.roundUser == 1) {
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
        let cardUserRequesting: Card = (self.game?.deckUserRequesting[(self.game?.round)!])!
        let cardUserChallenging: Card = (self.game?.deckUserChallenging[(self.game?.round)!])!
        // delay
        if self.game?.userRequesting == self.appDelegate.user?.displayName {
            loadImage(imageUrlString: cardUserChallenging.url, view: self.opponentImageCard)
        } else {
            loadImage(imageUrlString: cardUserRequesting.url, view: self.opponentImageCard)
        }
        
        switch attribute {
            case AttributeEnum.strenght:
                checkWinner(powerRequesting: cardUserRequesting.strength, powerChallenging: cardUserChallenging.strength)
                break
            case AttributeEnum.velocity:
                checkWinner(powerRequesting: cardUserRequesting.speed, powerChallenging: cardUserChallenging.speed)
                break
            case AttributeEnum.hability:
                checkWinner(powerRequesting: cardUserRequesting.ability, powerChallenging: cardUserChallenging.ability)
                break
            case AttributeEnum.equipament:
                checkWinner(powerRequesting: cardUserRequesting.equipment, powerChallenging: cardUserChallenging.equipment)
                break
            case AttributeEnum.intelligence:
                checkWinner(powerRequesting: cardUserRequesting.intelligence, powerChallenging: cardUserChallenging.intelligence)
                break
        }
        
        self.game?.opponentHasPlayed = true
        self.hideAllAttributes(hidden: true)
        self.updateGame()
        
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.game?.round += 1
            self.lastRoundMine = true
            self.game?.opponentHasPlayed = false
            self.updateGame()
        }
    }
    
    func checkWinner(powerRequesting: Int, powerChallenging: Int) {
        if powerRequesting > powerChallenging {
            self.game?.scoreUserRequesting += 1
            self.gameStatus.text = (self.game?.userRequesting)! + " ganhou!"
            self.game?.roundUser = 0
        } else if powerRequesting < powerChallenging {
            self.game?.scoreUserChallenging += 1
            self.gameStatus.text = (self.game?.userChallenging)! + " ganhou!"
            self.game?.roundUser = 1
        } else {
            self.gameStatus.text = "empate!"
            if self.game?.roundUser == 0 {
                self.game?.roundUser = 1
            } else {
                self.game?.roundUser = 0
            }
        }
        checkEndGame(game: self.game!)
    }
    
    func checkEndGame(game: Game) -> Bool {
        let maxRounds = game.deckUserChallenging.count
        var isEndGame = false
        var isRequesting = false
        
        if self.game?.userRequesting == self.appDelegate.user?.displayName {
            isRequesting = true
        }
        
        if(game.scoreUserRequesting >= (maxRounds / 2) + 1) {
            isEndGame = true
            if(isRequesting) {
                showEndGame(win: true)
            } else {
                showEndGame(win: false)
            }
        } else if (game.scoreUserChallenging >= (maxRounds / 2) + 1) {
            isEndGame = true
            if(!isRequesting) {
                showEndGame(win: true)
            } else {
                showEndGame(win: false)
            }

        } else if (game.round >= maxRounds) {
            isEndGame = true
            showEndGame()
        }
        
        return isEndGame
    }
    
    func showEndGame(win: Bool? = nil) {
        var title = "Derrota"
        if win == nil{
            title = "Empate"
        } else if win! {
            title = "Vitoria"
        }
        let alert = UIAlertController(title: title,
                                      message: "",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            self.exitGame()
            self.performSegue(withIdentifier: "detailToListSegue", sender: self)
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideAllAttributes(hidden: Bool) {
        self.strengthBtn.isHidden = hidden
        self.velocityBtn.isHidden = hidden
        self.habilityBtn.isHidden = hidden
        self.equipamentBtn.isHidden = hidden
        self.intelligenceBtn.isHidden = hidden
    }
    
    func exitGame() {
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
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let test = "teste"
    }
     */
}
