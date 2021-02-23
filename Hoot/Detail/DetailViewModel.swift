//
//  DetailViewModel.swift
//  Hoot
//
//  Created by Kristian Helenius on 12/09/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import Firebase

class DetailViewModel: NSObject, DeleteObservationDelegate{
    
    // Firebase
    
    var uid = Auth.auth().currentUser?.uid
    
    
    
    weak var delegate: DetailViewModelDelegate?
    
    var deleteObservation: DeleteObservation!
    
    var soundUrl: String = ""
    
    var videoUrl: String = ""
    
    var observation: MainItem!
    
    var soundPlayer: AVAudioPlayer?
    
    let fileManager = FileManager.default
    
    let notice = Notice()
    
    unowned let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    func viewDidLoadWasCalled(){
        
        soundUrl = observation.soundUrl!
        videoUrl = observation.videoUrl!
    }
    
    
    
    func soundPlayButtonWasPressed(){
        
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
    
    
    
    func videoPlayButtonWasPressed(){
        
        if observation.uid! == uid! {
            
            let videoFile = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask)[0].appendingPathComponent(videoUrl)
            let video = AVPlayer(url: videoFile)
            let videoPlayer = AVPlayerViewController()
            videoPlayer.player = video
            
            delegate?.presentViewControllerWasCalled(vc: videoPlayer)
            
            video.play()
        }
        else {
            
            let video = AVPlayer(url: URL(string: videoUrl)!)
            
            let videoPlayer = AVPlayerViewController()
            videoPlayer.player = video
            
            delegate?.presentViewControllerWasCalled(vc: videoPlayer)
            
            video.play()
            
        }
    }
    
    
    func showConfirmAlert(){
        
        let titleString = NSLocalizedString("Are you sure you want to remove this observation?", comment: "Confirmation to remove item")
        let confirmString = NSLocalizedString("Confirm", comment: "Confirm")
        let cancelString = NSLocalizedString("Cancel", comment: "Cancel")
        
        let alert = UIAlertController(title: titleString, message: "", preferredStyle: .alert)
        
        let confirmOption = UIAlertAction(title: confirmString, style: .default, handler: {(UIAlertAction) in
            
            let obs = self.observation as! OwnObservation
            
            self.deleteObservation = DeleteObservation(observationToDelete: obs)
            self.deleteObservation.delegate = self
            
            self.delegate?.setUIInterActionStateWasCalled(enable: false)
            
            self.delegate?.setLoaderStateWasCalled(show: true)
            
            self.deleteObservation.deleteObservation()
        })
        
        let cancelOption = UIAlertAction(title: cancelString, style: .cancel, handler: nil)
        
        alert.addAction(cancelOption)
        alert.addAction(confirmOption)
        
        delegate?.presentAlertWasCalled(alert: alert)
        
    }
    
    
    func deleteObservationDidRun(result: DeleteResult) {
        
        if result == .success{
            delegate?.setLoaderStateWasCalled(show: false)
            delegate?.popViewControllerWasCalled()
        }
        
        if result == .uploading{
            delegate?.setLoaderStateWasCalled(show: false)
            
            delegate?.setUIInterActionStateWasCalled(enable: true)
            
            delegate?.presentAlertWasCalled(alert: notice.syncAlert)
            
        }
        
        if result == .failure{
            
            delegate?.setLoaderStateWasCalled(show: false)
            
           delegate?.setUIInterActionStateWasCalled(enable: true)
            
            delegate?.presentAlertWasCalled(alert: notice.generalAlert)
            
        }
        
        if result == .networkNeeded {
            delegate?.setLoaderStateWasCalled(show: false)
            
            delegate?.setUIInterActionStateWasCalled(enable: true)
            
            delegate?.presentAlertWasCalled(alert: notice.deleteNetworkAlert)
        }
        
    }
    
    
}
