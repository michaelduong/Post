//
//  PostController.swift
//  Post
//
//  Created by Michael Duong on 1/29/18.
//  Copyright © 2018 Turnt Labs. All rights reserved.
//

import Foundation

class PostController {
    
    static let shared = PostController()
    
    var posts = [Post]()
    
    let baseURL = URL(string: "https://ct-posts.firebaseio.com/posts")!
    
    func fetchPosts(reset: Bool = true, completion: @escaping(_ success: Bool) -> Void) {
        
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
            ]
        
        let queryItems = urlParameters.flatMap( { URLQueryItem(name: $0.key, value: $0.value) } )
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else { return }
        
        let getterEndPoint = url.appendingPathExtension("json")
        
        var request = URLRequest(url: getterEndPoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                print("Error retrieveing data in \(#function). Error: \(error)")
                completion(false);return
            }
            
            if let data = data {
                
                do {
                    let jsonDecoder = JSONDecoder()
                    let postsDictionary = try jsonDecoder.decode([String:Post].self, from: data)
                    let results = postsDictionary.flatMap{$0.value}
                    let sortedPosts = results.sorted(by: { (lhs, rhs) -> Bool in
                        lhs.timestamp > rhs.timestamp
                    })
                    self.posts.append(contentsOf: sortedPosts)
                    completion(true)
                    
                } catch let error {
                    print("Error decoding: \(error.localizedDescription)")
                    completion(false)
                }
            }
            }.resume()
    }
    
    func addNewPostWith(username: String, text: String, completion: @escaping( _ success: Bool) -> Void) {
        
        let post = Post(username: username, text: text)
        
        var postData: Data
        
        do {
            let encoder = JSONEncoder()
            postData = try encoder.encode(post)
            
        } catch let error {
            print("Error encoding data \(error) \(error.localizedDescription)")
            completion(false); return
        }
        
        let postEndpoint = baseURL.appendingPathExtension("json")
        
        var request = URLRequest(url: postEndpoint)
        request.httpBody = postData
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                print("Error with data request \(error) \(error.localizedDescription)")
                completion(false); return
            }
            
            guard let data = data, let responseData = String(data: data, encoding: .utf8) else { return }
            print(responseData)
            
//            self.posts.append(post)
//            completion(true)
            self.fetchPosts {_ in
                completion(true)
            }
        }.resume()
    }
}
