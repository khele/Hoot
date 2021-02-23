//
//  MainViewController.swift
//  Hoot
//
//  Created by Kristian Helenius on 31/08/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import CoreData

class MainViewController: UIViewController, UICollectionViewDelegateFlowLayout, MainViewModelDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
   
    
   
    
    // MARK: ViewModel
    
    var viewModel: MainViewModel!
    
   
    
    // MARK: IB vars
    
    @IBOutlet var canvasView: UIView!
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var ownSwitch: UISwitch!
    
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var offlineLabel: UILabel!
    
    @IBOutlet weak var emptyImage: UIImageView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    @IBOutlet weak var sortView: UIView!
    @IBOutlet weak var sortLabel: UILabel!
    @IBOutlet weak var sortTextField: UITextField!
    @IBOutlet weak var sortViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var confirmSortButton: UIButton!
    
    var categoryPicker: UIPickerView!
   
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.viewWillAppearWasCalled()
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = MainViewModel()
        viewModel.delegate = self
        
        viewModel.viewDidLoadWasCalled()
        
        setupLayout()
        
        mainCollectionView.register(MainCell.self, forCellWithReuseIdentifier: "main")
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
        categoryPicker = viewModel.setupCategoryPicker()
        sortTextField.inputView = categoryPicker
        sortTextField.inputAccessoryView = viewModel.createCategoryPickerToolBar()
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel.viewDidDisappearWasCalled()
        
    }

    
    func setupLayout(){
        
        sortTextField.text = viewModel.selectedSort
        
        canvasView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 1, alpha: 1)
        mainCollectionView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 1, alpha: 1)
        
        let hootIcon = UIImageView()
        hootIcon.image = #imageLiteral(resourceName: "hoot144")
        hootIcon.contentMode = .scaleAspectFit
        navigationItem.titleView = hootIcon
        
        let logOutButton = UIBarButtonItem(image: #imageLiteral(resourceName: "logOut"), style: .plain, target: self, action: #selector(logOutButtonPressed))
        logOutButton.tintColor = .lightGray
        navigationItem.leftBarButtonItem = logOutButton
        
        let filterButton = UIBarButtonItem(image: #imageLiteral(resourceName: "sort60"), style: .plain, target: self, action: #selector(showFilterView))
        navigationItem.rightBarButtonItem = filterButton
        
        sortTextField.text = "Date: Newest first"
        sortView.layer.cornerRadius = 5
        sortView.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 1, alpha: 1)
        sortView.layer.shadowColor = UIColor.lightGray.cgColor
        sortView.layer.shadowOffset = CGSize(width: 0, height: 4)
        sortView.layer.shadowOpacity = 0.2
        
        addButton.layer.shadowColor = UIColor.lightGray.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addButton.layer.shadowOpacity = 0.4
        
        confirmSortButton.layer.shadowColor = UIColor.lightGray.cgColor
        confirmSortButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        confirmSortButton.layer.shadowOpacity = 0.2
        
    }
    
    @objc func logOutButtonPressed(){
        viewModel.logOutButtonPressed()
    }
    
    @objc func showFilterView(){
        
        if sortViewTopConstraint.constant == 0
        {
            sortViewTopConstraint.constant = -500
            UIView.animate(withDuration: 0.3, animations:{ self.view.layoutIfNeeded() })
        }
        else{
            sortViewTopConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations:{ self.view.layoutIfNeeded() })
        }
    }
    
    
    
    func keyboardDismissWasCalled() {
        view.endEditing(true)
    }
    
    
    func updateEmptyElementsWasCalled(empty: Bool) {
        
        if empty == true {
            mainCollectionView.alpha = 0
            emptyImage.alpha = 1
            emptyLabel.alpha = 1
        }
        else {
            mainCollectionView.alpha = 1
            emptyImage.alpha = 0
            emptyLabel.alpha = 0
        }
    }
    
    
    
    func collectionViewReloadDataWasCalled(){
        mainCollectionView.reloadData()
    }
    
    func collectionViewScrollToTopWasCalled(){
        mainCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    
    
    func ownSwitchFlipWasCalled(isOn: Bool) {
        if isOn == true {
            ownSwitch.isOn = true
        }
        else{
            ownSwitch.isOn = false
        }
    }
    
    
    
    func ownSwitchStateChangeWasRequested(isOn: Bool?, userActionEnabled: Bool?){
        if isOn != nil{
        if isOn == true{ownSwitch.isOn = true}
        else { ownSwitch.isOn = false }
        }
        
        if userActionEnabled != nil{
        if userActionEnabled == true { ownSwitch.isUserInteractionEnabled = true }
        else { ownSwitch.isUserInteractionEnabled = false }
        }
    }
    
    
    
    func offlineLabelStateChangeWasRequested(alpha: Int){
        
        if alpha == 0{
            UIView.animate(withDuration: 0.2, animations: { self.offlineLabel.alpha = 0 } )
        }
        else{
            UIView.animate(withDuration: 0.2, animations: { self.offlineLabel.alpha = 1 } )
        }
    }
    
    
    
    func presentAlertWasCalled(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func dismissParentWasCalled() {
        parent?.dismiss(animated: true, completion: nil)
    }
    
    func sortTextWasSet(text: String){
        sortTextField.text = text
    }
    
    
    
    
    @IBAction func confirmSortButtonPressed(_ sender: Any) {
        
        sortViewTopConstraint.constant = -500
        UIView.animate(withDuration: 0.3, animations:{ self.view.layoutIfNeeded() })
    
        viewModel.confirmSortButtonWasPressed()
    }
    
    
    
    
    @IBAction func addItemButtonPressed(_ sender: Any) {
        
        let vc = UIStoryboard(name: "Add", bundle: nil).instantiateViewController(withIdentifier: "addViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    @IBAction func ownSwitchFlipped(_ sender: Any) {
        viewModel.ownSwitchFlipped(isOn: ownSwitch.isOn)
    }
    
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModel.mainItemSetSorted.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "main", for: indexPath) as! MainCell
        
       
        if viewModel.mainItemSetSorted[indexPath.row].uid != viewModel.uid! {
            
            let processor = ResizingImageProcessor(referenceSize: CGSize(width: view.bounds.width * 0.9 * UIScreen.main.scale, height: view.bounds.width * 0.9 * UIScreen.main.scale)) >> RoundCornerImageProcessor(cornerRadius: 10)
            
            let pictureUrl = URL(string: viewModel.mainItemSetSorted[indexPath.row].pictureUrl!)
            
            cell.itemView.kf.setImage(with: pictureUrl, options: [.cacheSerializer(FormatIndicatedCacheSerializer.png), .processor(processor)])
            
        }
            
        else {
            
            let picturePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(viewModel.mainItemSetSorted[indexPath.row].pictureUrl!)
            
            cell.itemView.image = UIImage(contentsOfFile: picturePath)
            cell.itemView.layer.cornerRadius = 5
            cell.itemView.layer.masksToBounds = true
            
        }
        
        
        cell.species.text = viewModel.mainItemSetSorted[indexPath.row].species!
        cell.rarity.text = viewModel.mainItemSetSorted[indexPath.row].rarity!
        
        
        let tempMsg = viewModel.mainItemSetSorted[indexPath.row].notes!
        
        var notes = ""
        
        if tempMsg.count > 25 {
            notes = "\(String(tempMsg[..<tempMsg.index(tempMsg.startIndex, offsetBy: 25)]))..."
        }
        else if tempMsg.count == 0 {
            notes = ""
        }
        else {
            notes = "\(tempMsg)"
        }
        
        cell.notes.text = notes
        
        if viewModel.mainItemSetSorted[indexPath.row].soundUrl! == "" {
            cell.soundIndicatorImage.image = #imageLiteral(resourceName: "characterX")
        }
        else{
            cell.soundIndicatorImage.image = #imageLiteral(resourceName: "checkMark")
        }
        
        if viewModel.mainItemSetSorted[indexPath.row].videoUrl! == "" {
            cell.videoIndicatorImage.image = #imageLiteral(resourceName: "characterX")
        }
        else{
            cell.videoIndicatorImage.image = #imageLiteral(resourceName: "checkMark")
        }
        
        cell.lat.text = "\(viewModel.mainItemSetSorted[indexPath.row].lat)"
        
        cell.long.text = "\(viewModel.mainItemSetSorted[indexPath.row].long)"
        
        let dateAndTime = DateFormatter.localizedString(from: Date(timeIntervalSince1970: Double(viewModel.mainItemSetSorted[indexPath.row].created)), dateStyle: .short, timeStyle: .short)
        
        cell.time.text = dateAndTime
        
        return cell
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = UIStoryboard(name: "Detail", bundle: nil).instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
        vc.viewModel = DetailViewModel()
        vc.viewModel.observation = viewModel.mainItemSetSorted[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.collectionViewWillDisplayCell(indexPath: indexPath)
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if traitCollection.horizontalSizeClass == .regular{
            switch view.frame.width{
                
            case 0...800: return CGSize(width: view.frame.width, height: view.frame.width * 1.48)
                
            case 800...1000: return CGSize(width: view.frame.width, height: view.frame.width * 1.451)
                
            case 1000...2000: return CGSize(width: view.frame.width, height: view.frame.width * 1.399)
                
            default: return CGSize(width: view.frame.width, height: view.frame.width * 1.48)
            }
           
        }
        else {
            switch view.frame.width{
                
            case 1...350: return CGSize(width: view.frame.width, height: view.frame.width * 1.9)
                
            case 350...400: return CGSize(width: view.frame.width, height: view.frame.width * 1.8)
                
            case 400...450: return CGSize(width: view.frame.width, height: view.frame.width * 1.735)
            
            default: return CGSize(width: view.frame.width, height: view.frame.width * 1.8)
            }
            
        }
    }
    
    
    
}
