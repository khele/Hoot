//
//  AddViewController.swift
//  Hoot
//
//  Created by Kristian Helenius on 31/08/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import CropViewController
import AVFoundation
import AVKit
import MobileCoreServices
import CoreData
import CoreLocation

class AddViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, CLLocationManagerDelegate {
    
    
    // Firebase Storage itemImage ref
    
    let itemImageFireRef = Storage.storage().reference().child("itemImages")
    
    
    // Firebase Firestore db ref
    
    let db = Firestore.firestore()
    
    
    // User uid ref
    
    let uid = Auth.auth().currentUser?.uid
    
    let dname = Auth.auth().currentUser?.displayName

    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var canvasView: UIView!
    
    @IBOutlet weak var pictureView: UIImageView!
    
    @IBOutlet weak var speciesLabel: UILabel!
    
    @IBOutlet weak var speciesTextField: UITextField!
    
    @IBOutlet weak var rarityLabel: UILabel!
    
    @IBOutlet weak var rarityTextField: UITextField!
    
    @IBOutlet weak var notesLabel: UILabel!
    
    @IBOutlet weak var notesTextField: UITextField!
    
    @IBOutlet weak var addSoundLabel: UILabel!
    
    @IBOutlet weak var addSoundButton: UIButton!
    
    @IBOutlet weak var addVideoLabel: UILabel!
    
    @IBOutlet weak var addVideoButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var soundButtonStackView: UIStackView!
    
    @IBOutlet weak var videoButtonStackView: UIStackView!
    
    
    unowned let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var id = ""
    
    var activeField: UITextField?
    
    var selectedRarity = ""
    
    let notice = Notice()
    
    var categoryPickerList: [String] = ["-- Select rarity --", "Common", "Rare", "Extremely rare"]
    
    var categoryPicker = UIPickerView()
    
    var spinner: UIActivityIndicatorView!
    
    var soundRecorded = false
    
    var videoRecorded = false
    
    var isRecordingSound = false
    
    var soundUrl: URL?
    
    var videoUrl: URL?
    
    let fileManager = FileManager.default
    
    var soundRecorder: AVAudioRecorder?
    
    var soundPlayer: AVAudioPlayer?
    
    var deleteSoundButton: UIButton?
    
    var deleteVideoButton: UIButton?
    
    let locationManager = CLLocationManager()
    
    var lat: Double?
    
    var long: Double?
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerForKeyboardNotifications()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
       
        setupCategoryPicker()
        createCategoryPickerToolBar()
        
        speciesTextField.delegate = self
        notesTextField.delegate = self
        
        hideKeyboard()
        
        id = randomString()
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        deregisterFromKeyboardNotifications()
        
    }
    
    
    func setupLayout(){
        
        canvasView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 1, alpha: 1)
        
        navigationItem.hidesBackButton = true
        
        speciesLabel.text = NSLocalizedString("Species", comment: "")
        rarityLabel.text = NSLocalizedString("Rarity", comment: "")
        notesLabel.text = NSLocalizedString("Notes", comment: "")
        addSoundLabel.text = NSLocalizedString("Add sound (optional)", comment: "")
        addVideoLabel.text = NSLocalizedString("Add video (optional)", comment: "")
        
        cancelButton.layer.cornerRadius = 21
        cancelButton.layer.shadowColor = UIColor.lightGray.cgColor
        cancelButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        cancelButton.layer.shadowOpacity = 0.4
        confirmButton.layer.cornerRadius = 21
        confirmButton.layer.shadowColor = UIColor.lightGray.cgColor
        confirmButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        confirmButton.layer.shadowOpacity = 0.4
        
        confirmButton.alpha = 0.5
        confirmButton.isUserInteractionEnabled = false
        
    }
    
    
    func randomString() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<8).map{ _ in letters.randomElement()! })
    }
    
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    
    
    
    
    func registerForKeyboardNotifications(){
       
        
        unowned let _self = self
        
        NotificationCenter.default.addObserver(_self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(_self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications(){
      
        
        unowned let _self = self
        
        NotificationCenter.default.removeObserver(_self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(_self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
    
    
    @objc func keyboardWasShown(notification: NSNotification){
        
        
        unowned let _self = self
        
        scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = _self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    
    
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        
        
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        view.endEditing(true)
        scrollView.isScrollEnabled = false
    }
    
    
    func hideKeyboard() {
        
        unowned let _self = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: _self,
            action: #selector(dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == speciesTextField{
            
            let maxLength = 27
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
            
        }
        
        if textField == notesTextField {
            
            let maxLength = 150
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
            
        }
        return false
    }
    
    
    
    
    
    func controlOkButtonState() {
        guard pictureView.image != #imageLiteral(resourceName: "addImage") && speciesTextField.text?.isEmpty != true && rarityTextField.text?.isEmpty != true && rarityTextField.text != "-- Select rarity --" && notesTextField.text?.isEmpty != true
            else {
                confirmButton.alpha = 0.5
                confirmButton.isUserInteractionEnabled = false
                return }
        
        confirmButton.alpha = 1
        confirmButton.isUserInteractionEnabled = true
        
    }
    
    
    
    @IBAction func speciesTextFieldEditingDidChange(_ sender: Any) {
        controlOkButtonState()
    }
    
    @IBAction func rarityTextFieldEditingDidChange(_ sender: Any) {
        controlOkButtonState()
    }
    
    @IBAction func notesTextFieldEditingDidChange(_ sender: Any) {
        controlOkButtonState()
    }
    
    
    
    
    
    func setupCategoryPicker(){
        
        categoryPicker.delegate = self
        
        rarityTextField.inputView = categoryPicker
    }
    
    
    
  
    
    func createCategoryPickerToolBar(){
        
        let doneString = NSLocalizedString("Done", comment: "Done")
        
        unowned let _self = self
        
        let categoryPickerToolBar = UIToolbar()
        categoryPickerToolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: doneString, style: .plain, target: _self, action: #selector(AddViewController.dismissKeyboard))
        
        categoryPickerToolBar.setItems([doneButton], animated: false)
        categoryPickerToolBar.isUserInteractionEnabled = true
        
        rarityTextField.inputAccessoryView = categoryPickerToolBar
    }
    
    
    
    
    
    func showLoader() {
        DispatchQueue.main.async() { [unowned self] in
            
            self.spinner = UIActivityIndicatorView(style: .gray)
            self.spinner.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
            self.spinner.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(self.spinner)
            self.spinner.centerXAnchor.constraint(equalTo: self.confirmButton.centerXAnchor).isActive = true
            self.spinner.centerYAnchor.constraint(equalTo: self.confirmButton.centerYAnchor).isActive = true
            self.confirmButton.setBackgroundImage(#imageLiteral(resourceName: "emptyButton"), for: .normal)
            
            self.spinner.startAnimating()
        }
    }
    
    func hideLoader() {
        DispatchQueue.main.async() { [unowned self] in
            self.spinner.stopAnimating()
            self.spinner.removeFromSuperview()
        }
    }
    
    
    
    
    
    
    @IBAction func addPicturePressed(_ sender: Any) {
        
      
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
       
        
        let titleString = NSLocalizedString("Choose from gallery or use camera?", comment: "Ask user whether to choose from image gallery or camera")
        
        let photoString = NSLocalizedString("Photo library", comment: "")
        
        let cameraString = NSLocalizedString("Camera", comment: "")
        
        let cancelString = NSLocalizedString("Cancel", comment: "")
        
        let actionSheet = UIAlertController(title: titleString, message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: photoString, style: .default, handler: {[unowned self] (action: UIAlertAction) in imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: cameraString, style: .default, handler: {[unowned self] (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                
                self.present(imagePicker, animated: true, completion: nil)
            }
            else {
                print("Camera not available")
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: cancelString, style: .cancel, handler: nil))
        
      
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if info[UIImagePickerController.InfoKey.mediaType] as! String == (kUTTypeImage as String) {
        
            let img = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
            let image = imageOrientation(img)
        
            let cropViewController = CropViewController(croppingStyle: .default, image: image)
            cropViewController.delegate = self
            cropViewController.aspectRatioPreset = .presetSquare
            cropViewController.aspectRatioLockEnabled = true
            cropViewController.resetAspectRatioEnabled = false
            picker.dismiss(animated: true, completion: nil)
            present(cropViewController, animated: false, completion: nil)
            }
        
        
        if info[UIImagePickerController.InfoKey.mediaType] as! String == (kUTTypeMovie as String) {
            
            
            
            let url = info[UIImagePickerController.InfoKey.mediaURL] as! URL
            
            let asset = AVURLAsset(url: url)
            
            guard asset.duration.seconds < 15 else { picker.dismiss(animated: true, completion: nil); present(notice.videoAlert, animated: true, completion: nil); return }
            
            deleteVideoButton = UIButton(type: .system)
            deleteVideoButton!.setBackgroundImage(#imageLiteral(resourceName: "cancelButton"), for: .normal)
            deleteVideoButton!.addTarget(self, action: #selector(deleteVideoButtonPressed), for: .touchUpInside)
            deleteVideoButton!.translatesAutoresizingMaskIntoConstraints = false
            
            videoButtonStackView.addArrangedSubview(deleteVideoButton!)
            
            deleteVideoButton!.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.17).isActive = true
            deleteVideoButton!.heightAnchor.constraint(equalTo: deleteVideoButton!.widthAnchor, multiplier: 1).isActive = true
            
            videoRecorded = true
            
            addVideoButton.setBackgroundImage(#imageLiteral(resourceName: "playButton"), for: .normal)
            
            picker.dismiss(animated: true, completion: nil)
            
            let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(id).mp4")
            
            fileManager.createFile(atPath: path, contents: try!(Data(contentsOf: url)), attributes: nil)
            
            videoUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask)[0].appendingPathComponent("\(id).mp4")
            
            
        }
        
    }
    
    
    
    
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
        
        pictureView.image = image
        
        
        
        guard pictureView.image != #imageLiteral(resourceName: "addImage") && speciesTextField.text?.isEmpty != true && rarityTextField.text?.isEmpty != true && rarityTextField.text != "-- Select rarity --" && notesTextField.text?.isEmpty != true
            else {
                confirmButton.alpha = 0.5
                confirmButton.isUserInteractionEnabled = false
                cropViewController.dismiss(animated: false, completion: nil)
                return }
        
        confirmButton.alpha = 1
        confirmButton.isUserInteractionEnabled = true
        
        cropViewController.dismiss(animated: false, completion: nil)
    }
    
    
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    @objc func deleteSoundButtonPressed(){
        
        try!(fileManager.removeItem(at: soundUrl!))
        
        deleteSoundButton?.removeFromSuperview()
        
        soundRecorded = false
        
        addSoundButton.setBackgroundImage(#imageLiteral(resourceName: "addSoundButton"), for: .normal)
        
        deleteSoundButton = nil
        
        soundUrl = nil
        
        soundRecorder = nil
        
        soundPlayer = nil
        
    }
    
    
    @objc func deleteVideoButtonPressed(){
        
        try!(fileManager.removeItem(at: videoUrl!))
        
        deleteVideoButton?.removeFromSuperview()
        
        videoRecorded = false
        
        addVideoButton.setBackgroundImage(#imageLiteral(resourceName: "addVideoButton"), for: .normal)
        
        deleteVideoButton = nil
        
        videoUrl = nil
        
    }
    
   
    
    
    
    
    @IBAction func addSoundButtonPressed(_ sender: Any) {
        
        if isRecordingSound == true {
            
            soundRecorder!.stop()
            isRecordingSound = false
            soundRecorded = true
            
            addSoundButton.setBackgroundImage(#imageLiteral(resourceName: "playButton"), for: .normal)
            
            deleteSoundButton = UIButton(type: .system)
            deleteSoundButton!.setBackgroundImage(#imageLiteral(resourceName: "cancelButton"), for: .normal)
            deleteSoundButton!.addTarget(self, action: #selector(deleteSoundButtonPressed), for: .touchUpInside)
            deleteSoundButton!.translatesAutoresizingMaskIntoConstraints = false
            
            soundButtonStackView.addArrangedSubview(deleteSoundButton!)
            
            deleteSoundButton!.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.17).isActive = true
            deleteSoundButton!.heightAnchor.constraint(equalTo: deleteSoundButton!.widthAnchor, multiplier: 1).isActive = true
            
            addSoundLabel.text = NSLocalizedString("Add sound (optional)", comment: "")
            addSoundLabel.textColor = UIColor.darkGray
            
        }
        
            
        else if isRecordingSound == false && soundRecorded == false {
        
            let session = AVAudioSession.sharedInstance()
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
        addSoundButton.setBackgroundImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
        addSoundLabel.text = NSLocalizedString("Recording", comment: "")
        addSoundLabel.textColor = UIColor.red
            
            
        }
        
        else {
            
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(AVAudioSession.Category.playback)
            soundPlayer = try!(AVAudioPlayer(contentsOf: soundUrl!))
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
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.videoMaximumDuration = 0.1
            imagePicker.videoQuality = .type640x480
            
            self.present(imagePicker, animated: true, completion: nil)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: cameraString, style: .default, handler: {[unowned self] (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                
                self.present(imagePicker, animated: true, completion: nil)
            }
            else {
                print("Camera not available")
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: cancelString, style: .cancel, handler: nil))
        
        
        
        present(actionSheet, animated: true, completion: nil)
        
        }
        
        else {
            
            let video = AVPlayer(url: videoUrl!)
            
            let videoPlayer = AVPlayerViewController()
            videoPlayer.player = video
            
            present(videoPlayer, animated: true, completion: nil)
            
            video.play()
            
        }
            
    }
    
    
    
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        if videoUrl != nil {  try? fileManager.removeItem(at: videoUrl!) }
        
        if soundUrl != nil { try? fileManager.removeItem(at: soundUrl!) }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    
    
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        guard lat != nil && long != nil else { present(notice.locationAlert, animated: true, completion: nil); return }
        
        showLoader()
        
        let pictureJpeg = pictureView.image?.jpegData(compressionQuality: 0.05)
        
        let picturePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(id).jpeg")
        
        fileManager.createFile(atPath: picturePath, contents: pictureJpeg, attributes: nil)
       
        
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let observationEntity = NSEntityDescription.entity(forEntityName: "OwnObservation", in: managedContext)
        
        let observation = NSManagedObject(entity: observationEntity!, insertInto: managedContext)
       
        var soundU = ""
        
        var videoU = ""
        
        if soundUrl != nil { soundU = "\(id).m4a" }
        
        if videoUrl != nil { videoU = "\(id).mp4" }
        
        observation.setValuesForKeys(["species": speciesTextField.text!, "rarity": selectedRarity, "notes": notesTextField.text!, "created": Int(Date().timeIntervalSince1970), "id": id, "uid": uid!, "dname": dname!, "uploaded": false, "pictureUrl": "\(id).jpeg", "soundUrl": soundU, "videoUrl": videoU, "lat": lat!, "long": long!])
        
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Error occurred: \(error)")
            self.present(self.notice.generalAlert, animated: true, completion: nil)
            return
        }
        hideLoader()
        navigationController?.popViewController(animated: true)
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
        rarityTextField.text = NSLocalizedString(categoryPickerList[row], comment: "")
        controlOkButtonState()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        lat = locations.last?.coordinate.latitude
     
        long = locations.last?.coordinate.longitude
        
    }
    
}
