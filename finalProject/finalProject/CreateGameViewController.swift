//
//  CreateGameViewController.swift
//  finalProject
//  THis VC is used to create a new game to the playground
//  Created by Shakthi  Prashanth champaka on 9/5/2022.
//

import UIKit
import Firebase

class CreateGameViewController: UIViewController {
    
    //attributes required for playground information
    var recordid: String?
    var postcode: String?
    var playground_name: String?
    var suburb_name: String?
    var latitude: Double?
    var longitude: Double?
    
    weak var databaseController: DatabaseProtocol?
    
        
    @IBOutlet weak var gameName: UITextField!
    @IBOutlet weak var gameNumPlayers: UITextField!
    @IBOutlet weak var dateTime: UIDatePicker!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
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
        
        //databaseController?.updateGameToUser()

        // Do any additional setup after loading the view.
        submitButton.addSubview(submitSpinner)
        submitSpinner.centerXAnchor.constraint(equalTo: submitButton.centerXAnchor).isActive = true
        submitSpinner.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor).isActive = true
    }
    
    
    
    
    @IBAction func onClick(_ sender: Any) {
        
        //check if values have been entered for them.
        guard let gameName = gameName.text, let gameNumPlayers = gameNumPlayers.text, let phoneNumber = phoneNumber.text else {
         return
        }
                
        // the following conditions check if they are empty or not
        
        if gameName.isEmpty || gameNumPlayers.isEmpty || phoneNumber.isEmpty{
                    
            var errorMsg = "Please ensure all fields are filled:\n"
                
            if gameName.isEmpty {
                 
                 errorMsg += "- Should provide a name for the game\n"
                 
            }
                
            if gameNumPlayers.isEmpty {
                 
                 errorMsg += "- Should specifiy the number of players allowed\n"
            }
                
            if phoneNumber.isEmpty{
                 errorMsg += "- Must provide a phone number\n"
                    
            }
            //finally display the details of the error.
             displayMessage(title: "Fields Are Not Filled", message: errorMsg)
            
             return
        }
        
        submitSpinner.startAnimating()
        
        guard let recordid = recordid else {
            return
        }
        
        guard let postcode = postcode else {
            return
        }
        guard let playground_name = playground_name else {
            return
        }
        guard let suburb_name = suburb_name else {
            return
        }
        
        let gameTime = DateFormatter.localizedString(from: dateTime.date, dateStyle: .medium, timeStyle: .short)
                
        databaseController?.createNewGame(recordid: recordid, postcode: postcode, playground_name: playground_name, suburb_name: suburb_name, gameName: gameName, numPlayers: gameNumPlayers, dateTime: gameTime, phoneNumber: phoneNumber)
        
        
        //add the game to the user
        databaseController?.updateGameToUser(recordid: recordid, postcode: postcode, playground_name: playground_name, suburb_name: suburb_name, gameName: gameName, numPlayers: gameNumPlayers, dateTime: gameTime, phoneNumber: phoneNumber)
        
        
        //Wait untial user has logged in
        let seconds = 4.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            //stop animating
            self.displaConfirmation(title: "Game Created!", message: "The game has been created successfully.")
            self.submitSpinner.stopAnimating()
            
        }
        
    }
        
    
    func displaConfirmation(title: String, message: String){
        //this method is used to print a confirmation to the user once the game has been created
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "HOME PAGE", style: .default, handler: { _ in
                var _ = self.backToHome()}))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func backToHome(){
        
        //allows the user to go to the Home Page
       let storyboard = UIStoryboard(name: "Main", bundle: nil)
       let loggedIn = storyboard.instantiateViewController(withIdentifier: "homePage")
       self.navigationController?.pushViewController(loggedIn, animated: true)
       
    }
    
    //this function is used to print any alerts to the user.
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message,
         preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }


}
