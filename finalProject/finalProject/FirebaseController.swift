//
//  FirebaseController.swift
//  Lab-03
//  This is used to control firebase
//  Created by Shakthi  Prashanth champaka on 11/4/2022.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift


class FirebaseController: NSObject, DatabaseProtocol{

    var authController: Auth
    var currentUser: FirebaseAuth.User?
    var loginButtonClicked = false
    var loginOutcome = false
    var currentUserName: String?
    var gameDict = [[String : Any]]()
    let db :Firestore
    
    override init(){
        FirebaseApp.configure()
        authController = Auth.auth()
        db = Firestore.firestore()
        super.init()
    }
    
        
    //This method is used for login
    func loginUser(email: String, password: String){
        
        Task {
            
         do {
             
             let authDataResult = try await authController.signIn(withEmail: email, password: password)
             currentUser = authDataResult.user
             loginButtonClicked = true
             loginOutcome = true
         }
         catch let error {
                print(error)
         }
            
        }
    }
    
    //This method is used to create a new user account
    func signUpUser(email: String, password: String, name: String){
        
        
        Task {
            
         do {
             
             let authDataResult = try await authController.createUser(withEmail: email, password: password)
             currentUser = authDataResult.user
             currentUserName = name
             
             //add a new user to the collection.
             self.db.collection("userList").addDocument(data: [
                "name": name,
                "userID": currentUser?.uid as Any,
                "email": email,
                "gameCollection": []
             ]){ err in
             if let err = err {
                 print("Error writing document: \(err)")
             }
                 else {
                 print("Document successfully written!")
             }
                    
             }
                 
         }
         catch let error {
             print(error)
         }
        
        }
        
    }
    
    //This method is used to sign out the users from the app.
    func signOutUser(){
        
        Task {
            
         do {
             
             let _ = try authController.signOut()
         }
            catch let error {
                print(error)
            }
                    
        }
        
    }

    func cleanup(){
        //to be done
    }
    
    func handlePasswordChange(email: String, oldPassword: String, newPassword: String) -> Bool{
        
        let user = Auth.auth().currentUser
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
        
        var status = true
        
        
        user?.reauthenticate(with: credential, completion: { (result, error) in
           if let err = error {
               
               print(err)
               status = false
               
               
              //..read error message
           } else {
               
              //.. go on and update the password
               Auth.auth().currentUser?.updatePassword(to: newPassword)
           }
        })
        
        return status
    }
    
    func createNewGame(recordid: String, postcode: String, playground_name: String, suburb_name: String, gameName: String, numPlayers: String, dateTime: String, phoneNumber: String){
        
        
        guard let email = Auth.auth().currentUser?.email else{
            return
        }
        
        //add a new game to the collection.
        self.db.collection("gameList").addDocument(data: [
               "recordid": recordid,
               "creatorEmail": email,
               "postcode": postcode,
               "playground_name": playground_name,
               "suburb_name": suburb_name,
               "gameName": gameName,
               "numPlayers": numPlayers,
               "dateTime": dateTime,
               "phoneNumber": phoneNumber]){ err in
            if let err = err {
                print("Error writing document: \(err)")
            }
            else {
                print("Document successfully written!")
            }
                   
        }
    }
    
    
    
    func getGamesList() async{
          
        //perform asyn call in non-main thread.
        gameDict = [[String : Any]]()
        self.db.collection("userList").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                } else {
                    for document in querySnapshot!.documents {
                        let myDict = document.data()
                        if myDict["userID"] as? String == Auth.auth().currentUser?.uid{
                            
                            let game_collection = myDict["gameCollection"] as! Array<Any>
                            for game in game_collection{
                                self.gameDict.append(game as! [String : Any])
                                
                            }
                            
                        }

                    }
                }

        }
            
    }
    
    
        
    func updateGameToUser(recordid: String, postcode: String, playground_name: String, suburb_name: String, gameName: String, numPlayers: String, dateTime: String, phoneNumber: String){
        
        //first get the games
        Task{
            await self.getGamesList()
        }
        
        
        self.db.collection("userList").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    //if the user is the current user
                    if document.data()["userID"] as? String == Auth.auth().currentUser?.uid{
                        
                        let reference = self.db.collection("userList").document(document.documentID)
                        
                        guard let email = Auth.auth().currentUser?.email else{
                            return
                        }
                        
                        let myDict:[String:String] = [
                        "recordid": recordid,
                        "creatorEmail": email,
                        "postcode": postcode,
                        "playground_name": playground_name,
                        "suburb_name": suburb_name,
                        "gameName": gameName,
                        "numPlayers": numPlayers,
                        "dateTime": dateTime,
                        "phoneNumber": phoneNumber]
                        
                        
                        //Wait untial user has logged in
                        let seconds = 3.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                            self.gameDict.append(myDict)
                            reference.updateData([
                                "gameCollection": self.gameDict])
                        }
                        
                    }

                }
            }
        }
        
    }


}
 
