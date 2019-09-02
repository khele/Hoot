//
//  DetailViewController.swift
//  Hoot
//
//  Created by Kristian Helenius on 02/09/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import AVFoundation
import AVKit

class DetailViewController: UIViewController {

    
    let soundFireRef = Storage.storage().reference().child("sound")
   
    let videoFireRef = Storage.storage().reference().child("video")
    
    let uid = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var canvasView: UIView!
    
    @IBOutlet weak var pictureView: UIImageView!
    
    @IBOutlet weak var speciesIndicatorLabel: UILabel!
    
    @IBOutlet weak var speciesLabel: UILabel!
    
    @IBOutlet weak var rarityIndicatorLabel: UILabel!
    
    @IBOutlet weak var rarityLabel: UILabel!
    
    @IBOutlet weak var notesIndicatorLabel: UILabel!
    
    @IBOutlet weak var notesLabel: UILabel!
    
    @IBOutlet weak var locationIndicatorLabel: UILabel!
    
    @IBOutlet weak var latLabel: UILabel!
    
    @IBOutlet weak var longLabel: UILabel!
    
    @IBOutlet weak var soundImage: UIImageView!
    
    @IBOutlet weak var videoImage: UIImageView!
    
    @IBOutlet weak var soundPlayButton: UIButton!
    
    @IBOutlet weak var videoPlayButton: UIButton!
    
    var soundUrl: String = ""
    
    var videoUrl: String = ""
    
    var observation: MainItem!
    
    var soundPlayer: AVAudioPlayer?
    
    let fileManager = FileManager.default
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       setupLayout()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
    }
    
    
    func setupLayout(){
        
        canvasView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 1, alpha: 1)
        
        
        
        speciesLabel.text = observation.species!
        rarityLabel.text = observation.rarity!
        
        notesLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        notesLabel.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 0.4
        
        let attributes : [NSAttributedString.Key  : AnyObject] = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        let attributedText = NSAttributedString.init(string: observation.notes!, attributes: attributes)
        notesLabel.attributedText = attributedText
        
        if observation.uid != uid! {
            
            let pictureUrl = URL(string: observation.pictureUrl!)
            
            pictureView.kf.setImage(with: pictureUrl, options: [.cacheSerializer(FormatIndicatedCacheSerializer.png)])
            
        }
            
        else {
            
            let picturePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(observation.pictureUrl!)
            
            pictureView.image = UIImage(contentsOfFile: picturePath)
            
        }
        
        latLabel.text = "\(observation.lat)"
        longLabel.text = "\(observation.long)"
        
        soundUrl = observation.soundUrl!
        videoUrl = observation.videoUrl!
        
        if soundUrl == "" { soundPlayButton.alpha = 0.5; soundPlayButton.isUserInteractionEnabled = false }
        if videoUrl == "" { videoPlayButton.alpha = 0.5; videoPlayButton.isUserInteractionEnabled = false }
        
    }
    
    
    @IBAction func soundPlayButtonPressed(_ sender: Any) {
        
        if observation.uid! == uid! {
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playback)
        
        let soundFile = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask)[0].appendingPathComponent(soundUrl)
        
        soundPlayer = try!(AVAudioPlayer(contentsOf: soundFile))
        soundPlayer?.play()
        
        }
        
        else {
            
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(AVAudioSession.Category.playback)
            
            soundPlayer = try!(AVAudioPlayer(contentsOf: URL(string: soundUrl)!))
            soundPlayer?.play()
            
        }
        
    }
    

    @IBAction func videoPlayButtonPressed(_ sender: Any) {
        
        if observation.uid! == uid! {
        
        let videoFile = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask)[0].appendingPathComponent(videoUrl)
        
        let video = AVPlayer(url: videoFile)
        
        let videoPlayer = AVPlayerViewController()
        videoPlayer.player = video
        
        present(videoPlayer, animated: true, completion: nil)
        
        video.play()
        
    }
        
        else {
            
            let video = AVPlayer(url: URL(string: videoUrl)!)
            
            let videoPlayer = AVPlayerViewController()
            videoPlayer.player = video
            
            present(videoPlayer, animated: true, completion: nil)
            
            video.play()
            
        }
        
    }
    
}
