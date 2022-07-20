//
//  GameDetailsViewController.swift
//  finalProject
//  This VC is used to show the game details
//  Created by Shakthi  Prashanth champaka on 17/5/2022.
//

import UIKit
import Firebase

class GameDetailsViewController: UIViewController {
    
    //variables associated with the view
    @IBOutlet weak var gameAddress: UILabel!
    var address: String?
    @IBOutlet weak var gamecoord: UILabel!
    var coordinator: String?
    @IBOutlet weak var availSpots: UILabel!
    var spots: String?
    @IBOutlet weak var submitButton: UIButton!
    weak var databaseController: DatabaseProtocol?
    
    //reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var favGround: [FavrouiteGround]?

    //attributes required for seguring
    var recordid: String?
    var postcode: String?
    var playground_name: String?
    var suburb_name: String?
    var phoneNumber: String?
    var gameName: String?
    var gameNumPlayers: String?
    var gameTime: String?
    var latitude: Double?
    var longitude: Double?
    var numSpots: String?
    
    //an activity indicator
    let submitSpinner: UIActivityIndicatorView = {
        let loginSpinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        loginSpinner.translatesAutoresizingMaskIntoConstraints = false
        loginSpinner.hidesWhenStopped = true
        return loginSpinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the firebaseController
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        // Do any additional setup after loading the view.
        self.fetchFavrouiteGround()
        
        submitButton.addSubview(submitSpinner)
        submitSpinner.centerXAnchor.constraint(equalTo: submitButton.centerXAnchor).isActive = true
        submitSpinner.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor).isActive = true
        
        Task{
            await getGamesList()
            
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let text = address {
            self.gameAddress.text = text          // Now you can set the IBOutlet
        }
        
        if let text = coordinator{
            self.gamecoord.text = text
        }
        
        
        //Wait untial user has logged in
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            
            if let text = self.spots, let numSpots = self.numSpots{
                self.availSpots.text = text + numSpots
            }
            
        }
        
    }
    
    @IBAction func onClick(_ sender: Any) {
        //dont do anything as of now
        //start spinning
        submitSpinner.startAnimating()
        
        //unwrap the ooptional variables.
        guard let recordid = self.recordid else {
            return
        }
        
        guard let postcode = self.postcode else {
            return
        }
        
        guard let playground_name = self.playground_name else {
            return
        }
        
        guard let suburb_name = self.suburb_name else {
            return
        }
        
        guard let gameName = self.gameName else {
            return
        }
        
        guard let gameNumPlayers = self.gameNumPlayers else {
            return
        }
        
        guard let gameTime = self.gameTime else {
            return
        }
        
        guard let phoneNumber = self.phoneNumber else {
            return
        }
        
        
        //if spots are full
        if let numSpots = Int(self.numSpots!){
            if numSpots <= 0{
                self.submitSpinner.stopAnimating()
                self.displayMessage(title: "Game Full!", message: "The limit for the game has been reached!")
                return
            }
        }

        //creating the new game
        databaseController?.updateGameToUser(recordid: recordid, postcode: postcode, playground_name: playground_name, suburb_name: suburb_name, gameName: gameName, numPlayers: gameNumPlayers, dateTime: gameTime, phoneNumber: phoneNumber)
        
        
        //update the game to user
        self.updateGameSpots()
        
        //Wait untial user has logged in
        let seconds = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            
            self.submitSpinner.stopAnimating()
            self.displayMessage(title: "Player Added!", message: "You have been added to this game!")
            
        }
    }
    
    //this function is used to print any alerts to the user.
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message,
         preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    func getGamesList() async{
        let db = Firestore.firestore()
        db.collection("gameList").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                } else {
                    for document in querySnapshot!.documents {
                        let myDict = document.data()
                        if myDict["gameName"] as? String == self.gameName{
                            self.numSpots = myDict["numPlayers"] as? String
                        }

                    }
                }
        }
            
    }
    
    
    func updateGameSpots(){
        
        //this method is used to update the games in the gamesList collection in the firebase.
        let db = Firestore.firestore()
        db.collection("gameList").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                } else {
                    for document in querySnapshot!.documents {
                        let myDict = document.data()
                        if myDict["gameName"] as? String == self.gameName{
                            
                            let reference = db.collection("gameList").document(document.documentID)
                            
                            let seconds = 3.0
                            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                
                                //get the number of spots available
                                guard let numSpots = Int(self.numSpots!) else {
                                    return
                                }
                                
                                var updated_spot: String?
                                
                                if numSpots <= 0{
                                    updated_spot = String(0)
                                }
                                else{
                                    updated_spot = String(numSpots - 1)
                                }
                                
                                guard let updated_spot = updated_spot else {
                                    return
                                }
                                reference.updateData([
                                    "numPlayers": updated_spot])
                            }
                        }

                    }
                }
        }
    }
    
    
    @IBAction func makeFavourite(_ sender: Any) {
        
        //this method us used to select a playground as favrouite and then uses core data.
        // Do any additional setup after loading the view.
        self.fetchFavrouiteGround()
        
        if let favGround = favGround {
            if favGround.count > 0{
                
                let deleteFavGround = favGround[0]
                
                //delete the ground
                
                self.context.delete(deleteFavGround)
                
                do{
                    try self.context.save()
                }
                
                catch{
                    print(error)
                }
            }
        }
        
        let favrouiteGround = FavrouiteGround(context: self.context)
        
        //unwrap the optional variables
        guard let recordid = self.recordid else {
            return
        }
        guard let postcode = self.postcode else {
            return
        }
        guard let playground_name = self.playground_name else {
            return
        }
        guard let suburb_name = self.suburb_name else {
            return
        }
        guard let latitude = latitude else {
            return
        }
        guard let longitude = longitude else {
            return
        }
        favrouiteGround.recordid = recordid
        favrouiteGround.postcode = postcode
        favrouiteGround.playground_name = playground_name
        favrouiteGround.suburb_name = suburb_name
        favrouiteGround.latitude = latitude
        favrouiteGround.longitude = longitude
        
        //save the data
        do{
            try self.context.save()
        }
        
        catch{
            print(error)
        }
        
        self.displayMessage(title: "Made Favrouite", message: "This ground has been made your favrouite and will be shown in purple in the map")
    }

    func fetchFavrouiteGround(){
         //Fetch the data from the core data
        do{
            self.favGround = try context.fetch(FavrouiteGround.fetchRequest())
            
        }
        catch{
            print(error)
        }
    }
    
    
}
