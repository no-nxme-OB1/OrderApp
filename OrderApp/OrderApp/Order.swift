//
//  Order.swift
//  OrderApp
//
//  Created by Given Maphiri on 2023/12/05.
//

import Foundation


struct Order: Codable {
    var menuItems: [MenuItem]
    
    init(menuItems: [MenuItem] = []) {
            self.menuItems = menuItems
    }
}
