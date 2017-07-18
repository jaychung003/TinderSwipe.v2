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
    
    // getDeckSize obtains the size of the deck stored in Firebase under users/uid/groupsAssociatedWith/groupID
    // REQUIRES A DELAY OF 1s after this function is called
    func getDeckSize() {
        
        
        var sizeOfDeck = 0
        
        let uid = Auth.auth().currentUser?.uid
        
    }

    
    // uploadMasterSwipeArray uploads the swipe results onto Firebase, under the myGroups/<current group ID> tree
//    func uploadMasterSwipeArray() {
//        
//        var refMyGroupsIndividualID: DatabaseReference!
//        refMyGroupsIndividualID = Database.database().reference().child("myGroups/\(DataManager.sharedData.individualGroupID)")
//        
//        // sets the masterSwipeArray
//        self.masterSwipeArray =
//        
//        var masterSwipeArrayUploadDict: [String: Any]
//        
//        masterSwipeArrayUploadDict = ["masterSwipeArray": self.masterSwipeArray]
//        
//        refMyGroupsIndividualID.setValue(masterSwipeArrayUploadDict)
//    }
    
    
    
    
    
    
    
    
    
    
//    func uploadNewGroupWithMembers() {
//        
//        var databaseRef: DatabaseReference!
//        databaseRef = Database.database().reference() // sets up reference to the Firebase database
//        
//        // Create a dictionary memberDict with usernames as the keys and default boolean 'true' as the values. This is for easier access of data in future (unordered list instead of an ordered list)
//        
//        var memberDict = [String: Bool]()
//        
//        var cardDict = [String: Bool]()
//        
//        for member in group1.listOfMembers {
//            memberDict[member] = true
//        }
//        
//        print("MEMBER DICT: ", memberDict)
//        var groupInfo: [String: Any]
//        groupInfo = ["members": memberDict, "event name": DataManager.sharedData.eventName, "deck": DataManager.sharedData.deck, "deck size": DataManager.sharedData.deck.count]
//        var myGroupsReference = databaseRef.child("myGroups").childByAutoId()
//        myGroupsReference.setValue(groupInfo)
//        groupID = myGroupsReference.key
//        //GroupInfo.sharedGroupInfo.currentUserGroupID = groupID
//        print("printing groupID: ", groupID)
//
//        
//    }

    
    
    
    
    
    
    
    
    
    // END OF CLASS
}
