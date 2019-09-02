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

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    
    
    // Firebase Firestore db ref
    
    let db = Firestore.firestore()
    
    // User uid ref
    
    let uid = Auth.auth().currentUser?.uid
    
    
    @IBOutlet var canvasView: UIView!
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var ownSwitch: UISwitch!
    
    @IBOutlet weak var switchLabel: UILabel!
    
    @IBOutlet weak var offlineLabel: UILabel!
    
    
    var ownItemSet: [OwnObservation] = []{
        
        didSet{
            mainCollectionView.reloadData()
        }
        
    }
    
    var worldItemSet: [[Observation]] = []{
        
        didSet{
            mainCollectionView.reloadData()
        }
    }
    
    var itemSetNumber = 1
    
    var refComplete = false
    
    var lastSnapshot: [QueryDocumentSnapshot] = []
    
    var listereners: [ListenerRegistration] = []
    
    let networkNotice = Notice()
    
    let fileManager = FileManager.default
    
    let notice = Notice()
    
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
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        
        mainCollectionView.register(MainCell.self, forCellWithReuseIdentifier: "main")
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
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
        
    }
    
    @objc func logOutButtonPressed(){
        
        if appDelegate.connected == false {
            present(notice.networkAlert, animated: true, completion: nil)
        }
        else {
            logOut()
        }
        
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
    
    func getOwnObservations(){
        
        ownItemSet = []
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OwnObservation")
     
        
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
        
        let observationsRef = db.collection("observation")
        
        let listener = observationsRef.limit(to: 15).addSnapshotListener(){
            [unowned self] (querySnapshot, err) in
            if let err = err{
                print("error getting documents: \(err)")
                // error alert here
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
        
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var itemSet: [MainItem] = []
        
        for item in ownItemSet{
            itemSet.append(item)
        }
        
        for item in worldItemSet{
            for observation in item {
            itemSet.append(observation)
            }
        }
        
        return itemSet.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "main", for: indexPath) as! MainCell
        
        var mainItemSet: [MainItem] = []
        
        for item in ownItemSet{
            mainItemSet.append(item)
        }
        
        for item in worldItemSet{
            for observation in item {
                mainItemSet.append(observation)
            }
        }
        
        let mainItemSetSorted = mainItemSet.sorted(by:{ $0.created > $1.created })
        
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
        
       
        
        return cell
        
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var mainItemSet: [MainItem] = []
        
        for item in ownItemSet{
            mainItemSet.append(item)
        }
        
        for item in worldItemSet{
            for observation in item {
                mainItemSet.append(observation)
            }
        }
        
        let mainItemSetSorted = mainItemSet.sorted(by:{ $0.created > $1.created })
        
        
        let vc = UIStoryboard(name: "Detail", bundle: nil).instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
        
        vc.observation = mainItemSetSorted[indexPath.row]
            
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        var localMasterItemSet: [Observation] = []
        
        for itemSet in worldItemSet {
            
            for doc in itemSet {
                localMasterItemSet.append(doc)
            }
        }
        
        guard refComplete == false else { return }
        
        if indexPath.row == localMasterItemSet.count - 1{
            
            
                let observationRef = db.collection("observation")
                
                
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
                                //  print("index existed, added to \(self.itemSetNumber), total number: \(self.masterItemSet.count)")
                            }
                            else {
                                self.worldItemSet.insert(localItemSet, at: self.itemSetNumber)
                                // print("index didn't exist, added to \(self.itemSetNumber), total number: \(self.masterItemSet.count)")
                                var veryLocal: [Observation] = []
                                for itemSet in self.worldItemSet{
                                    for doc in itemSet{
                                        veryLocal.append(doc)
                                    }
                                }
                                //   print("The new count of masterdata is \(veryLocal.count), consists of 1: \(self.masterItemSet[0].count) and 2: \(self.masterItemSet[1].count)")
                            }
                            if let lastSnapshot = querySnapshot.documents.last{
                                self.lastSnapshot.append(lastSnapshot)
                            }
                        }
                        self.itemSetNumber += 1
                    }
                    //  print("-------------this is end of item, 1st option")
                    self.mainCollectionView.reloadData()
                }
                self.listereners.append(listener)
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.width * 1.7)
        
    }
    
}
