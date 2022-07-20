//
//  InitialViewController.swift
//  finalProject
//  This is the initial view controller / the first page
//  Created by Shakthi  Prashanth champaka on 26/4/2022.
//

import UIKit
import FirebaseAuth

class InitialViewController: UIViewController {
    
    
    @IBOutlet weak var applicationImage: UIImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let _ = Auth.auth().currentUser?.uid else{
            return
        }
        
        self.displayMessage(title: "Logged In", message: "You Have Already Logged In. Please Head To Home Page")
        
    }
    
    
    func displayMessage(title: String, message: String){
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "HOME PAGE", style: .default, handler: { _ in
            var _ = self.checkIfLoggedIn()}))
    self.present(alertController, animated: true, completion: nil)
    }
    
    // This method is used to check if a user is already logged in the app
    func checkIfLoggedIn(){
        Auth.auth().addStateDidChangeListener { (auth, user) in
                if user == nil {
                }
                else {
                     //Signed in
                    //if the user is already logged in then directly move to the home page
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loggedIn = storyboard.instantiateViewController(withIdentifier: "homePage")
                    self.navigationController?.pushViewController(loggedIn, animated: true)
                    //self.parent?.present(loggedIn, animated: true)
                }
        }
    }
    
}


