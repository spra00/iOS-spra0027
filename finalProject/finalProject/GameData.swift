//
//  GameData.swift
//  finalProject
//  This class is used to store the decoded game data
//  Created by Shakthi  Prashanth champaka on 16/5/2022.
//

import Foundation
import Firebase

class GameData{
    var gameDict = [[String : Any]]()
    
    func getGamesList() async{
        //this method is used to get games list from the gamesList collection in the firebase
        //perform asyn call in non-main thread.
        let db = Firestore.firestore()
        db.collection("gameList").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
                } else {
                    for document in querySnapshot!.documents {
                        //gameData.append(document.data())
                        let myDict = document.data()
                        self.gameDict.append(myDict)
                    }
                }
        }
            
    }

    
    
}
