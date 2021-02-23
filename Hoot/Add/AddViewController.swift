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
import Photos

class AddViewController: UIViewController, UITextFieldDelegate, AddViewModelDelegate {
    
    
    

    // IB vars
    
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
    
    
    var activeField: UITextField?
    
    var spinner: UIActivityIndicatorView!
    
    var deleteSoundButton: UIButton?
    var deleteVideoButton: UIButton?
    
    var categoryPicker = UIPickerView()
    
    var viewModel: AddViewModel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerForKeyboardNotifications()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = AddViewModel()
        viewModel.delegate = self
        viewModel.viewDidLoadWasCalled()
        setupLayout()
       
        speciesTextField.delegate = self
        notesTextField.delegate = self
        
        rarityTextField.inputView = viewModel.setupCategoryPicker()
        rarityTextField.inputAccessoryView = viewModel.createCategoryPickerToolBar()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        deregisterFromKeyboardNotifications()
        
    }
    

    func setupLayout(){
        
        canvasView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 1, alpha: 1)
        
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 1, alpha: 1)
        
        navigationItem.hidesBackButton = true
        
        pictureView.layer.cornerRadius = 10
        
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
        
        let hootIcon = UIImageView()
        hootIcon.image = #imageLiteral(resourceName: "hoot144")
        hootIcon.contentMode = .scaleAspectFit
        navigationItem.titleView = hootIcon
        
    }
    
    
    func controlOkButtonStateWasCalled(){
        controlOkButtonState()
    }
    
    func setImageWasCalled(image: UIImage){
        pictureView.image = image
    }
    
    func setRarityTextFieldTextWasCalled(text: String){
        rarityTextField.text = text
    }

    func setUIInteractionStateWasCalled(enabled: Bool){
        
        if enabled == true{
            cancelButton.isUserInteractionEnabled = true
            addSoundButton.isUserInteractionEnabled = true
            addVideoButton.isUserInteractionEnabled = true
            deleteSoundButton?.isUserInteractionEnabled = true
            deleteVideoButton?.isUserInteractionEnabled = true
        }
        else{
            cancelButton.isUserInteractionEnabled = false
            addSoundButton.isUserInteractionEnabled = false
            addVideoButton.isUserInteractionEnabled = false
            deleteSoundButton?.isUserInteractionEnabled = false
            deleteVideoButton?.isUserInteractionEnabled = false
        }
    }
    
    func setLoaderStateWasCalled(show: Bool){
        if show == true{
            showLoader()
        }
        else{
            hideLoader()
        }
    }
    
    func getObservationContentWasCalled(){
        viewModel.picture = pictureView.image!
        viewModel.speciesText = speciesTextField.text!
        viewModel.notesText = notesTextField.text!
    }
    
    
    
    func presentAlertControllerWasCalled(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func presentViewControllerWasCalled(vc: UIViewController, animated: Bool) {
        present(vc, animated: animated, completion: nil)
    }
    
    
    func presentActionSheetWasCalled(ac: UIAlertController){
        
        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(ac, animated: true, completion: nil)
    }
    
    
    func dismissViewControllerWasCalled(vc: UIViewController, animated: Bool){
        vc.dismiss(animated: animated, completion: nil)
    }
    
    func popViewControllerWasCalled(){
        navigationController?.popViewController(animated: true)
    }
    
    
    
    func setupStopSoundButtonWasCalled(){
        
        addSoundButton.setBackgroundImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
        addSoundLabel.text = NSLocalizedString("Recording", comment: "")
        addSoundLabel.textColor = UIColor.red
    }
    
    
    
    func setupDeleteSoundButtonWasCalled() {
        
        addSoundButton.setBackgroundImage(#imageLiteral(resourceName: "playButton"), for: .normal)
        
        deleteSoundButton = UIButton(type: .system)
        deleteSoundButton!.setBackgroundImage(#imageLiteral(resourceName: "cancelButton"), for: .normal)
        deleteSoundButton!.addTarget(self, action: #selector(deleteSoundButtonPressed), for: .touchUpInside)
        deleteSoundButton!.translatesAutoresizingMaskIntoConstraints = false
        
        soundButtonStackView.addArrangedSubview(deleteSoundButton!)
        
        if traitCollection.horizontalSizeClass == .regular{
            deleteSoundButton!.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1).isActive = true
        }
        else{
            deleteSoundButton!.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.17).isActive = true
        }
        deleteSoundButton!.heightAnchor.constraint(equalTo: deleteSoundButton!.widthAnchor, multiplier: 1).isActive = true
        
        addSoundLabel.text = NSLocalizedString("Add sound (optional)", comment: "")
        addSoundLabel.textColor = UIColor.darkGray
        
    }
    
    
    func setupDeleteVideoButtonWasCalled(){
        
        deleteVideoButton = UIButton(type: .system)
        deleteVideoButton!.setBackgroundImage(#imageLiteral(resourceName: "cancelButton"), for: .normal)
        deleteVideoButton!.addTarget(self, action: #selector(deleteVideoButtonPressed), for: .touchUpInside)
        deleteVideoButton!.translatesAutoresizingMaskIntoConstraints = false
        
        videoButtonStackView.addArrangedSubview(deleteVideoButton!)
        
        if traitCollection.horizontalSizeClass == .regular{
            deleteVideoButton!.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1).isActive = true
        }
        else{
            deleteVideoButton!.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.17).isActive = true
        }
        deleteVideoButton!.heightAnchor.constraint(equalTo: deleteVideoButton!.widthAnchor, multiplier: 1).isActive = true
        
        addVideoButton.setBackgroundImage(#imageLiteral(resourceName: "playButton"), for: .normal)
        
    }
    
    
    @objc func deleteSoundButtonPressed(){
        viewModel.deleteSoundButtonPressed()
    }
    
    @objc func deleteVideoButtonPressed(){
        viewModel.deleteVideoButtonPressed()
    }
    
    
    
    func removeDeleteSoundButtonWasCalled() {
        
        deleteSoundButton?.removeFromSuperview()
        addSoundButton.setBackgroundImage(#imageLiteral(resourceName: "addSoundButton"), for: .normal)
        deleteSoundButton = nil
    }
    
    func removeDeleteVideoButtonWasCalled() {
        
        deleteVideoButton?.removeFromSuperview()
        addVideoButton.setBackgroundImage(#imageLiteral(resourceName: "addVideoButton"), for: .normal)
        deleteVideoButton = nil
    }
    
    func keyboardDismissWasCalled(){
        self.view.endEditing(true)
    }
    
   
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
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
    
    
    
    @IBAction func canvasViewWasTapped(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [unowned self] in
            self.view.endEditing(true)
        }
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
        viewModel.addPictureWasPressed()
    }
    
     @IBAction func confirmButtonPressed(_ sender: Any) {
     viewModel.confirmButtonPressed()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
      viewModel.cancelButtonPressed()
    }
    
    
}
