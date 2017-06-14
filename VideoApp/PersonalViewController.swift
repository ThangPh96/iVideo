//
//  PersonalViewController.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/7/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit
import FontAwesome_swift
import RealmSwift

class PersonalViewController: VideoAppViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var videoListView: UIView!
    
    var isFavoriteVC: Bool = true
    
    let downloadsVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "VideoListViewController") as! VideoListViewController
    let vC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "VideoListViewController") as! VideoListViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        // Custom searchBar
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.isTranslucent = true
        
        let textField: UITextField? = searchBar.value(forKey: "_searchField") as? UITextField
        textField?.backgroundColor = UIColor.white
        textField?.textColor = UIColor.black
        textField?.tintColor = UIColor.black
        let textFieldInsideSearchBarLabel = textField?.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = UIColor.lightGray
        //
        let sortRightButtonItem = UIBarButtonItem(image: UIImage(named: "EditFilled"), style: .plain, target: self, action: #selector(self.showEdit))
        sortRightButtonItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = sortRightButtonItem
        //
        if isFavoriteVC {
            loadFavoritesVC()
        } else {
            loadHistoryVC()
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != "" {
            if isFavoriteVC {
                if VideoApp.realm.objects(Videos.self).filter("name = '\(VideoApp.Constants.favoritesVideoListName)'")[0].videos.filter("title CONTAINS[c] %@", (self.searchBar.text!)).count != 0 {
                    let videoItems = VideoApp.realm.objects(Videos.self).filter("name = '\(VideoApp.Constants.favoritesVideoListName)'")[0].videos.filter("title CONTAINS[c] %@", (self.searchBar.text!)).sorted(byProperty: "modifiedAt", ascending: false)
                    vC.videos.videos.removeAll()
                    vC.videos.videos.append(objectsIn: videoItems)
                    vC.tableView.reloadData()
                } else {
                    vC.videos.videos.removeAll()
                    vC.tableView.reloadData()
                }
                
            } else {
                if VideoApp.realm.objects(Videos.self).filter("name = '\(VideoApp.Constants.downloadListName)'")[0].videos.filter("title CONTAINS[c] %@", (self.searchBar.text!)).count != 0 {
                    let videoItems = VideoApp.realm.objects(Videos.self).filter("name = '\(VideoApp.Constants.downloadListName)'")[0].videos.filter("title CONTAINS[c] %@", (self.searchBar.text!)).sorted(byProperty: "modifiedAt", ascending: false)
                    downloadsVC.videos.videos.removeAll()
                    downloadsVC.videos.videos.append(objectsIn: videoItems)
                    downloadsVC.tableView.reloadData()
                } else {
                    downloadsVC.videos.videos.removeAll()
                    downloadsVC.tableView.reloadData()
                }
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    //
    private func loadHistoryVC() {
        downloadsVC.title = NSLocalizedString("My Videos", comment: "")
        downloadsVC.isHistoryVC = true
        
        downloadsVC.viewDidLoadHandler = {
            self.downloadsVC.swipeRefreshControl.startRefreshing()
            self.loadDownloadData(downloadVC: self.downloadsVC)
            self.downloadsVC.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        downloadsVC.refreshListHander = {
            self.loadDownloadData(downloadVC: self.downloadsVC)
        }
        
        downloadsVC.registerObserver(name: VideoApp.Notifications.selectSortVideosDone, object: nil, queue: nil) { (noti) -> Void in
            self.loadDownloadData(downloadVC: self.downloadsVC)
        }
        
        downloadsVC.registerObserver(name: VideoApp.Notifications.downloadVideoDone, object: nil, queue: nil) { (noti) -> Void in
            self.loadDownloadData(downloadVC: self.downloadsVC)
            self.downloadsVC.tableView.reloadData()
        }
        
        downloadsVC.extraButtonAtCellTappedHandler = { cell in
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
                    let videos = VideoApp.realm.objects(Videos.self).filter("name = '\(VideoApp.Constants.downloadListName)'")[0].videos
                    //sortedResultsUsingProperty("dateStart", ascending: true)
                    
                    for i in 0...videos.count - 1 {
                        if videos[i].videoId == cell.video.videoId {
                            let fileManager = FileManager.default
                            let directoryURL = NSHomeDirectory().appending("/Documents")
                            try? fileManager.removeItem(atPath: directoryURL + "/" + (videos[i].offlinePath))
                            DispatchQueue.main.async {
                                autoreleasepool {
                                    try! VideoApp.realm.write() {
                                        videos.remove(objectAtIndex: i)
                                        let videoItems = VideoApp.realm.objects(Videos.self).filter("name = '\(VideoApp.Constants.downloadListName)'")[0].videos.sorted(byProperty: VideoApp.Settings.videoSort.rawValue, ascending: VideoApp.Settings.videoSort == .CreatedAt ? false : true)
                                        self.downloadsVC.videos.videos.removeAll()
                                        self.downloadsVC.videos.videos.append(objectsIn: videoItems)
                                        self.downloadsVC.tableView.reloadData()
                                    }
                                }
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
        
        self.addChildViewController(downloadsVC)
        downloadsVC.view.frame = self.videoListView.bounds
        self.videoListView.addSubview(downloadsVC.view)
        
        // call before adding child view controller's view as subview
        downloadsVC.didMove(toParentViewController: self)
    }
    
    func loadDownloadData(downloadVC: VideoListViewController) {
        let mediaItems = VideoApp.realm.objects(Videos.self).filter("name = '\(VideoApp.Constants.downloadListName)'")[0].videos.sorted(byProperty: VideoApp.Settings.videoSort.rawValue, ascending: VideoApp.Settings.videoSort == .CreatedAt ? false : true)
        downloadVC.videos.videos.removeAll()
        downloadVC.videos.videos.append(objectsIn: mediaItems)
        downloadVC.tableView.reloadData()
        downloadVC.navigationItem.rightBarButtonItem?.isEnabled = true
        downloadVC.swipeRefreshControl.endRefreshing()
    }
    
    func loadFavoritesVC() {
        
        
        vC.viewDidLoadHandler = {
            self.vC.swipeRefreshControl.startRefreshing()
            self.loadvideos(favoriteVideosVC: self.vC)
        }
        
        vC.refreshListHander = {
            self.loadvideos(favoriteVideosVC: self.vC)
        }
        
        vC.registerObserver(name: VideoApp.Notifications.addVideoToFavoriteDone, object: nil, queue: nil) { (noti) -> Void in
            self.loadvideos(favoriteVideosVC: self.vC)
            self.vC.tableView.reloadData()
        }
        
        vC.registerObserver(name: VideoApp.Notifications.selectSortVideosDone, object: nil, queue: nil) { (noti) -> Void in
            self.loadvideos(favoriteVideosVC: self.vC)
            self.vC.tableView.reloadData()
        }
        
        self.registerObserver(name: VideoApp.Notifications.deleteAllFavoriteVideosDone, object: nil, queue: nil) { (noti) -> Void in
            self.loadvideos(favoriteVideosVC: self.vC)
        }
        
        vC.extraButtonAtCellTappedHandler = { cell in
            var items: [BottomMenuViewItem] = []
            items.append(BottomMenuViewItem(title: cell.titleLbl.text))
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.shareAlt.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Share...", comment: ""), selectedAction: { (Void) -> Void in
                    VideoApp.shareVideo(video: cell.video)
            }))
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.trash.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Delete", comment: ""), selectedAction: { (Void) -> Void in
                    var videos = VideoApp.realm.objects(Videos.self).filter("name = '\(VideoApp.Constants.favoritesVideoListName)'")[0].videos
                    for i in 0...videos.count - 1 {
                        if cell.video.videoId != nil {
                            if videos[i].videoId == cell.video.videoId {
                                DispatchQueue.main.async {
                                    autoreleasepool {
                                        try! VideoApp.realm.write() {
                                            videos.remove(at: i)
                                            let videoItems = VideoApp.realm.objects(Videos.self).filter("name = '\(VideoApp.Constants.favoritesVideoListName)'")[0].videos.sorted(byProperty: VideoApp.Settings.videoSort.rawValue, ascending: VideoApp.Settings.videoSort == .CreatedAt ? false : true)
                                            self.vC.videos.videos.removeAll()
                                            self.vC.videos.videos.append(objectsIn: videoItems)
                                            self.vC.tableView.reloadData()
                                        }
                                    }
                                }
                            }
                        }
                    }
            }))
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.list.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to playlist", comment: ""), selectedAction: { (Void) -> Void in
                    VideoApp.addVideoToPlaylist(video: cell.video)
                    
            }))
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesome.angleDown.rawValue)!, textColor: VideoApp.Settings.themeColor, size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Cancel", comment: ""), selectedAction: { (Void) -> Void in
                    //
            }))
            let bottomMenu = BottomMenuView(items: items, didSelectedHandler: nil)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            bottomMenu.showInViewController(viewController: (appDelegate.window?.rootViewController)!)
        }
        self.addChildViewController(vC)
        vC.view.frame = self.videoListView.bounds
        self.videoListView.addSubview(vC.view)
        
        // call before adding child view controller's view as subview
        vC.didMove(toParentViewController: self)
        
    }

    // load data
    func loadvideos(favoriteVideosVC: VideoListViewController) {
        let videoItems = VideoApp.realm.objects(Videos.self).filter("name = '\(VideoApp.Constants.favoritesVideoListName)'")[0].videos.sorted(byProperty: VideoApp.Settings.videoSort.rawValue, ascending: VideoApp.Settings.videoSort == .CreatedAt ? false : true)
        favoriteVideosVC.videos.videos.removeAll()
        favoriteVideosVC.videos.videos.append(objectsIn: videoItems)
        favoriteVideosVC.tableView.reloadData()
        favoriteVideosVC.navigationItem.rightBarButtonItem?.isEnabled = true
        favoriteVideosVC.swipeRefreshControl.endRefreshing()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Func
    func showEdit() {
        VideoApp.editOfflineVideo()
    }
}
