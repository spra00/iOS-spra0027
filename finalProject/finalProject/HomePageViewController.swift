//
//  ViewController.swift
//  finalProject
//  This VC powers the Home Page
//  Created by Shakthi  Prashanth champaka on 2/5/2022.
//

import UIKit


class HomePageViewController: UIViewController {
    
    //the user entered.
    @IBOutlet weak var userEnteredPinCode: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //try to remove the
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        
    }
    
    
    
    
    @IBAction func logOut(_ sender: Any) {
        // check if the user is sure about log off
        self.displayMessage(title: "Confirm", message: " You want to Log Out?")

    }
    
    func displayMessage(title: String, message: String){
        // used to display message
        let alertController = UIAlertController(title: title, message: message,
         preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                var _ = self.handleLogOutFirebase()}))
        
        alertController.addAction(UIAlertAction(title: "No", style: .default, handler: .none))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //Calls the firebase method to logout
    func handleLogOutFirebase(){
        // method to sign out the user from the application
        databaseController?.signOutUser()
        self.navigationController?.popToRootViewController(animated: true)
        
        
    }
    
    
    
    @IBAction func letsPlayClicked(_ sender: Any) {
        //once the lets's play is clicked.
        self.performSegue(withIdentifier: "homeToGroundSegue", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "homeToGroundSegue"{
            let destination = segue.destination as! PlaygroundViewController
            
            
            if let userEnteredPinCode = userEnteredPinCode.text{
                if userEnteredPinCode == ""{
                    destination.myPinCode = "0000"
                }
                else{
                    destination.myPinCode = userEnteredPinCode
                }
                
            }
            
        }
    
    }

    
    
    
    
    
    


}
