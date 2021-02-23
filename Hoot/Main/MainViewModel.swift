//
//  MainViewModel.swift
//  Hoot
//
//  Created by Kristian Helenius on 10/09/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import Foundation
import Firebase
import CoreData


class MainViewModel: NSObject, UIPickerViewDataSource, UIPickerViewDelegate{
    
    
    // Firebase Firestore db ref
    
    let db = Firestore.firestore()
    
    var observationsRef = Firestore.firestore().collection("observation")
    
    // User uid ref
    
    let auth = Auth.auth()
    
    var uid = Auth.auth().currentUser?.uid
    
    
    weak var delegate: MainViewModelDelegate?
    
    
    
    var ownItemSet: [OwnObservation] = []{
        
        willSet {
            if newValue.isEmpty && worldItemSet.isEmpty {
                delegate?.updateEmptyElementsWasCalled(empty: true)
            }
            else if newValue.isEmpty && ownSwitchIsOn == true {
                delegate?.updateEmptyElementsWasCalled(empty: true)
            }
                
            else{
                delegate?.updateEmptyElementsWasCalled(empty: false)
            }
            
        }
        
        didSet{
            setMainItemSetSorted()
        }
        
    }
    
    var worldItemSet: [[Observation]] = []{
        
        willSet {
            if newValue.isEmpty && ownItemSet.isEmpty {
                delegate?.updateEmptyElementsWasCalled(empty: true)
            }
            else if ownItemSet.isEmpty && ownSwitchIsOn == true {
                delegate?.updateEmptyElementsWasCalled(empty: true)
            }
            else{
                delegate?.updateEmptyElementsWasCalled(empty: false)
            }
        }
        
        didSet{
            print("IT RAN")
            setMainItemSetSorted()
        }
    }
    
    var mainItemSetSorted: [MainItem] = []
    
    var itemSetNumber = 1
    
    var refComplete = false
    
    var lastSnapshot: [QueryDocumentSnapshot] = []
    
    var listereners: [ListenerRegistration] = []
    
    var getObs: Query?
    
    var categoryPickerList: [String] = ["Date: Newest first", "Date: Oldest first", "Alphabetically: Ascending", "Alphabetically: Descending", "Rarity: Extremely rare first", "Rarity: Common first"]
    
    var categoryPicker = UIPickerView()
    
    var selectedSort = "Date: Newest first"
    
    var selectedSortTemp = "Date: Newest first"
    
    let networkNotice = Notice()
    
    let fileManager = FileManager.default
    
    let notice = Notice()
    
    var ownSwitchIsOn = false{
        
        willSet{
            
            if newValue == true{
            
            if ownItemSet.isEmpty{
                delegate?.updateEmptyElementsWasCalled(empty: true)
            }
            else { delegate?.collectionViewScrollToTopWasCalled() }
            }
        }
        
    }
    
    var OnlyOwn = false
    
    let sync = SyncObservations()
    
    var connected: Bool?{
        
        willSet {
            
            if newValue == false {
               delegate?.ownSwitchStateChangeWasRequested(isOn: true, userActionEnabled: false)
                ownSwitchIsOn = true
                delegate?.offlineLabelStateChangeWasRequested(alpha: 1)
                setMainItemSetSorted()
                if ownItemSet.isEmpty{
                    delegate?.updateEmptyElementsWasCalled(empty: true)
                }
                else { delegate?.collectionViewScrollToTopWasCalled() }
            }
            if newValue == true {
                if OnlyOwn == false { delegate?.ownSwitchStateChangeWasRequested(isOn: false, userActionEnabled: nil); ownSwitchIsOn = false; setMainItemSetSorted()
                    if !worldItemSet.isEmpty {
                        delegate?.updateEmptyElementsWasCalled(empty: false)
                        delegate?.collectionViewScrollToTopWasCalled()
                    }
                }
                delegate?.ownSwitchStateChangeWasRequested(isOn: nil, userActionEnabled: true)
                delegate?.offlineLabelStateChangeWasRequested(alpha: 0)
                
            }
        }
        
    }
    
    unowned let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    deinit {
        for l in listereners{
            l.remove()
        }
    }
    
    func viewWillAppearWasCalled(){
        getWorldObservations()
        getOwnObservations()
        
        DispatchQueue.global().async {
            self.sync.sync()
            self.sync.checkLocalValidity()
        }
    }

    func viewDidLoadWasCalled(){
        setupUserDefaults()
    }
    
    
    func viewDidDisappearWasCalled(){
        for l in listereners{
            l.remove()
        }
    }
    

    func confirmSortButtonWasPressed(){
        
        guard selectedSortTemp != selectedSort else { delegate?.keyboardDismissWasCalled();return }
        
        selectedSort = selectedSortTemp
        
        UserDefaults.standard.set(selectedSort, forKey: "sort")
        
        for l in listereners{
            l.remove()
        }
        
        itemSetNumber = 1
        
        refComplete = false
        
        lastSnapshot = []
        
        worldItemSet = []
        
        getWorldObservations()
        
        delegate?.keyboardDismissWasCalled()
        
        if ownItemSet.isEmpty && worldItemSet.isEmpty { return }
        
        delegate?.collectionViewScrollToTopWasCalled()
        
    }
    
    
    func setMainItemSetSorted(){
        
        var mainItemSet: [MainItem] = []
        
        if ownSwitchIsOn == false{
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
        
        mainItemSetSorted = mainItemSet.sorted(by:{ $0.created > $1.created })
        
        switch selectedSort {
            
        case "Date: Newest first":
            
            if refComplete == false && ownSwitchIsOn == false && !worldItemSet.isEmpty{
                let tempSet = mainItemSetSorted.filter({$0.uid != uid!})
                var tempEdgeSet: [Int64] = []
                for i in tempSet{
                    tempEdgeSet.append(i.created)
                }
                let edge = tempEdgeSet.min()
                let filterSet = mainItemSetSorted.filter({ $0.uid != uid || $0.uid == uid! && $0.created >= edge! })
                
                mainItemSetSorted = filterSet.sorted(by:{ $0.created > $1.created })
            }
                
            else { mainItemSetSorted = mainItemSet.sorted(by:{ $0.created > $1.created }) }
            
            
        case "Date: Oldest first":
            
            if refComplete == false && ownSwitchIsOn == false && !worldItemSet.isEmpty {
                let tempSet = mainItemSetSorted.filter({$0.uid != uid!})
                var tempEdgeSet: [Int64] = []
                for i in tempSet{
                    tempEdgeSet.append(i.created)
                }
                let edge = tempEdgeSet.max()
                let filterSet = mainItemSetSorted.filter({ $0.uid != uid || $0.uid == uid! && $0.created <= edge! })
                
                mainItemSetSorted = filterSet.sorted(by:{ $1.created > $0.created })
            }
                
            else { mainItemSetSorted = mainItemSet.sorted(by:{ $1.created > $0.created }) }
            
        case "Alphabetically: Ascending":
            
            if refComplete == false && ownSwitchIsOn == false && !worldItemSet.isEmpty {
                let tempSet = mainItemSetSorted.filter({$0.uid != uid!})
                var tempEdgeSet: [String] = []
                for i in tempSet{
                    tempEdgeSet.append(i.species!)
                }
                let edge = tempEdgeSet.max()
                let filterSet = mainItemSetSorted.filter({ $0.uid != uid || $0.uid == uid! && $0.species! <= edge! })
                
                mainItemSetSorted = filterSet.sorted(by:{ $1.species! > $0.species! })
            }
                
            else { mainItemSetSorted = mainItemSet.sorted(by:{ $1.species! > $0.species! }) }
            
        case "Alphabetically: Descending":
            
            if refComplete == false && ownSwitchIsOn == false && !worldItemSet.isEmpty {
                let tempSet = mainItemSetSorted.filter({$0.uid != uid!})
                var tempEdgeSet: [String] = []
                for i in tempSet{
                    tempEdgeSet.append(i.species!)
                }
                let edge = tempEdgeSet.min()
                let filterSet = mainItemSetSorted.filter({ $0.uid != uid || $0.uid == uid! && $0.species! >= edge! })
                
                mainItemSetSorted = filterSet.sorted(by:{ $0.species! > $1.species! })
            }
                
            else { mainItemSetSorted = mainItemSet.sorted(by:{ $0.species! > $1.species! }) }
            
            
        case "Rarity: Extremely rare first": mainItemSetSorted = mainItemSet.sorted(by:{ $0.rarityNumber > $1.rarityNumber })
        
        if refComplete == false && ownSwitchIsOn == false && !worldItemSet.isEmpty {
            let tempSet = mainItemSetSorted.filter({$0.uid != uid!})
            var tempEdgeSet: [Int64] = []
            for i in tempSet{
                tempEdgeSet.append(i.rarityNumber)
            }
            let edge = tempEdgeSet.min()
            let filterSet = mainItemSetSorted.filter({ $0.uid != uid || $0.uid == uid! && $0.rarityNumber >= edge! })
            
            mainItemSetSorted = filterSet.sorted(by:{ $0.rarityNumber > $1.rarityNumber })
        }
            
        else { mainItemSetSorted = mainItemSet.sorted(by:{ $0.rarityNumber > $1.rarityNumber }) }
            
            
        case "Rarity: Common first":
            
            if refComplete == false && ownSwitchIsOn == false && !worldItemSet.isEmpty {
                let tempSet = mainItemSetSorted.filter({$0.uid != uid!})
                var tempEdgeSet: [Int64] = []
                for i in tempSet{
                    tempEdgeSet.append(i.rarityNumber)
                }
                let edge = tempEdgeSet.max()
                let filterSet = mainItemSetSorted.filter({ $0.uid != uid || $0.uid == uid! && $0.rarityNumber <= edge! })
                
                mainItemSetSorted = filterSet.sorted(by:{ $1.rarityNumber > $0.rarityNumber })
            }
                
            else { mainItemSetSorted = mainItemSet.sorted(by:{ $1.rarityNumber > $0.rarityNumber }) }
            
        default: break
            
        }
        delegate?.collectionViewReloadDataWasCalled()
        
    }
    
    func collectionViewWillDisplayCell(indexPath: IndexPath){
        
        guard ownSwitchIsOn == false else { return }
        
        var localMasterItemSet: [Observation] = []
        
        for itemSet in worldItemSet {
            
            for doc in itemSet {
                localMasterItemSet.append(doc)
            }
        }
        
        guard refComplete == false else { return }
        
        if indexPath.row == localMasterItemSet.count - 1 {
            
            
            let observationRef = getObs!.start(afterDocument: lastSnapshot[lastSnapshot.count - 1])
            
            
            let listener = observationRef.limit(to: 3).addSnapshotListener(){
                [unowned self] (querySnapshot, err) in
                if let err = err{
                    print("error getting documents: \(err)")
                }
                    
                else {
                    var localItemSet: [Observation] = []
                    if let querySnapshot = querySnapshot{
                        if querySnapshot.documents.count < 3 {self.refComplete = true}
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
            }
            self.listereners.append(listener)
        }
        
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
            delegate?.sortTextWasSet(text: UserDefaults.standard.object(forKey: "sort") as! String)
        }
        
    }

    func setupCategoryPicker() -> UIPickerView{
        
        categoryPicker.dataSource = self
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

    func ownSwitchFlipped(isOn: Bool){
        
        if isOn == true {
            ownSwitchIsOn = true
        }
        else{
            ownSwitchIsOn = false
        }
        
        if ownSwitchIsOn == true {
            OnlyOwn = true
            setMainItemSetSorted()
           
            
            if ownItemSet.isEmpty{
                delegate?.updateEmptyElementsWasCalled(empty: true)
            }
            else { delegate?.collectionViewScrollToTopWasCalled() }
        }
        else{
            OnlyOwn = false
            setMainItemSetSorted()
            if !worldItemSet.isEmpty {
               delegate?.updateEmptyElementsWasCalled(empty: false)
                setMainItemSetSorted()
            }
        }
        
    }
    
    
    
    

    @objc func dismissKeyboard(){
        delegate?.keyboardDismissWasCalled()
    }



    @objc func logOutButtonPressed(){
        
        if appDelegate.connected == false {
            delegate?.presentAlertWasCalled(alert: notice.networkAlert)
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
        
        delegate?.presentAlertWasCalled(alert: alert)
        
    }


    func logOut(){
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OwnObservation")
        fetchRequest.predicate = NSPredicate(format: "uid = %@", uid!)
        
        var tempItemSet: [OwnObservation] = []
        
        do{
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [OwnObservation] {
                tempItemSet.append(data)
            }
            for item in tempItemSet{
                if item.uploading == true { delegate?.presentAlertWasCalled(alert: notice.syncLogoutAlert); return }
            }
            
        }
        catch {
            print("own data retrieve failed")
        }
        
        for l in listereners{
            l.remove()
        }
        
        do { try Auth.auth().signOut() }
        catch { print("there was an error in sign out: \(error)")
            delegate?.presentAlertWasCalled(alert: notice.generalAlert); return
        }
        
        showLogOutNotice()
        
    }


    func showLogOutNotice(){
        
        let titleString = NSLocalizedString("Logged out", comment: "Message to confirm that user has been logged out")
        let okString = NSLocalizedString("Ok", comment: "Ok")
        
        let alert = UIAlertController(title: titleString, message: "", preferredStyle: .alert)
        
        let notice = UIAlertAction(title: okString, style: .default, handler: { [unowned self] (UIAlertAction) in
            
            let window = self.appDelegate.window
            
            window?.rootViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "loginViewController")
            
            self.delegate?.dismissParentWasCalled()
            
        })
        
        alert.addAction(notice)
        
        delegate?.presentAlertWasCalled(alert: alert)
        
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
        
        switch selectedSort{
            
        case "Date: Newest first": getObs = observationsRef.order(by: "created", descending: true)
            
        case "Date: Oldest first": getObs = observationsRef.order(by: "created")
            
        case "Alphabetically: Ascending": getObs = observationsRef.order(by: "species")
            
        case "Alphabetically: Descending": getObs = observationsRef.order(by: "species", descending: true)
            
        case "Rarity: Extremely rare first": getObs = observationsRef.order(by: "rarityNumber", descending: true)
            
        case "Rarity: Common first": getObs = observationsRef.order(by: "rarityNumber")
            
        default: break
        }
        
        let listener = getObs!.limit(to: 3).addSnapshotListener(){
            [unowned self] (querySnapshot, err) in
            self.lastSnapshot = []
            if let err = err{
                print("error getting documents: \(err)")
            }
            else {
                var localItemSet: [Observation] = []
                if let querySnapshot = querySnapshot{
                    if querySnapshot.documents.count < 3 {self.refComplete = true}
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
        }
        self.listereners.append(listener)
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
        delegate?.sortTextWasSet(text: NSLocalizedString(categoryPickerList[row], comment: ""))
    }
    
    
}
