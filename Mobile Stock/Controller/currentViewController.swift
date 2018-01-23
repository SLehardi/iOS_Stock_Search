//
//  currentViewController.swift
//  Mobile Stock
//
//  Created by Samuel Lehardi on 11/23/17.
//  Copyright © 2017 Samuel Lehardi. All rights reserved.


import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import WebKit
import EasyToast
import FacebookShare

class currentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, WKUIDelegate, WKNavigationDelegate  {
    
    var symbol = ""
    let stockURL = "http://lehardimobile.us-east-2.elasticbeanstalk.com/mobilestock.php"
    
    //Picker options
    @IBOutlet weak var indicatorPickerView: UIPickerView!
    let indicatorArray = ["Price", "SMA", "EMA","STOCH","RSI","ADX","CCI","BBANDS","MACD"]
    
    //Interact with Model
    let stockModel = StockDataModel()
    
    //Stock Table
    @IBOutlet weak var stockTable: UITableView!
    
    //Webview
    @IBOutlet weak var indicatorWebView: WKWebView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    //FB Buton and Favorite Button
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var starButton: UIButton!
    
    //segmented control for the three container views
    @IBOutlet weak var changeButton: UIButton!
    
    //View on load for stock details
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden=false
        //Creating delegates to stock table
        self.stockTable.delegate = self
        self.stockTable.dataSource = self
        self.stockTable.isScrollEnabled=false
        fbButton.isEnabled=false
        let paramPrice: [String: String] = ["type" : "price", "symbol" : symbol]
        //Loading sign
        SwiftSpinner.show("Loading Data")
        
        //Call Function to get stock information
        getStockPrice(url: stockURL, parameters: paramPrice)
        
        //Delegate for the pickers
        indicatorPickerView.delegate=self
        indicatorPickerView.dataSource=self
        
        //Webview Delegate and url request
        indicatorWebView.navigationDelegate = self
        let htmlPath = Bundle.main.path(forResource: "index", ofType: "html")
        let url = URL(fileURLWithPath: htmlPath!)
        let request = URLRequest (url:url)
        indicatorWebView.load(request)
        
        stockModel.currentValue="Price"
        
        //Determining if stock is in favorites
        let faveDefaults=UserDefaults.standard
        let faveArray=faveDefaults.object(forKey: "FavoritesList") as? [String] ?? [String]()
        if faveArray.index(of: self.symbol) != nil {
            self.starButton.setImage(UIImage(named:"filled"), for: [])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Picker View default functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return indicatorArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return indicatorArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
            stockModel.indicatorValue=indicatorArray[row] as String
        if stockModel.currentValue != stockModel.indicatorValue {
            changeButton.isEnabled=true
        } else {
            changeButton.isEnabled=false
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label = UILabel()
        if let v = view {
            label = v as! UILabel
        }
            label.font = UIFont (name: "Helvetica Neue", size: 18)
            label.text =  indicatorArray[row]
            label.textAlignment = .center
            return label
    }
    
    //Webview functions
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicatorWebView.evaluateJavaScript("chartPicker('\(self.symbol)','\(stockModel.currentValue)')") { result, error in
            //print(result ?? "null")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.fbButton.isEnabled=true
            }
        }
        
    }
    
    //Function when picker value is changed
    @IBAction func changeButton(_ sender: UIButton) {
        stockModel.currentValue=stockModel.indicatorValue
        indicatorWebView.reload()
        changeButton.isEnabled=false
        self.fbButton.isEnabled=false
    }
    
    //Function for Facebook Posting
    func showShareDialog<C: ContentProtocol>(_ content: C, mode: ShareDialogMode = .automatic) {
        let dialog = ShareDialog(content: content)
        dialog.presentingViewController = self
        dialog.mode = mode
        dialog.failsOnInvalidData = true
        dialog.completion = { result in
            switch result {
            case .success:
                print("Share posted")
                self.view.showToast("Post Successful!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
            case .failed:
                print("Failure")
                self.view.showToast("Post Failed!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
            case .cancelled:
                print("Share cancelled")
                self.view.showToast("Post Cancelled!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
            }
        }
        do {
            try dialog.show()
        } catch (let error) {
            print(error)
        }
    }
  
    //On click of Facebook Button
    @IBAction func fbPress(_ sender: UIButton) {
        indicatorWebView.evaluateJavaScript("getURL()") { result, error in
            //print(result ?? "null")
            if result != nil {
                let fbURL : String = result as! String
                let url = URL(string: fbURL)
                let content = LinkShareContent(url: url!)
                self.showShareDialog(content, mode: .web)
            }
         
          
        }
    }
    
    //On click of favorite(star) button
    @IBAction func starPress(_ sender: UIButton) {
        self.starButton.isEnabled=false
        let faveDefaults=UserDefaults.standard
        var faveArray=faveDefaults.object(forKey: "FavoritesList") as? [String] ?? [String]()
        if let index=faveArray.index(of: self.symbol){
            faveArray.remove(at: index)
            self.starButton.setImage(UIImage(named:"empty"), for: [])
        } else {
            faveArray.append(self.symbol)
            self.starButton.setImage(UIImage(named:"filled"), for: [])
        }
        faveDefaults.set(faveArray, forKey: "FavoritesList")
        self.starButton.isEnabled=true
    }
    
    //Call Backend to receive stock price table information
    func getStockPrice (url: String, parameters: [String:String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                let dataJSON : JSON = JSON (response.result.value!)
                SwiftSpinner.hide()
                self.updateStockData(json : dataJSON)
            } else {
                print("Error \(String(describing: response.result.error))")
                self.indicator.isHidden=true
                self.fbButton.isEnabled=false
                self.starButton.isEnabled=false
                self.view.showToast("Failed to load data. Please try again later", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
                self.view.showToast("Failed to load data and display the chart!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
                SwiftSpinner.hide()
            }
        }
    }
    
    //Update stock table information
    func updateStockData(json : JSON) {
        let results : JSON = json
        if results != JSON.null {
            stockModel.stockSymbol=json["stockSymbol"].stringValue
            let lastPrice=json["lastprice"].floatValue
            stockModel.lastPrice=String(format: "%.2f", lastPrice)
            let change=json["change"].floatValue
            let changePer=json["changeper"].floatValue
            stockModel.change=String(format: "%.2f", change)+" ("+String(format: "%.2f", changePer)+"%)"
            if json["change"].floatValue>0.0{
                stockModel.changeImageName="Green_Arrow_Up"
            } else {
                stockModel.changeImageName="Red_Arrow_Down"
            }
            
            stockModel.timestamp=json["stamp"].stringValue+" EDT"
            let open=json["open"].floatValue
            let close=json["close"].floatValue
            stockModel.open = String(format: "%.2f", open)
            stockModel.close = String(format: "%.2f", close)
            stockModel.dayRange=stockModel.open+" - "+stockModel.close
            stockModel.volume=json["volume"].stringValue
        stockModel.detailArray=[stockModel.stockSymbol,stockModel.lastPrice,stockModel.change,stockModel.timestamp,stockModel.open,stockModel.close, stockModel.dayRange,stockModel.volume]
        }
        self.starButton.isEnabled=true
        self.stockTable.reloadData()
    }
    
    //Default Functions for Stock Table
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return stockModel.stockSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stockModel.stockRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stockCell", for: indexPath) as! StockCell
        let label = stockModel.labelArray[indexPath.row]
        let detail = stockModel.detailArray[indexPath.row]
        cell.label.text=label
        cell.detail.text=detail
        if label == "Change" && detail != "" {
            cell.arrow.image=UIImage(named: stockModel.changeImageName)
            cell.arrow.isHidden=false
        }
        return cell
    }
    
    
}




