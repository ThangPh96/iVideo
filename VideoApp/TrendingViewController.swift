//
//  TrendingViewController.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/6/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit

class TrendingViewController: VideoAppViewController {

    @IBOutlet weak var videoListView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        VideoApp.tabbarController = self.tabBarController!
        // Set default categoryId value
        if VideoApp.categoriesTrendingVideo.videoCategoriesId.count != 0 {
            VideoApp.categoryId = VideoApp.categoriesTrendingVideo.videoCategoriesId[0]
            VideoApp.categoryTitle = VideoApp.categoriesTrendingVideo.titles[0]
        }
        VideoApp.tabbarController.selectedIndex = 2
        
        let leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "SortDownFilled"), style: .plain, target: self, action: #selector(self.showVideoCategories))
        leftBarButtonItem.tintColor = UIColor.white
        
        let leftBarButtonItem2 = UIBarButtonItem(title: VideoApp.categoryTitle, style: .plain, target: self, action: #selector(self.showVideoCategories))
        leftBarButtonItem.tintColor = UIColor.white
        
        self.registerObserver(name: VideoApp.Notifications.didChangeCategory, object: nil, queue: nil) { (noti) -> Void in
            leftBarButtonItem2.title = VideoApp.categoryTitle
        }

        navigationItem.leftBarButtonItems = [leftBarButtonItem, leftBarButtonItem2]
        //
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vC = storyboard.instantiateViewController(withIdentifier: "VideoListViewController") as! VideoListViewController
        
        vC.viewDidLoadHandler = {
            VideoApp.tabbarController.selectedIndex = 0
            vC.swipeRefreshControl.startRefreshing()
            self.loadVideoList(vC: vC)
        }
        
        vC.reloadDataHandler = {
            if VideoApp.isConnectedToNetwork() == false {
                let alert = UIAlertView()
                alert.title = NSLocalizedString("Connection Failed", comment: "")
                alert.message = NSLocalizedString("Please Check Your Internet Connection", comment: "")
                alert.addButton(withTitle: "OK")
                alert.show()
            } else {
                sharedAPI.getVideoCategories { (videoCategories) in
                    // Save categories trending video
                    VideoApp.categoriesTrendingVideo = videoCategories
                    VideoApp.categoryId = VideoApp.categoriesTrendingVideo.videoCategoriesId[0]
                    VideoApp.categoryTitle = VideoApp.categoriesTrendingVideo.titles[0]
                    vC.swipeRefreshControl.startRefreshing()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: VideoApp.Notifications.didChangeCategory), object: nil)
                }
            }
        }
        
        vC.refreshListHander = {
            vC.swipeRefreshControl.startRefreshing()
            self.loadVideoList(vC: vC)
        }
        
        vC.extraButtonAtCellTappedHandler = { cell in
            VideoApp.showExtraOptionOnlineVideo(video: cell.video)
        }
        
        vC.registerObserver(name: VideoApp.Notifications.didChangeCategory, object: nil, queue: nil) { (noti) -> Void in
            vC.swipeRefreshControl.startRefreshing()
            self.loadVideoList(vC: vC)
        }
        
        vC.scrollViewDidEndDraggingHandler = {
            if let _ = vC.videos.nextPage {
                sharedAPI.getTrendingVideos(categoryId: VideoApp.categoryId, videos: vC.videos, completionHandler: { (videos) in
                    vC.videos = videos
                    vC.tableView.reloadData()
                })
            }
        }

        self.addChildViewController(vC)
        vC.view.frame = self.videoListView.bounds
        self.videoListView.addSubview(vC.view)
        
        // call before adding child view controller's view as subview
        vC.didMove(toParentViewController: self)
    }
    
    private func loadVideoList(vC: VideoListViewController) {
        if VideoApp.categoriesTrendingVideo.videoCategoriesId.count != 0 {
            sharedAPI.getTrendingVideos(categoryId: VideoApp.categoryId, videos: Videos(), completionHandler: { (videos) in
                vC.videos = videos
                vC.tableView.reloadData()
                vC.swipeRefreshControl.endRefreshing()
            })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - BarButtonItem Action
    func showVideoCategories() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vC = storyboard.instantiateViewController(withIdentifier: "CategoriesViewController") as! CategoriesViewController
        self.navigationController?.pushViewController(vC, animated: false)
    }
    
}
