//
//  CategoriesViewController.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/9/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit

class CategoriesViewController: VideoAppViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    private let reuseIdentifier = "CategoriesCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Categories"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VideoApp.categoriesTrendingVideo.titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = VideoApp.categoriesTrendingVideo.titles[indexPath.row]
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        VideoApp.categoryId = VideoApp.categoriesTrendingVideo.videoCategoriesId[indexPath.row]
        VideoApp.categoryTitle = VideoApp.categoriesTrendingVideo.titles[indexPath.row]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: VideoApp.Notifications.didChangeCategory), object: nil)
        self.navigationController?.popViewController(animated: false)
    }
}
