//
//  ViewController.swift
//  UploadMusic
//
//  Created by Olorunshola Godwin on 14/11/2020.
//  Copyright © 2020 Olorunshola Godwin. All rights reserved.
//
import MediaPlayer
import UIKit
import FirebaseStorage

class ViewController: UIViewController, MPMediaPickerControllerDelegate{
    let selectedSongArtCover = UIImageView(frame: CGRect(x: 20, y: 100, width: 200, height: 200))
    let selectSongTitleLabel = UILabel(frame: CGRect(x: 20, y: 40, width: 200, height: 40))
    let selectMusicButton = UIButton(frame: CGRect(x: 240, y: 40, width: 160, height: 40))
    var selectedSong: MPMediaItem!
    var mediaItemCollection: MPMediaItemCollection?
    let storage = Storage.storage()

    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        playSong()
        exportSong()
    }
    
    func getSongCoverArt(){
        if let artwork: MPMediaItemArtwork = selectedSong.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork{
            selectedSongArtCover.image = artwork.image(at: CGSize(width: 400, height: 400))
        }
        if let songTitle = selectedSong.value(forProperty: MPMediaItemPropertyTitle) as? String{
            selectSongTitleLabel.text = "Title: " + songTitle
        }
    }
    
    
    func playSong() {
        if let mediaItemCollection = mediaItemCollection {
            let appMusicPlayer = MPMusicPlayerController.applicationMusicPlayer
            appMusicPlayer.setQueue(with: mediaItemCollection)
            appMusicPlayer.play()
        }
    }
    
    func exportSong() {
        let songURL = selectedSong.value(forProperty: MPMediaItemPropertyAssetURL) as? URL
        
        guard let unwrappedSongURL = songURL,  !selectedSong.hasProtectedAsset else {
            print("You cant upload this song as it is protected.")
            return
        }
        //Async call, would take some seconds, show a loader
        exportToTemporaryFileLocation(unwrappedSongURL) { (url, error) in
            if let url = url {
                self.uploadToFirebase(songURL: url)
            }
        }

    }
    
    func uploadToFirebase(songURL : URL){
        let storageRef = storage.reference()
        let audioRef = storageRef.child("audio/\(UUID().uuidString).mp3")
        //Async call, would take some seconds, show a loader
        let uploadTask = audioRef.putFile(from: songURL, metadata: nil) { metadata, error in
          guard let metadata = metadata else {
            return
          }
          let size = metadata.size
          audioRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
              return
            }
          }
        }
    }
    
    func exportToTemporaryFileLocation(_ assetURL: URL, completionHandler: @escaping (_ fileURL: URL?, _ error: Error?) -> ()) {
        let asset = AVURLAsset(url: assetURL)
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            completionHandler(nil, ExportError.unableToCreateExporter)
            return
        }

        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(NSUUID().uuidString)
            .appendingPathExtension("m4a")

        exporter.outputURL = fileURL
        exporter.outputFileType = AVFileType(rawValue: "com.apple.m4a-audio")

        exporter.exportAsynchronously {
            if exporter.status == .completed {
                completionHandler(fileURL, nil)
            } else {
                completionHandler(nil, exporter.error)
            }
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        print("did cancel selecting a song")
    }
    
    
}

enum ExportError: Error {
    case unableToCreateExporter
}
