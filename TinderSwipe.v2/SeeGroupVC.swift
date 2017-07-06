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
        //look for own username in groups
        self.lookUpGroups()
        self.loadGroupIDs()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfUserLoggedIn()
    }
    
    func lookUpGroups() {
        
        
//        // first, look for own username
//        var ref: DatabaseReference!
//        ref = Database.database().reference()
//        let queryUsername = ref.child(")
//        
    }
    
    
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
            
            // Load items into list.
            print("loading page...")
            //self.loadItems() // Load items after callback has happened.
            //self.loadGroupNames() // Less important to load names, but they exist. Call afterward
            //print(groupIDs)
            self.tableView.reloadData()
        }) {(error) in
            print(error.localizedDescription)
        }
    }
    
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
        print(self.groupIDs)
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        cell.textLabel?.text = self.groupIDs[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupIDs.count
    }
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
}
