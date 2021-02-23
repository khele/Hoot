//
//  AddViewModel.swift
//  Hoot
//
//  Created by Kristian Helenius on 12/09/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import Foundation
import Firebase
import Photos
import AVFoundation
import AVKit
import CoreLocation
import MobileCoreServices
import CoreData
import CropViewController

class AddViewModel: NSObject, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    weak var delegate: AddViewModelDelegate?
    
    // Firebase Storage itemImage ref
    
    let itemImageFireRef = Storage.storage().reference().child("itemImages")
    
    
    // Firebase Firestore db ref
    
    let db = Firestore.firestore()
    
    
    // User refs
    
    let uid = Auth.auth().currentUser?.uid
    
    let dname = Auth.auth().currentUser?.displayName
    
    
    unowned let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var id = ""
    
    var selectedRarity = ""
    var selectedRarityNumber = 1
    
    let notice = Notice()
    
    var categoryPickerList: [String] = ["-- Select rarity --", "Common", "Rare", "Extremely rare"]

    var soundRecorded = false
    var videoRecorded = false
    var isRecordingSound = false
    
    var soundUrl: URL?
    var videoUrl: URL?
    
    let fileManager = FileManager.default
    
    var soundRecorder: AVAudioRecorder?
    var soundPlayer: AVAudioPlayer?
    
    let locationManager = CLLocationManager()
    
    var lat: Double?
    var long: Double?
    
    let session = AVAudioSession.sharedInstance()
    
    var speciesText: String!
    
    var notesText: String!
    
    var picture: UIImage!
   
    
    
    func viewDidLoadWasCalled(){
    
        id = getId()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        session.requestRecordPermission() {result in print(result)}
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { result in print(result) }
        
        PHPhotoLibrary.requestAuthorization(){ result in print(result) }
    }
    
    func addPictureWasPressed(){
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        
        
        let titleString = NSLocalizedString("Choose from gallery or use camera?", comment: "Ask user whether to choose from image gallery or camera")
        let photoString = NSLocalizedString("Photo library", comment: "")
        let cameraString = NSLocalizedString("Camera", comment: "")
        let cancelString = NSLocalizedString("Cancel", comment: "")
        
        let actionSheet = UIAlertController(title: titleString, message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: photoString, style: .default, handler: {[unowned self] (action: UIAlertAction) in
            
            guard PHPhotoLibrary.authorizationStatus() == .authorized else { self.delegate?.presentAlertControllerWasCalled(alert: self.notice.photoAlert); return }
            
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            self.delegate?.presentViewControllerWasCalled(vc: imagePicker, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: cameraString, style: .default, handler: {[unowned self] (action: UIAlertAction) in
            
            guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else { self.delegate?.presentAlertControllerWasCalled(alert: self.notice.cameraAlert); return }
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                
                self.delegate?.presentViewControllerWasCalled(vc: imagePicker, animated: true)
            }
            else {
                print("Camera not available")
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: cancelString, style: .cancel, handler: nil))
        
        
        delegate?.presentActionSheetWasCalled(ac: actionSheet)
        
    }
    
    
    
    
    
    func getId() -> String {
        
        let idRef = db.collection("observation").document()
        let documentId = idRef.documentID
        
        return documentId
    }
    
    
    func setupCategoryPicker() -> UIPickerView{
        
        let categoryPicker = UIPickerView()
        categoryPicker.delegate = self
        
        return categoryPicker
    }
    
    func createCategoryPickerToolBar() -> UIToolbar{
        
        let doneString = NSLocalizedString("Done", comment: "Done")
        
        unowned let _self = self
        
        let categoryPickerToolBar = UIToolbar()
        categoryPickerToolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: doneString, style: .plain, target: _self, action: #selector(dismissKeyboard))
        
        categoryPickerToolBar.setItems([doneButton], animated: false)
        categoryPickerToolBar.isUserInteractionEnabled = true
        
        return categoryPickerToolBar
    }
    
    
    @objc func dismissKeyboard(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [unowned self] in
            self.delegate?.keyboardDismissWasCalled()
        }
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! String
        
        if mediaType == (kUTTypeImage as String) {
            
            let img = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            
            let image = imageOrientation(img)
            
            let cropViewController = CropViewController(croppingStyle: .default, image: image)
            cropViewController.delegate = self
            cropViewController.aspectRatioPreset = .presetSquare
            cropViewController.aspectRatioLockEnabled = true
            cropViewController.resetAspectRatioEnabled = false
            picker.dismiss(animated: true, completion: nil)
            delegate?.presentViewControllerWasCalled(vc: cropViewController, animated: false)
        }
        
        
        if mediaType == (kUTTypeMovie as String) {
            
            
            let url = info[UIImagePickerController.InfoKey.mediaURL] as! URL
            
            let asset = AVURLAsset(url: url)
            
            guard asset.duration.seconds < 15 else { delegate?.dismissViewControllerWasCalled(vc: picker, animated: true); delegate?.presentAlertControllerWasCalled(alert: notice.videoAlert); return }
            
            delegate?.setupDeleteVideoButtonWasCalled()
            
            videoRecorded = true
            
            delegate?.dismissViewControllerWasCalled(vc: picker, animated: true)
            
            let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(id).mp4")
            
            fileManager.createFile(atPath: path, contents: try!(Data(contentsOf: url)), attributes: nil)
            
            videoUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask)[0].appendingPathComponent("\(id).mp4")
            
            
        }
        
    }
    
    
    // Orientate image correctly by EXIF
    
    func imageOrientation(_ src:UIImage)->UIImage {
        print(src.imageOrientation.rawValue)
        print(src.imageOrientation.hashValue)
        if src.imageOrientation == UIImage.Orientation.up {
            return src
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch src.imageOrientation {
        case UIImageOrientation.up, UIImageOrientation.upMirrored:
            transform = transform.translatedBy(x: src.size.width, y: src.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case UIImageOrientation.down, UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: src.size.width, y: src.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: src.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
            break
        case UIImageOrientation.right, UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: src.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi / 2))
            break
            
        @unknown default:
            fatalError()
        }
        
        switch src.imageOrientation {
        case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
            transform.translatedBy(x: src.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
            transform.translatedBy(x: src.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.up, UIImageOrientation.down, UIImageOrientation.left, UIImageOrientation.right:
            break
        @unknown default:
            fatalError()
        }
        
        let ctx:CGContext = CGContext(data: nil, width: Int(src.size.width), height: Int(src.size.height), bitsPerComponent: (src.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (src.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch src.imageOrientation {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.height, height: src.size.width))
            break
        default:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
            break
        }
        
        let cgimg:CGImage = ctx.makeImage()!
        let img:UIImage = UIImage(cgImage: cgimg)
        
        return img
    }
    
    
    
    
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        delegate?.setImageWasCalled(image: image)
        delegate?.controlOkButtonStateWasCalled()
        delegate?.dismissViewControllerWasCalled(vc: cropViewController, animated: false)
        
    }
    
    
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.dismissViewControllerWasCalled(vc: picker, animated: true)
    }
    
    
    
    
    
    
    func deleteSoundButtonPressed(){
        
        try!(fileManager.removeItem(at: soundUrl!))
        
        delegate?.removeDeleteSoundButtonWasCalled()
        
        soundRecorded = false
        
        soundUrl = nil
        
        soundRecorder = nil
        
        soundPlayer = nil
        
    }
    
    
    func deleteVideoButtonPressed(){
        
        try!(fileManager.removeItem(at: videoUrl!))
        
        delegate?.removeDeleteVideoButtonWasCalled()
        
        videoRecorded = false
        
        videoUrl = nil
    }
    
    
    
    
    
    
    @IBAction func addSoundButtonPressed(_ sender: Any) {
        
        if isRecordingSound == true {
            
            soundRecorder!.stop()
            isRecordingSound = false
            soundRecorded = true
            
           delegate?.setupDeleteSoundButtonWasCalled()
            
        }
            
            
        else if isRecordingSound == false && soundRecorded == false {
            
            guard session.recordPermission == .granted else { delegate?.presentAlertControllerWasCalled(alert: notice.microphoneAlert); return}
            
            try! session.setCategory(AVAudioSession.Category.playAndRecord)
            
            soundUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask)[0].appendingPathComponent("\(id).m4a")
            
            let recordingSettings: [String: Any] = [AVFormatIDKey: kAudioFormatAppleLossless,
                                                    AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue, AVEncoderBitRateKey: 320000,
                                                    AVNumberOfChannelsKey: 2, AVSampleRateKey: 44100.2]
            
            soundRecorder = try!(AVAudioRecorder(url: soundUrl!, settings: recordingSettings))
            soundRecorder!.delegate = self
            soundRecorder!.isMeteringEnabled = true
            soundRecorder!.prepareToRecord()
            soundRecorder!.record()
            
            isRecordingSound = true
            delegate?.setupStopSoundButtonWasCalled()
            
            
            
        }
            
        else {
            
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(AVAudioSession.Category.playback)
            do{
                soundPlayer = try AVAudioPlayer(contentsOf: soundUrl!)
            }
            catch{
                print(error)
            }
            soundPlayer?.play()
        }
        
    }
    
    
    
    
    
    
    
    @IBAction func addVideoButtonPressed(_ sender: Any) {
        
        if videoRecorded == false {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            
            let titleString = NSLocalizedString("Choose from gallery or use camera? ", comment: "Ask user whether to choose from image gallery or camera")
            
            let messageString = NSLocalizedString("Video length limit is 15 seconds!", comment: "")
            
            let photoString = NSLocalizedString("Photo library", comment: "")
            
            let cameraString = NSLocalizedString("Camera", comment: "")
            
            let cancelString = NSLocalizedString("Cancel", comment: "")
            
            let actionSheet = UIAlertController(title: titleString, message: messageString, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: photoString, style: .default, handler: {[unowned self] (action: UIAlertAction) in
                
                guard PHPhotoLibrary.authorizationStatus() == .authorized else { self.delegate?.presentAlertControllerWasCalled(alert: self.notice.photoAlert); return }
                
                imagePicker.sourceType = .photoLibrary
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.videoMaximumDuration = 0.1
                imagePicker.videoQuality = .type640x480
                
                self.delegate?.presentViewControllerWasCalled(vc: imagePicker, animated: true)
                
            }))
            
            actionSheet.addAction(UIAlertAction(title: cameraString, style: .default, handler: {[unowned self] (action: UIAlertAction) in
                
                guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else { self.delegate?.presentAlertControllerWasCalled(alert: self.notice.cameraAlert); return }
                
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    imagePicker.sourceType = .camera
                    imagePicker.mediaTypes = [kUTTypeMovie as String]
                    
                    self.delegate?.presentViewControllerWasCalled(vc: imagePicker, animated: true)
                }
                else {
                    print("Camera not available")
                }
                
            }))
            
            actionSheet.addAction(UIAlertAction(title: cancelString, style: .cancel, handler: nil))
            
            delegate?.presentActionSheetWasCalled(ac: actionSheet)
            
        }
            
        else {
            
            let video = AVPlayer(url: videoUrl!)
            
            let videoPlayer = AVPlayerViewController()
            videoPlayer.player = video
            
            delegate?.presentViewControllerWasCalled(vc: videoPlayer, animated: true)
            
            video.play()
        }
    }
    
    
    
    
    
    func cancelButtonPressed() {
        
        if videoUrl != nil {  try? fileManager.removeItem(at: videoUrl!) }
        if soundUrl != nil { try? fileManager.removeItem(at: soundUrl!) }
        
        delegate?.popViewControllerWasCalled()
        
    }
    
    
    
    
   func confirmButtonPressed() {
        
        guard lat != nil && long != nil else { delegate?.presentAlertControllerWasCalled(alert: notice.locationAlert); return }
        
        delegate?.getObservationContentWasCalled()
        
        delegate?.setUIInteractionStateWasCalled(enabled: false)
        
        delegate?.setLoaderStateWasCalled(show: true)
        
        let pictureJpeg = picture.jpegData(compressionQuality: 0.05)
        
        let picturePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(id).jpeg")
        
        fileManager.createFile(atPath: picturePath, contents: pictureJpeg, attributes: nil)
        
        
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let observationEntity = NSEntityDescription.entity(forEntityName: "OwnObservation", in: managedContext)
        
        let observation = NSManagedObject(entity: observationEntity!, insertInto: managedContext)
        
        var soundU = ""
        
        var videoU = ""
        
        if soundUrl != nil { soundU = "\(id).m4a" }
        
        if videoUrl != nil { videoU = "\(id).mp4" }
        
        observation.setValuesForKeys(["species": speciesText!, "rarity": selectedRarity, "rarityNumber": selectedRarityNumber, "notes": notesText!, "created": Int(Date().timeIntervalSince1970), "id": id, "uid": uid!, "dname": dname!, "uploaded": false, "uploading": false, "pictureUrl": "\(id).jpeg", "soundUrl": soundU, "videoUrl": videoU, "lat": lat!, "long": long!])
        
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Error occurred: \(error)")
            delegate?.presentAlertControllerWasCalled(alert: notice.generalAlert)
            delegate?.setUIInteractionStateWasCalled(enabled: true)
            
            return
        }
        delegate?.setLoaderStateWasCalled(show: false)
        delegate?.popViewControllerWasCalled()
    }
    
    
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryPickerList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return NSLocalizedString(categoryPickerList[row], comment: "")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRarity = categoryPickerList[row]
        selectedRarityNumber = row
        delegate?.setRarityTextFieldTextWasCalled(text: NSLocalizedString(categoryPickerList[row], comment: ""))
        delegate?.controlOkButtonStateWasCalled()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lat = locations.last?.coordinate.latitude
        long = locations.last?.coordinate.longitude
        
    }
    
    
}
