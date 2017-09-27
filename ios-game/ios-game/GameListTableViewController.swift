//
//  GameListTableViewController.swift
//  ios-game
//
//  Created by Lucas de Oliveira Reis on 20/09/17.
//  Copyright © 2017 Lucas de Oliveira Reis. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class GameListTableViewController: UITableViewController {

    var games = [Game]()
    var selectedGame: Game?
    let gamesDb = Database.database().reference(withPath: "games")
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        self.gamesDb.observe(.value, with: { snapshot in
            self.games.removeAll()
            
            if snapshot.childrenCount > 0 {
                for item in snapshot.children {
                    let gameItem = Game(snapshot: item as! DataSnapshot)
                    self.games.append(gameItem)
                }
            }
            
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return games.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "GameTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GameTableViewCell else {
            fatalError("A célula não é uma instância de GameTableViewCell")
        }
        
        let game = games[indexPath.row]
        
        cell.gameName.text = game.name
        cell.userRequesting.text = game.userRequesting
        cell.userChallenging.text = game.userChallenging

        return cell
    }

    
    @IBAction func addNewGame(_ sender: Any) {
        let alert = UIAlertController(title: "Adicionar Novo Jogo",
                                      message: "",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            
            guard let textField = alert.textFields?.first,
                let text = textField.text else { return }
            
            let id = self.gamesDb.childByAutoId().key
            
            let game = Game(id: id, name: text, userRequesting: (self.appDelegate.user?.displayName)!);
            
            self.gamesDb.child(id).setValue(game?.toAnyObject())
            
            self.selectedGame = game
            self.performSegue(withIdentifier: "listToDetailSegue", sender: self.selectedGame)
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listToDetailSegue" {
            if let gameViewController = segue.destination as? GameViewController {
                gameViewController.game = selectedGame
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedGame = self.games[indexPath.row]
        
        if self.selectedGame?.userChallenging == "" {
            self.selectedGame?.userChallenging = (self.appDelegate.user?.displayName)!
            self.performSegue(withIdentifier: "listToDetailSegue", sender: self.selectedGame)
        } else {
            let alert = UIAlertController(title: "Jogo cheio.",
                                          message: "",
                                          preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
