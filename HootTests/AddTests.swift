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
        
        let addVm = AddViewModel()
        
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("test.m4a")
        
        let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/hoot-26efb.appspot.com/o/test%2Fsound%2FNew%20Recording%205.m4a?alt=media&token=a2055a21-ebf0-4467-91ce-be056e286b9b")!
        
        addVm.soundUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask)[0].appendingPathComponent("test.m4a")
        
        addVm.fileManager.createFile(atPath: path, contents: try!(Data(contentsOf: url)), attributes: nil)
        
        addVm.soundRecorded = true
        
        let recordingSettings: [String: Any] = [AVFormatIDKey: kAudioFormatAppleLossless,
                                                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue, AVEncoderBitRateKey: 320000,
                                                AVNumberOfChannelsKey: 2, AVSampleRateKey: 44100.2]
        
        addVm.soundRecorder = try!(AVAudioRecorder(url: addVm.soundUrl!, settings: recordingSettings))
        
        addVm.soundPlayer = try!(AVAudioPlayer(data: Data(contentsOf: addVm.soundUrl!)))
        
        addVm.deleteSoundButtonPressed()
        
        XCTAssert(addVm.soundRecorded == false && addVm.soundUrl == nil && addVm.soundRecorder == nil && addVm.soundPlayer == nil)
        
    }

    func testDeleteVideoButton(){
        
        let addVm = AddViewModel()
   
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("test.mp4")
        
        let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/hoot-26efb.appspot.com/o/test%2Fvideo%2FIMG_2620.MOV?alt=media&token=6c8629ce-f6e7-4fef-8297-ea4ab5488a08")!
        
        addVm.videoUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask)[0].appendingPathComponent("test.mp4")
        
        addVm.fileManager.createFile(atPath: path, contents: try!(Data(contentsOf: url)), attributes: nil)
        
        addVm.videoRecorded = true
        
        addVm.deleteVideoButtonPressed()
        
        XCTAssert(addVm.videoRecorded == false && addVm.videoUrl == nil)
        
    }
    
    

}
