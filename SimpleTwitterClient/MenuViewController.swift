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
    
    let menuItems: [NSDictionary] = [["text": "Profile", "color": UIColor.red],
                                     ["text": "Timeline", "color": UIColor.blue],
                                     ["text": "Mentions", "color": UIColor.green],
                                     ["text": "Accounts", "color": UIColor.orange]]
 
    var viewControllers: [UIViewController] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
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
        
        
    }
}

