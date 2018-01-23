//
//  FavoriteDataModel.swift
//  Mobile Stock
//
//  Created by Samuel Lehardi on 11/24/17.
//  Copyright © 2017 Samuel Lehardi. All rights reserved.
//

import Foundation

class FavoriteDataModel {
    var faveSymbolArray: [String] = []
    var faveLastPriceArray: [String] = []
    var faveChangeArray: [Float] = []
    var faveChangePerArray: [Float] = []
    var faveCombinedArray: [String] = []
    let faveSections: Int = 1
    var faveRows: Int = 0
    var faveCounter=0
    var sortValue: String = "Default"
    var orderValue: String = "Ascending"
    
    
    var symbolArray: [String] = []
}

struct FavoriteStock {
    var symbol:String = ""
    var price:Float = 0.0
    var change:Float = 0.0
    var per: Float=0.0
    var priceString:String=""
    var changeString:String=""
}
