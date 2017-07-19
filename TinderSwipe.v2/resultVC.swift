//
//  resultVC.swift
//  TinderSwipe
//
//  Created by cssummer17 on 6/21/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit

class resultVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    var wholeDeck = DataManager.sharedData.deck
    var swipeResult = DataManager.sharedData.swipes
    var yesDeck = DataManager.sharedData.yesDeck
    var myIndex = 0
    var venueName = ""
    var foursquarePageUrl = ""
    var venueID = ""
    
    var p: Int!
    
    var testArray = [[[String]]]()
    
    var testTest = [["1 a","2 b","3 c","4 d","5 e"],["a 1","b 2","c 3","d 4"]]
    
    @IBAction func switchTable(_ sender: UISegmentedControl) {
        p = sender.selectedSegmentIndex
        resultsTableView.reloadData()
        
    }
//    @IBAction func switchTable(_ sender: UISegmentedControl) {
//        p = sender.selectedSegmentIndex
//        resultsTableView.reloadData()
//    }
//    @IBAction func myGroupsClicked(_ sender: UIButton) {
//        handleMyGroups()
//    }
    
    @IBAction func myGroupsClicked(_ sender: UIButton) {
        handleMyGroups()
    }
    
    func handleMyGroups() {
        performSegue(withIdentifier: "MyGroupsIdentifier", sender: self)
    }
    
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ResultsData.sharedResultsData.getCurrentMasterSwipeArray()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            ResultsData.sharedResultsData.updateMasterSwipeArray()
                print("Compiled MasterSwipeArray: ", ResultsData.sharedResultsData.masterSwipeArray)
                ResultsData.sharedResultsData.sortMasterSwipeArray()
                ResultsData.sharedResultsData.sortDeck()
        }
        
        
        
    }
    
    
    override func viewDidLoad() {
        testArray.append(wholeDeck)
        testArray.append(yesDeck)
        print("test array", testArray)
        print(swipeResult)
        print(yesDeck)
        p = 0
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.resultsTableView.addGestureRecognizer(longPressGesture)
        
        // SwipeResultToGroups.layer.cornerRadius = 7
        
    }
    
    func handleLongPress(longPressGesture:UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: self.resultsTableView)
        let indexPath = self.resultsTableView.indexPathForRow(at: p)
        if indexPath == nil {
            print("Long press on table view, not row.")
        }
        else if (longPressGesture.state == UIGestureRecognizerState.began) {
            print("Long press on row, at \(indexPath!.row)")
            var restaurant2 = yesDeck[(indexPath?.row)!]
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
        return testArray[p].count
    }
    
    @IBOutlet weak var restaurantImage: UIImageView!
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellRestaurant", for: indexPath)
        
        //segmented control stuff
        let restaurant = testArray[p][indexPath.row]
        cell.textLabel?.text = restaurant[0]
        cell.detailTextLabel?.text = restaurant[1] + "\n" + restaurant[2] + ", " + restaurant[3] + "\n" + restaurant[4] + "🔥" + "  " + restaurant[5] //detailed info
        
        //pull image from url and set it as the image in each cell
        let url = NSURL(string:testArray[p][indexPath.row][6])
        let data = NSData(contentsOf:url! as URL)
        let restImage = UIImage(data: data! as Data)
        cell.imageView!.image = restImage
        //cell.imageView!.image.layer.borderColor = UIColor.white
        //cell.imageView!.image.layer.borderWidth = 2
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var restaurant2 = yesDeck[indexPath.row]
        myIndex = indexPath.row
        venueName = restaurant2[0].replacingOccurrences(of: " ", with: "-", options: .literal, range: nil)
        venueName = venueName.lowercased()
        foursquarePageUrl = "https://foursquare.com/v/" + venueName + "/" + restaurant2[7]
        print(foursquarePageUrl)
        UIApplication.shared.openURL(URL(string: foursquarePageUrl)!)
    }
    
    
}
