//
//  StockDataModel.swift
//  Mobile Stock
//
//  Created by Samuel Lehardi on 11/22/17.
//  Copyright © 2017 Samuel Lehardi. All rights reserved.
//

import Foundation

class StockDataModel {
    var stockSymbol : String = ""
    var lastPrice : String = ""
    var change: String = ""
    var changeImageName: String = ""
    var timestamp: String = ""
    var open: String = ""
    var close: String = ""
    var dayRange: String = ""
    var volume: String = ""
    let stockSections: Int = 1
    var stockRows: Int = 8
    
    var indicatorValue: String = "Price"
    var currentValue: String = ""
    var indicatorType: String = ""
    
    let labelArray = ["Stock Symbol","Last Price","Change","Timestamp","Open","Close","Day's Range","Volume"]
    var detailArray = ["","","","","","","",""]
}
