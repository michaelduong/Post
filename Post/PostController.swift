//
//  PostController.swift
//  Post
//
//  Created by Caleb Hicks on 5/16/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

class PostController {
    
    static let baseURL = URL(string: "https://devmtn-post.firebaseio.com/posts/")
    static let getterEndpoint = baseURL?.appendingPathExtension("json")
    
    init() {
        fetchPosts()
    }
    
    // MARK: Request
    
    func fetchPosts(reset: Bool = true, completion: (([Post]) -> Void)? = nil) {
        
        guard let requestURL = PostController.getterEndpoint else { fatalError("Post Endpoint url failed") }
        
        NetworkController.performRequest(for: requestURL, httpMethod: .get) { (data, error) in
            
            let responseDataString = String(data: data!, encoding: .utf8)
            
            guard let data = data,
                let postDictionaries = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: [String: Any]] else {
                    
                    NSLog("Unable to deserialize JSON. \nResponse: \(responseDataString)")
                    completion?([])
                    return
            }
            
            let posts = postDictionaries.flatMap { Post(json: $0.1, identifier: $0.0) }
            let sortedPosts = posts.sorted(by: { $0.0.timestamp > $0.1.timestamp })
            
            DispatchQueue.main.async {
                self.posts = sortedPosts
                completion?(sortedPosts)
            }
        }
    }
    
    // MARK: Properties
    
    weak var delegate: PostControllerDelegate?
    
    var posts: [Post] = [] {
        didSet {
            delegate?.postsWereUpdatedTo(posts: posts, on: self)
        }
    }
}

protocol PostControllerDelegate: class {
    
    func postsWereUpdatedTo(posts: [Post], on postController: PostController)
}
