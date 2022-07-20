//
//  SignUpViewController.swift
//  finalProject
//  This handles the sign up process of the user
//  Created by Shakthi  Prashanth champaka on 26/4/2022.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var userEmail: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var confirmPassword: UITextField!
    
    
    @IBOutlet weak var signupButton: UIButton!
    
    let signupSpinner: UIActivityIndicatorView = {
        let signupSpinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        signupSpinner.translatesAutoresizingMaskIntoConstraints = false
        signupSpinner.hidesWhenStopped = true
        return signupSpinner
    }()
        
    
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Do any additional setup after loading the view.
        signupButton.addSubview(signupSpinner)
        signupSpinner.centerXAnchor.constraint(equalTo: signupButton.centerXAnchor).isActive = true
        signupSpinner.centerYAnchor.constraint(equalTo: signupButton.centerYAnchor).isActive = true
    }
    
    //once the user clicks on the sign up button, this method initiates
    
    @IBAction func onSignUpClick(_ sender: Any) {
        
        //signupspinner starts animating
        signupSpinner.startAnimating()
        
        guard let email = userEmail.text, let password = password.text, let name = userName.text, let confirmPassd = confirmPassword.text else {
         return
        }
        
        // check if password and confirm password is same or not
        if password != confirmPassd{
            
            signupSpinner.stopAnimating()
            displayMessage(title: "Password Didn't Match", message: "Your Password DID NOT match. Please Enter correctly!.")
                
            return
                
        }
        
        // the following conditions check if they are empty or not
        
        if email.isEmpty || password.isEmpty || name.isEmpty || confirmPassd.isEmpty {
                    
            var errorMsg = "Please ensure all fields are filled:\n"
                
            if email.isEmpty {
                 
                 errorMsg += "- Must provide an email address\n"
                 
            }
                
            if password.isEmpty {
                 
                 errorMsg += "- Must enter a password\n"
            }
                
            if name.isEmpty{
                 errorMsg += "- Must provide a name\n"
                    
            }
                
            if password.isEmpty {
                    
                 errorMsg += "- Must enter the confirm password\n"
            }
            
            //stop the spinner
             signupSpinner.stopAnimating()
             displayMessage(title: "Fields Are Not Filled", message: errorMsg)
            
             return
                
        }
        
        // if every condition is met then perform the sign up process
        databaseController?.signUpUser(email: email, password: password, name: name)
        
        
        //Wait untial user has created an account
        let seconds = 4.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            
            // Put your code which should be executed with a delay here
            // Put your code which should be executed with a delay here
            guard let _ = Auth.auth().currentUser?.uid else{
                self.signupSpinner.stopAnimating()
                self.displayMessage(title: "Couldn't Sign-Up", message: "Email or Password maybe Invalid")
                return
                
            }
            //self.performSegue(withIdentifier: "signupHomeSegue", sender: self)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let gameDetails = storyboard.instantiateViewController(withIdentifier: "homePage") as! HomePageViewController
            self.navigationController?.pushViewController(gameDetails, animated: false)
            return
        }
        
    }
    
    //this function is used to print any alerts to the user.
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message,
         preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // should perform method to perform the segue only if an account was created successfully.
    /*override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "signupHomeSegue"{
            return false
        }
        
        
        return false
        
    }*/

    
    
    

}
