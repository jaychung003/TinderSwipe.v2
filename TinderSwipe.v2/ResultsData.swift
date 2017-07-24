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
    var sortedMasterSwipeArrayValue = [Int]() // the sorted master swipe array, in decreasing order, elements representing the yes counts for each card
    var sortedMasterSwipeArrayIndices = [Int]() // the sorted master swipe array, in decreasing order, elements representing the indices for each card from the original deck
    var sortedDeck = [[String]]() // the sorted deck, in the order determined by the variable sortedMasterSwipeArrayIndices
    
    
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
    
    
    // sortMasterSwipeArray sorts the masterSwipeArray in decreasing order of the number of yes counts for each card in the deck
    // updates the variables sortedMasterSwipeArrayValue and sortedMasterSwipeArrayIndices
    func sortMasterSwipeArray() {
        
        let sortedMasterSwipeArray = self.masterSwipeArray.enumerated().sorted(by: {$0.element > $1.element})
        self.sortedMasterSwipeArrayIndices = sortedMasterSwipeArray.map{$0.offset}
        self.sortedMasterSwipeArrayValue = sortedMasterSwipeArray.map{$0.element}
        
        print("Sorted by vote count: ", self.sortedMasterSwipeArrayValue)
        print("Sorted by original indices: ", self.sortedMasterSwipeArrayIndices)
        
    }
    
    
    // sortDeck sorts the original deck of cards in decreasing order of vote counts, based on the variable sortedMasterSwipeArrayIndices
    // NOTE: Make sure sortMasterSwipeArray is called before this function, so that sortedMasterSwipeArrayIndices is updated to the latest version after user has swiped
    // updates the variable sortedDeck
    func sortDeck() {
        
        for i in 0...(DataManager.sharedData.deck.count - 1) {
            
            let indexToRefFromDeck = sortedMasterSwipeArrayIndices[i]
            
            sortedDeck.append(DataManager.sharedData.deck[indexToRefFromDeck])
            
        }
        
        print("sorted deck in results data  ", sortedDeck)
        
        
    }
    
    
    
    // END OF CLASS
}
