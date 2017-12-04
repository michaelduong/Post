//
//  PostListTableViewController.swift
//  Post
//
//  Created by Caleb Hicks on 5/16/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {
    
    let postController = PostController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        postController.fetchPosts {
            self.reloadTableView()
        }
    }
    
    // MARK: Actions
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
        
        presentNewPostAlert()
    }
    
    @IBAction func refreshControlPulled(_ sender: UIRefreshControl) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        postController.fetchPosts {
            self.reloadTableView()
            DispatchQueue.main.async {
                sender.endRefreshing()
            }
        }
    }
    
    func reloadTableView() {
        
        DispatchQueue.main.async {

            self.tableView.reloadData()
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    func presentNewPostAlert() {
        let alertController = UIAlertController(title: "New Post", message: nil, preferredStyle: .alert)
        
        var usernameTextField: UITextField?
        var messageTextField: UITextField?
        
        alertController.addTextField { (usernameField) in
            usernameField.placeholder = "Display name"
            usernameTextField = usernameField
        }
        
        alertController.addTextField { (messageField) in
            
            messageField.placeholder = "What's up?"
            messageTextField = messageField
        }
        
        let postAction = UIAlertAction(title: "Post", style: .default) { (action) in
            
            guard let username = usernameTextField?.text, !username.isEmpty,
                let text = messageTextField?.text, !text.isEmpty else {
                    
                    self.presentErrorAlert()
                    return
            }
            
            self.postController.addPost(username: username, text: text, completion: {
                self.reloadTableView()
            })
            
        }
        alertController.addAction(postAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentErrorAlert() {
        
        let alertController = UIAlertController(title: "Uh oh!", message: "You may be missing information or have network connectivity issues. Please try again.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: UITableViewDataSource/Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postController.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        let post = postController.posts[indexPath.row]
        
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(indexPath.row) - \(post.username) - \(Date(timeIntervalSince1970: post.timestamp))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if indexPath.row >= postController.posts.count - 1 {
            postController.fetchPosts(reset: false, completion: {
                self.reloadTableView()
            })
        }
    }
}
