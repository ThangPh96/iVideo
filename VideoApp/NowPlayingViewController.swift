//
//  NowPlayingViewController.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/6/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit
import XCDYouTubeKit
import AVFoundation
import AVKit
import QorumLogs
import SSSnackbar

class NowPlayingViewController: UIViewController {

    let vC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "VideoListViewController") as! VideoListViewController
    var playerViewController = AVPlayerViewController()
    var player = AVPlayer()
    var showSetting = false
    var showPlaylist = false
    var videoQuality: VideoApp.Settings.VideoQuality = VideoApp.Settings.videoQuality {
        didSet {
            if VideoApp.nowPlaying.getPlaylist().videos.count != 0 {
                if VideoApp.nowPlaying.getPlaylist().videos[VideoApp.nowPlaying.getIndex()].offlinePath == nil {
                    if VideoApp.isConnectedToNetwork() == false {
                        let alert = UIAlertView()
                        alert.title = NSLocalizedString("Connection Failed", comment: "")
                        alert.message = NSLocalizedString("Please Check Your Internet Connection", comment: "")
                        alert.addButton(withTitle: "OK")
                        alert.show()
                    } else {
                        self.playVideo()
                        self.removeChildView()
                    }

                } else {
                    self.playVideo()
                    self.removeChildView()
                }
            }
        }
    }
    
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var playlistBtn: UIButton!
    @IBOutlet weak var funcView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var currentCountLbl: UILabel!
    @IBOutlet weak var videoQualityBtn: UIButton!
    @IBOutlet weak var childView: UIView!
    
    private let preferredVideoQualities: [Any] = [
        NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue),
        NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue),
        NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue)
    ]
    
    @IBOutlet weak var playerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.addChildViewController(playerViewController)
        playerViewController.view.frame = self.playerView.bounds
        self.playerView.addSubview(playerViewController.view)
        playerViewController.didMove(toParentViewController: self)

        self.registerObserver(name: VideoApp.Notifications.playVideo, object: nil, queue: nil) { (noti) -> Void in
            self.videoQualityBtn.setTitle(VideoApp.Settings.videoQuality.rawValue, for: .normal)
            self.videoQuality = VideoApp.Settings.videoQuality
        }
        self.registerObserver(name: VideoApp.Notifications.changeQualityDone, object: nil, queue: nil) { (noti) -> Void in
            self.videoQualityBtn.setTitle(VideoApp.Settings.videoQuality.rawValue, for: .normal)
            self.videoQuality = VideoApp.Settings.videoQuality
        }
        //
        self.videoQualityBtn.layer.cornerRadius = 5
        self.videoQualityBtn.layer.borderColor = UIColor.lightGray.cgColor
        self.videoQualityBtn.layer.borderWidth = 1
        self.videoQualityBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        self.videoQualityBtn.setTitleColor(UIColor.white, for: .normal)
        self.videoQualityBtn.setTitle(VideoApp.Settings.videoQuality.rawValue, for: .normal)
        self.videoQualityBtn.titleLabel?.textAlignment = .center
        self.currentCountLbl.text = "\(VideoApp.nowPlaying.getIndex())/\(VideoApp.nowPlaying.getPlaylist().videos.count)"
        self.childView.alpha = 0
        if VideoApp.nowPlaying.getPlaylist().videos.count != 0 {
            self.nameLabel.text = VideoApp.nowPlaying.getPlaylist().videos[VideoApp.nowPlaying.getIndex()].title
        }
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }

    func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        if VideoApp.nowPlaying.getIndex() != VideoApp.nowPlaying.getPlaylist().videos.count {
            VideoApp.nowPlaying.changeVideoPlaying(index: VideoApp.nowPlaying.getIndex() + 1)
        } else {
            VideoApp.nowPlaying.changeVideoPlaying(index: 0)
        }
    }
    
    func applicationDidEnterBackground(notification: Notification) {
        playerViewController.player?.perform(#selector(playerViewController.player?.play), with: nil, afterDelay: 0.01)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        playerViewController.player?.pause()
        super.viewDidAppear(true)
        UIApplication.shared.endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        let event = event?.subtype
        if event == UIEventSubtype.remoteControlTogglePlayPause {
            if playerViewController.player?.rate == 0 {
                playerViewController.player?.play()
            } else {
                playerViewController.player?.pause()
            }
        } else if event == UIEventSubtype.remoteControlPlay {
            playerViewController.player?.play()
        } else if event == UIEventSubtype.remoteControlPause {
            playerViewController.player?.pause()
        }
    }
    // MARK: - Play Video
    
    private func playVideo() {
        
        let video = VideoApp.nowPlaying.getPlaylist().videos[VideoApp.nowPlaying.getIndex()]
//        var prevVideo = Video()
//        var nextVideo = Video()
//        if VideoApp.nowPlaying.getIndex() != 0 {
//            prevVideo = VideoApp.nowPlaying.getPlaylist().videos[VideoApp.nowPlaying.getIndex()-1]
//        } else {
//            prevVideo = VideoApp.nowPlaying.getPlaylist().videos[VideoApp.nowPlaying.getPlaylist().videos.count-1]
//        }
//        if VideoApp.nowPlaying.getIndex() != VideoApp.nowPlaying.getPlaylist().videos.count {
//            nextVideo = VideoApp.nowPlaying.getPlaylist().videos[VideoApp.nowPlaying.getIndex()+1]
//        } else {
//            nextVideo = VideoApp.nowPlaying.getPlaylist().videos[0]
//        }
//        var queue: [AVPlayerItem] = []
        //
        self.currentCountLbl.text = "\(VideoApp.nowPlaying.getIndex()+1)/\(VideoApp.nowPlaying.getPlaylist().videos.count)"
        self.nameLabel.text = video.title
        if let offlinePath = video.offlinePath {
            self.getVideoOfflinePath( offlinePath: offlinePath, completionHandler: { (url) in
//                self.getVideoOfflinePath(offlinePath: prevVideo.offlinePath, completionHandler: { (prevURL) in
//                    queue.append(AVPlayerItem(url: prevURL as URL))
//                    queue.append(AVPlayerItem(url: url as URL))
//                    self.getVideoOfflinePath(offlinePath: nextVideo.offlinePath, completionHandler: { (nextURL) in
//                        queue.append(AVPlayerItem(url: nextURL as URL))
                        self.startVideo(video: XCDYouTubeVideo(), streamURL: url)
//                    })
//                })
            })
        } else {
            self.getVideoWithIdentifier(video: video, completionHandler: { (videoURL) in
                self.startVideo(video: videoURL.video, streamURL: videoURL.streamURL)
            })
        }
    }
    
    class VideoURL {
        var streamURL = NSURL()
        var video = XCDYouTubeVideo()
        
        func create(streamURL: NSURL, video: XCDYouTubeVideo) {
            self.streamURL = streamURL
            self.video = video
        }
    }
    
    func getVideoOfflinePath(offlinePath: String, completionHandler: ((NSURL) -> Void)?) {
        let fileManager = FileManager.default
        let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dataPath = directoryURL.appendingPathComponent(offlinePath)
        debugPrint(dataPath)
        completionHandler?(dataPath as NSURL)
    }
    
    func getVideoWithIdentifier(video: Video, completionHandler: ((VideoURL) -> Void)?) {
        let videoURL = VideoURL()
        XCDYouTubeClient.default().getVideoWithIdentifier(video.videoId!) { (video, error) -> Void in
            if let video = video {
                QL1(video.streamURLs)
                var streamURL: NSURL?
                switch self.videoQuality {
                case .hd720p:
                    streamURL = video.streamURLs[NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue) as NSObject] as NSURL?
                    break
                case .medium:
                    streamURL = video.streamURLs[NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue) as NSObject] as NSURL?
                    break
                case .small:
                    streamURL = video.streamURLs[NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue) as NSObject] as NSURL?
                    break
                }
                if streamURL == nil {
                    for videoQuality in self.preferredVideoQualities {
                        if let streamURL = video.streamURLs[videoQuality as! NSObject] {
                            videoURL.create(streamURL: streamURL as NSURL, video: video)
                            completionHandler?(videoURL)
                            break
                        }
                    }
                } else {
                    videoURL.create(streamURL: streamURL!, video: video)
                    completionHandler?(videoURL)
                }
            } else {
                let snackBar = SSSnackbar.init(message: NSLocalizedString("This video can't use. Playing next video.", comment: ""), actionText: NSLocalizedString("OK", comment: ""), duration: 5, actionBlock: nil, dismissalBlock: nil)
                snackBar?.show()
                if VideoApp.nowPlaying.getIndex() != VideoApp.nowPlaying.getPlaylist().videos.count {
                    VideoApp.nowPlaying.changeVideoPlaying(index: VideoApp.nowPlaying.getIndex() + 1)
                } else {
                    VideoApp.nowPlaying.changeVideoPlaying(index: 0)
                }
            }
        }
    }
    
    func startVideo(video: XCDYouTubeVideo, streamURL: NSURL) {
        player = AVPlayer(url: streamURL as URL)
//        player = AVQueuePlayer(items: queue)
        playerViewController.player = player
        playerViewController.player!.play()
    }
    
    //
    @IBAction func settingBtnTapped(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let vC = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
//        
//        if !showSetting {
//            self.childView.alpha = 1
//            vC.title = "Playlist Is On"
//            vC.title = NSLocalizedString("Setting", comment: "")
//            self.addChildViewController(vC)
//            vC.view.frame = self.childView.bounds
//            self.childView.addSubview(vC.view)
//            
//            // call before adding child view controller's view as subview
//            vC.didMove(toParentViewController: self)
//        } else {
//            self.childView.alpha = 0
//            vC.willMove(toParentViewController: nil)
//            vC.view.removeFromSuperview()
//            vC.removeFromParentViewController()
//        }
//        self.showSetting = !self.showSetting
        showVideoQualityOptions()
    }
    
    func showVideoQualityOptions() {
        let items: [BottomMenuViewItem] = [
            BottomMenuViewItem(title: "Video Quality Setting"),
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
        let bottomMenu = BottomMenuView(items: items, didSelectedHandler: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        bottomMenu.showInViewController(viewController: (appDelegate.window?.rootViewController)!)
    }

    @IBAction func playlistBtnTapped(_ sender: Any) {
        if !showPlaylist {
            self.childView.alpha = 1
            if VideoApp.isConnectedToNetwork() == true {
                if VideoApp.nowPlaying.getPlaylist().videos.count != 0 {
                    vC.tableView.backgroundColor = UIColor.black
                    vC.isPlayingList = true
                    
                    vC.videos = VideoApp.nowPlaying.getPlaylist()
                    vC.tableView.reloadData()
                    
                    vC.viewDidLoadHandler = {
                        self.vC.videos = VideoApp.nowPlaying.getPlaylist()
                        self.vC.tableView.reloadData()
                    }
                    
                    vC.registerObserver(name: VideoApp.Notifications.playVideo, object: nil, queue: nil) { (noti) -> Void in
                        self.removeChildView()
                    }
                }
            }
            self.addChildViewController(vC)
            vC.view.frame = self.childView.bounds
            self.childView.addSubview(vC.view)
            
            // call before adding child view controller's view as subview
            vC.didMove(toParentViewController: self)
        } else {
            removeChildView()
        }
        self.showPlaylist = !self.showPlaylist
    }
    
    func removeChildView() {
        self.childView.alpha = 0
        vC.willMove(toParentViewController: nil)
        vC.view.removeFromSuperview()
        vC.removeFromParentViewController()
    }
    
    @IBAction func videoQualityBtn(_ sender: Any) {
        var items: [BottomMenuViewItem] = []
        items.append(BottomMenuViewItem(title: "hd720", selectedAction: { (Void) -> Void in
            self.videoQualityBtn.setTitle("hd720", for: .normal)
            self.videoQuality = .hd720p
        }))
        items.append(BottomMenuViewItem(title: "medium", selectedAction: { (Void) -> Void in
            self.videoQualityBtn.setTitle("medium", for: .normal)
            self.videoQuality = .medium
        }))
        items.append(BottomMenuViewItem(title: "small", selectedAction: { (Void) -> Void in
            self.videoQualityBtn.setTitle("small", for: .normal)
            self.videoQuality = .small
        }))
        items.append(BottomMenuViewItem(title: NSLocalizedString("Cancel", comment: ""), selectedAction: { (Void) -> Void in
            //
        }))
        
        let bottomMenu = BottomMenuView(items: items, didSelectedHandler: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        bottomMenu.showInViewController(viewController: (appDelegate.window?.rootViewController)!)
    }
}
