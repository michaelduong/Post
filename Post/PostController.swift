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
    
    let baseURL = URL(string: "https://devmtn-post.firebaseio.com/posts/")
    
    init() {
        fetchPosts()
    }
    
    // MARK: Request
    
    func fetchPosts() {
        
        guard let baseURL = baseURL else { fatalError("Post endpoint url failed") }
        
        let requestURL = baseURL.appendingPathExtension("json")
        
        let dataTask = URLSession.shared.dataTask(with: requestURL, completionHandler: { (data, _, error) in
            
            guard let data = data, let responseDataString = String(data: data, encoding: .utf8) else {
                NSLog("No data returned from data task")
                return
            }
            
            guard let postDictionaries = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: [String: Any]] else {
                
                NSLog("Unable to deserialize JSON. \nResponse: \(responseDataString)")
                return
            }
            
            let posts = postDictionaries.flatMap { Post(json: $0.value, identifier: $0.key) }
            
            let sortedPosts = posts.sorted(by: { $0.timestamp > $1.timestamp })
            
            
            self.posts = sortedPosts
            
        })
        
        dataTask.resume()
    }
    
    func addPost(username: String, text: String) {
        
        let post = Post(username: username, text: text)
        
        guard let baseURL = self.baseURL else { return }
        
        let requestURL = baseURL.appendingPathComponent(post.identifier.uuidString)
        
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = "PUT"
        
        request.httpBody = post.jsonData
        
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
