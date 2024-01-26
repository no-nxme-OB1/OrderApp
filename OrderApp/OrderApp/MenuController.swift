//
//  MenuController.swift
//  OrderApp
//
//  Created by Given Maphiri on 2023/12/05.
//

import Foundation
import UIKit



class MenuController{
    
    var userActivity = NSUserActivity(activityType: "com.Given.OrderApp.order")
    
    static let orderUpdatedNotification = Notification.Name("MenuController.orderUpdated")
    
    static let shared = MenuController()
    
    var order = Order() {
            didSet {
                NotificationCenter.default.post(name: MenuController.orderUpdatedNotification, object: nil)
                
                userActivity.order = order
            }
        }
    
    let baseURL = URL(string: "http://localhost:8080/")!
    
    enum MenuControllerError: Error, LocalizedError {
        case categoriesNotFound
        case menuItemNotFound
        case orderRequestFailed
        case imageDataMissing
    }
    
    
    func updateUserActivity(with controller: StateRestorationController) {
            switch controller {
            case .menu(let category):
                userActivity.menuCategory = category
            case .menuItemDetail(let menuItem):
                userActivity.menuItem = menuItem
            case .order, .categories:
                break
            }

            userActivity.controllerIdentifier = controller.identifier
        }
    
    func fetchImage(from url: URL) async throws -> UIImage {
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.imageDataMissing
        }
        
        guard let image = UIImage(data: data) else{
            throw MenuControllerError.imageDataMissing
        }
        
        return image
    }
    
    
    func fetchCategories() async throws -> [String]{
        
        let categoriesURL = baseURL.appendingPathComponent("categories")
        
        let (data, response) = try await URLSession.shared.data(from: categoriesURL)
        
       
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.categoriesNotFound
        }
        
        let decoder = JSONDecoder()
        let categoriesResponse = try decoder.decode(CategoriesResponse.self, from: data)
        
        return categoriesResponse.categories

    }
    
    
   
    
    
    func fetchMenuItem(forCategory categoryName: String) async throws -> [MenuItem] {
        
        let initialMenuURL = baseURL.appendingPathComponent("menu")
        
        var components = URLComponents(url: initialMenuURL,resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "category",value: categoryName)]
        
        let menuURL = components.url!
        let (data, response) = try await URLSession.shared.data(from: menuURL)
        
        guard let httpResponse = response as? HTTPURLResponse,httpResponse.statusCode == 200 else {
            throw MenuControllerError.menuItemNotFound
        }
        
        let decoder = JSONDecoder()
        let menuResponse = try decoder.decode(MenuResponse.self, from: data)
        
        return menuResponse.items
    }
    
   
   
    
    
    typealias MinutesToPrepare = Int
    
    func submitOrder(forMenuIDs menuIDs: [Int]) async throws -> MinutesToPrepare {
        
        let orderURL = baseURL.appendingPathComponent("order")
        
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //store array of menuIDs
        let menuIDsDict = ["menuIds": menuIDs]
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(menuIDsDict)

        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.orderRequestFailed
        }
        
        let decoder = JSONDecoder()
        let orderResponse = try decoder.decode(OrderResponse.self, from: data)
        
        return orderResponse.prepTime
    }
    
    
    
    
    
    
}
