//
//  newsViewController.swift
//  Mobile Stock
//
//  Created by Samuel Lehardi on 11/21/17.
//  Copyright © 2017 Samuel Lehardi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class newsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var symbol = ""
    let stockURL = "http://lehardimobile.us-east-2.elasticbeanstalk.com/mobilestock.php"
    
    let newsModel = NewsDataModel()

    @IBOutlet weak var newsTable: UITableView!
    @IBOutlet weak var errorNews: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.errorNews.isHidden=true
        self.newsTable.delegate = self
        self.newsTable.dataSource = self
        let paramNews: [String: String] = ["type" : "News", "symbol" : symbol]
        getStockNews(url: stockURL, parameters: paramNews)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Call Backend to receive stock news table information
    func getStockNews (url: String, parameters: [String:String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                let newsJSON : JSON = JSON (response.result.value!)
                self.updateNewsData(json : newsJSON)
                if newsJSON["News"]["Results"].exists() == false {
                    print("Error News Feed")
                    self.errorNews.isHidden=false
                }
            } else {
                print("Error News Feed")
                self.errorNews.isHidden=false
            }
        }
    }
    
    // Get JSON and update data
    func updateNewsData(json : JSON) {
        let results : JSON = json["News"]["Results"]
        if results.array?.count != nil {
            newsModel.newsRows=(results.array?.count)!
            for (_, result): (String, JSON) in results {
                newsModel.titleArray.append(result["title"]["0"].stringValue)
                newsModel.authorArray.append(result["author"]["0"].stringValue)
                newsModel.dateArray.append(result["date"].stringValue)
                newsModel.urlArray.append(result["url"]["0"].stringValue)
                
            }
        } else {
            newsModel.newsRows=1
            newsModel.titleArray.append(results["title"].stringValue)
            newsModel.authorArray.append(results["author"].stringValue)
            newsModel.dateArray.append(results["date"].stringValue)
            newsModel.urlArray.append(results["url"].stringValue)
            
        }
        self.newsTable.reloadData()
    }
    
    //number of sections in table
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return newsModel.newsSections
    }
    
    //number of rows in table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsModel.newsRows
    }
    
    //table contents
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsCell
        cell.titleLabel.text=newsModel.titleArray[indexPath.row]
        cell.authorLabel.text=newsModel.authorArray[indexPath.row]
        cell.dateLabel.text=newsModel.dateArray[indexPath.row]
        return cell
    }
    
    //click to open link
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let url = NSURL(string: newsModel.urlArray[indexPath.row]) {
            let options = [UIApplicationOpenURLOptionUniversalLinksOnly : false]
            UIApplication.shared.open(url as URL, options: options, completionHandler: nil)
        }
    }
    
    //adjust cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      if(tableView==newsTable) {
            return 110
        }
        return 100
    }

    
}



