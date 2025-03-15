//
//  ModelData.swift
//  Tabbar SwiftUI
//
//  Created by Erikneon on 8/2/24.
//

import Foundation

struct ModelData:Codable {
    let id:Int
    let dish_name : String?
    let cost: Float?
    let image_url: String?
    let quantity_available: Int?
    let ratings: Float?
}

// typealias is used to define a complex, customized datatype or give another name to datatype
typealias ItemList = [ModelData]
