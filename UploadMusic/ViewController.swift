//
//  ViewController.swift
//  UploadMusic
//
//  Created by Olorunshola Godwin on 14/11/2020.
//  Copyright © 2020 Olorunshola Godwin. All rights reserved.
//
import MediaPlayer
import UIKit

class ViewController: UIViewController, MPMediaPickerControllerDelegate{
    let selectedSongArtCover = UIImageView(frame: CGRect(x: 20, y: 100, width: 200, height: 200))
    let selectSongTitleLabel = UILabel(frame: CGRect(x: 20, y: 40, width: 100, height: 40))
    let selectMusicButton = UIButton(frame: CGRect(x: 240, y: 40, width: 160, height: 40))
    var selectedSong: MPMediaItem!
    var mediaItemCollection: MPMediaItemCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(selectedSongArtCover)
        view.addSubview(selectSongTitleLabel)
        view.addSubview(selectMusicButton)
        selectMusicButton.setTitle("Select Music", for: .normal)
        selectMusicButton.addTarget(self, action: #selector(openMusicPicker), for: .touchUpInside)
    }
    
    @objc func openMusicPicker() {
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.delegate = self
        present(mediaPicker, animated: true, completion: {})
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        dismiss(animated: true, completion: nil)
        if mediaItemCollection.count < 1 {
            return
        }
        self.mediaItemCollection = mediaItemCollection
        selectedSong = mediaItemCollection.items[0]
        getSongCoverArt()
        playUnProtectedSong()
    }
    
    func getSongCoverArt(){
        if let artwork: MPMediaItemArtwork = selectedSong.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork{
            selectedSongArtCover.image = artwork.image(at: CGSize(width: 400, height: 400))
        }
        if let songTitle = selectedSong.value(forProperty: MPMediaItemPropertyTitle) as? String{
            selectSongTitleLabel.text = "Song Title" + songTitle
        }
    }
    
    
    func playUnProtectedSong() {
        if let mediaItemCollection = mediaItemCollection {
            let appMusicPlayer = MPMusicPlayerController.applicationMusicPlayer
            appMusicPlayer.setQueue(with: mediaItemCollection)
            appMusicPlayer.play()
        }
    }
    
    func exportSong() {
        let songURL = selectedSong.value(forProperty: MPMediaItemPropertyAssetURL)
        if selectedSong.hasProtectedAsset || songURL  == nil {
            print("You cant upload this song as it is protected.")
        }
        let itemUrl = selectedSong.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
        
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        print("did cancel selecting a song")
    }
    
    
}
