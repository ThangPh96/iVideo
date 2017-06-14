//
//  CreateNewPlaylistViewController.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 2/17/16.
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit

class CreateNewPlaylistViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var playlistNameTextField: UITextField!

    var cancelButtonTappedHandler: ((Void) -> Void)?
    var addButtonTappedHandler: ((Void) -> Void)?
    var createdPlaylistHandler: ((Videos) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playlistNameTextField.becomeFirstResponder()
        cancelButton.setTitleColor(VideoApp.Settings.themeColor, for: .normal)
        addButton.setTitleColor(VideoApp.Settings.themeColor, for: .normal)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        self.view.endEditing(true)
        cancelButtonTappedHandler?()
    }

    @IBAction func addButtonTapped(sender: UIButton) {
        self.view.endEditing(true)
        if let playlistName = playlistNameTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines
            ) {
                if playlistName != "" {
                    createNewPlaylist(playlistName: playlistName)
                } else {
                    playlistNameTextField.isHighlighted = true
                    playlistNameTextField.becomeFirstResponder()
                }
        } else {
            playlistNameTextField.isHighlighted = true
            playlistNameTextField.becomeFirstResponder()
        }
        addButtonTappedHandler?()
    }
    
    private func createNewPlaylist(playlistName: String) {
        let playlist = Videos()
        
        playlist.name = playlistName
        
        try! VideoApp.realm.write({
            VideoApp.realm.add(playlist)
            createdPlaylistHandler?(playlist)
        })
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
