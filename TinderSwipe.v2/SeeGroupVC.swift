//
//  SeeGroupVC.swift
//  loginPage2
//
//  Created by cssummer17 on 6/29/17.
//  Copyright © 2017 Julius Lauw. All rights reserved.
//

import UIKit
import Firebase

class SeeGroupVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    var groupIDs = [String]()
    var groupInfo = [String]()
    var groupInfoObject = GroupInfo() // initialize the groupInfo object
    var indexGroupID: Int = 0
    
    @IBOutlet weak var navBarUserName: UINavigationItem!
    
    @IBAction func createEvent(_ sender: Any) {
        print("event button clicked")
        handleCreateEvent()
    }
    @IBAction func logOut(_ sender: UIButton) {
        handleLogout()
    }
    
    override func viewDidLoad() {
        if checkIfUserLoggedIn() == true{
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfUserLoggedIn()
        //self.loadGroupIDs()
        GroupInfo.sharedGroupInfo.loadGroupIDs()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0){
        GroupInfo.sharedGroupInfo.loadGroupMembers()
        GroupInfo.sharedGroupInfo.loadDecks()
        }
        
        // NEED A 5 SECOND DELAY TO GENERATE THE 3-LEVEL ARRAY THAT INCLUDES ALL DECKS IN ALL GROUPS
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0){
            print("ALL DECKS IN ALL GROUPS: ", GroupInfo.sharedGroupInfo.allDecks)
        }
    }
    
//    func loadGroupIDs() { // Put IDs into group IDs array.
//        var ref: DatabaseReference!
//        ref = Database.database().reference()
//        ref.child("users/\(Auth.auth().currentUser!.uid)/groupsAssociatedWith").observeSingleEvent(of: .value, with: {(snapshot) in
//            for child in snapshot.children {
//                if let childRef = child as? DataSnapshot {
//                    self.groupIDs.append(childRef.key)
//                }
//            }
//            print("Here are the IDs of groups you are in. \(self.groupIDs)")
//        }) {(error) in
//            print(error.localizedDescription)
//        }
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
//        self.loadGroupNames()
//        }
//    }
    
    
//    func loadGroupNames() {
//        var ref: DatabaseReference!
//        ref = Database.database().reference()
//        for individualID in groupIDs {
//        ref.child("myGroups").child(individualID).observeSingleEvent(of: .value, with: { (DataSnapshot) in
//            if let dictionary = DataSnapshot.value as? [String: AnyObject] {
//                let eventName = (dictionary["event name"] as? String)!
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
//                self.groupInfo.append(eventName)
//                self.tableView.reloadData()
//                }
//            }
//        }, withCancel: nil)
//        }
//    }
//    
//    func loadGroupMembers() {
//        var ref: DatabaseReference!
//        ref = Database.database().reference()
//        for individualID in groupIDs {
//            var members = [String]()
//            ref.child("myGroups").child(individualID).child("members").observeSingleEvent(of: .value, with: { (DataSnapshot) in
//                for child in DataSnapshot.children {
//                    if let childRef = child as? DataSnapshot {
//                        members.append(childRef.key)
//                    }
//                }
//                
//                
//                
//            }, withCancel: nil)
//        }
//    }

    
    func checkIfUserLoggedIn() -> (Bool) {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            return false
        } else {
            // THIS IS HOW WE FETCH DATA FROM THE DATABASE!!!
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (DataSnapshot) in
                print(DataSnapshot)
                print(uid)
                if let dictionary = DataSnapshot.value as? [String: AnyObject] {
                    self.navBarUserName.title = (dictionary["name"] as? String)! + "'s groups"
                }
            }, withCancel: nil)
        return true
        }
    }
    
    func handleLogout() {
        
        do {
            try Auth.auth()
                .signOut()
        } catch let logoutError {
            print(logoutError)
        }
        performSegue(withIdentifier: "LogOutIdentifier", sender: self)
    }
    
    func handleCreateEvent() {
        performSegue(withIdentifier: "CreateEventIdentifier", sender: self)
    }
    
    
    // UITable functions
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("group info:", self.groupInfo)
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        cell.textLabel?.text = self.groupInfo[indexPath.row]
        cell.detailTextLabel?.text = self.groupIDs[indexPath.row]
        
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupInfo.count
    }
    
    
}
