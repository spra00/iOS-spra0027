//
//  ProfileViewController.swift
//  finalProject
//  This VC is used to mainly accomodates the change of password
//  Created by Shakthi  Prashanth champaka on 3/5/2022.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift


class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    
    let submitSpinner: UIActivityIndicatorView = {
        let loginSpinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        loginSpinner.translatesAutoresizingMaskIntoConstraints = false
        loginSpinner.hidesWhenStopped = true
        return loginSpinner
    }()
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Load the firebaseController
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        
        // Do any additional setup after loading the view.
        submitButton.addSubview(submitSpinner)
        submitSpinner.centerXAnchor.constraint(equalTo: submitButton.centerXAnchor).isActive = true
        submitSpinner.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor).isActive = true

    }
    
    
    @IBAction func changePassword(_ sender: Any) {
        
        //start animating the spin
        submitSpinner.startAnimating()
        
        //perform validations
        guard let oldPassword = oldPassword.text, let newPassword = newPassword.text else {
         return
            
        }
        
        if oldPassword.isEmpty || newPassword.isEmpty {
            
         var errorMsg = "Please ensure all fields are filled:\n"
            
         if oldPassword.isEmpty {
             
             errorMsg += "- Must provide the current password\n"
             
         }
            
         if newPassword.isEmpty {
             
             errorMsg += "- Must enter a new password"
         }
        
         displayMessage(title: "Fields Are Not Filled", message: errorMsg)
         self.submitSpinner.stopAnimating()
         return
        }
        
        
        let outcome = databaseController?.handlePasswordChange(email: (Auth.auth().currentUser?.email)!, oldPassword: oldPassword, newPassword: newPassword)
        
    
        //Wait untial user has logged in
        let seconds = 3.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            
            if outcome == true{
                self.submitSpinner.stopAnimating()
                self.confirmPasswordChange(title: "Password Change Sucessful", message: "Your Password was changed successfully!")
            }
        }
    }
    
    func confirmPasswordChange(title: String, message: String){
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Home Page", style: .default, handler: { _ in
        self.navigationController?.popViewController(animated: true)}))
    self.present(alertController, animated: true, completion: nil)
    }
    
    
    func displayMessage(title: String, message: String){
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
    self.present(alertController, animated: true, completion: nil)
    }
    
    

}
