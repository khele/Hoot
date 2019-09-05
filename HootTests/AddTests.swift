//
//  AddTests.swift
//  HootTests
//
//  Created by Kristian Helenius on 05/09/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import XCTest
import AVKit


@testable import Hoot
class AddTests: XCTestCase {

   

    func testControlOkButton() {
        
        let addVc = UIStoryboard(name: "Add", bundle: Bundle.main).instantiateViewController(withIdentifier: "addViewController") as! AddViewController
        
        let _ = addVc.view
        
        addVc.controlOkButtonState()
        
        print("ALPHA IS  \(addVc.confirmButton.alpha)")
        
        XCTAssert(addVc.confirmButton.alpha == 0.5 &&
            addVc.confirmButton.isUserInteractionEnabled == false)
        
        addVc.pictureView.image = #imageLiteral(resourceName: "birdie")
        
        addVc.controlOkButtonState()
        
        print("ALPHA IS  \(addVc.confirmButton.alpha)")
        
        XCTAssert(addVc.confirmButton.alpha == 0.5 &&
            addVc.confirmButton.isUserInteractionEnabled == false)
        
        addVc.speciesTextField.text = "test"
        
        addVc.controlOkButtonState()
        
        print("ALPHA IS  \(addVc.confirmButton.alpha)")
        
        XCTAssert(addVc.confirmButton.alpha == 0.5 &&
            addVc.confirmButton.isUserInteractionEnabled == false)
        
        addVc.rarityTextField.text = "rare"
        
        addVc.controlOkButtonState()
        
        print("ALPHA IS  \(addVc.confirmButton.alpha)")
        
        XCTAssert(addVc.confirmButton.alpha == 0.5 &&
            addVc.confirmButton.isUserInteractionEnabled == false)
        
        addVc.notesTextField.text = "test"
        
        addVc.controlOkButtonState()
        
        print("ALPHA IS  \(addVc.confirmButton.alpha)")
        
        XCTAssert(addVc.confirmButton.alpha == 1 &&
            addVc.confirmButton.isUserInteractionEnabled == true)
        
        addVc.speciesTextField.text = ""
        
        addVc.controlOkButtonState()
        
        print("ALPHA IS  \(addVc.confirmButton.alpha)")
        
        XCTAssert(addVc.confirmButton.alpha == 0.5 &&
            addVc.confirmButton.isUserInteractionEnabled == false)
    }
    
    func testDeleteSoundButton(){
        
        let addVc = UIStoryboard(name: "Add", bundle: Bundle.main).instantiateViewController(withIdentifier: "addViewController") as! AddViewController
        
        let _ = addVc.view
        
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("test.m4a")
        
        let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/hoot-26efb.appspot.com/o/test%2Fsound%2FNew%20Recording%205.m4a?alt=media&token=a2055a21-ebf0-4467-91ce-be056e286b9b")!
        
        addVc.soundUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask)[0].appendingPathComponent("test.m4a")
        
        addVc.fileManager.createFile(atPath: path, contents: try!(Data(contentsOf: url)), attributes: nil)
        
        addVc.deleteSoundButton = UIButton(type: .system)
        addVc.deleteSoundButton!.setBackgroundImage(#imageLiteral(resourceName: "cancelButton"), for: .normal)
        addVc.deleteSoundButton!.addTarget(self, action: #selector(addVc.deleteSoundButtonPressed), for: .touchUpInside)
        addVc.deleteSoundButton!.translatesAutoresizingMaskIntoConstraints = false
        
        addVc.soundButtonStackView.addArrangedSubview(addVc.deleteSoundButton!)
        
        addVc.deleteSoundButton!.widthAnchor.constraint(equalTo: addVc.view.widthAnchor, multiplier: 0.17).isActive = true
        addVc.deleteSoundButton!.heightAnchor.constraint(equalTo: addVc.deleteSoundButton!.widthAnchor, multiplier: 1).isActive = true
        
        addVc.soundRecorded = true
        
        addVc.addSoundButton.setBackgroundImage(#imageLiteral(resourceName: "playButton"), for: .normal)
        
        let recordingSettings: [String: Any] = [AVFormatIDKey: kAudioFormatAppleLossless,
                                                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue, AVEncoderBitRateKey: 320000,
                                                AVNumberOfChannelsKey: 2, AVSampleRateKey: 44100.2]
        
        addVc.soundRecorder = try!(AVAudioRecorder(url: addVc.soundUrl!, settings: recordingSettings))
        
        addVc.soundPlayer = try!(AVAudioPlayer(data: Data(contentsOf: addVc.soundUrl!)))
        
        addVc.deleteSoundButtonPressed()
        
        XCTAssert(addVc.soundRecorded == false && addVc.deleteSoundButton == nil && addVc.soundUrl == nil && addVc.soundRecorder == nil && addVc.soundPlayer == nil && addVc.addSoundButton.backgroundImage(for: .normal) == UIImage(imageLiteralResourceName: "addSoundButton"))
        
        let lastView = addVc.soundButtonStackView.arrangedSubviews.last as! UIButton
        
        XCTAssert(lastView.backgroundImage(for: .normal) != UIImage(imageLiteralResourceName: "cancelButton"))
        
    }

    func testDeleteVideoButton(){
        
        let addVc = UIStoryboard(name: "Add", bundle: Bundle.main).instantiateViewController(withIdentifier: "addViewController") as! AddViewController
        
        let _ = addVc.view
        
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("test.mp4")
        
        let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/hoot-26efb.appspot.com/o/test%2Fvideo%2FIMG_2620.MOV?alt=media&token=6c8629ce-f6e7-4fef-8297-ea4ab5488a08")!
        
        addVc.videoUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask)[0].appendingPathComponent("test.mp4")
        
        addVc.fileManager.createFile(atPath: path, contents: try!(Data(contentsOf: url)), attributes: nil)
        
        addVc.deleteVideoButton = UIButton(type: .system)
        addVc.deleteVideoButton!.setBackgroundImage(#imageLiteral(resourceName: "cancelButton"), for: .normal)
        addVc.deleteVideoButton!.addTarget(self, action: #selector(addVc.deleteVideoButtonPressed), for: .touchUpInside)
        addVc.deleteVideoButton!.translatesAutoresizingMaskIntoConstraints = false
        
        addVc.videoButtonStackView.addArrangedSubview(addVc.deleteVideoButton!)
        
        addVc.deleteVideoButton!.widthAnchor.constraint(equalTo: addVc.view.widthAnchor, multiplier: 0.17).isActive = true
        addVc.deleteVideoButton!.heightAnchor.constraint(equalTo: addVc.deleteVideoButton!.widthAnchor, multiplier: 1).isActive = true
        
        addVc.videoRecorded = true
        
        addVc.addVideoButton.setBackgroundImage(#imageLiteral(resourceName: "playButton"), for: .normal)
        
        addVc.deleteVideoButtonPressed()
        
        XCTAssert(addVc.videoRecorded == false && addVc.deleteVideoButton == nil && addVc.videoUrl == nil && addVc.addVideoButton.backgroundImage(for: .normal) == UIImage(imageLiteralResourceName: "addVideoButton"))
        
        let lastView = addVc.videoButtonStackView.arrangedSubviews.last as! UIButton
        
        XCTAssert(lastView.backgroundImage(for: .normal) != UIImage(imageLiteralResourceName: "cancelButton"))
        
    }
    
    

}
