//
//  TestDetailViewController.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 10/3/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class TestDetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Remove the drop shadow from the navigation bar
        navigationController!.navigationBar.clipsToBounds = true
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
