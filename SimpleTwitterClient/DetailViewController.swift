//
//  DetailViewController.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/27/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

private let tweetDetailCellIdentifier = "TweetDetailCell"
private let tweetStatsCellIdentifier = "TweetStatsCell"

class DetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var tweet: Tweet!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        
        // Set estimatedRowHeight to improve performance of loading the tableView
        tableView.estimatedRowHeight = 270
        // Set the rowHeight to UITableViewAutomaticDimension to get the self-sizing behavior we want for the cell.
        tableView.rowHeight = UITableViewAutomaticDimension
        
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
        
        if segue.identifier == "ReplySegue" {
            print("reply!")
        }
    }


}

extension DetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: tweetDetailCellIdentifier, for: indexPath) as! TweetDetailCell
            cell.tweet = tweet
            return cell
        } else if section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: tweetStatsCellIdentifier, for: indexPath) as! TweetStatsCell
            cell.tweet = tweet
            return cell
        } else if section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TweetOptionsCell", for: indexPath) as! TweetOptionsCell
            cell.tweet = tweet
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: tweetStatsCellIdentifier, for: indexPath) as! TweetStatsCell
            cell.tweet = tweet
            return cell
        }
        
    }
    
}

extension DetailViewController: UITableViewDelegate {
       
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section > 0 {
            return 60.0
        } else {
            return 270.0
        }
    }
}
