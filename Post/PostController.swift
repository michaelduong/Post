//
//  PostController.swift
//  Post
//
//  Created by Caleb Hicks on 5/16/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

class PostController {
    
    static let shared = PostController()
    
    let baseURL = URL(string: "https://dm-post.firebaseio.com/posts/")
    
    // MARK: Request
    
    func fetchPosts(completion: @escaping() -> Void) {
        
        guard let baseURL = baseURL else { fatalError("Post endpoint url failed") }
        
        let requestURL = baseURL.appendingPathExtension("json")
        
        let dataTask = URLSession.shared.dataTask(with: requestURL, completionHandler: { (data, _, error) in
            
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
                self.posts = sortedPosts
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
        
        guard let postData = try? JSONEncoder().encode(post) else { completion(); return }
        
        guard let baseURL = self.baseURL else { completion(); return }
        
        let requestURL = baseURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = "PUT"
        
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
