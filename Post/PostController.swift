//
//  PostController.swift
//  Post
//
//  Created by Caleb Hicks on 5/16/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

class PostController {
    
    static let baseURL = URL(string: "https://dm-post.firebaseio.com/posts/")
    
    static let getterEndpoint = baseURL?.appendingPathExtension("json")
    
    // MARK: Request
    
    func fetchPosts(reset: Bool = true, completion: @escaping() -> Void) {
        
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        
        guard let baseURL = PostController.baseURL else { fatalError("Post endpoint url failed") }
        
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
            ]
        
        let queryItems = urlParameters.flatMap( { URLQueryItem(name: $0.key, value: $0.value) } )
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else { completion(); return }
        
        let getterEndpoint = url.appendingPathExtension("json")
        
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, _, error) in
            
            if let error = error {
                NSLog("There was an error retrieving data in \(#function). Error: \(error)")
                completion()
                return
            }
            
            guard let data = data else { NSLog("No data returned from data task."); completion();  return }
            
            do {
                let decoder = JSONDecoder()
                let postsDictionary = try decoder.decode([String:Post].self, from: data)
                let posts: [Post] = postsDictionary.flatMap( { $0.value })
                let sortedPosts = posts.sorted(by: { $0.timestamp > $1.timestamp })
                if reset {
                    self.posts = sortedPosts
                } else {
                    self.posts.append(contentsOf: sortedPosts)
                }
                completion()
            } catch let error {
                NSLog("ERROR decoding: \(error.localizedDescription)")
                completion()
            }
        })
        dataTask.resume()
    }
    
    func addPost(username: String, text: String, completion: @escaping() -> Void) {
        
        let post = Post(username: username, text: text)
        
        var postData: Data
        
        do {
            let encoder = JSONEncoder()
            postData = try encoder.encode(post)
        } catch let error {
            NSLog("ERROR encoding post to be saved: \(error.localizedDescription)")
            completion()
            return
        }
        
        guard let baseURL = PostController.baseURL else { completion(); return }
        
        let postEndpoint = baseURL.appendingPathExtension("json")
        
        var request = URLRequest(url: postEndpoint)
        
        request.httpMethod = "POST"
        
        request.httpBody = postData
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error { completion(); NSLog(error.localizedDescription) }
            
            guard let data = data,
                let responseDataString = String(data: data, encoding: .utf8)
                else { NSLog("Data is nil. Unable to verify if data was able to be put to endpoint.");
                    completion()
                    return }
            
            self.fetchPosts {
                completion()
            }
        }
        dataTask.resume()
        
        
    }
    
    // MARK: Properties
    
    var posts: [Post] = []
}
