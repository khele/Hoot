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

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPickerViewDelegate, UIPickerViewDataSource {
   
    
    
    // Firebase Firestore db ref
    
    let db = Firestore.firestore()
    
    var observationsRef = Firestore.firestore().collection("observation")
    
    // User uid ref
    
    let auth = Auth.auth()
    
    var uid = Auth.auth().currentUser?.uid
    
    // IB vars
    
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
    
    
    
    var ownItemSet: [OwnObservation] = []{
        
        willSet {
            if newValue.isEmpty && worldItemSet.isEmpty {
                mainCollectionView.alpha = 0
                emptyImage.alpha = 1
                emptyLabel.alpha = 1
            }
            else{
                mainCollectionView.alpha = 1
                emptyImage.alpha = 0
                emptyLabel.alpha = 0
            }
        }
        
        didSet{
            mainCollectionView.reloadData()
        }
        
    }
    
    var worldItemSet: [[Observation]] = []{
        
        willSet {
            if newValue.isEmpty && ownItemSet.isEmpty {
                mainCollectionView.alpha = 0
                emptyImage.alpha = 1
                emptyLabel.alpha = 1
            }
            else{
                mainCollectionView.alpha = 1
                emptyImage.alpha = 0
                emptyLabel.alpha = 0
            }
        }
        
        didSet{
            mainCollectionView.reloadData()
        }
    }
    
    var itemSetNumber = 1
    
    var refComplete = false
    
    var lastSnapshot: [QueryDocumentSnapshot] = []
    
    var listereners: [ListenerRegistration] = []
    
    var categoryPickerList: [String] = ["Date: Newest first", "Date: Oldest first", "Alphabetically: Ascending", "Alphabetically: Descending", "Rarity: Extremely rare first", "Rarity: Common first"]
    
    var categoryPicker = UIPickerView()
    
    var selectedSort = "Date: Newest first"
    
    var selectedSortTemp = "Date: Newest first"
    
    let networkNotice = Notice()
    
    let fileManager = FileManager.default
    
    let notice = Notice()
    
    var OnlyOwn = false
    
    let sync = SyncObservations()
    
    var connected: Bool?{
        
        willSet {
            
            if newValue == false {
                ownSwitch.isOn = true
                ownSwitch.isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.2, animations: { self.offlineLabel.alpha = 1 } )
                mainCollectionView.reloadData()
                if ownItemSet.isEmpty{
                    mainCollectionView.alpha = 0
                    emptyImage.alpha = 1
                    emptyLabel.alpha = 1
                }
            }
            if newValue == true {
                if OnlyOwn == false { ownSwitch.isOn = false; mainCollectionView.reloadData()
                    if !worldItemSet.isEmpty {
                        mainCollectionView.alpha = 1
                        emptyImage.alpha = 0
                        emptyLabel.alpha = 0
                    }
                }
                ownSwitch.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.2, animations: { self.offlineLabel.alpha = 0 } )
                
            }
        }
        
    }
    
    unowned let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    deinit {
        for l in listereners{
            l.remove()
    }
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getWorldObservations()
        
        getOwnObservations()
        
        DispatchQueue.global().async {
            self.sync.sync()
        }

        
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        mainCollectionView.register(MainCell.self, forCellWithReuseIdentifier: "main")
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
        setupCategoryPicker()
        createCategoryPickerToolBar()
        
        setupUserDefaults()
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        for l in listereners{
            l.remove()
        }
        
    }

    
    func setupLayout(){
        
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
    
    
    func setupUserDefaults(){
        
        
        if UserDefaults.standard.object(forKey: "uid") == nil || UserDefaults.standard.object(forKey: "uid") as! String != uid! {
            UserDefaults.standard.set(uid!, forKey: "uid")
            if UserDefaults.standard.object(forKey: "sort") != nil{
                UserDefaults.standard.removeObject(forKey: "sort")}
        }
        
        if UserDefaults.standard.object(forKey: "sort") != nil {
            selectedSort = UserDefaults.standard.object(forKey: "sort") as! String
            selectedSortTemp = UserDefaults.standard.object(forKey: "sort") as! String
            sortTextField.text = UserDefaults.standard.object(forKey: "sort") as? String
        }
        
    }
    
    
    func setupCategoryPicker(){
        
        categoryPicker.delegate = self
        sortTextField.inputView = categoryPicker
    }
    
    
    func createCategoryPickerToolBar(){
        
        let doneString = NSLocalizedString("Done", comment: "Done")
        
        unowned let _self = self
        
        let categoryPickerToolBar = UIToolbar()
        categoryPickerToolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: doneString, style: .plain, target: _self, action: #selector(MainViewController.dismissKeyboard))
        
        categoryPickerToolBar.setItems([doneButton], animated: false)
        categoryPickerToolBar.isUserInteractionEnabled = true
        
        sortTextField.inputAccessoryView = categoryPickerToolBar
    }
    
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    
    
    @objc func logOutButtonPressed(){
        
        if appDelegate.connected == false {
            present(notice.networkAlert, animated: true, completion: nil)
        }
        else {
            showLogOutAlert()
        }
        
    }
    
    func showLogOutAlert(){
        
        
        let logOutString = NSLocalizedString("Log out?", comment: "")
        
        let logOutSecondString = NSLocalizedString("Log out", comment: "")
        
        let cancelString = NSLocalizedString("Cancel", comment: "")
        
        let messageString = NSLocalizedString("Are you sure you wish to log out?", comment: "")
        
        let alert = UIAlertController(title: logOutString, message: messageString, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: logOutSecondString, style: .default, handler: { [unowned self] (UIAlertAction) in
            self.logOut()
        })
        
        let cancel = UIAlertAction(title: cancelString, style: .cancel, handler: nil )
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func logOut(){
                
        do { try Auth.auth().signOut() }
        catch { print("there was an error in sign out: \(error)") }
                
        showLogOutNotice()
                
            
        
    }
    
    
    func showLogOutNotice(){
        
        let titleString = NSLocalizedString("Logged out", comment: "Message to confirm that user has been logged out")
        
        let okString = NSLocalizedString("Ok", comment: "Ok")
        
        let alert = UIAlertController(title: titleString, message: "", preferredStyle: .alert)
        
        let notice = UIAlertAction(title: okString, style: .default, handler: { [unowned self] (UIAlertAction) in
            
            let window = self.appDelegate.window
            
            window?.rootViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "loginViewController")
            
            self.parent!.dismiss(animated: true, completion: nil)
            
        })
        
        alert.addAction(notice)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    @objc func showFilterView(){
        
        sortViewTopConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3, animations:{ self.view.layoutIfNeeded() })
        
    }
    
    
    @IBAction func confirmSortButtonPressed(_ sender: Any) {
        
        sortViewTopConstraint.constant = -500
        
        UIView.animate(withDuration: 0.3, animations:{ self.view.layoutIfNeeded() })
        
        selectedSort = selectedSortTemp
        
        UserDefaults.standard.set(selectedSort, forKey: "sort")
        
        mainCollectionView.reloadData()
        
    }
    
    
    func getOwnObservations(){
        
        ownItemSet = []
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OwnObservation")
        fetchRequest.predicate = NSPredicate(format: "uid = %@", uid!)
        
        do{
         let result = try managedContext.fetch(fetchRequest)
            for data in result as! [OwnObservation] {
                ownItemSet.append(data)
            }
        }
        catch {
            print("own data retrieve failed")
        }
    }
    
    
    func getWorldObservations(){
        
        
        
        let listener = observationsRef.limit(to: 15).addSnapshotListener(){
            [unowned self] (querySnapshot, err) in
            self.lastSnapshot = []
            if let err = err{
                print("error getting documents: \(err)")
            }
            else {
                var localItemSet: [Observation] = []
                if let querySnapshot = querySnapshot{
                    if querySnapshot.documents.count < 15 {self.refComplete = true}
                    for document in querySnapshot.documents{
                        let data = document.data()
                        if data["uid"] as! String != self.uid! {
                            localItemSet.append(Observation(data))
                        }
                    }
                  
                    if self.worldItemSet.indices.contains(0) {
                        if !localItemSet.isEmpty { self.worldItemSet[0] = localItemSet }
                    }
                    else {
                        if !localItemSet.isEmpty { self.worldItemSet.insert(localItemSet, at: 0) }
                    }
                    if let lastSnapshot = querySnapshot.documents.last{
                        self.lastSnapshot.append(lastSnapshot)
                    }
                }
            }
            self.mainCollectionView.reloadData()
        }
        self.listereners.append(listener)
        
        
        
        
    }
    
    @IBAction func addItemButtonPressed(_ sender: Any) {
        
        let vc = UIStoryboard(name: "Add", bundle: nil).instantiateViewController(withIdentifier: "addViewController")
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @IBAction func ownSwitchFlipped(_ sender: Any) {
        
        if ownSwitch.isOn == true {
            OnlyOwn = true
            mainCollectionView.reloadData()
           
            if ownItemSet.isEmpty{
            mainCollectionView.alpha = 0
            emptyImage.alpha = 1
            emptyLabel.alpha = 1
            }
        }
        else{
            OnlyOwn = false
            mainCollectionView.reloadData()
            if !worldItemSet.isEmpty {
                mainCollectionView.alpha = 1
                emptyImage.alpha = 0
                emptyLabel.alpha = 0
            }
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var itemSet: [MainItem] = []
        
        for item in ownItemSet{
            itemSet.append(item)
        }
        
        if ownSwitch.isOn == false{
        for item in worldItemSet{
            for observation in item {
            itemSet.append(observation)
            }
        }
        }
        
        return itemSet.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "main", for: indexPath) as! MainCell
        
        var mainItemSet: [MainItem] = []
        
        
        
        if ownSwitch.isOn == false{
        for item in ownItemSet{
            mainItemSet.append(item)
        }
        
        for item in worldItemSet{
            for observation in item {
                mainItemSet.append(observation)
            }
        }
        }
        
        else {
            for item in ownItemSet{
                mainItemSet.append(item)
            }
        }
        
        var mainItemSetSorted = mainItemSet.sorted(by:{ $0.created > $1.created })
        
        switch selectedSort {
            
        case "Date: Newest first": mainItemSetSorted = mainItemSet.sorted(by:{ $0.created > $1.created })
            
        case "Date: Oldest first": mainItemSetSorted = mainItemSet.sorted(by:{ $1.created > $0.created })
            
        case "Alphabetically: Ascending": mainItemSetSorted = mainItemSet.sorted(by:{ $0.species! > $1.species! })
            
        case "Alphabetically: Descending": mainItemSetSorted = mainItemSet.sorted(by:{ $1.species! > $0.species! })
            
        case "Rarity: Extremely rare first": mainItemSetSorted = mainItemSet.sorted(by:{ $1.rarityNumber > $0.rarityNumber })
            
        case "Rarity: Common first": mainItemSetSorted = mainItemSet.sorted(by:{ $0.rarityNumber > $1.rarityNumber })
            
        default: break
            
        }
        
        
        if mainItemSetSorted[indexPath.row].uid != uid! {
            
            let processor = ResizingImageProcessor(referenceSize: CGSize(width: view.bounds.width * 0.9 * UIScreen.main.scale, height: view.bounds.width * 0.9 * UIScreen.main.scale)) >> RoundCornerImageProcessor(cornerRadius: 10)
            
            let pictureUrl = URL(string: mainItemSetSorted[indexPath.row].pictureUrl!)
          
            cell.itemView.kf.setImage(with: pictureUrl, options: [.cacheSerializer(FormatIndicatedCacheSerializer.png), .processor(processor)])
            
         }
         
        else {
            
            let picturePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(mainItemSetSorted[indexPath.row].pictureUrl!)
        
            cell.itemView.image = UIImage(contentsOfFile: picturePath)
            cell.itemView.layer.cornerRadius = 5
            cell.itemView.layer.masksToBounds = true
            
            }
        
        
            cell.species.text = mainItemSetSorted[indexPath.row].species!
            cell.rarity.text = mainItemSetSorted[indexPath.row].rarity!
            
            let tempMsg = mainItemSetSorted[indexPath.row].notes!
            
            var notes = ""
            
            if tempMsg.count > 25 {
                notes = "\(String(tempMsg[..<tempMsg.index(tempMsg.startIndex, offsetBy: 25)]))..."
            }
            else if tempMsg.count == 0 {
                notes = ""
            }
            else {
                notes = "\(tempMsg)..."
            }
            
            cell.notes.text = notes
            
            if mainItemSetSorted[indexPath.row].soundUrl! == "" {
                cell.soundIndicatorImage.image = #imageLiteral(resourceName: "characterX")
            }
            else{
                cell.soundIndicatorImage.image = #imageLiteral(resourceName: "checkMark")
            }
            
            if mainItemSetSorted[indexPath.row].videoUrl! == "" {
                cell.videoIndicatorImage.image = #imageLiteral(resourceName: "characterX")
            }
            else{
                cell.videoIndicatorImage.image = #imageLiteral(resourceName: "checkMark")
            }
            
            cell.lat.text = "\(mainItemSetSorted[indexPath.row].lat)"
            
            cell.long.text = "\(mainItemSetSorted[indexPath.row].long)"
        
            let dateAndTime = DateFormatter.localizedString(from: Date(timeIntervalSince1970: Double(mainItemSetSorted[indexPath.row].created)), dateStyle: .short, timeStyle: .short)
        
            cell.time.text = dateAndTime
        
        return cell
        
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var mainItemSet: [MainItem] = []
        
        if ownSwitch.isOn == false{
            for item in ownItemSet{
                mainItemSet.append(item)
            }
            
            for item in worldItemSet{
                for observation in item {
                    mainItemSet.append(observation)
                }
            }
        }
            
        else {
            for item in ownItemSet{
                mainItemSet.append(item)
            }
        }
        
        var mainItemSetSorted = mainItemSet.sorted(by:{ $0.created > $1.created })
        
        switch selectedSort {
            
        case "Date: Newest first": mainItemSetSorted = mainItemSet.sorted(by:{ $0.created > $1.created })
            
        case "Date: Oldest first": mainItemSetSorted = mainItemSet.sorted(by:{ $1.created > $0.created })
            
        case "Alphabetically: Ascending": mainItemSetSorted = mainItemSet.sorted(by:{ $0.species! > $1.species! })
            
        case "Alphabetically: Descending": mainItemSetSorted = mainItemSet.sorted(by:{ $1.species! > $0.species! })
            
        case "Rarity: Extremely rare first": mainItemSetSorted = mainItemSet.sorted(by:{ $1.rarityNumber > $0.rarityNumber })
            
        case "Rarity: Common first": mainItemSetSorted = mainItemSet.sorted(by:{ $0.rarityNumber > $1.rarityNumber })
            
        default: break
            
        }
        
        let vc = UIStoryboard(name: "Detail", bundle: nil).instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
        
        vc.observation = mainItemSetSorted[indexPath.row]
            
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard ownSwitch.isOn == false else { return }
        
        var localMasterItemSet: [Observation] = []
        
        for itemSet in worldItemSet {
            
            for doc in itemSet {
                localMasterItemSet.append(doc)
            }
        }
        
        guard refComplete == false else { return }
        
        if indexPath.row == localMasterItemSet.count - 1 {
            
            
                let observationRef = db.collection("observation").start(afterDocument: lastSnapshot[lastSnapshot.count - 1])
                
                
                let listener = observationRef.limit(to: 15).addSnapshotListener(){
                    [unowned self] (querySnapshot, err) in
                    if let err = err{
                        print("error getting documents: \(err)")
                    }
                        
                    else {
                        var localItemSet: [Observation] = []
                        if let querySnapshot = querySnapshot{
                            if querySnapshot.documents.count < 15 {self.refComplete = true}
                            for document in querySnapshot.documents{
                                let data = document.data()
                                if data["uid"] as! String != self.uid! {
                                    localItemSet.append(Observation(data))
                                }
                            }
                            if self.worldItemSet.indices.contains(self.itemSetNumber) {
                                self.worldItemSet[self.itemSetNumber] = localItemSet
                            }
                            else {
                                self.worldItemSet.insert(localItemSet, at: self.itemSetNumber)
                                var veryLocal: [Observation] = []
                                for itemSet in self.worldItemSet{
                                    for doc in itemSet{
                                        veryLocal.append(doc)
                                    }
                                }
                            }
                            if let lastSnapshot = querySnapshot.documents.last{
                                self.lastSnapshot.append(lastSnapshot)
                            }
                        }
                        self.itemSetNumber += 1
                    }
                    self.mainCollectionView.reloadData()
                }
                self.listereners.append(listener)
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if traitCollection.horizontalSizeClass == .regular{
            return CGSize(width: view.frame.width, height: view.frame.width * 1.5)
        }
        else {
        return CGSize(width: view.frame.width, height: view.frame.width * 1.9)
        }
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
        selectedSortTemp = categoryPickerList[row]
        sortTextField.text = NSLocalizedString(categoryPickerList[row], comment: "")
    }
    
}
