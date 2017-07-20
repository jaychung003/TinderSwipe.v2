//SwipeVC.swift
//  TinderSwipe
//
//  Created by cssummer17 on 6/15/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import Firebase

class SwipeVC: UIViewController {
    
    //restaurant profile info
    @IBOutlet weak var card: UIViewX!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
    
    //menu things that aren't being used right now
    @IBOutlet weak var thumbImageView: UIImageView!
    
    var point = CGPoint()
    var timer: Timer?
    var action1 = UIAlertAction()
    var alertView1 = UIAlertController()
    var deck = DataManager.sharedData.deck
    var divisor: CGFloat! //variable for angle tilt
    var cardIndex: Int = 0
    //var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //button that brings to the next page
    @IBOutlet weak var seeResults: UIButton!
    @IBAction func seeResultsClicked(_ sender: UIButton) {
        handleSeeResults()
    }
    
    func handleSeeResults() {
        performSegue(withIdentifier: "SeeResultsIdentifier", sender: self)
    }
    
    //see menu button & hyperlink
    @IBOutlet weak var seeMenu: UIButton!
    @IBAction func menuLink(_ sender: AnyObject) {
        if (self.deck[self.cardIndex][8] == "Menu is not available")
        {
            alertView1 = UIAlertController(title: "Whoops!", message: "It appears there is no menu available for this venue.", preferredStyle: .alert)
                action1 = UIAlertAction(title: "Return to swiping", style: .default, handler: { (alert) in })
                alertView1.addAction(action1)
                self.present(alertView1, animated: true, completion: nil)
        }
        print(self.deck[self.cardIndex][8])
        if let url = NSURL(string: self.deck[self.cardIndex][8]) {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    //right and left button action
    
    @IBOutlet weak var checkMark: UIButtonX!
    @IBAction func checkMarkClicked(_ sender: UIButton) {
        timer = nil
        while timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.loopRight), userInfo: nil, repeats: true)
        }
    }

    func loopRight() {
        
        point.x = point.x + 1
        
        let xFromCenter = self.card.center.x - self.view.center.x
        
        self.card.center = CGPoint(x: self.view.center.x + point.x, y: self.view.center.y + point.y)
        
        let scale = min(1, (100/abs(xFromCenter)))
        self.card.transform = CGAffineTransform(rotationAngle: xFromCenter / divisor).scaledBy(x: scale, y: scale)
        
        
        if xFromCenter > 0 {
            thumbImageView.image = #imageLiteral(resourceName: "thumb")
            thumbImageView.tintColor = UIColor.green
            thumbImageView.transform = CGAffineTransform(rotationAngle: 0)

            print(xFromCenter)
        }
        thumbImageView.alpha = abs(xFromCenter) / self.view.center.x
        
        if card.center.x > (view.frame.width - 5) {
            point.x = 0
            timer?.invalidate()
            loadNew()
            DataManager.sharedData.swipes.append(1)

            print(DataManager.sharedData.swipes)
            return
        }
    }

    @IBOutlet weak var xMark: UIButtonX!
    @IBAction func xMarkClicked(_ sender: UIButton) {
        timer = nil
        while timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.loopLeft), userInfo: nil, repeats: true)
        }
    }
    
    func loopLeft() {
        
        point.x = point.x - 1
        
        let xFromCenter = self.card.center.x - self.view.center.x
        
        self.card.center = CGPoint(x: self.view.center.x + point.x, y: self.view.center.y + point.y)
        
        let scale = min(1, (100/abs(xFromCenter)))
        self.card.transform = CGAffineTransform(rotationAngle: xFromCenter / divisor).scaledBy(x: scale, y: scale)
        
        
        if xFromCenter < 0 {
            thumbImageView.image = #imageLiteral(resourceName: "thumb")
            thumbImageView.tintColor = UIColor.red
            thumbImageView.transform = CGAffineTransform(rotationAngle: 3.14)
            
            print(xFromCenter)
        }
        thumbImageView.alpha = abs(xFromCenter) / self.view.center.x
        
        if card.center.x < 5 {
            point.x = 0
            timer?.invalidate()
            loadNew()
            DataManager.sharedData.swipes.append(0)

            print(DataManager.sharedData.swipes)
            return
        }
    }
    
    func swipeRight() {
        UIView.animate(withDuration: 0.3, animations: {
            self.card.center = CGPoint(x: self.card.center.x + 200, y: self.card.center.y)
        })
        loadNew()
        DataManager.sharedData.swipes.append(1)

        print(DataManager.sharedData.swipes)
    }
    
    func swipeLeft() {
        UIView.animate(withDuration: 0.3, animations: {
            self.card.center = CGPoint(x: self.card.center.x - 200, y: self.card.center.y)
        })
        loadNew()
        DataManager.sharedData.swipes.append(0)

        print(DataManager.sharedData.swipes)
        return
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        divisor = (view.frame.width / 2) / 0.61 //degree tilted
        //for a few second delay of showing card's info
        card.alpha = 0
        nameLabel.alpha = 0
        typeLabel.alpha = 0
        ratingLabel.alpha = 0
        addressLabel.alpha = 0
        priceLabel.alpha = 0
        seeMenu.alpha = 0
        seeResults.alpha = 0
        activityIndicator.alpha = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.card.alpha = 1 //have to refer self if using outside of the brackets
        }) { (true) in
            self.showInfo()
        }
    }
    
    //populates the card with info
    func showInfo() {
        deck = DataManager.sharedData.deck
        print("did deck transfer:", deck)
        UIView.animate(withDuration: 0.1, animations: {
        self.nameLabel.text = self.deck[self.cardIndex][0]
        self.typeLabel.text = self.deck[self.cardIndex][1]
        self.ratingLabel.text = self.deck[self.cardIndex][4] + "🔥"
        self.addressLabel.text = self.deck[self.cardIndex][2] + ", " + self.deck[self.cardIndex][3]
        self.priceLabel.text = self.deck[self.cardIndex][5]
        self.nameLabel.alpha = 1
        self.typeLabel.alpha = 1
        self.ratingLabel.alpha = 1
        self.addressLabel.alpha = 1
        self.priceLabel.alpha = 1
        self.seeMenu.alpha = 1

        //picture
        let url = NSURL(string:self.deck[self.cardIndex][6])
        let data = NSData(contentsOf:url! as URL)
        self.picture.image = UIImage(data: data! as Data)
        self.picture.alpha = 1
    })
    }
    

    func loadNew() {
        if self.cardIndex < (deck.count-1) {
            resetCard()
            self.cardIndex += 1
            showInfo()
        }
        else {
            //make a new list of restaurants that got YES swipes
            for index in 0...(DataManager.sharedData.swipes.count - 1) {
                if DataManager.sharedData.swipes[index] == 1 {
                    DataManager.sharedData.yesDeck.append(DataManager.sharedData.deck[index])
                }
            }
            
            // function that updates swipe Array once swiping is done
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
            self.updateSwipeArray()
            
            }
            print(DataManager.sharedData.swipes.count)
            self.activityIndicator.alpha = 1
            self.checkMark.alpha = 0
            self.xMark.alpha = 0
            self.card.alpha = 0
            activityIndicator.hidesWhenStopped = true
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            ResultsData.sharedResultsData.getCurrentMasterSwipeArray()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                //self.seeResults.alpha = 1
                ResultsData.sharedResultsData.updateMasterSwipeArray()
                print("Compiled MasterSwipeArray: ", ResultsData.sharedResultsData.masterSwipeArray)
                ResultsData.sharedResultsData.sortMasterSwipeArray()
                ResultsData.sharedResultsData.sortDeck()
                print("sorted deck in swipe vc   ", ResultsData.sharedResultsData.sortedDeck)
                self.performSegue(withIdentifier: "SeeResultsIdentifier", sender: self)
            }
            
            return
        }
    }
    
    func updateSwipeArray() {
        var IDtoFix = DataManager.sharedData.individualGroupID
        
        let ref = Database.database().reference()
        let usersRef = ref.child("users")
        guard let currentUID = Auth.auth().currentUser?.uid else {
            print("user is not currently logged in.")
            return
        }
        print("ID to Fix:: ", IDtoFix)
        print("ID should come up on this long one", DataManager.sharedData.individualGroupID)
        let eachUserRef = usersRef.child("\(currentUID)/groupsAssociatedWith/\(IDtoFix)")
        var updatedSwipeArray = [String: Any]()
        updatedSwipeArray = ["swipeArray": DataManager.sharedData.swipes, "deck": DataManager.sharedData.deck, "deck size": DataManager.sharedData.deck.count]
        eachUserRef.setValue(updatedSwipeArray)
        
    }
    
    
    
    //swiping action
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        let card = sender.view!
        let point = sender.translation(in: view)
        let xFromCenter = card.center.x - view.center.x
        
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        
        let scale = min(1, (100/abs(xFromCenter)))
        card.transform = CGAffineTransform(rotationAngle: xFromCenter / divisor).scaledBy(x: scale, y: scale)
        
        
        if xFromCenter > 0 {
            thumbImageView.image = #imageLiteral(resourceName: "thumb")
            thumbImageView.tintColor = UIColor.green
            thumbImageView.transform = CGAffineTransform(rotationAngle: 0)
        }
        else {
            thumbImageView.image = #imageLiteral(resourceName: "thumb")
            thumbImageView.tintColor = UIColor.red
            thumbImageView.transform = CGAffineTransform(rotationAngle: 3.14)
        }
        thumbImageView.alpha = abs(xFromCenter) / view.center.x
        
        //for when finger is off the screen
        if sender.state == UIGestureRecognizerState.ended {
            if card.center.x < 75 {
                swipeLeft()
            }
            else if card.center.x > (view.frame.width - 75) {
                // move off to the right side of screen
                swipeRight()
                return
            }
            //bring back to center if let go in the middle range
            resetCard()
        }
    }

    func resetCard() {
            UIView.animate(withDuration: 0.2, animations: { //come back to center
                self.card.center = self.view.center
                self.thumbImageView.alpha = 0
                self.card.alpha = 1
                self.card.transform = CGAffineTransform.identity
        })
    }

}
