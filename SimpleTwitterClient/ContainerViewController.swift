//
//  ContainerViewController.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 10/3/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    fileprivate var detailViewController: TestDetailViewController?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var menuContainerView: UIView!
    
    var showingMenu = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideOrShowMenu(show: false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func hideOrShowMenu(show: Bool, animated: Bool) {
        let menuOffset = menuContainerView.bounds.width
        
        scrollView.setContentOffset(show ? CGPoint.zero : CGPoint(x: menuOffset, y: 0), animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        menuContainerView.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
        hideOrShowMenu(show: showingMenu, animated: false)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "DetailViewSegue" {
            let navigationController = segue.destination as! UINavigationController
            detailViewController = navigationController.topViewController as? TestDetailViewController
        }
        
    }
    

    func transformForFraction(fraction:CGFloat) -> CATransform3D {
        var identity = CATransform3DIdentity
        identity.m34 = -1.0 / 1000.0;
        let angle = Double(1.0 - fraction) * -(Double.pi / 2)
        let xOffset = menuContainerView.bounds.width * 0.5
        let rotateTransform = CATransform3DRotate(identity, CGFloat(angle), 0.0, 1.0, 0.0)
        let translateTransform = CATransform3DMakeTranslation(xOffset, 0.0, 0.0)
        return CATransform3DConcat(rotateTransform, translateTransform)
    }
}

extension ContainerViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let multiplier = 1.0 / menuContainerView.bounds.width
        let offset = scrollView.contentOffset.x * multiplier
        let fraction = 1.0 - offset
        
        menuContainerView.layer.transform = transformForFraction(fraction: fraction)
        menuContainerView.alpha = fraction
        
        
//        if let detailViewController = detailViewController {
//            if let rotatingView = detailViewController.hamburgerView {
//                rotatingView.rotate(fraction)
//            }
//        }
        
        /*
         Fix for the UIScrollView paging-related issue mentioned here:
         http://stackoverflow.com/questions/4480512/uiscrollview-single-tap-scrolls-it-to-top
         */
        scrollView.isPagingEnabled = scrollView.contentOffset.x < (scrollView.contentSize.width - scrollView.frame.width)
        
        let menuOffset = menuContainerView.bounds.width
        showingMenu = !CGPoint(x: menuOffset, y: 0).equalTo(scrollView.contentOffset)

    }
}
