//
//  LoginViewController.swift
//  finalProject
//  This used to handle Login
//  Created by Shakthi  Prashanth champaka on 26/4/2022.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var userEmail: UITextField!
    
    @IBOutlet weak var userPassword: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    
    
    @IBOutlet weak var loginButton: UIButton!
    
    let loginSpinner: UIActivityIndicatorView = {
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
        loginButton.addSubview(loginSpinner)
        loginSpinner.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor).isActive = true
        loginSpinner.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor).isActive = true
    }
    
    
    
    @IBAction func onSignUpClick(_ sender: Any) {
        
        //it will go to sign up page

    }
    

    
        
    //this method handles when the user clicks in a login button
    @IBAction func onLoginClick(_ sender: Any){
        
        //start animating the spin
        loginSpinner.startAnimating()
        
        //Handle wrong inputs by the user.
        guard let email = userEmail.text, let password = userPassword.text else {
         return
        }
        
        if email.isEmpty || password.isEmpty {
            
         var errorMsg = "Please ensure all fields are filled:\n"
            
         if email.isEmpty {
             
             errorMsg += "- Must provide an email address\n"
             
         }
            
         if password.isEmpty {
             
             errorMsg += "- Must enter a password"
         }
        
         loginSpinner.stopAnimating()
         displayMessage(title: "Fields Are Not Filled", message: errorMsg)
         return 
        }
        

        
        // if every conidtion is met then
        databaseController?.loginUser(email: email, password: password)
        
        //Wait untial user has logged in
        let seconds = 4.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            
            // Put your code which should be executed with a delay here
            guard let _ = Auth.auth().currentUser?.uid else{
                self.loginSpinner.stopAnimating()
                self.displayMessage(title: "Couldn't Login", message: "Email or Password not correct")
                return
                
            }
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let gameDetails = storyboard.instantiateViewController(withIdentifier: "homePage") as! HomePageViewController
            self.navigationController?.pushViewController(gameDetails, animated: false)
            return
            
        }
        
        
                
    }
    
    //Function used to let users know of any mistakes they have made
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message,
         preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
        


}
