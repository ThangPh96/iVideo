//
//  CreatedPlaylistTableViewController.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 2/17/16.
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit
import RealmSwift
import UIColor_Hex_Swift
import XCDYouTubeKit
import DZNEmptyDataSet
import FontAwesome_swift
import CarbonKit

class CreatedPlaylistViewController: VideoAppViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let reuseableCellIdentifiler = "cell"
    
    var playlists: Results<Videos>?
    var swipeRefreshControl: CarbonSwipeRefresh!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        // ButtonItem

        let editBarButtonItem = UIBarButtonItem(image: UIImage(named: "EditFilled"), style: .plain, target: self, action: #selector(self.editPlaylistButtonTapped(sender:)))
        editBarButtonItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = editBarButtonItem

        swipeRefreshControl = CarbonSwipeRefresh.init(scrollView: self.tableView)
        swipeRefreshControl.colors = [VideoApp.Settings.themeColor]
        swipeRefreshControl.addTarget(self, action: Selector(("refreshList:")), for: UIControlEvents.valueChanged)
        self.view.addSubview(swipeRefreshControl)
        
        self.loadData()
        self.swipeRefreshControl.endRefreshing()
        
    }
    
    func loadData() {
        self.playlists = VideoApp.realm.objects(Videos.self).filter("name != 'FavoriteVideos' && name != 'Histories' && name != 'Downloads'")
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let playlists = self.playlists {
            return playlists.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseableCellIdentifiler, for: indexPath as IndexPath)
        cell.textLabel?.text = playlists![indexPath.row].name
        cell.detailTextLabel?.text = "\(playlists![indexPath.row].videos.count) video(s)"
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let videoListVC = self.loadVideoListVC(playlist: playlists![indexPath.row], index: indexPath.row)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        titleLabel.text = playlists![indexPath.row].name
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = NSTextAlignment.center
        videoListVC.navigationItem.titleView = titleLabel
        
        self.navigationController?.pushViewController(videoListVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! VideoApp.realm.write({ () -> Void in
                VideoApp.realm.delete(playlists![indexPath.row])
                self.tableView.reloadData()
            })
        }
    }

    // MARK: - Navigation

    // MARK: - Navigation bar button action
    
    func editPlaylistButtonTapped(sender: UIBarButtonItem) {
        var items: [BottomMenuViewItem] = []
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.plus.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Create new playlist", comment: ""), selectedAction: { (Void) -> Void in
                self.createNewPlaylist()
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.trash.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Remove", comment: ""), selectedAction: { (Void) -> Void in
                self.tableView.setEditing(true, animated: true)
                self.navigationItem.rightBarButtonItem?.image = UIImage(named: "OkFilled")
                self.navigationItem.rightBarButtonItem?.action = #selector(self.editDone)
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.angleDown.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Cancel", comment: ""), selectedAction: { (Void) -> Void in
                //
        }))
        let bottomMenu = BottomMenuView(items: items, didSelectedHandler: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        bottomMenu.showInViewController(viewController: (appDelegate.window?.rootViewController)!)
    }
    
    func editDone() {
        self.tableView.setEditing(false, animated: true)
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "EditFilled")
        self.navigationItem.rightBarButtonItem?.action = #selector(self.editPlaylistButtonTapped(sender:))
    }
    
    // MARK: SwipeRefreshControl delegate
    func refreshList(swipeRefreshControl: CarbonSwipeRefresh) {
        self.playlists = VideoApp.realm.objects(Videos.self).filter("name != 'FavoriteVideos' && name != 'Histories' && name != 'Downloads'")
        self.tableView.reloadData()
        swipeRefreshControl.endRefreshing()
    }
    
    // MARK: - DZNEmptyDataSetSource
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let string = NSLocalizedString("Create new playlist.", comment: "")
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
                          NSForegroundColorAttributeName: UIColor.lightGray]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.fontAwesomeIcon(name: FontAwesome.film, textColor: UIColor.lightGray, size: CGSize(width: 80, height: 80))
    }
    
    func emptyDataSetDidTap(_ scrollView: UIScrollView!) {
        self.createNewPlaylist()
    }
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        self.createNewPlaylist()
    }

    // MARK: - Private function
    
    private func createNewPlaylist() {
        let popup = PopUpViewController(size: CGSize(width: 280, height: 120))
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let createNewPlaylistVC = storyboard.instantiateViewController(withIdentifier: "CreateNewPlaylist") as! CreateNewPlaylistViewController
        popup.addChildViewController(createNewPlaylistVC)
        popup.viewContainer.addSubview(createNewPlaylistVC.view)
        createNewPlaylistVC.view.translatesAutoresizingMaskIntoConstraints = false
        popup.viewContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[createNewPlaylistView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["createNewPlaylistView": createNewPlaylistVC.view]))
        popup.viewContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[createNewPlaylistView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["createNewPlaylistView": createNewPlaylistVC.view]))
        createNewPlaylistVC.cancelButtonTappedHandler = {
            popup.hide()
        }
        createNewPlaylistVC.addButtonTappedHandler = {
            popup.hide()
            self.playlists = VideoApp.realm.objects(Videos.self).filter("name != 'FavoriteVideos' && name != 'Histories' && name != 'Downloads'")
            self.tableView.reloadData()
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        popup.showInViewController(viewController: (appDelegate.window?.rootViewController)!)
    }
    
    // Get videos of playlist
    private func loadVideoListVC(playlist: Videos, index: Int) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let videoListVC = storyboard.instantiateViewController(withIdentifier: "VideoListViewController") as! VideoListViewController
        
        videoListVC.viewDidLoadHandler = {
            videoListVC.videos = playlist
            videoListVC.tableView.reloadData()
            videoListVC.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        videoListVC.registerObserver(name: VideoApp.Notifications.addVideoToPlaylistDone, object: nil, queue: nil) { (noti) -> Void in
            self.loadData()
            videoListVC.videos = (self.playlists?[index])!
            videoListVC.tableView.reloadData()
        }
        
        videoListVC.refreshListHander = {
            videoListVC.videos = playlist
            videoListVC.tableView.reloadData()
            videoListVC.swipeRefreshControl.endRefreshing()
        }
        
        videoListVC.extraButtonAtCellTappedHandler = { cell in
            var items: [BottomMenuViewItem] = []
            items.append(BottomMenuViewItem(title: cell.titleLbl.text))
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIcon(name: FontAwesome.shareAlt, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Share...", comment: ""), selectedAction: { (Void) -> Void in
                    VideoApp.shareVideo(video: cell.video)
            }))
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIcon(name: FontAwesome.heart, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to favorites", comment: ""), selectedAction: { (Void) -> Void in
                    VideoApp.addVideoToFavorites(video: cell.video)
            }))
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIcon(name: FontAwesome.list, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to playlist", comment: ""), selectedAction: { (Void) -> Void in
                    VideoApp.addVideoToPlaylist(video: cell.video)
            }))
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIcon(name: FontAwesome.trash, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Delete", comment: ""), selectedAction: { (Void) -> Void in
                    DispatchQueue.main.async {
                        autoreleasepool {
                            try! VideoApp.realm.write() {
                                playlist.videos.remove(objectAtIndex: playlist.videos.index(of: cell.video)!)
                                videoListVC.tableView.reloadData()
                            }
                        }
                    }
            }))
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIcon(name: FontAwesome.angleDown, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Cancel", comment: ""), selectedAction: { (Void) -> Void in
                   //
            }))
            let bottomMenu = BottomMenuView(items: items, didSelectedHandler: nil)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            bottomMenu.showInViewController(viewController: (appDelegate.window?.rootViewController)!)
        }
        
        return videoListVC
    }

}
