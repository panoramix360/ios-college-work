//
//  Game.swift
//  ios-game
//
//  Created by Lucas de Oliveira Reis on 21/09/17.
//  Copyright © 2017 Lucas de Oliveira Reis. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Game {
    
    var id: String
    var name: String
    var userRequesting: String
    var userChallenging: String = ""
    
    var scoreUserRequesting: Int = 0
    var scoreUserChallenging: Int = 0
    
    var round: Int = 0
    var roundUser: Int = 0
    
    var deckUserRequesting = [Card]()
    var deckUserChallenging = [Card]()
    
    var opponentHasPlayed: Bool = false
    
    init?(id: String, name: String, userRequesting: String) {
        if id.isEmpty || name.isEmpty || userRequesting.isEmpty {
            return nil
        }
        
        self.id = id
        self.name = name
        self.userRequesting = userRequesting
    }
    
    init(snapshot: DataSnapshot) {
        self.id = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.name = snapshotValue["name"] as! String
        self.userRequesting = snapshotValue["userRequesting"] as! String
        if let userChallenging = snapshotValue["userChallenging"] {
            self.userChallenging = userChallenging as! String
        }
        self.scoreUserRequesting = snapshotValue["scoreUserRequesting"] as! Int
        self.scoreUserChallenging = snapshotValue["scoreUserChallenging"] as! Int
        self.round = snapshotValue["round"] as! Int
        self.roundUser = snapshotValue["roundUser"] as! Int
        self.opponentHasPlayed = snapshotValue["opponentHasPlayed"] as! Bool
        
        if let deckUserRequesting = snapshotValue["deckUserRequesting"] {
            for item in deckUserRequesting as! NSArray {
                self.deckUserRequesting.append(Card(dict: item as! NSDictionary))
            }
        }
        
        if let deckUserChallenging = snapshotValue["deckUserChallenging"] {
            for item in deckUserChallenging as! NSArray {
                self.deckUserChallenging.append(Card(dict: item as! NSDictionary))
            }
        }
    }
    
    func toAnyObject() -> Any {
        return [
            "id": self.id,
            "name": self.name,
            "userRequesting": self.userRequesting,
            "userChallenging": self.userChallenging,
            "scoreUserRequesting": self.scoreUserRequesting,
            "scoreUserChallenging": self.scoreUserChallenging,
            "round": self.round,
            "roundUser": self.roundUser,
            "opponentHasPlayed": self.opponentHasPlayed,
            "deckUserRequesting": self.toAnyArrayObject(cards: self.deckUserRequesting),
            "deckUserChallenging": self.toAnyArrayObject(cards: self.deckUserChallenging)
        ]
    }
    
    func toAnyArrayObject(cards: [Card]) -> NSArray {
        let arr: NSMutableArray = NSMutableArray()
        for card in cards {
            arr.add(card.toAnyObject())
        }
        return arr
    }
}
