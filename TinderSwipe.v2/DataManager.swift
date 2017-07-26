//
//  DataManager.swift
//  TinderSwipe
//
//  Created by cssummer17 on 6/27/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation

let client_id = "ATKKYJPOH2QICUOFJIPDB4ADPYMX0QCUH4PSC5W1AWPQETNI" // visit developer.foursqure.com for API key
let client_secret = "OX4X2U05FUO11RIPB0D1Y4CJCOV0ESFA1YW4UH5EEQDIPMZD" // visit developer.foursqure.com for API key

class DataManager: NSObject {
    static let sharedData = DataManager()
    
    //initial variables for user input
    var venueType = ""
    var eventDate = ""
    var eventTime = ""
    var eventDateAndTime = ""
    var eventName = ""
    var eventCity = ""
    var eventState = ""
    var URLtoPass = String()
    var URLtoPassNoSpace = ""
    var urlHERE = ""
    var myCurrentLocation = CLLocationCoordinate2D()
    var eventType = ["Food","Breakfast","Brunch","Lunch","Coffee","Dinner","Dessert","Drinks"]
    
    var PriceAndTier = String()
    var llURL = ""
    
    //variables for creating JSON file
    let session = URLSession.shared
    var request: NSMutableURLRequest?
    
    //price array variable
    var priceArray:[Int] = []
    
    // variables for full JSON file
    var fullJson: AnyObject?
    var resultJson: AnyObject?
    var indexRestaurant: Int = 0
    var specificRestaurant: NSDictionary?
    
    // variables for each piece of information
    var JSONname: String!
    var JSONLocationType: String!
    var JSONLocationAddress: String!
    var JSONLocationCity: String!
    var JSONRating: String!
    var JSONPrice: String!
    var storeImageURLString = "" // variable to store image url prefix, dimensions, suffix, combined
    var JSONMenuID: String!
    var JSONHasMenu = ""
    var JSONMenuURL = ""
    var JSONTier: Int!
    
    var JSONPhoneNumberString: String!
    var arraySize = 0
    var sizeCount = 0
    var cardTierValue = 0
    
    // variables for data structures, card and deck
    var card = [String]() // an array of strings
    var deck = [[String]]() // an array of cards
    var swipes = [Int]() //an array of YES or NO swipes
    var yesDeck = [[String]]() //an array of cards with YES swipes
    var individualGroupID = String()
    var groupResultDenominator = String()
    
    // miscellaneous variables
    var currentUsername = "" // a string storing a reference to the username of the current user
    
    // variables in InviteFriends VC
    var allUsernames = [String]()
    
    //Calls to server to get Foursquare data and returns the full file as myJson5
    func getJSONData()
    {
        let task = session.dataTask(with: request! as URLRequest) {(data, response, error) in
            let content = data!
            do
            {
                let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                self.fullJson = myJson
            }
            catch
            {
            }
        }
        task.resume()
    }
    
    // gets the top level of the JSON file that is the same for all of the restaurants (before specific). Leaves us with a Specific5 value
    func getResultJson(indexRestaurant: Int) -> NSDictionary
    {
        if let JSONResponse = fullJson?["response"] as? NSDictionary
        {
            if let JSONGroup = JSONResponse["group"] as? NSDictionary
            {
                if let JSONResult = JSONGroup["results"] as? NSArray
                {
                    specificRestaurant = JSONResult[indexRestaurant] as? NSDictionary
                    arraySize = JSONResult.count
                }
            }
        }
        return specificRestaurant!
    }
    
    func addRemoveValue(dollarSignValue: Int)
    {
        if (priceArray.contains(dollarSignValue))
        {priceArray = priceArray.filter
            {
                $0 != dollarSignValue
                
            }
            print(priceArray)
        }
        else{
            priceArray.append(dollarSignValue)
            print(priceArray)
        }
    }
    
    
    //creates Deck
    func createDeck() -> [[String]]
    {   findSize()
        var count = 0
        while count < sizeCount
        {
            getResultJson(indexRestaurant: indexRestaurant)
            getPrice()
            if priceArray.contains(cardTierValue)
            {
                getJSONVenueID()
                setName()
                setLocationType()
                setLocationAddress()
                setLocationCity()
                setRating()
                setPrice()
                setImageURL()
                setMenuID()
                setHasMenu()
                setPhoneNumber()
                deck.append(card)
                count = count + 1
                // reset card and imageURL
                resetCard()
                resetImageURL()
            }
            indexRestaurant = indexRestaurant + 1
        }
        
        // print user input information
        print("eventCity: ", eventCity)
        print("eventState: ", eventState)
        print("venueType: ", venueType)
        print("urlHERE: ", urlHERE)
        
        
        
//        var venueType = ""
//        var eventDate = ""
//        var eventTime = ""
//        var eventDateAndTime = ""
//        var eventName = ""
//        var eventCity = ""
//        var eventState = ""
//        var URLtoPass = String()
//        var URLtoPassNoSpace = ""
//        var urlHERE = ""
//        var myCurrentLocation = CLLocationCoordinate2D()
//        var eventType = ["Food","Breakfast","Brunch","Lunch","Coffee","Dinner","Dessert","Drinks"]
        
        
        
        //print the JSON information
        print("JSONname: ", JSONname)
        print("JSONLocationType: ", JSONLocationType)
        print("JSONLocationAddress: ", JSONLocationAddress)
        print("JSONLocationCity: ", JSONLocationCity)
        print("JSONRating: ", JSONRating)
        print("JSONPrice: ", JSONPrice)
        print("storeImageURLString: ", storeImageURLString)
        print("JSONMenuID: ", JSONMenuID)
        print("JSONHasMenu: ", JSONHasMenu)
        print("JSONMenuURL: ", JSONMenuURL)
        print("JSONTier: ", JSONTier)
        
//        var JSONname: String!
//        var JSONLocationType: String!
//        var JSONLocationAddress: String!
//        var JSONLocationCity: String!
//        var JSONRating: String!
//        var JSONPrice: String!
//        var storeImageURLString = "" // variable to store image url prefix, dimensions, suffix, combined
//        var JSONMenuID: String!
//        var JSONHasMenu = ""
//        var JSONMenuURL = ""
//        var JSONTier: Int!
        
        priceArray = []
        print("This is the deck from data manager:", deck)
        return deck
    }
    
    func findSize()
    {   while indexRestaurant < (arraySize - 1)
    {   getResultJson(indexRestaurant: indexRestaurant)
        getPrice()
        if priceArray.contains(cardTierValue)
        {sizeCount = sizeCount + 1 }
        indexRestaurant = indexRestaurant + 1
        }
        print("SIZE COUNT: ", sizeCount)
        indexRestaurant = 0
    }
    
    func getJSONVenueID() -> String
    {
        getMenuID()
        print("Try this as the id:", JSONMenuID)
        return ""
    }
    
    //takes user input location and generates foursquare url
    func makeInputLocationURL()  {
        URLtoPass =  "https://api.foursquare.com/v2/search/recommendations?near=\(eventCity),\(eventState)&v=20160607&intent=\(venueType)&limit=15&client_id=\(client_id)&client_secret=\(client_secret)"
        URLtoPassNoSpace = URLtoPass.replacingOccurrences(of: " ", with: "_", options: .literal, range: nil)
        urlHERE = URLtoPassNoSpace
        print("This is url from input", urlHERE)
        print("This is url from INPUT", urlHERE)
    }
    
    func makeMyLocationURL()
    {
        urlHERE = "https://api.foursquare.com/v2/search/recommendations?ll=\(myCurrentLocation.latitude),\(myCurrentLocation.longitude)&v=20160607&intent=\(venueType)&limit=15&client_id=\(client_id)&client_secret=\(client_secret)"
        print("This is url from current location", urlHERE)
        
    }
    
    func resetCard()
    {
        card = []
    }
    
    func getLocationType() -> String
    {if let JSONVenue = specificRestaurant?["venue"] as? NSDictionary
    {
        if let JSONResponse = JSONVenue["categories"] as? NSArray
        {
            if let CategoryName = JSONResponse[0] as? NSDictionary
            {
                JSONLocationType = CategoryName["name"] as! String
            }
            if JSONLocationType == nil
            {
                print("is this printing?")
                JSONLocationType = "N/A"
                return JSONLocationType
            }
            
        }
        
        }
        return JSONLocationType!
    }
    
    func setLocationType()
    {
        card.append(getLocationType())
        
    }
    
    func getName() -> String
    {
        if let JSONVenue = specificRestaurant?["venue"] as? NSDictionary
        {
            JSONname = JSONVenue["name"] as! String
        }
        if JSONname == nil
        {
            JSONname = "N/A"
            return JSONname
        }
        return JSONname!
    }
    
    func setName()
    {
        card.append(getName())
    }
    
    func getLocationAddress() -> String
    {
        if let JSONVenue = specificRestaurant?["venue"] as? NSDictionary
        {
            if let JSONLocation = JSONVenue["location"] as? NSDictionary
            {
                JSONLocationAddress = JSONLocation["address"] as? String
            }
        }
        if JSONLocationAddress == nil
        {
            JSONLocationAddress = "N/A"
            return JSONLocationAddress
        }
        return JSONLocationAddress
    }
    
    func setLocationAddress()
    {
        card.append(getLocationAddress())
    }
    
    func getLocationCity() -> String
    {
        if let JSONVenue = specificRestaurant?["venue"] as? NSDictionary
        {
            print(JSONVenue)
            if let JSONLocation = JSONVenue["location"] as? NSDictionary
            {
                print(JSONLocation)
                JSONLocationCity = JSONLocation["city"] as? String
                print("City of current search:", JSONLocationCity)
            }
            if JSONLocationCity == nil
            {
                JSONLocationCity = "N/A"
                return JSONLocationCity
            }
        }
        return JSONLocationCity!
    }
    
    func setLocationCity()
    {
        card.append(getLocationCity())
    }
    
    func getRating() -> String
    {
        if let JSONVenue = specificRestaurant?["venue"] as? NSDictionary
        {
            if let JSONRatingDouble = JSONVenue["rating"] as? Double
            {
                JSONRating = String(JSONRatingDouble)
                
            }
            
        }
        if JSONRating == nil
        {
            JSONRating = "N/A"
            return JSONRating
        }
        return JSONRating
        
    }
    
    func setRating()
    {
        card.append(getRating())
    }
    
    func getPrice() -> String
    {
        if let JSONVenue = specificRestaurant?["venue"] as? NSDictionary
        {
            if let JSONPriceGeneral = JSONVenue["price"] as? NSDictionary
            {
                JSONTier = JSONPriceGeneral["tier"] as? Int
                cardTierValue = JSONTier
                print("JSONTIER is: ", JSONTier)
            }
        }
        if JSONPrice == nil || JSONTier == nil
        {
            JSONPrice = "N/A"
            //Let's say that any venue without a tier is a 1
            JSONTier = 1
        }
        print("cardTierValue:", cardTierValue)
        for numbers in 1...cardTierValue
        {
            PriceAndTier = PriceAndTier + "$"
        }
        print("Price and Tier to be Returned", PriceAndTier)
        return (PriceAndTier)
    }
    
    func setPrice()
    {
        PriceAndTier = ""
        JSONTier = 1
        card.append(getPrice())
    }
    
    
    
    func getImageURL() -> String
    {
        if let JSONPhoto = specificRestaurant?["photo"] as? NSDictionary
        {
            if let JSONPrefix = JSONPhoto["prefix"] as? String
            {
                storeImageURLString = storeImageURLString + JSONPrefix + "480x400"
            }
            if let JSONSuffix = JSONPhoto["suffix"] as? String
            {
                storeImageURLString = storeImageURLString + JSONSuffix
            }
            
        }
        if storeImageURLString == nil
        {
            storeImageURLString = "N/A"
            return storeImageURLString
        }
        return storeImageURLString
    }
    
    func setImageURL()
    {
        card.append(getImageURL())
    }
    
    func resetImageURL()
    {
        storeImageURLString = ""
    }
    
    func getMenuID() -> String
    {
        if let JSONVenue = specificRestaurant?["venue"] as? NSDictionary
        {
            JSONMenuID = JSONVenue["id"] as! String?
        }
        if JSONMenuID == nil
        {
            JSONMenuID = "N/A"
            return JSONMenuID
        }
        return JSONMenuID
    }
    
    func setMenuID()
    {
        card.append(getMenuID())
    }
    
    
    func getHasMenu()  -> String
    {
        if let JSONVenue = specificRestaurant?["venue"] as? NSDictionary
        {
            if JSONVenue["hasMenu"] != nil {
                JSONHasMenu = "1"
            }
            else {
                JSONHasMenu = "0"
            }
        }
        if JSONHasMenu == nil
        {
            JSONHasMenu = "N/A"
            return JSONHasMenu
        }
        return JSONHasMenu
    }
    
    func setHasMenu()
    {
        if getHasMenu() == "1" { // if the restaurant's menu is available
            JSONMenuURL = "https://foursquare.com/v/" + JSONMenuID + "/menu"
            card.append(JSONMenuURL)
        }
            
        else {
            card.append("Menu is not available") // if restaurant does not have menu, append the string "Menu is not available"
        }
        
    }
    
    func getPhoneNumber() -> String
    { if let JSONVenue = specificRestaurant?["venue"] as? NSDictionary
    {
        if let JSONContactInfo = JSONVenue["contact"] as? NSDictionary
        {
            let phoneNumber = JSONContactInfo["phone"] as? String
            
            if phoneNumber == nil {
                JSONPhoneNumberString = "NoNumber"
            }
            else{
                JSONPhoneNumberString = String(phoneNumber!)!
            }
            
        }
        
        }
        return(JSONPhoneNumberString)
    }
    
    func setPhoneNumber()
    {
        card.append(getPhoneNumber())
    }
    
    
    
}


