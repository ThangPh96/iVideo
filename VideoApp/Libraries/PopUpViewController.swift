//
//  PopUpViewController.swift
//  ChiaSeNhac
//
//  Created by Vũ Trung Thành on 1/9/16.
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit

public class PopUpViewController: UIViewController {
    
    private var widthConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    private var overlayView = UIView()
    
    var viewContainer = UIView()
    
    var viewDidLoadHandler: ((Void) -> Void)?
    
    var viewSize: CGSize = CGSize(width: 0.8*UIScreen.main.bounds.width, height: 0.5*UIScreen.main.bounds.height)
    
    init(size: CGSize) {
        super.init(nibName: nil, bundle: nil)
        self.viewSize = size
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        self.overlayView.backgroundColor = UIColor.black
        self.overlayView.alpha = 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PopUpViewController.hide))
        self.overlayView.addGestureRecognizer(tapGesture)
        
        self.viewContainer.backgroundColor = UIColor.white
        
        self.viewContainer.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.overlayView)
        self.view.addSubview(self.viewContainer)
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[overlayView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["overlayView": overlayView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[overlayView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["overlayView": overlayView]))
        
        widthConstraint = NSLayoutConstraint(item: viewContainer, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0, constant: viewSize.width)
        heightConstraint = NSLayoutConstraint(item: viewContainer, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0, constant: viewSize.height)
        self.view.addConstraints([widthConstraint, heightConstraint])
        self.view.addConstraints([
            NSLayoutConstraint(item: viewContainer, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: viewContainer, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0)
            ])
        
        self.viewContainer.alpha = 0
        UIView.animate(withDuration: 0.3) { () -> Void in
            self.viewContainer.alpha = 1
            self.overlayView.alpha = 0.5
        }
        
        viewDidLoadHandler?()
    }
    
    public func hide() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.alpha = 0
            }) { (bool) -> Void in
                self.willMove(toParentViewController: nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        }
    }
    
    public func showInViewController(viewController: UIViewController) {
        viewController.addChildViewController(self)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(self.view)
        viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["view": self.view]))
        viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["view": self.view]))
        self.didMove(toParentViewController: viewController)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
