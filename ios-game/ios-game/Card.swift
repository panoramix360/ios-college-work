//
//  Card.swift
//  ios-game
//
//  Created by Lucas de Oliveira Reis on 26/09/17.
//  Copyright © 2017 Lucas de Oliveira Reis. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Card {
    
    var id: String
    var ability: Int
    var equipment: Int
    var intelligence: Int
    var name: String
    var speed: Int
    var strength: Int
    var url: String
    
    init?(id: String, ability: Int, equipment: Int, intelligence: Int, name: String, speed: Int, strength: Int, url: String) {
        if id.isEmpty || name.isEmpty || url.isEmpty {
            return nil
        }
        
        self.id = id
        self.ability = ability
        self.equipment = equipment
        self.intelligence = intelligence
        self.name = name
        self.speed = speed
        self.strength = strength
        self.url = url
    }
    
    init(snapshot: DataSnapshot) {
        self.id = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.ability = snapshotValue["ability"] as! Int
        self.equipment = snapshotValue["equipment"] as! Int
        self.intelligence = snapshotValue["intelligence"] as! Int
        self.name = snapshotValue["name"] as! String
        self.speed = snapshotValue["speed"] as! Int
        self.strength = snapshotValue["strength"] as! Int
        self.url = snapshotValue["url"] as! String
    }
    
    init(dict: NSDictionary) {
        self.id = dict["id"] as! String
        self.ability = dict["ability"] as! Int
        self.equipment = dict["equipment"] as! Int
        self.intelligence = dict["intelligence"] as! Int
        self.name = dict["name"] as! String
        self.speed = dict["speed"] as! Int
        self.strength = dict["strength"] as! Int
        self.url = dict["url"] as! String
    }
    
    func toAnyObject() -> Any {
        return [
            "id": self.id,
            "ability": self.ability,
            "equipment": self.equipment,
            "intelligence": self.intelligence,
            "name": self.name,
            "speed": self.speed,
            "strength": self.strength,
            "url": self.url
        ]
    }
}

