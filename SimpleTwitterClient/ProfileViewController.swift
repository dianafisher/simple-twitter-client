//
//  ProfileViewController.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 10/4/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit
import MBProgressHUD

private let tweetTableViewCellIdentifier = "TweetTableViewCell"


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
    
    var hamburgerView: HamburgerView?
    var tweets: [Tweet]!
    var user: User! {
        didSet {
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
                Utils.fadeInImageAt(url: headerImageUrl, placeholderImage: #imageLiteral(resourceName: "placeholder_profile"), imageView: headerImageView)
            }
            
            
        }
    }
    
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
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.hamburgerViewTapped))
        hamburgerView = HamburgerView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        hamburgerView!.addGestureRecognizer(tapGestureRecognizer)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerView!)
        
        // Set the corner radius to 50% of width to get round profile image
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
        setupTableView()
        
        requestUserTweets()
    }
    
    func requestUserTweets() {
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        TwitterClient.sharedInstance?.userTimeline(user: user, sinceId: nil, maxId: nil, success: { [weak self] (tweets: [Tweet]) in
            log.info("I got the tweets!")
            log.info(tweets.count)
            
            
            
            self?.tweets = tweets
            
//            self?.lastLoadedTweetId = tweets.last?.idString
            
            self?.tweetsTableView.reloadData()
            
            DispatchQueue.main.async {
//                self?.refreshControl.endRefreshing()
//                self?.loadingMoreView?.stopAnimating()
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
        tweetsTableView.register(tweetTableViewCellNib, forCellReuseIdentifier: tweetTableViewCellIdentifier)
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tweets = self.tweets else {
            return 0
        }
        
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tweetTableViewCellIdentifier, for: indexPath) as! TweetTableViewCell
        cell.mediaImageView.image = nil
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
    
}

extension ProfileViewController: UITableViewDelegate {
    
}
