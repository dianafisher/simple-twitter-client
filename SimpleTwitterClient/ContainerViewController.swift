//
//  ContainerViewController.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 10/4/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
    
    var originalLeftMargin: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {

        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)

        switch(sender.state) {
        case UIGestureRecognizerState.began:
//            log.verbose("Started panning")
            originalLeftMargin = leftMarginConstraint.constant
            break
        case UIGestureRecognizerState.changed:
//            log.verbose("Panning..")
            leftMarginConstraint.constant = originalLeftMargin + translation.x
            break
        case UIGestureRecognizerState.ended:
//            log.verbose("Ended panning")
            
            UIView.animate(withDuration: 0.3, animations: {
                if velocity.x > 0 {
                    self.leftMarginConstraint.constant = self.view.frame.size.width - 50
                } else {
                    self.leftMarginConstraint.constant = 0
                }
                self.view.layoutIfNeeded()
            })
            
            break
        default:
            break
        }
        
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
