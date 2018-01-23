//
//  stockViewController.swift
//  Mobile Stock
//
//  Created by Samuel Lehardi on 11/21/17.
//  Copyright © 2017 Samuel Lehardi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class stockViewController: UIViewController{
    
    var symbol = ""
    let stockURL = "http://lehardimobile.us-east-2.elasticbeanstalk.com/mobilestock.php"
    
    let stockModel = StockDataModel()
    //segmented control for the three container views
    
    @IBOutlet weak var currentView: UIView!
    @IBOutlet weak var historicalView: UIView!
    @IBOutlet weak var newsView: UIView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //Function to change to the three tab views when clicked
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            newsView.isHidden = true
            historicalView.isHidden = true
            currentView.isHidden = false
        case 1:
            newsView.isHidden = true
            historicalView.isHidden = false
            currentView.isHidden = true
        case 2:
            newsView.isHidden = false
            historicalView.isHidden = true
            currentView.isHidden = true
        default:
            break;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //let paramPrice: [String: String] = ["type" : "price", "symbol" : symbol]
        //SwiftSpinner.show("Loading Data")
        //getStockPrice(url: stockURL, parameters: paramPrice)
        //let paramNews: [String: String] = ["type" : "News", "symbol" : symbol]
        //getStockNews(url: stockURL, parameters: paramNews)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Call Backend to receive stock price table information
    func getStockPrice (url: String, parameters: [String:String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                let dataJSON : JSON = JSON (response.result.value!)
                print (dataJSON)
                SwiftSpinner.hide()
                
            } else {
                print("Error \(String(describing: response.result.error))")
                print(self.symbol)
                SwiftSpinner.hide()
            }
        }
    }
    
    //Segue preparation to handle which tab is clicked
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendNewsSymbol" {
            let newsVC = segue.destination as! newsViewController
            newsVC.symbol=symbol
        }
        if segue.identifier == "sendCurrentSymbol" {
            let currentVC = segue.destination as! currentViewController
            currentVC.symbol=symbol
        }
        if segue.identifier == "sendHistoricSymbol" {
            let historicVC = segue.destination as! historicViewController
            historicVC.symbol=symbol
        }
        
    }

    
    
}


