//
//  SettingViewController.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 9/30/16.
//  Copyright © 2016 Ahiho. All rights reserved.
//

import UIKit

class SettingViewController: VideoAppViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    private let reuseCellIdentifierNormal: String = "normalCell"
    private let reuseCellIdentifierSwitchBool: String = "switchControlCell"
    
    enum RowType {
        case Normal
        case SwitchBool
    }
    
    class RowItem: NSObject {
        var title: String = ""
        var value: AnyObject?
        var hidden: Bool = false
        var type: RowType = .Normal
        var action: ((AnyObject) -> Void)?
        init(title: String, value: AnyObject?, type: RowType, action: ((AnyObject) -> Void)?) {
            super.init()
            self.title = title
            self.value = value
            self.action = action
            self.type = type
        }
    }
    
    var rows: [RowItem] {
        return [
            RowItem(title: NSLocalizedString("Video Quality", comment: ""), value: VideoApp.Settings.videoQuality.rawValue as AnyObject?, type: .Normal, action: { (indexPath) -> Void in
                self.showVideoQualityOptions(atCell: self.tableView.cellForRow(at: (indexPath as! NSIndexPath) as IndexPath))
            })
//            RowItem(title: NSLocalizedString("Play video in background", comment: ""), value: VideoApp.Settings.playVideoInBackground as AnyObject?, type: .SwitchBool, action: { (switchBoolCell) -> Void in
//                let cell = switchBoolCell as! SwitchBoolTableViewCell
//                VideoApp.Settings.playVideoInBackground = cell.switchControl.isOn
//                VideoApp.sharedVideoDetailVC?.videoPlayerVC.moviePlayer.isBackgroundPlaybackEnabled = VideoApp.Settings.playVideoInBackground
//            })
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.black
    }

    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch self.rows[indexPath.row].type {
//        case .Normal:
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellIdentifierNormal, for: indexPath as IndexPath) as UITableViewCell
            cell.textLabel?.text = self.rows[indexPath.row].title
            cell.detailTextLabel?.text = self.rows[indexPath.row].value as? String
            cell.detailTextLabel?.textColor = UIColor.white
            let backgroundView = UIView()
            cell.selectedBackgroundView = backgroundView
            return cell
//        case .SwitchBool:
//            let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellIdentifierSwitchBool, for: indexPath as IndexPath) as! SwitchBoolTableViewCell
//            cell.titleCell.text = self.rows[indexPath.row].title
//            cell.switchControl.isOn = self.rows[indexPath.row].value as! Bool
//            cell.switchControl.onTintColor = VideoApp.Settings.themeColor
//            cell.switchBoolCellChanged = self.rows[indexPath.row].action
//            return cell
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        self.rows[indexPath.row].action?(indexPath as AnyObject)
    }
    
    //
    func showVideoQualityOptions(atCell cell: UITableViewCell?) {
        let items: [BottomMenuViewItem] = [
            BottomMenuViewItem(title: "hd720", selectedAction: { (Void) -> Void in
                VideoApp.Settings.videoQuality = .hd720p
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: VideoApp.Notifications.changeQualityDone), object: nil)
            }),
            BottomMenuViewItem(title: "medium", selectedAction: { (Void) -> Void in
                VideoApp.Settings.videoQuality = .medium
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: VideoApp.Notifications.changeQualityDone), object: nil)
            }),
            BottomMenuViewItem(title: "small", selectedAction: { (Void) -> Void in
                VideoApp.Settings.videoQuality = .small
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: VideoApp.Notifications.changeQualityDone), object: nil)
            }),
            BottomMenuViewItem(title: "Cancel", selectedAction: { (Void) -> Void in
                //
            })
        ]
        let bottomMenu = BottomMenuView(items: items) { (index) -> Void in
            if let cell = cell {
                cell.detailTextLabel?.text = items[index].title
            }
        }
        //        bottomMenu.itemAgliment = .Center
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        bottomMenu.showInViewController(viewController: appDelegate.window!.rootViewController!)
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
