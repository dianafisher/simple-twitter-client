//
//  ProfileViewController.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 10/4/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    var hamburgerView: HamburgerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set navigationBar tint colors
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1148131862, green: 0.6330112815, blue: 0.9487846494, alpha: 1)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        // Remove the drop shadow from the navigation bar
//        navigationController!.navigationBar.clipsToBounds = true

        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.hamburgerViewTapped))
        hamburgerView = HamburgerView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        hamburgerView!.addGestureRecognizer(tapGestureRecognizer)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerView!)
        
    
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
