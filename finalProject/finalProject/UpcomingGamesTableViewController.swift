//
//  UpcomingGamesTableViewController.swift
//  finalProject
//  This Table VC is used to create a table of the upcoming games for the user.
//  Created by Shakthi  Prashanth champaka on 23/5/2022.
//

import UIKit
import Firebase

class UpcomingGamesTableViewController: UITableViewController {

    weak var databaseController: DatabaseProtocol?
    var gameDict = [[String : Any]]()
    var indicator = UIActivityIndicatorView()
    var playgroundLocations = [PlaygroundData]()
    
    //attributes required for segueing
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
        
        Task {
         URLSession.shared.invalidateAndCancel()
         await requestPlaygrounds()
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
        
        //start the indicator animation
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
          
        //this method is used to get all the games from the firebase.
        
        //perform asyn call in non-main thread.
        let db = Firestore.firestore()
        db.collection("userList").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                } else {
                    for document in querySnapshot!.documents {
                        let myDict = document.data()
                        if myDict["userID"] as? String == Auth.auth().currentUser?.uid{
                            
                            guard myDict["gameCollection"] != nil else{
                                return
                            }
                            
                            let game_collection = myDict["gameCollection"] as! Array<Any>
                            for game in game_collection{
                                self.gameDict.append(game as! [String : Any])
                                
                            }
                            
                        }

                    }
                    
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //method specifying whethere a segue needs to be performed or not
        
        if identifier == "myGameDetailSegue"{
            return false
            
        }
        
        return true
    }

    public func requestPlaygrounds() async{
        
        //method used to obtain the playground details
        // CREDITS: ALL THE DATA HAS BEEN OBTAINED FROM CITY OF CASEY OPEN DATA's API
        // https://www.casey.vic.gov.au/
        
        let requestURL = URL(string: "https://data.casey.vic.gov.au/api/records/1.0/search/?dataset=playgrounds&q=&rows=50")!
    
        let urlRequest = URLRequest(url: requestURL)
        
        //using do and catch block to catch any errors
        do {
            let (data, _) =
         try await URLSession.shared.data(for: urlRequest)
            
            do{
                //Decode using the RecoredData which is created
                let decoder = JSONDecoder()
                let recordData = try decoder.decode(RecordData.self, from: data)
                
                if let playground = recordData.playgrounds{
                    
                    //store the obtained data in this list.
                    self.playgroundLocations = playground
                                        
                }

            }
            //if any errors are caught
            catch let error {
             print(error)
            }
        
        }
        catch let error {
         print(error)
        }


    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath) != nil{
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let gameDetails = storyboard.instantiateViewController(withIdentifier: "seeGameDetail") as! UpcomingGameDetailViewController
            
            let code:String = gameDict[indexPath.row]["postcode"] as! String
            let ground_name: String = gameDict[indexPath.row]["playground_name"] as! String
            let suburbname = gameDict[indexPath.row]["suburb_name"] as! String
            let email = gameDict[indexPath.row]["creatorEmail"] as! String
            let phone = gameDict[indexPath.row]["phoneNumber"] as! String
            
            
            
            gameDetails.suburb_name = suburbname
            gameDetails.recordid = gameDict[indexPath.row]["recordid"] as? String
            gameDetails.playground_name = ground_name
            gameDetails.postcode = code
            
            
            for ground in self.playgroundLocations{
                
                if ground.recordid == gameDict[indexPath.row]["recordid"] as? String{
                    gameDetails.latitude = ground.latitude
                    gameDetails.longitude = ground.longitude
                }
            }
            
            gameDetails.address = ground_name + ", " + suburbname + ", " + code
            gameDetails.coordinator = "Email: " + email + " and Phone: " + phone
            
            //present in the current view
            self.parent?.present(gameDetails, animated: true)
        }
        
        
    }
    

}

