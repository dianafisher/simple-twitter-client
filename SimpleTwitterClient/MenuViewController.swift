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
    
    let menuItems: [NSDictionary] = [["text": "Profile", "color": UIColor.red],
                                     ["text": "Timeline", "color": UIColor.blue],
                                     ["text": "Mentions", "color": UIColor.green],
                                     ["text": "Accounts", "color": UIColor.orange]]
 
    var viewControllers: [UIViewController] = []
    var containerViewController: ContainerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        // Set the rowHeight to UITableViewAutomaticDimension to get the self-sizing behavior we want for the cell.
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set estimatedRowHeight to improve performance of loading the tableView
        tableView.estimatedRowHeight = 150
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        tweetsNavigationController = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController")
        
        viewControllers.append(tweetsNavigationController)
        
        containerViewController?.contentViewController = tweetsNavigationController
        
        // Set navigationBar tint colors
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1148131862, green: 0.6330112815, blue: 0.9487846494, alpha: 1)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

