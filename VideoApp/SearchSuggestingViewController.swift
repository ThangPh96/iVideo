//
//  SearchSuggestingViewController.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/11/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit

class SearchSuggestingViewController: VideoAppViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var searchSuggests: [String] = []
    private let reuseIdentifier = "SearchSugestingCell"
    var extraButtonAtCellTappedHandler: ((SearchHistoriesTableViewCell) -> Void)?
    var cell: SearchHistoriesTableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchSuggests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchHistoriesTableViewCell
        cell.searchHistoryLabel.text = searchSuggests[indexPath.row]
        cell.extraButtonTappedHandler = extraButtonAtCellTappedHandler
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cell.startSearch = true
        VideoApp.saveSearchHistory(searchHistoryName: searchSuggests[indexPath.row])
        cell.searchHistoryLabel.text = searchSuggests[indexPath.row]
        cell.extraButtonTappedHandler?(cell)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: VideoApp.Notifications.searchButtonDidTapped), object: nil)
    }
}
