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


class DetailViewController: UIViewController, UIScrollViewDelegate, DetailViewModelDelegate {
   
    
    
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
    
    var viewModel: DetailViewModel!
    
    var spinner: UIActivityIndicatorView!
    
    var scrollOffset: CGFloat?
    
    var loaderView: UIView!
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        viewModel.viewDidLoadWasCalled()
        
       setupLayout()
       scrollView.delegate = self
        
    }
    
    
    
    func setupLayout(){
        
        canvasView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 1, alpha: 1)
        
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 1, alpha: 1)
        
        if viewModel.observation.uid! == uid! {
        let trashButton = UIBarButtonItem(image: #imageLiteral(resourceName: "trash"), style: .plain, target: self, action: #selector(showConfirmAlert))
        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItem = trashButton
        navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGray
        }
        
        let hootIcon = UIImageView()
        hootIcon.image = #imageLiteral(resourceName: "hoot144")
        hootIcon.contentMode = .scaleAspectFit
        navigationItem.titleView = hootIcon
        
        speciesLabel.text = viewModel.observation.species!
        rarityLabel.text = viewModel.observation.rarity!
        
        notesLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        notesLabel.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 0.4
        
        let attributes : [NSAttributedString.Key  : AnyObject] = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        let attributedText = NSAttributedString.init(string: viewModel.observation.notes!, attributes: attributes)
        notesLabel.attributedText = attributedText
        
        if viewModel.observation.uid != uid! {
            
            let pictureUrl = URL(string: viewModel.observation.pictureUrl!)
            
            pictureView.kf.setImage(with: pictureUrl, options: [.cacheSerializer(FormatIndicatedCacheSerializer.png)])
            
        }
            
        else {
            
            let picturePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(viewModel.observation.pictureUrl!)
            
            pictureView.image = UIImage(contentsOfFile: picturePath)
            
        }
        
        latLabel.text = "\(viewModel.observation.lat)"
        longLabel.text = "\(viewModel.observation.long)"
        
        timeLabel.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: Double(viewModel.observation.created)), dateStyle: .short, timeStyle: .short)
        
        
        if viewModel.soundUrl == "" { soundPlayButton.alpha = 0.5; soundPlayButton.isUserInteractionEnabled = false }
        if viewModel.videoUrl == "" { videoPlayButton.alpha = 0.5; videoPlayButton.isUserInteractionEnabled = false }
        
    }
    
    
    @objc func showConfirmAlert(){
        
        viewModel.showConfirmAlert()
    }
    
    
    func presentAlertWasCalled(alert: UIAlertController){
        present(alert, animated: true, completion: nil)
    }
    
    
    func presentViewControllerWasCalled(vc: UIViewController){
        
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func soundPlayButtonPressed(_ sender: Any) {
        
        viewModel.soundPlayButtonWasPressed()
    }
    

    @IBAction func videoPlayButtonPressed(_ sender: Any) {
        
       viewModel.videoPlayButtonWasPressed()
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
    
    
    func setUIInterActionStateWasCalled(enable: Bool){
        
        if enable == true {
            navigationItem.hidesBackButton = false
            soundPlayButton.isUserInteractionEnabled = true
            videoPlayButton.isUserInteractionEnabled = true
            scrollView.isUserInteractionEnabled = true
        }
        else{
            self.navigationItem.hidesBackButton = true
            self.soundPlayButton.isUserInteractionEnabled = false
            self.videoPlayButton.isUserInteractionEnabled = false
            self.scrollView.isUserInteractionEnabled = false
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
    
    func popViewControllerWasCalled(){
        navigationController?.popViewController(animated: true)
    }
   
    
}
