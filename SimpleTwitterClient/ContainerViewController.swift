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
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    var originalLeftMargin: CGFloat!

    var menuViewController: UIViewController! {
        didSet(oldMenuViewController) {
            view.layoutIfNeeded()
            
            if oldMenuViewController != nil {
                oldMenuViewController.willMove(toParentViewController: nil)
                oldMenuViewController.view.removeFromSuperview()
                oldMenuViewController.didMove(toParentViewController: nil)
            }
            
            menuView.addSubview(menuViewController.view)
        }
    }
    
    var contentViewController: UIViewController! {
        didSet(oldContentViewController) {
            
            view.layoutIfNeeded()
            
            if oldContentViewController != nil {
                oldContentViewController.willMove(toParentViewController: nil)
                oldContentViewController.view.removeFromSuperview()
                oldContentViewController.didMove(toParentViewController: nil)
            }
            
            contentViewController.willMove(toParentViewController: self)
            contentView.addSubview(contentViewController.view)
            
            // Call didMove(toParentViewController parent: UIViewController?) after a view controller is added or removed from a container view controller.
            contentViewController.didMove(toParentViewController: self)
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.leftMarginConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
            
        }
    }
    
    func hideOrShowMenu() {
        print("hide or show menu")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        panGestureRecognizer.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {

        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        if sender.state == .began {
            originalLeftMargin = leftMarginConstraint.constant
            
        } else if sender.state == .changed {
            leftMarginConstraint.constant = originalLeftMargin + translation.x
            
        } else if sender.state == .ended {
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 2,
                options: UIViewAnimationOptions.curveEaseIn,
                animations: {
                    if velocity.x > 0 {
                        self.leftMarginConstraint.constant = self.view.frame.size.width - 50
                    } else {
                        self.leftMarginConstraint.constant = 0
                    }
                    self.view.layoutIfNeeded()
                },
                completion: nil)
        }
        
    }
}

extension ContainerViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer
        let velocity = panGestureRecognizer?.velocity(in: view) ?? CGPoint.zero
        
//        log.info("velocity: \(velocity)")
        let leftMargin = leftMarginConstraint.constant
//        log.info("leftMargin: \(leftMargin)")
        
        // Do not allow the user to move the content view towards the left unless it is on the right-hand side of the screen.
        if leftMargin == 0.0 && velocity.x < 0.0 {
            
            return false
        }
        
        return true
    }
}

