//
//  TweetsViewController.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/25/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

private let detailsSegueIdentifier = "DetailsSegue"
private let composeSegueIdentifier = "ComposeSegue"
private let tweetCellIdentifier = "TweetCell"

// twitter blue = #1DA1F2


class TweetsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    var loadingMoreView: InfiniteScrollActivityView?
    
    var tweets: [Tweet]!
    
    var isMoreDataLoading = false
    
    var lastLoadedTweetId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupRefreshControl()
        setupLoadingMoreView()
        
        requestTweets()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        
        // Set the rowHeight to UITableViewAutomaticDimension to get the self-sizing behavior we want for the cell.
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set estimatedRowHeight to improve performance of loading the tableView
        tableView.estimatedRowHeight = 150
    }
    
    func setupRefreshControl() {
        // Initialize a UIRefreshControl
        refreshControl = UIRefreshControl()
        
        // Set the background color and tint of the refresh control
        refreshControl.backgroundColor = UIColor.gray
        refreshControl.tintColor = UIColor.white
        
        // Bind refreshControlAction as the target for our refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        
        // Add the refresh control to the table view
        tableView.refreshControl = refreshControl
        
    }
    
    func setupLoadingMoreView() {
        // Set up the InfiniteScrollActivityView loading indicator
        let loadingViewFrame = CGRect(x: 0,
                                      y: tableView.contentSize.height,
                                      width: tableView.bounds.size.width,
                                      height: InfiniteScrollActivityView.defaultHeight)
        
        loadingMoreView = InfiniteScrollActivityView(frame: loadingViewFrame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)

        // Adjust the table view insets to make room for the activity view
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIRefreshControl action
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        requestTweets()
    }
    
    // MARK: - Logout action
    
    @IBAction func onLogoutPressed(_ sender: Any) {
        TwitterClient.sharedInstance?.logout()
    }
    
    // MARK: Network request
    
    func requestTweets() {
        TwitterClient.sharedInstance?.homeTimeline(sinceId: nil, maxId: nil, success: { (tweets: [Tweet]) in
            log.info("I got the tweets!")
            log.info(tweets.count)
            
            self.tweets = tweets
            
            self.lastLoadedTweetId = tweets.last?.idString
            
            self.tableView.reloadData()
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.loadingMoreView?.stopAnimating()
            }
            
        }, failure: { (error:Error) in
            log.error(error.localizedDescription)
        })
    }
    
    fileprivate func loadMoreData() {
        
        TwitterClient.sharedInstance?.homeTimeline(sinceId: nil, maxId: lastLoadedTweetId, success: { (tweets: [Tweet]) in
            log.info("I got more tweets!")
            log.info(tweets.count)
            
            self.tweets.append(contentsOf: tweets)
            
            self.lastLoadedTweetId = tweets.last?.idString
            
            self.tableView.reloadData()
            
            self.isMoreDataLoading = false
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.loadingMoreView?.stopAnimating()
            }
            
        }, failure: { (error:Error) in
            log.error(error.localizedDescription)
        })

    }
        
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == detailsSegueIdentifier {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            let tweet = tweets?[indexPath!.row]
            
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.tweet = tweet
        }
        
        
        
    }

}

extension TweetsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tweets = self.tweets else {
            return 0
        }
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tweetCellIdentifier, for: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
                
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension TweetsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Handle scroll behavior
        
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled beyond the threshold, request more data
            if (scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                
                isMoreDataLoading = true

                // Update position of loading indicator
                let frame = CGRect(x: 0,
                                   y: tableView.contentSize.height,
                                   width: tableView.bounds.size.width,
                                   height: InfiniteScrollActivityView.defaultHeight)
                
                loadingMoreView?.frame = frame
                
                // Start loading indicator
                loadingMoreView!.startAnimating()
                
                // Request more data
                self.loadMoreData()
                
            }
            
        }
    }
}


