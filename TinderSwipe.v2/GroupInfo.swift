//
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
    //var individualGroupID = String()
    
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
        
        for individualID in groupIDs {
            
            // START OF LOOP FOR 1 GROUP ID
            ref.child("myGroups").child(individualID).child("deck").observeSingleEvent(of: .value, with: { (DataSnapshot) in
                let deckInNSArrayForm = DataSnapshot.value as! NSArray
                
                // Declaration of local variables
                var cardInfo: NSArray = []
                var deckInfo = [[String]]()
                
                for cardIndexInDeck in 0...DataManager.sharedData.sizeCount {
                    cardInfo = deckInNSArrayForm[cardIndexInDeck] as! NSArray // cardInfo is the list of information for a card (contains 9 elements in total)
                    print("INFO FOR ONE CARD: ", cardInfo)
                    deckInfo.append(cardInfo as! Array)
                }
                
                print("INFO FOR ONE DECK: ", deckInfo)
                
                self.allDecks.append(deckInfo)
                deckInfo = [[]] // resets deckInfo after storing, since deckInfo is different for different group IDs
            }, withCancel: nil)
            // END OF LOOP FOR 1 GROUP ID
            
        }
        
    }
    

    
// END OF CLASS
}
    

