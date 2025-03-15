//
//  NetworkManager.swift
//  Tabbar SwiftUI
//
//  Created by Erikneon on 8/2/24.
//

import Foundation
import UIKit

struct NetworkManager {
    //let api = "https://jsonplaceholder.typicode.com/posts"
    
    let api = "http://localhost:3001/menu"

    //STEP 1: Creating the Delegate
    var delegate:NetworkManagerDelegate?
    
    func fetchData () {
        print(api)
        performRequest(urlString: api)
    }
    
    func performRequest(urlString: String) {
        //creating the url
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with:url) { (data, response, error) in

                print(data)
                if let safeData = data {
                    if let userInfo = parseJSON(modelData:safeData) {
                        //need to add any code for api chages to be reflected on code
                       self.delegate?.didUpdateData(_networkManager: self, data: userInfo)
                    }
                }
                
                if let error = error {
                    self.delegate?.didFailWithError(error: error)
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(modelData: Data) -> ItemList? {
        let decoder = JSONDecoder()
        do {
            //decodes the data from modeldata type to ItemList datatype
        let decodedData = try decoder.decode(ItemList.self, from: modelData) //decodedData=> array of modeldata object
                    
            print(" ++++++++++++++++++++ ")
            print(decodedData)
            for data in decodedData {

                
                print("dish_name :\(data.dish_name)")
                print("cost: \(data.cost)")
                print("iamge_url: \(data.image_url)")
                print("quantity_available: \(data.quantity_available)")
                print("ratings: \(data.ratings)")
            }

            print("*************")
            print(type(of:decodedData))
            return decodedData
        }
        catch {
            print(error)
            return nil
        }
    }
    
    
    func fetchAvailability(dishName: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:3001/menu/\(dishName)") else {
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let quantity = json["quantity_available"] as? Int {
                completion(quantity > 0)
            } else {
                completion(false)
            }
        }.resume()
    }

    func placeOrder(dishName: String, quantity: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:3001/order") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "dish_name": dishName,
            "quantity": quantity
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }

    func cancelOrder(dishName: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:3001/menu/\(dishName)") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }

}


extension NetworkManager {
    func fetchPrediction(for text: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:6001/predict") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["text": text]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let intent = json["intent"] as? String {
                    completion(intent)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
}


//STEP 2: Creating the protocols associated to the delegate
protocol NetworkManagerDelegate {
    func didUpdateData(_networkManager: NetworkManager, data:ItemList)
    func didFailWithError (error:Error)
}

