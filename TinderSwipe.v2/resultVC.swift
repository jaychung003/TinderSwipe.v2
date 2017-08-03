//
//  resultVC.swift
//  TinderSwipe
//
//  Created by cssummer17 on 6/21/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit

class resultVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    var swipeResult = DataManager.sharedData.swipes
    var yesDeck = DataManager.sharedData.yesDeck
    var myIndex = 0
    var venueName = ""
    var foursquarePageUrl = ""
    var venueID = ""
    var page: Int!
    var combinedSwipeResult = [[[String]]]()
    var voteCount = ""
    
    @IBAction func switchTable(_ sender: UISegmentedControl) {
        page = sender.selectedSegmentIndex
        resultsTableView.reloadData()
    }
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    @IBAction func myGroupsClicked(_ sender: UIButton) {
        ResultsData.sharedResultsData.sortedDeck = [[String]]() ///clear the deck
        handleMyGroups()
    }
    
    func handleMyGroups() {
        performSegue(withIdentifier: "MyGroupsIdentifier", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //update entire array
        print("sorted deck in results data", ResultsData.sharedResultsData.sortedDeck)
    }
    
    
    override func viewDidLoad() {
        combinedSwipeResult.append(ResultsData.sharedResultsData.sortedDeck) //wholeDeck
        combinedSwipeResult.append(yesDeck)
        print("combined group and individual swipe result", combinedSwipeResult)
        print("Sorted by vote count???: ", ResultsData.sharedResultsData.sortedMasterSwipeArrayValue)
        page = 0
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.resultsTableView.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongPress(longPressGesture:UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: self.resultsTableView)
        let indexPath = self.resultsTableView.indexPathForRow(at: p)
        if indexPath == nil {
            print("Long press on table view, not row.")
        }
        else if (longPressGesture.state == UIGestureRecognizerState.began) {
            print("Long press on row, at \(indexPath!.row)")
            var restaurant2 = combinedSwipeResult[page][(indexPath?.row)!]
            let busPhone = restaurant2[9]
            if let urlTest = URL(string: "tel://\(busPhone)"), UIApplication.shared.canOpenURL(urlTest) {
                UIApplication.shared.open(urlTest)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return combinedSwipeResult[page].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellRestaurant", for: indexPath)
        
        //segmented control stuff
        let restaurant = combinedSwipeResult[page][indexPath.row]
        let name = restaurant[0]
        let cuisine = restaurant[1]
        let address = restaurant[2] + ", " + restaurant[3]
        let rating = restaurant[4] + "🔥"
        let price = restaurant[5]
        
        let denominator = DataManager.sharedData.groupResultDenominator
        var voteResult = String()
        
        
        if page == 0 {
            voteCount = String(ResultsData.sharedResultsData.sortedMasterSwipeArrayValue[indexPath.row])
            voteResult = "\n" + voteCount + "/" + denominator + " YUMS"
        }
        
        
        cell.textLabel?.text = name + voteResult
        cell.detailTextLabel?.text = cuisine + "\n"  + rating + "  " + price + "\n" + address //detailed info
        
        
        //pull image from url and set it as the image in each cell
        let url = NSURL(string:combinedSwipeResult[page][indexPath.row][6])
        let data = NSData(contentsOf:url! as URL)
        let restImage = UIImage(data: data! as Data)
        cell.imageView!.image = restImage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var restaurant2 = combinedSwipeResult[page][indexPath.row]
        myIndex = indexPath.row
        venueName = restaurant2[0].replacingOccurrences(of: " ", with: "-", options: .literal, range: nil)
        venueName = venueName.lowercased()
        foursquarePageUrl = "https://foursquare.com/v/" + venueName + "/" + restaurant2[7]
        print(foursquarePageUrl)
        UIApplication.shared.openURL(URL(string: foursquarePageUrl)!)
    }
    
}
