//
//  TumblrViewController.swift
//  TumblrCodePath
//
//  Created by Micah Peoples on 2/2/17.
//  Copyright © 2017 micah. All rights reserved.
//

import UIKit
import AFNetworking

class TumblrViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    let clientID = "Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
    var posts : [NSDictionary] = []
    var isDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    var postsOffset = 0
    var tumblrAPIURLString = ""
    var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tumblrAPIURLString = "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV&offset=\(postsOffset)"
        
        // Initialize UIRefreshControl
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl!, at: 0)
        
        // Initialize infinite scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        // Load initial data
        loadData(endLoadingMore: false, endRefreshing: false)
    }
    
    func loadData(endLoadingMore: Bool, endRefreshing: Bool) {
        if endRefreshing {
//            print("resetting posts offset")
            self.postsOffset = 0
            self.posts = []
            self.tableView.reloadData()
        }
        
        // Update api string with new offset
        tumblrAPIURLString = "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV&offset=\(postsOffset)"
        
        //print("api string: \(self.tumblrAPIURLString)")
        
        let url = URL(string: tumblrAPIURLString)
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let responseDict = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.isDataLoading = false
                    self.loadingMoreView!.stopAnimating()
                    
                    let response = responseDict["response"] as! NSDictionary
                    let posts = response["posts"] as! [NSDictionary]
                    self.postsOffset += posts.count
                    
                    //print("After request, posts offset: \(self.postsOffset)")
                    
                    self.posts.append(contentsOf: posts)
                    self.tableView.reloadData()
                    
                    if (endRefreshing) {
                        // Tell refreshControl to stop spinning
                        self.refreshControl!.endRefreshing()
                    }
                    
                    if (endLoadingMore) {
                        // Stop the loading indicator
                        self.loadingMoreView!.stopAnimating()
                    }
                    
                    self.isDataLoading = false
                }
            }
        });
        task.resume()
    }
    
    // Called when tableView scrolls
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isDataLoading) {
            
            // Calculate the position of one screen length from the bottom of table
            let scrollViewContentHeight = scrollView.contentSize.height
            let scrollViewOffsetThreshold = scrollViewContentHeight - scrollView.bounds.height
            
            // When a user is past the threshold, start request
            if (scrollView.contentOffset.y >= scrollViewOffsetThreshold && scrollView.isDragging) {
                isDataLoading = true
                
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                loadData(endLoadingMore: true, endRefreshing: false)
            }
        }
    }
    
    // Makes call to refresh data
    // Updates table view with new data
    // Hides refresh control
    func refreshControlAction(refreshControl: UIRefreshControl) {
        if (!isDataLoading) {
            isDataLoading = true
            loadData(endLoadingMore: false, endRefreshing: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("in cell for row")
        let cell = tableView.dequeueReusableCell(withIdentifier: "tumblrCell") as! TumblrCell
        //        cell.label.text = "Row \(indexPath.row)"
        let post = posts[indexPath.row]
        let summary = post.value(forKeyPath: "summary") as? String
        cell.label.text = summary
        if let photos = post["photos"] as? [NSDictionary] {
            let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
            if let imageURL = URL(string: imageUrlString!) {
                cell.pictureView.setImageWith(imageURL)
            } else {
                print("image url probz")
            }
            
        }
        
        //cell.label.text = "Row"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as! PhotoDetailsViewController
        if let indexPath = tableView.indexPath(for: (sender as? UITableViewCell)!) {
//        print(indexPath)
        let post = self.posts[(indexPath.row)]
            if let photos = post["photos"] as? [NSDictionary] {
                let photo = photos[0].value(forKeyPath: "original_size.url") as! String
                vc.imageURL = photo
            }
        }
    }


}
