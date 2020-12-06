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
import NVActivityIndicatorView


class ViewController: UIViewController, MPMediaPickerControllerDelegate{
    var selectedSong: MPMediaItem!
    var mediaItemCollection: MPMediaItemCollection?
    let storage = Storage.storage()
    
    lazy var selectedSongArtCover: UIImageView = {
        let selectedSongArtCover = UIImageView()
        selectedSongArtCover.backgroundColor = .gray
        selectedSongArtCover.translatesAutoresizingMaskIntoConstraints = false
        return selectedSongArtCover
    }()
    
    lazy var selectSongTitleLabel: UIButton = {
        let selectSongTitleLabel = UIButton()
        selectSongTitleLabel.setTitleColor(.black, for: .normal)
        selectSongTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return selectSongTitleLabel
    }()
    
    lazy var selectMusicButton: UIButton = {
        let selectMusicButton = UIButton()
        selectMusicButton.setTitle("Select Music", for: .normal)
        selectMusicButton.addTarget(self, action: #selector(openMusicPicker), for: .touchUpInside)
        selectMusicButton.translatesAutoresizingMaskIntoConstraints = false
        return selectMusicButton
    }()
    
    lazy var playButton: UIButton = {
        let playButton = UIButton()
        playButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal), for: .normal)
        playButton.backgroundColor = .white
        playButton.addTarget(self, action: #selector(playSelectedSong), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        return playButton
    }()
    
    lazy var stopButton: UIButton = {
        let stopButton = UIButton()
        stopButton.setImage(UIImage(systemName: "stop.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), for: .normal)
        stopButton.backgroundColor = .white
        stopButton.addTarget(self, action: #selector(stopSelectedSong), for: .touchUpInside)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        return stopButton
    }()
    
    lazy var uploadButton: UIButton = {
        let uploadButton = UIButton()
        uploadButton.setTitle("Upload song", for: .normal)
        uploadButton.backgroundColor = .white
        uploadButton.setTitleColor(.black, for: .normal)
        uploadButton.addTarget(self, action: #selector(uploadSong), for: .touchUpInside)
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        return uploadButton
    }()
    
    lazy var activityLoader: UIView = {
        let activityLoader = UIView()
        activityLoader.backgroundColor = UIColor(red: 0.98, green: 0.878, blue: 0.184, alpha: 1)
        activityLoader.layer.cornerRadius = 10
        activityLoader.addSubview(preloader)
        activityLoader.isHidden = true
        activityLoader.translatesAutoresizingMaskIntoConstraints = false
        preloader.translatesAutoresizingMaskIntoConstraints = false
        return activityLoader
    }()
    
    var preloader = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: .white, padding: .none)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(selectedSongArtCover)
        view.addSubview(selectSongTitleLabel)
        view.addSubview(selectMusicButton)
        view.addSubview(playButton)
        view.addSubview(stopButton)
        view.addSubview(uploadButton)
        view.addSubview(activityLoader)
        

        NSLayoutConstraint.activate([
            selectedSongArtCover.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            selectedSongArtCover.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            selectedSongArtCover.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            selectedSongArtCover.heightAnchor.constraint(equalToConstant: 200),
            
            selectSongTitleLabel.topAnchor.constraint(equalTo: selectedSongArtCover.bottomAnchor, constant: 10),
            selectSongTitleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            selectSongTitleLabel.widthAnchor.constraint(equalToConstant: 200),
            
            selectMusicButton.topAnchor.constraint(equalTo: selectedSongArtCover.bottomAnchor, constant: 10),
            selectMusicButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            
            playButton.topAnchor.constraint(equalTo: selectSongTitleLabel.bottomAnchor, constant: 30),
            playButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            playButton.widthAnchor.constraint(equalToConstant: 60),
            playButton.heightAnchor.constraint(equalToConstant: 40),
            
            stopButton.topAnchor.constraint(equalTo: selectSongTitleLabel.bottomAnchor, constant: 30),
            stopButton.leftAnchor.constraint(equalTo: playButton.rightAnchor, constant: 20),
            stopButton.widthAnchor.constraint(equalToConstant: 60),
            stopButton.heightAnchor.constraint(equalToConstant: 40),
            
            uploadButton.topAnchor.constraint(equalTo: selectSongTitleLabel.bottomAnchor, constant: 30),
            uploadButton.leftAnchor.constraint(equalTo: stopButton.rightAnchor, constant: 20),
            uploadButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            uploadButton.heightAnchor.constraint(equalToConstant: 40),
            
            activityLoader.heightAnchor.constraint(equalToConstant: 50),
            activityLoader.widthAnchor.constraint(equalToConstant: 50),
            activityLoader.centerXAnchor.constraint(equalTo: selectedSongArtCover.centerXAnchor),
            activityLoader.centerYAnchor.constraint(equalTo: selectedSongArtCover.centerYAnchor),
            
            preloader.heightAnchor.constraint(equalToConstant: 30),
            preloader.widthAnchor.constraint(equalToConstant: 30),
            preloader.centerXAnchor.constraint(equalTo: selectedSongArtCover.centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: selectedSongArtCover.centerYAnchor),

        ])

    }
    
    @objc func openMusicPicker() {
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.delegate = self
        present(mediaPicker, animated: true, completion: {})
    }
    
    @objc func playSelectedSong() {
        playSong()
    }
    
    @objc func stopSelectedSong() {
        stopSong()
    }
    
    @objc func uploadSong() {
        uploadButton.isUserInteractionEnabled = false
        playButton.isUserInteractionEnabled = false
        stopButton.isUserInteractionEnabled = false
        selectSongTitleLabel.isUserInteractionEnabled = false
        selectMusicButton.isUserInteractionEnabled = false
        exportSong()
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        dismiss(animated: true, completion: nil)
        if mediaItemCollection.count < 1 {
            return
        }
        self.mediaItemCollection = mediaItemCollection
        selectedSong = mediaItemCollection.items[0]
        getSongCoverArt()
    }
    
    func getSongCoverArt(){
        if let artwork: MPMediaItemArtwork = selectedSong.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork{
            selectedSongArtCover.image = artwork.image(at: CGSize(width: 400, height: 400))
        }
        if let songTitle = selectedSong.value(forProperty: MPMediaItemPropertyTitle) as? String{
            selectSongTitleLabel.setTitle("Title: " + songTitle, for: .normal)
            selectSongTitleLabel.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    func playSong() {
        if let mediaItemCollection = mediaItemCollection {
            let appMusicPlayer = MPMusicPlayerController.applicationMusicPlayer
            appMusicPlayer.setQueue(with: mediaItemCollection)
            appMusicPlayer.play()
        }
    }
    
    func stopSong() {
        if let mediaItemCollection = mediaItemCollection {
            let appMusicPlayer = MPMusicPlayerController.applicationMusicPlayer
            appMusicPlayer.setQueue(with: mediaItemCollection)
            appMusicPlayer.stop()
        }
    }
    
    func exportSong() {
        activityLoader.isHidden = false
        preloader.startAnimating()
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
    
    func uploadToFirebase(songURL : URL) {
        let storageRef = storage.reference()
        let audioRef = storageRef.child("audio/\(UUID().uuidString).mp3")
        
        //Async call, would take some seconds, show a loader
        let uploadTask = audioRef.putFile(from: songURL, metadata: nil) { metadata, error in
          guard error == nil else {
            print("Failed to upload: \(String(describing: error?.localizedDescription))")
            let alert = UIAlertController(title: "❌", message: error?.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
          }
//          let size = metadata.size
          audioRef.downloadURL { (url, error) in
            guard let downloadURL = url, error == nil else { return }
            self.preloader.stopAnimating()
            self.activityLoader.isHidden = true
            let urlString = downloadURL.absoluteURL
            print(urlString)
            
            let alert = UIAlertController(title: "✅", message: "Song upload successful", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
          }
        }
        
        uploadTask.observe(.progress) { snapshot in
            // print reported upload progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("\(percentComplete) percent complete")
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
