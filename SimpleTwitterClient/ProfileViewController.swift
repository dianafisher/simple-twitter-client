//
//  ProfileViewController.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 10/4/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit
import MBProgressHUD
import FXBlurView

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var tweetsTableView: UITableView!
    @IBOutlet weak var tweetCountLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    
    var hamburgerView: HamburgerView?
    var blurredHeaderImageView:UIImageView?
    var headerBlurImageView:UIImageView?
    var refreshControl: UIRefreshControl!
    var loadingMoreView: InfiniteScrollActivityView?
    
    var tweets: [Tweet]!
    var user: User!
    var isMoreDataLoading = false
    var lastLoadedTweetId: String?

    let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
    let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
    let distance_W_LabelHeader:CGFloat = 35.0 // The distance between the bottom of the Header and the top of the White Label

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user == nil {
            user = User.currentUser
        }

        // Set navigationBar tint colors
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1148131862, green: 0.6330112815, blue: 0.9487846494, alpha: 1)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        navigationItem.title = user.name
        
        
        // Remove the drop shadow from the navigation bar
//        navigationController!.navigationBar.clipsToBounds = true
                
        // Set the corner radius to 50% of width to get round profile image
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
        setupHeaderView()
        setupTableView()
        
        setupLoadingMoreView()
        setupRefreshControl()
        requestUserTweets()
    }
    
    func setupHeaderView() {
        
        headerBlurImageView = UIImageView(frame: headerView.bounds)
        headerBlurImageView?.contentMode = UIViewContentMode.scaleAspectFill
        
        
        if let user = user {
            nameLabel.text = user.name
            screenNameLabel.text = "@\(user.screenname ?? "")"
            taglineLabel.text = user.tagline
            followersCountLabel.text = "\(user.followersCount)"
            followingCountLabel.text = "\(user.friendsCount)"
            tweetCountLabel.text = "\(user.statusesCount)"
            locationLabel.text = user.location
            
            if let profileImageUrl = user.profileUrl
            {
                Utils.fadeInImageAt(url: profileImageUrl, placeholderImage: #imageLiteral(resourceName: "placeholder_profile"), imageView: profileImageView)
            }
            
            if let headerImageUrl = user.profileBackgroundUrl {

                let imageRequest = URLRequest(url: headerImageUrl)
                headerImageView.setImageWith(imageRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) in
                    self.headerImageView.alpha = 0.0
                    self.headerImageView.image = image
                    self.headerBlurImageView?.image = image.blurredImage(withRadius: 10, iterations: 20, tintColor: UIColor.clear)
                    UIView.animate(withDuration: 0.3, animations: {
                        self.headerImageView.alpha = 1.0
                    })
                }) { (imageRequest, imageResponse, error) in
                    log.error(error)
                    self.headerImageView.image = nil
                }
            }
            
        } else {
            nameLabel.text = ""
            screenNameLabel.text = ""
            taglineLabel.text = ""
            followersCountLabel.text = "0"
            followingCountLabel.text = "0"
            tweetCountLabel.text = "0"
            locationLabel.text = "0"
        }
        
        headerBlurImageView?.alpha = 0.0
        headerView.insertSubview(headerBlurImageView!, belowSubview: headerLabel)
        headerView.clipsToBounds = true
        
        
                        
    }
    
    fileprivate func setupRefreshControl() {
        // Initialize a UIRefreshControl
        refreshControl = UIRefreshControl()
        
        // Set the background color and tint of the refresh control
        refreshControl.backgroundColor = UIColor.white
        refreshControl.tintColor = #colorLiteral(red: 0.1148131862, green: 0.6330112815, blue: 0.9487846494, alpha: 1)
        
        // Bind refreshControlAction as the target for our refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        
        // Add the refresh control to the table view
        tweetsTableView.refreshControl = refreshControl
        
    }
    
    fileprivate func setupLoadingMoreView() {
        // Set up the InfiniteScrollActivityView loading indicator
        let loadingViewFrame = CGRect(x: 0,
                                      y: tweetsTableView.contentSize.height,
                                      width: tweetsTableView.bounds.size.width,
                                      height: InfiniteScrollActivityView.defaultHeight)
        
        loadingMoreView = InfiniteScrollActivityView(frame: loadingViewFrame)
        loadingMoreView!.isHidden = true
        tweetsTableView.addSubview(loadingMoreView!)
        
        // Adjust the table view insets to make room for the activity view
        var insets = tweetsTableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tweetsTableView.contentInset = insets
        
    }
    
    fileprivate func requestUserTweets() {
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        TwitterClient.sharedInstance?.userTimeline(user: user, sinceId: nil, maxId: nil, success: { [weak self] (tweets: [Tweet]) in
            
             self?.tweets = tweets
            
            self?.lastLoadedTweetId = tweets.last?.idString
            
            self?.tweetsTableView.reloadData()
            
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                self?.loadingMoreView?.stopAnimating()
                MBProgressHUD.hide(for: self!.view, animated: true)
            }
            
            }, failure: { (error:Error) in
                log.error(error.localizedDescription)
        })
    }
    
    fileprivate func loadMoreData() {
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        TwitterClient.sharedInstance?.userTimeline(user: user, sinceId: nil, maxId: lastLoadedTweetId, success: { [weak self] (tweets: [Tweet]) in
            
            self?.tweets.append(contentsOf: tweets)
            
            self?.lastLoadedTweetId = tweets.last?.idString
            
            self?.tweetsTableView.reloadData()
            
            self?.isMoreDataLoading = false
            
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                self?.loadingMoreView?.stopAnimating()
                MBProgressHUD.hide(for: self!.view, animated: true)
            }
            
            }, failure: { (error:Error) in
                log.error(error.localizedDescription)
        })
        
    }
    
    fileprivate func setupTableView() {
        tweetsTableView.dataSource = self
        tweetsTableView.delegate = self
        
        let tweetTableViewCellNib = UINib(nibName: "TweetTableViewCell", bundle: nil)
        tweetsTableView.register(tweetTableViewCellNib, forCellReuseIdentifier: Constants.CellReuseIdentifier.TweetTableCell)
        
        // Set the rowHeight to UITableViewAutomaticDimension to get the self-sizing behavior we want for the cell.
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        
        // Set estimatedRowHeight to improve performance of loading the tableView
        tweetsTableView.estimatedRowHeight = 330
    }
    
    func hamburgerViewTapped() {
        let navigationController = parent as! UINavigationController
        
//        let containerViewController = navigationController.parent as! ContainerViewController
//        containerViewController.hideOrShowMenu()
        
        guard navigationController.parent != nil else {
            print("parent is nil")
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - UIRefreshControl action
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {        
        requestUserTweets()
    }

}

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tweets = self.tweets else {
            return 0
        }
        
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIdentifier.TweetTableCell, for: indexPath) as! TweetTableViewCell
        cell.mediaImageView.image = nil
        cell.tweet = tweets[indexPath.row]
        cell.delegate = self
        return cell
    }
    
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Show the details view for the selected tweet
        
        let tweet = tweets[indexPath.row]
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifier.DetailViewController) as? DetailViewController
        vc?.tweet = tweet
        
        navigationController?.pushViewController(vc!, animated: true)
    }
}

extension ProfileViewController: TweetTableViewCellDelegate {
    
    func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, replyTo tweet: Tweet) {
   
        // show the compose controller
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let navVC = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifier.ComposeNavigationController) as? UINavigationController
        
        let vc = navVC?.topViewController as? ComposeViewController
        if vc != nil {
            vc!.replyToTweet = tweet
            present(navVC!, animated: true, completion: {
                
            })
        }
    }
    
    func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, retweet tweet: Tweet) {
        
        let indexPath = tweetsTableView.indexPath(for: tweetTableViewCell)!
        let row = indexPath.row
        
        if let tweetId = tweet.idString {
            
            // Determine if this is a retweet or an unretweet action.
            if tweet.hasRetweeted {
                log.info("Calling unretweet on \(tweetId)")
                
                // Call the unretweet api
                TwitterClient.sharedInstance?.unretweet(tweetId: tweetId, success: { [weak self] (updatedTweet) in
                    
                    log.info("original tweet id: \(tweetId), updated tweet id: \(String(describing: updatedTweet.idString))")
                    
                    updatedTweet.hasRetweeted = false
                    
                    self?.tweets[row] = updatedTweet
                    
                    DispatchQueue.main.async {
                        self?.tweetsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }
                    
                    }, failure: { (error: Error) in
                        log.verbose("Error: \(error.localizedDescription)")
                })
                
            } else {
                log.info("Calling retweet on \(tweetId)")
                TwitterClient.sharedInstance?.retweet(tweetId: tweetId, success: { [weak self] (updatedTweet) in
                    
                    log.info("original tweet id: \(tweetId), updated tweet id: \(String(describing: updatedTweet.idString))")
                    
                    self?.tweets[row] = updatedTweet
                    
                    DispatchQueue.main.async {
                        self?.tweetsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }
                    
                    }, failure: { (error: Error) in
                        log.verbose("Error: \(error.localizedDescription)")
                })
            }
        }
    }
    
    func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, favorite tweet: Tweet) {
        
        let indexPath = tweetsTableView.indexPath(for: tweetTableViewCell)!
        let row = indexPath.row
        
        if let tweetId = tweet.idString {
            
            // Determine if this is a favorite or an unfavorite action.
            if tweet.hasFavorited {
                
                // Call the unretweet api
                TwitterClient.sharedInstance?.unlikeTweet(tweetId: tweetId, success: { [weak self] (updatedTweet) in
                    
                    self?.tweets[row] = updatedTweet
                    
                    DispatchQueue.main.async {
                        self?.tweetsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }
                    
                    }, failure: { (error: Error) in
                        log.verbose("Error: \(error.localizedDescription)")
                })
                
            } else {
                TwitterClient.sharedInstance?.likeTweet(tweetId: tweetId, success: { [weak self] (updatedTweet) in
                    
                    self?.tweets[row] = updatedTweet
                    
                    DispatchQueue.main.async {
                        self?.tweetsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }
                    
                    }, failure: { (error: Error) in
                        log.verbose("Error: \(error.localizedDescription)")
                })
            }
        }
    }
    
    func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, showUserProfile user: User) {
        log.verbose("Show profile for user: \(String(describing: user))")
        
        let navVC = Utils.instantiateNavController(identifier: Constants.ViewControllerIdentifier.ProfileNavigationController)
        let vc = navVC?.topViewController as? ProfileViewController
        if vc != nil {
            vc!.user = user
            navigationController?.pushViewController(vc!, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension ProfileViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Handle scroll behavior
        
        let offset = scrollView.contentOffset.y
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        // Pull Down
        if offset < 0 {
            let headerScaleFactor:CGFloat = -(offset) / headerView.bounds.height
            let headerSizevariation = ((headerView.bounds.height * (1.0 + headerScaleFactor)) - headerView.bounds.height)/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            headerImageView.layer.transform = headerTransform
        } else {
            // Scroll up/down
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
            headerLabel.layer.transform = labelTransform
            
            headerBlurImageView?.alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / profileImageView.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((profileImageView.bounds.height * (1.0 + avatarScaleFactor)) - profileImageView.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                if profileImageView.layer.zPosition < headerView.layer.zPosition{
                    headerView.layer.zPosition = 0
                }
                
            } else {
                if profileImageView.layer.zPosition >= headerView.layer.zPosition{
                    headerView.layer.zPosition = 2
                }
            }
            
            // Apply Transformations
            
            headerView.layer.transform = headerTransform
            profileImageView.layer.transform = avatarTransform
        }
        
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tweetsTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tweetsTableView.bounds.size.height
            
            // When the user has scrolled beyond the threshold, request more data
            if (scrollView.contentOffset.y > scrollOffsetThreshold && tweetsTableView.isDragging) {
                
                isMoreDataLoading = true
                
                // Update position of loading indicator
                let frame = CGRect(x: 0,
                                   y: tweetsTableView.contentSize.height,
                                   width: tweetsTableView.bounds.size.width,
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
