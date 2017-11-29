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
    
    init() {
        fetchPosts()
    }
    
    // MARK: Request
    
    func fetchPosts() {
        
        guard let baseURL = baseURL else { fatalError("Post endpoint url failed") }
        
        let requestURL = baseURL.appendingPathExtension("json")
        
        let dataTask = URLSession.shared.dataTask(with: requestURL, completionHandler: { (data, _, error) in
            
            if let error = error {
                NSLog("There was an error retrieving data in \(#function). Error: \(error)")
                return
            }
            
            guard let data = data else { NSLog("No data returned from data task."); return }
            
            do {
                let decoder = JSONDecoder()
                let postsDictionary = try decoder.decode([String:Post].self, from: data)
                let posts: [Post] = postsDictionary.flatMap( { $0.value })
                let sortedPosts = posts.sorted(by: { $0.timestamp > $1.timestamp })
                self.posts = sortedPosts
                
            } catch let error {
                NSLog("ERROR decoding: \(error.localizedDescription)")
            }
        })
        dataTask.resume()
    }
    
    func addPost(username: String, text: String) {
        
        let post = Post(username: username, text: text)
        
        guard let postData = try? JSONEncoder().encode(post) else { return }
        
        guard let baseURL = self.baseURL else { return }
        
        let requestURL = baseURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = "PUT"
        
        request.httpBody = postData
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error { NSLog(error.localizedDescription) }
            
            guard let data = data,
                let responseDataString = String(data: data, encoding: .utf8) else { NSLog("Data is nil. Unable to verify if data was able to be put to endpoint."); return }
            
            print("Successfully saved data to endpoint. \nResponse: \(responseDataString)")
            
            self.fetchPosts()
        }
        dataTask.resume()
    }
    
    // MARK: Properties
    
    weak var delegate: PostControllerDelegate?
    
    var posts: [Post] = [] {
        didSet {
            delegate?.postsWereUpdated()
        }
    }
}

protocol PostControllerDelegate: class {
    
    func postsWereUpdated()
}
