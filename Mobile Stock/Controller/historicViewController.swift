//
//  historicViewController.swift
//  Mobile Stock
//
//  Created by Samuel Lehardi on 11/25/17.
//  Copyright © 2017 Samuel Lehardi. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON

class historicViewController: UIViewController, WKUIDelegate, WKNavigationDelegate  {

    
    var symbol = ""
    @IBOutlet weak var historicWebView: WKWebView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorHistoric: UIView!
    
    //Onload prepare historic tab view
    override func viewDidLoad() {
        self.errorHistoric.isHidden=true
        let stockURL = "http://lehardimobile.us-east-2.elasticbeanstalk.com/mobilestock.php"
        let paramPrice: [String: String] = ["type" : "price", "symbol" : symbol]
        getStockPrice(url: stockURL, parameters: paramPrice)
        
        //Get Historic chart from local html
        historicWebView.navigationDelegate = self
        let htmlPath = Bundle.main.path(forResource: "index", ofType: "html")
        let url = URL(fileURLWithPath: htmlPath!)
        let request = URLRequest (url:url)
        
        historicWebView.load(request)
        
    }
    
    //Default WebView functions to get historic chart display
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //print (self.symbol)
        historicWebView.evaluateJavaScript("chartPicker('\(self.symbol)','historic')") { result, error in
            //print(result ?? "null")
        }
        
    }
    
    //Call to back end to get stock price information
    func getStockPrice (url: String, parameters: [String:String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
            } else {
                print("Error Bad Data Historic")
                self.errorHistoric.isHidden=false
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
     
    }
    

    

}
