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
    var numberOfPlayers: String = ""
    
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
        self.userChallenging = snapshotValue["userChallenging"] as! String
    }
    
    func toAnyObject() -> Any {
        return [
            "id": self.id,
            "name": self.name,
            "userRequesting": self.userRequesting
        ]
    }
}
