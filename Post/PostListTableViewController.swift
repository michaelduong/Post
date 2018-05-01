//
//  PostListTableViewController.swift
//  Post
//
//  Created by Michael Duong on 1/30/18.
//  Copyright © 2018 Turnt Labs. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {

    @IBAction func createPost(_ sender: Any) {
        presentNewPostAlert()
    }
    
    func presentNewPostAlert() {
        let alertController = UIAlertController(title: "New Post", message: nil, preferredStyle: .alert)
        
        var usernameTextField: UITextField?
        var postTextField: UITextField?
        
        alertController.addTextField { (usernameText) in
            usernameText.placeholder = "Enter username"
            usernameTextField = usernameText
        }
        
        alertController.addTextField { (postText) in
            postText.placeholder = "Enter post"
            postTextField = postText
        }
        
        let postAction = UIAlertAction(title: "Post", style: .default) { (action) in
            guard let username = usernameTextField?.text, !username.isEmpty, let post = postTextField?.text, !post.isEmpty else {
                self.presentErrorAlert()
                return
            }
            PostController.shared.addNewPostWith(username: username, text: post, completion: {_ in
                self.reloadTableView()
            })
        }
        alertController.addAction(postAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentErrorAlert() {
        
        let alertController = UIAlertController(title: "Error", message: "You're missing data. Try again.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func pullToRefresh(_ sender: UIRefreshControl) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        PostController.shared.fetchPosts() {_ in
            self.reloadTableView()
            DispatchQueue.main.async {
            sender.endRefreshing()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        PostController.shared.fetchPosts() {_ in
            self.reloadTableView()
            DispatchQueue.main.async {
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        PostController.shared.fetchPosts() {_ in
            self.reloadTableView()
            DispatchQueue.main.async {
            }
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return PostController.shared.posts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        let posts = PostController.shared.posts[indexPath.row]
        
        cell.textLabel?.text = posts.text
        cell.detailTextLabel?.text = "\(posts.username) - \(posts.timestamp)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= PostController.shared.posts.count - 1 {
            PostController.shared.fetchPosts(reset: false, completion: { _ in
                self.reloadTableView()
            })
        }
    }
}
