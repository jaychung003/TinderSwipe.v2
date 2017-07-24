//
//  Group.swift
//  TinderSwipe
//
//  Created by cssummer17 on 6/29/17.
//  Copyright © 2017 cssummer17. All rights reserved.
///Users/cssummer17/Desktop/TeamJApp/TinderSwipe.v2/TinderSwipe.v2/GroupInfo.swift

import UIKit

class Group: NSObject {

    // An instance of a group object
    static let groupInstance = Group()
    
    var groupName: String!
    var listOfMembers: [String] = []
    var deck = DataManager.sharedData.deck

}
