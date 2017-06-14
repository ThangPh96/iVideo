//
//  ViewController.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/6/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit

class LoadingViewController: VideoAppViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let rootVC = storyboard.instantiateViewController(withIdentifier: "RootViewController") as! RootViewController
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = rootVC
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

