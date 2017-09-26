//
//  LoginViewController.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/25/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let baseUrl = URL(string: "https://api.twitter.com")
let consumerKey: String = "2I62mbCjt75gMmxa6zgACtNij"
let consumerSecret: String = "Wz9iQTnjpCEQXT5o5KMLj7asB7qUI9sbGNYAvNDEGF9Y3hzzcA"

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginPressed(_ sender: Any) {
        
        let client = TwitterClient.sharedInstance
        
        client?.login(success: {
            print("I've logged in! 🎉")
            
        }, failure: { (error: Error) in
            print("Error: \(error.localizedDescription)")
        })
        
        
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
