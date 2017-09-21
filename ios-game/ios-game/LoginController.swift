//
//  LoginController.swift
//  ios-game
//
//  Created by Lucas de Oliveira Reis on 18/09/17.
//  Copyright © 2017 Lucas de Oliveira Reis. All rights reserved.
//

import UIKit
import FirebaseDatabase
import GoogleSignIn

class LoginController: UIViewController, GIDSignInUIDelegate {
    
    
    @IBAction func logout(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
    } 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
        // testing FirebaseDatabase
        let ref = Database.database().reference(withPath: "games")
        
        ref.observe(.value, with: {
            snapshot in print(snapshot.value!)
        })
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
