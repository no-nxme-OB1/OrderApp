//
//  ResponseModels.swift
//  OrderApp
//
//  Created by Given Maphiri on 2023/12/05.
//

import Foundation

struct MenuResponse: Codable{
    let items: [MenuItem]
}

struct CategoriesResponse: Codable {
    let categories: [String]
}


struct OrderResponse: Codable {
    let prepTime: Int
    
    enum CodingKeys: String, CodingKey {
        case prepTime = "preparation_time"
    }
}


