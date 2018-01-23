//
//  FavoriteViewController.swift
//  Mobile Stock
//
//  Created by Samuel Lehardi on 11/21/17.
//  Copyright © 2017 Samuel Lehardi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SearchTextField
import EasyToast

class FavoriteViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var sortPickerView: UIPickerView!
    @IBOutlet weak var orderPickerView: UIPickerView!
    @IBOutlet weak var stockSymbol: SearchTextField!
    
    var symbol = ""
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Creating structs and sorting variables
    let sortArray = ["Default","Symbol", "Price", "Change", "Change(%)"]
    let orderArray = ["Ascending","Descending"]
    var sortStruct:[FavoriteStock]=[FavoriteStock]()
    var defaultStruct:[FavoriteStock]=[FavoriteStock]()
    var initStruct:[FavoriteStock]=[FavoriteStock]()
    
    //Interacting with Favorite Data Model
    let favoriteModel = FavoriteDataModel()
    @IBOutlet weak var favoriteTable: UITableView!
    
    //Timer and variable for autorefresh button
    var autoTimer=Timer()
    @IBOutlet weak var autoRefreshSwitch: UISwitch!
    
    //Default Functions for PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if  pickerView == sortPickerView {
            return sortArray.count
        }else if pickerView == orderPickerView {
            return orderArray.count
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == sortPickerView  {
            return sortArray[row]
            
        } else if pickerView == orderPickerView {
            return orderArray[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
       if  pickerView == sortPickerView {
            favoriteModel.sortValue=sortArray[row] as String
            self.sortData()
        }
        
        if  pickerView == orderPickerView {
            favoriteModel.orderValue=orderArray[row] as String
            self.sortData()
        }
        
    }
    
    //Function to sort favorite table
    func sortData() {
        if favoriteModel.orderValue == "Ascending" {
            if favoriteModel.sortValue == "Default" {
                orderPickerView.isUserInteractionEnabled=false
                self.sortStruct=self.defaultStruct
                favoriteTable.reloadData()
            }
                
            else if favoriteModel.sortValue == "Symbol" {
                orderPickerView.isUserInteractionEnabled=true
                self.sortStruct.sort {$0.symbol < $1.symbol}
                favoriteTable.reloadData()
            }
                
            else if favoriteModel.sortValue == "Price" {
                orderPickerView.isUserInteractionEnabled=true
                self.sortStruct.sort {$0.price < $1.price}
                favoriteTable.reloadData()
            }
            else if favoriteModel.sortValue == "Change" {
                orderPickerView.isUserInteractionEnabled=true
                self.sortStruct.sort {$0.change < $1.change}
                favoriteTable.reloadData()
            }
            else if favoriteModel.sortValue == "Change(%)" {
                orderPickerView.isUserInteractionEnabled=true
                self.sortStruct.sort {$0.per < $1.per}
                favoriteTable.reloadData()
            }
        }
        
        if favoriteModel.orderValue == "Descending" {
            if favoriteModel.sortValue == "Default" {
                orderPickerView.isUserInteractionEnabled=false
                self.sortStruct=self.defaultStruct
                favoriteTable.reloadData()
            }
                
            else if favoriteModel.sortValue == "Symbol" {
                orderPickerView.isUserInteractionEnabled=true
                self.sortStruct.sort {$0.symbol > $1.symbol}
                favoriteTable.reloadData()
            }
                
            else if favoriteModel.sortValue == "Price" {
                orderPickerView.isUserInteractionEnabled=true
                self.sortStruct.sort {$0.price > $1.price}
                favoriteTable.reloadData()
            }
            else if favoriteModel.sortValue == "Change" {
                orderPickerView.isUserInteractionEnabled=true
                self.sortStruct.sort {$0.change > $1.change}
                favoriteTable.reloadData()
            }
            else if favoriteModel.sortValue == "Change(%)" {
                orderPickerView.isUserInteractionEnabled=true
                self.sortStruct.sort {$0.per > $1.per}
                favoriteTable.reloadData()
            }
        }
        
    }
    
    //Addjusting picker view size and font
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label = UILabel()
        if let v = view {
            label = v as! UILabel
        }
        if pickerView == sortPickerView  {
            label.font = UIFont (name: "Helvetica Neue", size: 15)
            label.text =  sortArray[row]
            label.textAlignment = .center
            return label
            
        } else if pickerView == orderPickerView {
            
            label.font = UIFont (name: "Helvetica Neue", size: 15)
            label.text =  orderArray[row]
            label.textAlignment = .center
            return label
        }
        return label
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden=true
        // Do any additional setup after loading the view, typically from a nib.
        //Delegates for picker view and table
        sortPickerView.delegate=self
        sortPickerView.dataSource=self
        orderPickerView.delegate=self
        orderPickerView.dataSource=self
        
        self.favoriteTable.delegate=self
        self.favoriteTable.dataSource=self
        
        //set navItem as transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        //autocomplete function call
         configureAutoSearchTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sortPickerView.selectRow(0, inComponent: 0, animated: true)
        orderPickerView.selectRow(0, inComponent: 0, animated: true)
        orderPickerView.isUserInteractionEnabled=false
        
        
        initializeFavorites()
        self.favoriteTable.reloadData()
        getFavorites()
    }
    
    //function to reresh table
    @objc func refreshTable(){
        self.favoriteTable.reloadData()
        self.activityIndicator.isHidden=false
        getFavorites()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //function to clear search field
    @IBAction func clearData(_ sender: UIButton) {
        stockSymbol.text = ""
    }
    
    //Initializing favorites information in struct
    func initializeFavorites() {
        self.sortStruct=self.initStruct
        favoriteModel.faveCounter=0
        /*
        favoriteModel.faveSymbolArray=[]
        favoriteModel.faveLastPriceArray=[]
        favoriteModel.faveCombinedArray=[]
        favoriteModel.faveChangeArray=[]
        favoriteModel.faveChangePerArray=[]
        */
        
        let faveDefaults=UserDefaults.standard
        let faveArray=faveDefaults.object(forKey: "FavoritesList") as? [String] ?? [String]()
        favoriteModel.faveRows=faveArray.count
        favoriteModel.faveSymbolArray=faveArray
        for _ in 0..<faveArray.count {
            /*
            favoriteModel.faveLastPriceArray.append("")
            favoriteModel.faveCombinedArray.append("")
            favoriteModel.faveChangeArray.append(0.0)
            favoriteModel.faveChangePerArray.append(0.0)
            */
            var stock: FavoriteStock=FavoriteStock()
            stock.price=0
            stock.symbol=""
            stock.change=0
            stock.per=0
            stock.priceString=""
            stock.changeString=""
            self.sortStruct.append(stock)
        }
    }
    
    //Calling backend for favorite stock details
    func getFavorites(){
        favoriteModel.faveCounter=0
        
        if favoriteModel.faveSymbolArray != [] {
            self.activityIndicator.isHidden=false
            for symbol: String in favoriteModel.faveSymbolArray {
                let parameters: [String: String] = ["type" : "price", "symbol" : symbol]
                let url = "http://lehardimobile.us-east-2.elasticbeanstalk.com/mobilestock.php"
                Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
                    response in
                    if response.result.isSuccess {
                        let json : JSON = JSON (response.result.value!)
                        if let index = self.favoriteModel.faveSymbolArray.index(of: symbol) {
                            let lastPrice=json["lastprice"].floatValue
                            let change=json["change"].floatValue
                            let changePer=json["changeper"].floatValue
                            /*
                            self.favoriteModel.faveLastPriceArray[index] = "$"+String(format: "%.2f", lastPrice)
                            self.favoriteModel.faveChangeArray[index]=change
                            self.favoriteModel.faveChangePerArray[index]=changePer
                            self.favoriteModel.faveCombinedArray[index]=String(format: "%.2f", change) + " (" + String(format: "%.2f", changePer) + "%)"
                            */
                            var stock: FavoriteStock=FavoriteStock()
                            stock.price=lastPrice
                            stock.symbol=symbol
                            stock.change=change
                            stock.per=changePer
                            stock.priceString="$"+String(format: "%.2f", lastPrice)
                            stock.changeString=String(format: "%.2f", change) + " (" + String(format: "%.2f", changePer) + "%)"
                            self.sortStruct[index]=stock
                        }
                        
                    } else {
                        print("Error \(String(describing: response.result.error))")
                        
                    }
                    
                    self.defaultStruct=self.sortStruct
                    self.favoriteTable.reloadData()
                    self.favoriteModel.faveCounter+=1
                    
                    if self.favoriteModel.faveCounter==self.favoriteModel.faveSymbolArray.count{
                        self.activityIndicator.isHidden=true
                    }
                    
                }
                }
            }
            
    }
    
    //Refresh Button
    @IBAction func refreshClicked(_ sender: UIButton) {
        self.favoriteTable.reloadData()
        getFavorites()
    }
    
    //Autorefresh Button
    @IBAction func autoRefreshClicked(_ sender: UISwitch) {
        if self.autoRefreshSwitch.isOn {
            self.favoriteTable.reloadData()
            getFavorites()
            self.autoTimer=Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.refreshTable), userInfo: nil, repeats: true)
        } else {
            self.autoTimer.invalidate()
        }
    }
    
    //Functions for Favorite Table
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return favoriteModel.faveSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteModel.faveRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as! FavoriteCell

        let stock = self.sortStruct[indexPath.row]
     
        cell.priceLabel.text=stock.priceString
        cell.changeLabel.text=stock.changeString
        cell.symbolLabel.text=stock.symbol
        if stock.change<0.0 {
            cell.changeLabel.textColor=UIColor.red
        } else {
            cell.changeLabel.textColor=UIColor.green
        }
 
        /*
        cell.priceLabel.text=favoriteModel.faveLastPriceArray[indexPath.row]
        cell.changeLabel.text=favoriteModel.faveCombinedArray[indexPath.row]
        cell.symbolLabel.text=favoriteModel.faveSymbolArray[indexPath.row]
        if favoriteModel.faveChangeArray[indexPath.row]<0.0 {
            cell.changeLabel.textColor=UIColor.red
        }
        */
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentSymbol = (tableView.cellForRow(at: indexPath) as! FavoriteCell).symbolLabel.text!
        stockSymbol.text! = currentSymbol
        self.performSegue(withIdentifier: "sendSymbol", sender: nil)
    }
   
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let faveDefaults=UserDefaults.standard
            var faveArray=faveDefaults.object(forKey: "FavoritesList") as? [String] ?? [String]()
            
            let deleteSymbol = (tableView.cellForRow(at: indexPath) as! FavoriteCell).symbolLabel.text!
            if let index = faveArray.index(of: deleteSymbol) {
                faveArray.remove(at: index)
            }
            
            faveDefaults.set(faveArray, forKey: "FavoritesList")
            initializeFavorites()
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    //Segue from favorite item to stock details
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        let whiteSpaceSet = CharacterSet.whitespaces
        if stockSymbol.text?.isEmpty == false && stockSymbol.text?.trimmingCharacters(in: whiteSpaceSet).isEmpty == false {
            return true
        } else {
            print("Symbol invalid")
            self.view.showToast("Please enter a stock name or symbol", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
            stockSymbol.text = ""
            return false
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "sendSymbol"{
                let secondVC = segue.destination as! stockViewController
                self.symbol = (stockSymbol.text?.components(separatedBy: " ").first!)!
                secondVC.symbol=self.symbol.uppercased()
                secondVC.navigationItem.title=self.symbol.uppercased()
            }
    }
    
    //Auto Complete Search Function
    fileprivate func configureAutoSearchTextField() {
        
        
        // Modify current theme properties
        stockSymbol.theme.bgColor = UIColor.white.withAlphaComponent(0.4)
        
        // Set specific comparision options - Default: .caseInsensitive
        stockSymbol.comparisonOptions = [.caseInsensitive]
        
        // Max number of results - Default: No limit
        stockSymbol.maxNumberOfResults = 5
        
        // Update data source when the user stops typing
        stockSymbol.userStoppedTypingHandler = {
            if let criteria = self.stockSymbol.text {
                if criteria.count > 0 {
                    self.filterAcronymInBackground(criteria) { results in
                        // Set new items to filter
                        self.stockSymbol.filterItems(results)
                        
                        // Stop loading indicator
                        self.stockSymbol.stopLoadingIndicator()
                    }
                }
            }
            } as (() -> Void)
    }
    
    
    // Hide keyboard when touching the screen
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    fileprivate func filterAcronymInBackground(_ criteria: String, callback: @escaping ((_ results: [SearchTextFieldItem]) -> Void)) {
        
        let url = URL(string: "http://lehardimobile.us-east-2.elasticbeanstalk.com/mobilestock.php?query=\(criteria)")
        
        //Filter Data from url
        if let url = url {
            let task = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
       
                do {
                    if  let data = data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let autoJSON = json["auto"] as? [[String: Any]] {
                        var results = [SearchTextFieldItem]()
                        for result in autoJSON {
                            let autoSymbol = result["Symbol"] as! String
                            let autoName = result["Name"] as! String
                            let autoExchange = result ["Exchange"] as! String
                            let autoString = autoSymbol + " - " + autoName + " (" + autoExchange + ")"
                            results.append(SearchTextFieldItem(title: autoString))
                        }
                        DispatchQueue.main.async {
                            callback(results)
                        }
                    }
                    
                }
                    
                catch {
                    print("Network error: \(error)")
                    DispatchQueue.main.async {
                        callback([])
                    }
                }
            })
            
            task.resume()
        }
    }

}

