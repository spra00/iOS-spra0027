//

//  GamesTableViewController.swift
//  finalProject
//  This Table VC is used to show all the games of a playground.
//  Created by Shakthi  Prashanth champaka on 16/5/2022.
//



import UIKit

import Firebase

class GamesTableViewController: UITableViewController {
            
    weak var databaseController: DatabaseProtocol?
    var gameDict = [[String : Any]]()
    var indicator = UIActivityIndicatorView()
    var playgroundLocations = [PlaygroundData]()
    
    //attributes required for seguring
    var recordid: String?
    var postcode: String?
    var playground_name: String?
    var suburb_name: String?
    var latitude: Double?
    var longitude: Double?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load all the games async
        Task{
            
            await getGamesList()
            
        }

        // Load the firebaseController
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        
        // Add a loading indicator view
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
         indicator.centerXAnchor.constraint(equalTo:
         view.safeAreaLayoutGuide.centerXAnchor),
         indicator.centerYAnchor.constraint(equalTo:
         view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        self.indicator.startAnimating()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return gameDict.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameDetail", for: indexPath) as! GameTableViewCell
        
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.systemYellow.cgColor
        cell.gameDate.font = UIFont.boldSystemFont(ofSize: 15.0)
        cell.gameName.font = UIFont.boldSystemFont(ofSize: 22.0)
        cell.gameName.text = gameDict[indexPath.row]["gameName"] as? String
        cell.gameDate.text = gameDict[indexPath.row]["dateTime"] as? String
        
        
        return cell
        
        
    }
    
    func getGamesList() async{
        //perform asyn call in non-main thread.
        let db = Firestore.firestore()
        db.collection("gameList").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                } else {
                    for document in querySnapshot!.documents {
                        //gameData.append(document.data())
                        let myDict = document.data()
                        
                        if myDict["recordid"] as? String == self.recordid{
                            self.gameDict.append(myDict)
                        }

                    }
                    //in the main thread
                    DispatchQueue.main.async{
                        self.indicator.stopAnimating()
                    }
                }
            self.tableView.reloadData()
        }
            
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //if a row in the table is selected.
        if tableView.cellForRow(at: indexPath) != nil{
            
           
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let gameDetails = storyboard.instantiateViewController(withIdentifier: "bookGame") as! GameDetailsViewController
            
            let code:String = gameDict[indexPath.row]["postcode"] as! String
            let ground_name: String = gameDict[indexPath.row]["playground_name"] as! String
            let suburbname = gameDict[indexPath.row]["suburb_name"] as! String
            let email = gameDict[indexPath.row]["creatorEmail"] as! String
            let phone = gameDict[indexPath.row]["phoneNumber"] as! String
            
            //send the required data
            gameDetails.postcode = gameDict[indexPath.row]["postcode"] as? String
            gameDetails.playground_name = gameDict[indexPath.row]["playground_name"] as? String
            gameDetails.suburb_name = gameDict[indexPath.row]["suburb_name"] as? String
            gameDetails.phoneNumber = gameDict[indexPath.row]["phoneNumber"] as? String
            gameDetails.gameName = gameDict[indexPath.row]["gameName"] as? String
            gameDetails.gameTime = gameDict[indexPath.row]["dateTime"] as? String
            gameDetails.gameNumPlayers = gameDict[indexPath.row]["numPlayers"] as? String
            gameDetails.recordid = gameDict[indexPath.row]["recordid"] as? String
            gameDetails.latitude = self.latitude
            gameDetails.longitude = self.longitude
            gameDetails.spots = "Available spots: "
            gameDetails.address = ground_name + ", " + suburbname + ", " + code
            gameDetails.coordinator = "Email: " + email + " and Phone: " + phone
            
            //present in the current view
            self.parent?.present(gameDetails, animated: true)
        }
        
        
    }

    
    @IBAction func createNewGame(_ sender: Any) {
        
        self.performSegue(withIdentifier: "createGameSegue", sender: self)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "bookSegue"{
            return false
            
        }
        
        return true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //preparing the required before seguing
        if segue.identifier == "createGameSegue"{
            let destination = segue.destination as! CreateGameViewController
            
            destination.suburb_name = self.suburb_name!
            destination.recordid = self.recordid!
            destination.playground_name = self.playground_name!
            destination.postcode = self.postcode!
            destination.latitude = self.latitude!
            destination.longitude = self.longitude!
        }
    
    }


}


