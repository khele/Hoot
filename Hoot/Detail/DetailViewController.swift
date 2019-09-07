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
import CoreData


class DetailViewController: UIViewController, UIScrollViewDelegate, DeleteObservationDelegate {

    // Firebase
    
    var uid = Auth.auth().currentUser?.uid
    
    
    
    
    // IB vars
    
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
    
    @IBOutlet weak var timeIndicatorLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var soundImage: UIImageView!
    
    @IBOutlet weak var videoImage: UIImageView!
    
    @IBOutlet weak var soundPlayButton: UIButton!
    
    @IBOutlet weak var videoPlayButton: UIButton!
    
    
    
    var deleteObservation: DeleteObservation!
    
    var soundUrl: String = ""
    
    var videoUrl: String = ""
    
    var observation: MainItem!
    
    var soundPlayer: AVAudioPlayer?
    
    let fileManager = FileManager.default
    
    let notice = Notice()
    
    var spinner: UIActivityIndicatorView!
    
    var scrollOffset: CGFloat?
    
    var loaderView: UIView!
    
    unowned let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    deinit {
        print("DETAIL DEINIT RAN")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       setupLayout()
       scrollView.delegate = self
        
    }
    
    
    
    func setupLayout(){
        
        canvasView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 1, alpha: 1)
        
        if observation.uid! == uid! {
        let trashButton = UIBarButtonItem(image: #imageLiteral(resourceName: "trash"), style: .plain, target: self, action: #selector(showConfirmAlert))
        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItem = trashButton
        navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGray
        }
        
        let hootIcon = UIImageView()
        hootIcon.image = #imageLiteral(resourceName: "hoot144")
        hootIcon.contentMode = .scaleAspectFit
        navigationItem.titleView = hootIcon
        
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
        
        timeLabel.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: Double(observation.created)), dateStyle: .short, timeStyle: .short)
        
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
            
            let soundFile = URL(string: soundUrl)!
            
            do{
             self.soundPlayer =  try AVAudioPlayer(data: Data(contentsOf: soundFile))
                
            }
            catch{
                print(error)
            }
            
            
            
            self.soundPlayer?.play()
            
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
    
    func showLoader() {
        DispatchQueue.main.async() { [unowned self] in
            
            self.loaderView = UIView()
            self.loaderView.backgroundColor = .white
            self.loaderView.layer.cornerRadius = 5
            self.loaderView.layer.masksToBounds = false
            self.loaderView.translatesAutoresizingMaskIntoConstraints = false
            self.loaderView.layer.shadowColor = UIColor.darkGray.cgColor
            self.loaderView.layer.shadowOffset = CGSize(width: 0, height: 4)
            self.loaderView.layer.shadowOpacity = 0.8
            
            self.canvasView.addSubview(self.loaderView)
     
            self.loaderView.centerXAnchor.constraint(equalTo: self.canvasView.centerXAnchor).isActive = true
            self.loaderView.centerYAnchor.constraint(equalTo: self.scrollView.centerYAnchor, constant: self.scrollOffset!).isActive = true
            self.loaderView.widthAnchor.constraint(equalTo: self.canvasView.widthAnchor, multiplier: 0.25).isActive = true
            self.loaderView.heightAnchor.constraint(equalTo: self.loaderView.widthAnchor, multiplier: 1).isActive = true
            
            
            self.spinner = UIActivityIndicatorView(style: .gray)
            self.spinner.frame = CGRect(x: 0.0, y: 0.0, width: 120.0, height: 120.0)
            self.spinner.translatesAutoresizingMaskIntoConstraints = false
            self.loaderView.addSubview(self.spinner)
            self.spinner.centerXAnchor.constraint(equalTo: self.loaderView.centerXAnchor).isActive = true
            self.spinner.centerYAnchor.constraint(equalTo: self.loaderView.centerYAnchor).isActive = true
            
            self.spinner.startAnimating()
        }
    }
    
    func hideLoader() {
        DispatchQueue.main.async() { [unowned self] in
            self.spinner.stopAnimating()
            self.spinner.removeFromSuperview()
            self.loaderView.removeFromSuperview()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      scrollOffset = scrollView.contentOffset.y
    }
    
    
    @objc func showConfirmAlert(){
        
        let titleString = NSLocalizedString("Are you sure you want to remove this observation?", comment: "Confirmation to remove item")
        
        let confirmString = NSLocalizedString("Confirm", comment: "Confirm")
        
        let cancelString = NSLocalizedString("Cancel", comment: "Cancel")
        
        let alert = UIAlertController(title: titleString, message: "", preferredStyle: .alert)
        
        let confirmOption = UIAlertAction(title: confirmString, style: .default, handler: {(UIAlertAction) in
            
            let obs = self.observation as! OwnObservation
            
            self.deleteObservation = DeleteObservation(observationToDelete: obs)
            self.deleteObservation.delegate = self
            
            self.navigationItem.hidesBackButton = true
            self.soundPlayButton.isUserInteractionEnabled = false
            self.videoPlayButton.isUserInteractionEnabled = false
            self.scrollView.isUserInteractionEnabled = false
            
            self.showLoader()
            
            self.deleteObservation.deleteObservation()
        })
        
        let cancelOption = UIAlertAction(title: cancelString, style: .cancel, handler: nil)
        
        alert.addAction(cancelOption)
        alert.addAction(confirmOption)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func deleteObservationDidRun(result: DeleteResult) {
        
        if result == .success {
            hideLoader()
            navigationController?.popViewController(animated: true)
        }
        
        if result == .uploading{
            hideLoader()
            
            navigationItem.hidesBackButton = false
            soundPlayButton.isUserInteractionEnabled = true
            videoPlayButton.isUserInteractionEnabled = true
            scrollView.isUserInteractionEnabled = true
            
            present(notice.syncAlert, animated: true, completion: nil)
            
        }
        
    }
    
}
