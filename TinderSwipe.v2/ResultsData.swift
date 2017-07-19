//
//  ResultsData.swift
//  TinderSwipe.v2
//
//  Created by cssummer17 on 7/18/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import Foundation
import Firebase

class ResultsData: NSObject {
    
    // Initialize an instance of the ResultsData object
    static let sharedResultsData = ResultsData()
    
    // Declare class variables
    var masterSwipeArray = [Int]() // the master swipe array that compiles the number of yes swipes for each card in the deck in an array, for a specific group
    
    
    
    // FUNCTIONS that handle the swipe results
    
    // populateInitialMasterSwipeArray initializes the masterSwipeArray everytime a group/event is created.
    // Upon initialization, masterSwipeArray is an Int array consisting of all 0s, with the number of elements determined by the size of the deck
    // called in inviteFriendsVC
    func populateInitialMasterSwipeArray() {
        
        for i in 0...(DataManager.sharedData.deck.count - 1) {
            self.masterSwipeArray.append(0)
        }
        print("INITIAL MASTERSWIPEARRAY: ", self.masterSwipeArray)
        
    }
    
    
    // getCurrentMasterSwipeArray queries the database under myGroups/<current group id> and sets the masterSwipeArray variable in this class as the current masterSwipeArray
    func getCurrentMasterSwipeArray() {
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("myGroups/\(DataManager.sharedData.individualGroupID)/masterSwipeArray").observeSingleEvent(of: .value, with: { (DataSnapshot) in
            
            let masterSwipeArrayInNSArrayForm = DataSnapshot.value as! NSArray
            
            var tempMasterSwipeArray = [Int]()
            
            for cardIndexInMasterSwipeArray in 0...(DataManager.sharedData.swipes.count - 1) {
                
                let currentCardSwipeValue = masterSwipeArrayInNSArrayForm[cardIndexInMasterSwipeArray]
                tempMasterSwipeArray.append(currentCardSwipeValue as! Int)
                
            }
        
        print("tempMasterSwipeArray: ", tempMasterSwipeArray)
    
        self.masterSwipeArray = tempMasterSwipeArray
            
        }, withCancel: nil)
        
    }
    
    
    // updateMasterSwipeArray updates the masterSwipeArray in the database, updating the current masterSwipeArray stored in this class based on the swipes array stored in the DataManager class
    // NOTE: getCurrentMasterSwipeArray() has to be called right before this function (possibly with a delay), so that the masterSwipeArray is updated
    //       as the latest masterSwipeArray from the database
    func updateMasterSwipeArray() {
        
        print("current masterSwipeArray before update: ", self.masterSwipeArray)
        
        for cardIndexInDeck in 0...(DataManager.sharedData.swipes.count - 1) {
            
            if DataManager.sharedData.swipes[cardIndexInDeck] == 0 {
                self.masterSwipeArray[cardIndexInDeck] += 0 // make sure masterSwipeArray is updated as the latest version, by calling getCurrentMasterSwipeArray()
            }
            
            else {
                self.masterSwipeArray[cardIndexInDeck] += 1 // make sure masterSwipeArray is updated as the latest version, by calling getCurrentMasterSwipeArray()
            }
        }
        
        print("updated masterSwipeArray: ", self.masterSwipeArray)
        
        // once masterSwipeArray is updated with swipe information from DataManager.sharedData.swipes, upload the updated masterSwipeArray to the database
        var refMyGroupsIndividualID: DatabaseReference!
        refMyGroupsIndividualID = Database.database().reference().child("myGroups/\(DataManager.sharedData.individualGroupID)/masterSwipeArray")
        
        var masterSwipeArrayUploadDict: [String: Any]
        
        masterSwipeArrayUploadDict = ["masterSwipeArray": self.masterSwipeArray]
        
        refMyGroupsIndividualID.setValue(self.masterSwipeArray)

    }
    
    // END OF CLASS
}
