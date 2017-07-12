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
    @IBOutlet weak var navBarUserName: UINavigationItem!
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Don't do anything if the user isn't logged in yet,
        // instead, transition to the login screen
        if !checkIfUserLoggedIn() {
            return
        }
        clearAllGroupInfo()
        while GroupInfo.sharedGroupInfo.groupIDs == nil {
            print("Group IDs is NIL")

            GroupInfo.sharedGroupInfo.loadGroupIDs()
        }
            GroupInfo.sharedGroupInfo.loadGroupIDs()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
                print("PRINT GROUPIDS: ", GroupInfo.sharedGroupInfo.groupIDs)

                GroupInfo.sharedGroupInfo.loadGroupNames()
                GroupInfo.sharedGroupInfo.loadGroupMembers()
                GroupInfo.sharedGroupInfo.loadDecks()
                self.tableView.reloadData()
            }
            
            // NEED A 5 SECOND DELAY TO GENERATE THE 3-LEVEL ARRAY THAT INCLUDES ALL DECKS IN ALL GROUPS
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0){
                print("ALL DECKS IN ALL GROUPS: ", GroupInfo.sharedGroupInfo.allDecks)
                self.tableView.reloadData()
                
            }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfUserLoggedIn()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        checkIfUserLoggedIn()
        self.tableView.reloadData()
        
    }
    
    
    //when create event button clicked
    @IBAction func createEvent(_ sender: Any) {
        print("event button clicked")
        handleCreateEvent()
    }
    func handleCreateEvent() {
        performSegue(withIdentifier: "CreateEventIdentifier", sender: self)
    }
    
    //when log out button clicked
    @IBAction func logOut(_ sender: UIButton) {
        handleLogout()
    }
    func handleLogout() {
        print("handling logout")
        do {
            try Auth.auth()
                .signOut()
        } catch let logoutError {
            print(logoutError)
        }
        performSegue(withIdentifier: "LogOutIdentifier", sender: self)
    }
    
    func clearAllGroupInfo() {
        GroupInfo.sharedGroupInfo.groupIDs = [String]()
        GroupInfo.sharedGroupInfo.groupNames = [String]()
        GroupInfo.sharedGroupInfo.groupMembers = [[String]]()
        GroupInfo.sharedGroupInfo.allDecks = [[[String]]]()
    }
    
    func checkIfUserLoggedIn() -> (Bool) {
        if Auth.auth().currentUser?.uid == nil {
            print("User not logged in.")
            handleLogout()
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
   
    
// UITable functions
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("group name:", GroupInfo.sharedGroupInfo.groupNames)
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        cell.textLabel?.text = GroupInfo.sharedGroupInfo.groupNames[indexPath.row]
        
        var stringArray =  GroupInfo.sharedGroupInfo.groupMembers[indexPath.row]
        var string = stringArray.joined(separator: " ")
        print("stringArray", stringArray)
        print("string  ", string)
        cell.detailTextLabel?.text = string
        return cell
    }
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("groupNames count:::", GroupInfo.sharedGroupInfo.groupNames.count)
        return GroupInfo.sharedGroupInfo.groupNames.count
    }
    
    //when tableview cell clicked, go to Swipe VC or Result VC
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DataManager.sharedData.deck = GroupInfo.sharedGroupInfo.allDecks[indexPath.row]
        print("DECK FOR THE GROUP CLICKED: ", DataManager.sharedData.deck)
        
        performSegue(withIdentifier: "SeeGroupToSwipeIdentifier", sender: self)
    }
    
}
