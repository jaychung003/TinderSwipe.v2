//
//  InviteFriendsVC.swift
//  TinderSwipe
//
//  Created by cssummer17 on 6/30/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class InviteFriendsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let group1 = Group()
    var groupMembers = Group().listOfMembers
    var listOfGroups = [String]()
    var groupID: String!
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func addButtonClicked(_ sender: Any) {
        handleAddButton()
    }

    @IBAction func doneButtonClicked(_ sender: UIButton) {
    
        // update the groupsAssociatedWith for each member of the group that has just been created
        
        appendCurrentUsername() // appends current username to the current list of members
        DataManager.sharedData.groupResultDenominator = String(Group.groupInstance.listOfMembers.count)
        print("listOfMembers finally apended with current user: ", Group.groupInstance.listOfMembers)
        handleDoneInviting()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
        self.handleGroupFormation()
        }
    }
    
    var action = UIAlertAction()
    var alertView = UIAlertController()
    var allUsernames = [String]()
    
    // a dummy array, supposed to be swipeArray
    var swipeArray = [Int]()
    
    // appendCurrentUsername appends the current username to Group.groupInstance.listOfMembers once the full group is created
    func appendCurrentUsername() {
        Group.groupInstance.listOfMembers.append(DataManager.sharedData.currentUsername)
    }
    
    func populateInitialArray() {
        
        for i in 0...DataManager.sharedData.sizeCount-1 {
            self.swipeArray.append(999999999)
        }
        print("SWIPEARRAY COUNT: ", self.swipeArray.count)
        print("SWIPEARRAY: ", self.swipeArray)
        GroupInfo.sharedGroupInfo.fetchedSwipeArray = self.swipeArray
    }
    
    
    func handleGroupFormation() {
        //iterate through each member in group
        let ref = Database.database().reference()
        var uid: String!
        print("LISTOFMEMBERS: ", Group.groupInstance.listOfMembers)
        for member in Group.groupInstance.listOfMembers {

            //find the matching uid for each username
            let usersRef = ref.child("users")
            
            let queryRef = usersRef.queryOrdered(byChild: "username")
                .queryEqual(toValue: member)
            queryRef.observeSingleEvent(of: .value, with: { (snapshot) in
                for snap in snapshot.children {
                    let userSnap = snap as! DataSnapshot
                    uid = userSnap.key
                    let userDict = userSnap.value as! [String:AnyObject]
                    print("uid:", uid)
                    
//                    var groupDict = [String: Bool]()
//                    print(uid)
//                    print("groupID:", self.groupID)
//                    ref.child("users/\(uid!)/groupsAssociatedWith/\(self.groupID!)").setValue(true)
                    
                    //for members of the group, make a new branch groupsAssociatedWith
                    let eachUserRef = usersRef.child("\(uid!)/groupsAssociatedWith")
                    var groupInfoForUserWithSwipes: [String: Any]
                    groupInfoForUserWithSwipes = ["swipeArray": self.swipeArray, "deck": DataManager.sharedData.deck, "deck size": DataManager.sharedData.deck.count, "yes deck": ["default yes deck"]]
                    var referenceForID =  eachUserRef.child("\(self.groupID!)")
                    referenceForID.setValue(groupInfoForUserWithSwipes)
                    DataManager.sharedData.individualGroupID = self.groupID
                    
                }
            }
            )
        }
    }
    
    
    func handleDoneInviting() {
        //upload data to database to share with the group
        handleDeckCreating()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
        self.uploadNewGroupWithMembers()
        self.performSegue(withIdentifier: "DoneInvitingIdentifier", sender: self)
        }
    }
    
    func handleDeckCreating() {
        DataManager.sharedData.makeInputLocationURL()
        let url = DataManager.sharedData.urlHERE
        DataManager.sharedData.request = NSMutableURLRequest(url: URL(string: url)!)
        DataManager.sharedData.getJSONData()
        
        // while statement allows for time for fullJson to populate
        
        while DataManager.sharedData.fullJson == nil {
        }
        DataManager.sharedData.getResultJson(indexRestaurant: DataManager.sharedData.indexRestaurant)
    }
    
    func uploadNewGroupWithMembers() {
        
        var databaseRef: DatabaseReference!
        databaseRef = Database.database().reference() // sets up reference to the Firebase database
        
        // Create a dictionary memberDict with usernames as the keys and default boolean 'true' as the values. This is for easier access of data in future (unordered list instead of an ordered list)
        
        var memberDict = [String: Bool]()
        
        var cardDict = [String: Bool]()
        
        for member in Group.groupInstance.listOfMembers {
            memberDict[member] = true
        }
        
        // initialize the masterSwipeArray
        ResultsData.sharedResultsData.populateInitialMasterSwipeArray()
            
        print("MEMBER DICT: ", memberDict)
        var groupInfo: [String: Any]
        groupInfo = ["members": memberDict, "event name": DataManager.sharedData.eventName, "deck": DataManager.sharedData.deck, "deck size": DataManager.sharedData.deck.count, "masterSwipeArray": ResultsData.sharedResultsData.masterSwipeArray]
        var myGroupsReference = databaseRef.child("myGroups").childByAutoId()
        myGroupsReference.setValue(groupInfo)
        groupID = myGroupsReference.key
        DataManager.sharedData.individualGroupID = myGroupsReference.key
        //GroupInfo.sharedGroupInfo.currentUserGroupID = groupID
        print("printing individualGroupID: ", DataManager.sharedData.individualGroupID)
        
    }
    
    func handleAddButton() {
//        print("groupMembers: ", groupMembers)
        //pop up an error message if nothing is typed in
        if userNameField.text == "" {
            alertView = UIAlertController(title: "Invalid Username", message: "Please put in a valid username", preferredStyle: .alert)
            action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in })
            alertView.addAction(action)
            self.present(alertView, animated: true, completion: nil)
            return
        }
        //pop up an error message if username is already a group member
        if Group.groupInstance.listOfMembers.contains(userNameField.text!) == true {
            alertView = UIAlertController(title: "Invalid Username", message: "The user is already in your group!", preferredStyle: .alert)
            action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in })
            alertView.addAction(action)
            self.present(alertView, animated: true, completion: nil)
            return
        }
        
        //pop up an error message if username is not registered
        if allUsernames.contains(userNameField.text!) == false {
            alertView = UIAlertController(title: "Invalid Username", message: "Please put in a valid username", preferredStyle: .alert)
            action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in })
            alertView.addAction(action)
            self.present(alertView, animated: true, completion: nil)
            return
        }
        
        // pop up an error message if username is the same
        if userNameField.text == DataManager.sharedData.currentUsername {
            alertView = UIAlertController(title: "You're already in the group!", message: "Please put in your friend's username", preferredStyle: .alert)
            action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in })
            alertView.addAction(action)
            self.present(alertView, animated: true, completion: nil)
            return
        }
            
        //append entered username to the list if the textfield is not empty
        else {
            
            //changes
            
            Group.groupInstance.listOfMembers.append(userNameField.text!)
            print("updated listOfMembers: ", Group.groupInstance.listOfMembers)
            userNameField.text = ""
            self.tableView.reloadData()
            
        }
    }
    
        func fetchUsernames() -> [String] {
            Database.database().reference().child("users").observe(.childAdded, with: { (DataSnapshot) in
    
                if let dictionary = DataSnapshot.value as? [String: AnyObject] {
                    print("Datasnapshot:  ", DataSnapshot)
                    print("dictionary: ", dictionary)
                    self.allUsernames.append(dictionary["username"] as! String)
                }
            }
                , withCancel: nil)
            return allUsernames
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usernameCell", for: indexPath)
        cell.textLabel?.text = Group.groupInstance.listOfMembers[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Group.groupInstance.listOfMembers.count
    }
    
    override func viewDidLoad() {
        fetchUsernames()
        populateInitialArray()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            print("all users: ", self.allUsernames)
        }
    }
    
}
