//  GroupInfo.swift
//  TinderSwipe.v2
//
//  Created by cssummer17 on 7/10/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import Foundation
import Firebase

class GroupInfo: NSObject {
    
    // FUNCTIONS REQUIRED TO LOAD AND DISPLAY GROUP INFORMATION FOR THE USER THAT IS CURRENTLY LOGGED IN, IN SeeGroupsVC
    
    // Declare global variables
    static let sharedGroupInfo = GroupInfo()
    var groupIDs = [String]()
    var groupNames = [String]()
    var groupMembers = [[String]]()
    var allDecks = [[[String]]]()
    
    // variables to handle segue from SeeGroupsVC to swipeVC/resultVC
    var fetchedSwipeArray = [Int]()
    
    func loadGroupIDs() { // Put IDs into group IDs array.
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("users/\(Auth.auth().currentUser!.uid)/groupsAssociatedWith").observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                if let childRef = child as? DataSnapshot {
                    self.groupIDs.append(childRef.key)
                }
            }
            print("Here are the IDs of groups you are in. \(self.groupIDs)")
        }) {(error) in
            print(error.localizedDescription)
        }
    }
    
    func loadGroupNames() {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        for individualID in groupIDs {
            ref.child("myGroups").child(individualID).observeSingleEvent(of: .value, with: { (DataSnapshot) in
                if let dictionary = DataSnapshot.value as? [String: AnyObject] {
                    let eventName = (dictionary["event name"] as? String)!
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                        self.groupNames.append(eventName)
                    }
                }
            }, withCancel: nil)
        }
    }
    
    func loadGroupMembers() -> [[String]]{
        var ref: DatabaseReference!
        ref = Database.database().reference()
        for individualID in groupIDs {
            var members = [String]()
            ref.child("myGroups").child(individualID).child("members").observeSingleEvent(of: .value, with: { (DataSnapshot) in
                for child in DataSnapshot.children {
                    if let childRef = child as? DataSnapshot {
                        members.append(childRef.key)
                    }
                }
                print("printing members: ", members)
                self.groupMembers.append(members)
                members = []
            }, withCancel: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            print("printing group members: ", self.groupMembers)
        }
        return self.groupMembers
    }
    
    func loadDecks() {
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        // START OF LOOP FOR 1 GROUP ID
        for individualID in groupIDs {
            
            var sizeOfCurrentDeck = 0
            
            let uid = Auth.auth().currentUser?.uid
            
            ref.child("users/\(uid!)/groupsAssociatedWith/\(individualID)").observeSingleEvent(of: .value, with: { (DataSnapshot) in
                print("CURRENT UID: ", uid)
                
                let dictionary = DataSnapshot.value as? [String: Any]
                print("DATASNAP DICTIONARY: ", dictionary)
                
                sizeOfCurrentDeck = dictionary?["deck size"] as! Int
                
            }, withCancel: nil)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0){
                print("SIZE OF THE CURRENT DECK: ", sizeOfCurrentDeck)
                
                ref.child("users/\(Auth.auth().currentUser!.uid)/groupsAssociatedWith/\(individualID)/deck").observeSingleEvent(of: .value, with: { (DataSnapshot) in
                    
                    let deckInNSArrayForm = DataSnapshot.value as! NSArray
                    
                    var cardInfo: NSArray = []
                    var deckInfo = [[String]]()
                    
                    print("sizecount:::: ", sizeOfCurrentDeck)
                    
                    for cardIndexInDeck in 0...(sizeOfCurrentDeck - 1) {
                        cardInfo = deckInNSArrayForm[cardIndexInDeck] as! NSArray
                        print("INFO FOR ONE CARD: ", cardInfo)
                        deckInfo.append(cardInfo as! Array)
                    }
                    
                    print("INFO FOR ONE DECK: ", deckInfo)
                    
                    self.allDecks.append(deckInfo)
                    deckInfo = [[]] // resets deckInfo after storing, since deckInfo is different for different group IDs
                    
                }, withCancel: nil)
            }
        }
    }
    
    
    
    // FUNCTIONS REQUIRED TO COMPILE AND UPLOAD SWIPE RESULTS ONTO FIREBASE
    
    
    func getSwipeArray() {
        
        var ref: DatabaseReference
        ref = Database.database().reference()
        var tempFetchedSwipeArray = [Int]()
        
        print("fetch swipe array userID", Auth.auth().currentUser!.uid)
        print("fetch swipe array groupID", DataManager.sharedData.individualGroupID)
        
        ref.child("users/\(Auth.auth().currentUser!.uid)/groupsAssociatedWith/\(DataManager.sharedData.individualGroupID)/swipeArray").observeSingleEvent(of: .value, with: { (DataSnapshot) in
            
            let fetchedSwipeArrayInNSArrayForm = DataSnapshot.value as! NSArray
            
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                
                var currentSwipeValue: Int
                
                for swipeIndex in 0...(fetchedSwipeArrayInNSArrayForm.count - 1) {
                    
                    currentSwipeValue = fetchedSwipeArrayInNSArrayForm[swipeIndex] as! Int
                    tempFetchedSwipeArray.append(currentSwipeValue)
                }
                print("FETCHED SWIPE ARRAY: ", tempFetchedSwipeArray)
                
                self.fetchedSwipeArray = tempFetchedSwipeArray
            }
            
        }, withCancel: nil)
    }
    
    func checkSwipeArray() -> Bool { //true when swiped
        
        var dummySwipeArray = [Int]() // dummySwipeArray is the default swipe array, containing all "x", depending on the size of the deck
        
        for i in 0...(DataManager.sharedData.deck.count - 1) {
            
            dummySwipeArray.append(999999999)
            
        }
        
        if self.fetchedSwipeArray == dummySwipeArray { //if all 999999999
            return false
        }
            
        else {
            return true
        }
    }
    
    
    
    // END OF CLASS
}
