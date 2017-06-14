//
//  BottomMenuView.swift
//  demoBottomMenuView
//
//  Created by Phan Hữu Thắng on 1/6/16.
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit

protocol BottomMenuViewDelegate {
    func bottomMenuViewDidDisAppear(viewController: BottomMenuView)
    func bottomMenuViewDidSelected(viewController: BottomMenuView, index: Int)
}

public class BottomMenuViewItem: NSObject {
    var icon: UIImage?
    var title: String?
    var selectedAction: ((Void) ->Void)?
    init(icon: UIImage?, title: String?, selectedAction: ((Void)->Void)?){
        super.init()
        self.icon = icon
        self.title = title
        self.selectedAction = selectedAction
    }
    init(icon: UIImage?, title: String?) {
        super.init()
        self.icon = icon
        self.title = title
    }
    init(title: String?, selectedAction: ((Void)->Void)?) {
        super.init()
        self.title = title
        self.selectedAction = selectedAction
    }
    init(title: String?) {
        super.init()
        self.title = title
    }
}

public class BottomMenuView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let reuseCellIdentifierSetting: String = "MusicSettingCell"
    private var viewAlpha: UIView!
    private let tableView = UITableView()
    
    var delegate: BottomMenuViewDelegate?
    
    var items: [BottomMenuViewItem] = []
    
    var itemAgliment: ItemAlignment = .Left
    
    var didSelectedItemHandler: ((Int) ->Void)?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        viewAlpha = UIView(frame: self.view.frame)
        self.viewAlpha.backgroundColor = UIColor.black
        self.viewAlpha.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BottomMenuView.hide))
        self.viewAlpha.addGestureRecognizer(tapGesture)
        self.view .addSubview(viewAlpha)
        
        
        // TableView
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.bounces = false
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseCellIdentifierSetting)
        self.tableView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(self.tableView)
        
        UIView.animate(withDuration: 0.3) { () -> Void in
            self.viewAlpha.alpha = 0.5
        }
        
        showTableView()
    }
    
    init(items: [BottomMenuViewItem], didSelectedHandler: ((Int) -> Void)?) {
        super.init(nibName: nil, bundle: nil)
        self.items = items
        self.didSelectedItemHandler = didSelectedHandler
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func showInViewController(viewController: UIViewController) {
        viewController.addChildViewController(self)
        self.view.frame = viewController.view.frame
//        UIApplication.sharedApplication().windows[0].addSubview(self.view)
        viewController.view.addSubview(self.view)
        self.didMove(toParentViewController: viewController)
    }
    
    public func hide() {
        UIView.animate(withDuration: 0.3) { () -> Void in
            self.viewAlpha.alpha = 0
        }
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.tableView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
            }) { (bool) -> Void in
                self.willMove(toParentViewController: nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    @nonobjc public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellIdentifierSetting, for: indexPath) as UITableViewCell
        if let icon = self.items[indexPath.row].icon {
            cell.imageView?.image = icon
        }
        if let title = self.items[indexPath.row].title {
            cell.textLabel?.text = title
        }
        switch itemAgliment {
        case .Left:
            cell.textLabel?.textAlignment = NSTextAlignment.left
            break
        case .Right:
            cell.textLabel?.textAlignment = NSTextAlignment.right
            break
        case .Center:
            cell.textLabel?.textAlignment = NSTextAlignment.center
            break
        }
        
        if indexPath.row == items.count - 1 {
            cell.textLabel?.textColor = UIColor.red
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.hide()
        if self.delegate != nil {
            self.delegate?.bottomMenuViewDidSelected(viewController: self, index: indexPath.row)
        }
        
        self.items[indexPath.row].selectedAction?()
        
        didSelectedItemHandler?(indexPath.row)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showTableView(){
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.tableView.frame = CGRect(x: 0, y: self.view.frame.height - CGFloat(44) * CGFloat(self.items.count), width: self.view.frame.width, height: self.view.frame.height)
            }) { (bool) -> Void in
        }
    }
    
    enum ItemAlignment {
        case Left
        case Right
        case Center
    }

}
