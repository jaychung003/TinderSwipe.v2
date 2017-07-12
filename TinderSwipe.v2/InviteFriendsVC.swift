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

    @IBAction func doneButtonClicked(_ sender: Any) {
        // update the groupsAssociatedWith for each member of the group that has just been created

        handleDoneInviting()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
        self.handleGroupFormation()
        }
    }
    
    var action = UIAlertAction()
    var alertView = UIAlertController()
    var allUsernames = [String]()
    
    // a dummy array, supposed to be swipeArray
    var swipeArray = [String]()
    
    func populateInitialArray() {
        
        for i in 0...DataManager.sharedData.sizeCount-1 {
            self.swipeArray.append("x")
        }
        print("SWIPEARRAY COUNT: ", self.swipeArray.count)
        print("SWIPEARRAY: ", self.swipeArray)

    }
    
    
    func handleGroupFormation() {
        //iterate through each member in group
        let ref = Database.database().reference()
        var uid: String!
        print("LISTOFMEMBERS: ", group1.listOfMembers)
        for member in group1.listOfMembers {

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
                    groupInfoForUserWithSwipes = ["swipeArray": self.swipeArray]
                    var referenceForID =  eachUserRef.child("\(self.groupID!)")
                    referenceForID.setValue(groupInfoForUserWithSwipes)



                    
                }
            }
            )


            
            
        }
    }
    
//    var databaseRef: DatabaseReference!
//    databaseRef = Database.database().reference() // sets up reference to the Firebase database
//    
//    // Create a dictionary memberDict with usernames as the keys and default boolean 'true' as the values. This is for easier access of data in future (unordered list instead of an ordered list)
//    
//    var memberDict = [String: Bool]()
//    
//    var cardDict = [String: Bool]()
//    
//    for member in group1.listOfMembers {
//    memberDict[member] = true
//    }
//    
//    print("MEMBER DICT: ", memberDict)
//    var groupInfo: [String: Any]
//    groupInfo = ["members": memberDict, "event name": DataManager.sharedData.eventName, "deck": DataManager.sharedData.deck]
//    var reference = databaseRef.child("myGroups").childByAutoId()
//    reference.setValue(groupInfo)
//    groupID = reference.key
//    print("printing groupID: ", groupID)
    
    
    
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
        
        for member in group1.listOfMembers {
            memberDict[member] = true
        }
            
        print("MEMBER DICT: ", memberDict)
        var groupInfo: [String: Any]
        groupInfo = ["members": memberDict, "event name": DataManager.sharedData.eventName, "deck": DataManager.sharedData.deck]
        var reference = databaseRef.child("myGroups").childByAutoId()
        reference.setValue(groupInfo)
        groupID = reference.key
        print("printing groupID: ", groupID)
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
        if groupMembers.contains(userNameField.text!) == true {
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
            
        //append entered username to the list if the textfield is not empty
        else {
            groupMembers.append(userNameField.text!)
            print(groupMembers)
            self.tableView.reloadData()
            userNameField.text = ""
            group1.listOfMembers = groupMembers
            print("group1.listOfMembers: ", group1.listOfMembers)
            
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
        cell.textLabel?.text = groupMembers[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMembers.count
    }
    
    override func viewDidLoad() {
        fetchUsernames()
        populateInitialArray()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            print("all users: ", self.allUsernames)
        }
    }
    
}
