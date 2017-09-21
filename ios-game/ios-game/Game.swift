//
//  Game.swift
//  ios-game
//
//  Created by Lucas de Oliveira Reis on 21/09/17.
//  Copyright © 2017 Lucas de Oliveira Reis. All rights reserved.
//

import Foundation

class Game {
    
    var uid: Int
    var name: String
    var numberOfPlayers: String
    
    init?(uid: Int, name: String, numberOfPlayers: String) {
        if uid < 0 || name.isEmpty || numberOfPlayers.isEmpty {
            return nil
        }
        
        self.uid = uid
        self.name = name
        self.numberOfPlayers = numberOfPlayers
    }
}
