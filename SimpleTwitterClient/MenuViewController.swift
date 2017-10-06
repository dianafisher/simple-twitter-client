//
//  MenuViewController.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 10/4/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var tweetsNavigationController: UIViewController!
    fileprivate var profileNavigationController: UIViewController!
    fileprivate var mentionsNavigationController: UIViewController!
    fileprivate var accountsNavigationController: UIViewController!
    
    let menuItems: [NSDictionary] = [["text": "Profile", "viewControllerIdentifier": "ProfileNavigationController"],
                                     ["text": "Timeline", "viewControllerIdentifier": "TweetsNavigationController"],
                                     ["text": "Mentions", "viewControllerIdentifier": "MentionsNavigationController"],
                                     ["text": "Accounts", "viewControllerIdentifier": "AccountsNavigationController"]]
 
    var viewControllers: [UIViewController] = []
    var containerViewController: ContainerViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Remove the drop shadow from the navigation bar
//        navigationController!.navigationBar.clipsToBounds = true
        
        setupTableView()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        profileNavigationController = storyboard.instantiateViewController(withIdentifier: "ProfileNavigationController")
        tweetsNavigationController = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController")
        mentionsNavigationController = storyboard.instantiateViewController(withIdentifier: "MentionsNavigationController")
        accountsNavigationController = storyboard.instantiateViewController(withIdentifier: "AccountsNavigationController")
        
        viewControllers.append(profileNavigationController)
        viewControllers.append(tweetsNavigationController)
        viewControllers.append(mentionsNavigationController)
        viewControllers.append(accountsNavigationController)
        
        containerViewController?.contentViewController = tweetsNavigationController
        
        // Set navigationBar tint colors
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1148131862, green: 0.6330112815, blue: 0.9487846494, alpha: 1)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        // Set the rowHeight to UITableViewAutomaticDimension to get the self-sizing behavior we want for the cell.
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set estimatedRowHeight to improve performance of loading the tableView
        tableView.estimatedRowHeight = 150
    }
    
}

extension MenuViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell") as! MenuItemCell
        let menuItem = menuItems[indexPath.row]
        
        cell.configureForMenuItem(menuItem)
        return cell
    }
}

extension MenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
                
        containerViewController?.contentViewController = viewControllers[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.size.height / CGFloat(menuItems.count)
    }
}

