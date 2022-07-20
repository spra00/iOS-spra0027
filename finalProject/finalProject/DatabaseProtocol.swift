//
//  DatabaseProtocol.swift
//  Lab-03
//
//  Created by Shakthi  Prashanth champaka on 29/3/2022.
//

import Foundation
import Firebase

enum DatabaseChange {
 case add
 case remove
 case update
}


enum ListenerType {
 case users
 case all
}

protocol DatabaseListener: AnyObject {
 var listenerType: ListenerType {get set}
 func onUserChange(change: DatabaseChange, user: FirebaseAuth.User?)

}



protocol DatabaseProtocol: AnyObject {
    

func cleanup()
//Login and signup methods
func loginUser(email: String, password: String)
func signUpUser(email: String, password: String, name: String)
func signOutUser()
func handlePasswordChange(email: String, oldPassword: String, newPassword: String) -> Bool
    
//create a new game
func createNewGame(recordid: String, postcode: String, playground_name: String, suburb_name: String, gameName: String, numPlayers: String, dateTime: String, phoneNumber: String)

//add the game to the user
func updateGameToUser(recordid: String, postcode: String, playground_name: String, suburb_name: String, gameName: String, numPlayers: String, dateTime: String, phoneNumber: String)
}
