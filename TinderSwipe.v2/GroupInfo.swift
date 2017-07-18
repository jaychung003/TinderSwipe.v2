//  GroupInfo.swift
//  TinderSwipe.v2
//
//  Created by cssummer17 on 7/10/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import Foundation
import Firebase

class GroupInfo: NSObject {
    
    // Declare global variables
    static let sharedGroupInfo = GroupInfo()
    var groupIDs = [String]()
    var groupNames = [String]()
    var groupMembers = [[String]]()
    var allDecks = [[[String]]]()
    var fetchedSwipeArray = [String]()
    var sizeOfSwipeArray = 0
    var fetchedDeckSize = 0 // this is the deck size of the group that is already created
    
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
            //self.loadGroupName()
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
                        //self.tableView.reloadData()
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
    
    func loadSwipes() {
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        print("currentuser uid   ", Auth.auth().currentUser!.uid)
        print("individual groupid ", DataManager.sharedData.individualGroupID)
        // START OF LOOP FOR 1 GROUP ID
        ref.child("users/\(Auth.auth().currentUser!.uid)/groupsAssociatedWith/\(DataManager.sharedData.individualGroupID)/swipeArray").observeSingleEvent(of: .value, with: { (DataSnapshot) in
            //print("DATASNAP: ", DataSnapshot)
            let swipeArrayInNSArrayForm = DataSnapshot.value as! NSArray
            //print("NS ARRAY SWIPE ARRAY: ", swipeArrayInNSArrayForm)
            print("deck count:::", DataManager.sharedData.deck.count)
            //print("deck::", DataManager.sharedData.deck)
            //print("all deck::", GroupInfo.sharedGroupInfo.allDecks)
            for swipeIndexInArray in 0...(DataManager.sharedData.deck.count - 1) {
                let currentSwipeResult = swipeArrayInNSArrayForm[swipeIndexInArray] as! NSString // cardInfo is the list of information for a card (contains 9 elements in total)
                self.fetchedSwipeArray.append(currentSwipeResult as! String)
            }
            print("FETCHED ARRAY: ", self.fetchedSwipeArray)
            print("SHAREDDATA DECK COUNT: ", DataManager.sharedData.deck.count)
        }, withCancel: nil)
        
    }
    
    func getSizeOfSwipeArray() {
        
        // Declare variable to return
        
        // Reference database
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("users/\(Auth.auth().currentUser!.uid)/groupsAssociatedWith/\(DataManager.sharedData.individualGroupID)/swipeArray").observeSingleEvent(of: .value, with: { (DataSnapshot) in
            print("DATASNAP: ", DataSnapshot)
            let swipeArrayInNSArrayForm = DataSnapshot.value as! NSArray
            print("NS ARRAY SWIPE ARRAY: ", swipeArrayInNSArrayForm)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                print("ns array count", swipeArrayInNSArrayForm.count)
                self.sizeOfSwipeArray = swipeArrayInNSArrayForm.count
                print("fetched ns array count", self.sizeOfSwipeArray)
            }
        }, withCancel: nil)
    }
    
    
    func getDeckSize() -> Int {
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        print("GROUP ID FOR getDeckSize", DataManager.sharedData.individualGroupID)
        ref.child("myGroups/\(DataManager.sharedData.individualGroupID)/deck size").observeSingleEvent(of: .value, with: { (DataSnapshot) in
            print("DECK SIZE DATASNAP: ", DataSnapshot)
            
            if let dictionary = DataSnapshot.value as? [String: AnyObject] {
                self.fetchedDeckSize = (dictionary["deck size"] as? Int)!
            }
            
            //let swipeArrayInNsArrayForm = DataSnapshot.value
            
            
        }, withCancel: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
            print("FETCHED DECK SIZE: ", self.fetchedDeckSize)
        }
        return self.fetchedDeckSize
    }
    
    
    
    // END OF CLASS
}
