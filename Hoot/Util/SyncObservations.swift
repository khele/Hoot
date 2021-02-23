//
//  SyncObservations.swift
//  Hoot
//
//  Created by Kristian Helenius on 02/09/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import Foundation
import Firebase
import CoreData


struct SyncObservations {

    
    let fileManager = FileManager.default
    
    var storage = Storage.storage().reference()
    
    var pictureRef = Storage.storage().reference().child("picture")
    
    var soundRef = Storage.storage().reference().child("sound")
    
    var videoRef = Storage.storage().reference().child("video")
    
    var observationRef = Firestore.firestore().collection("observation")
    
    var uid = Auth.auth().currentUser?.uid
    
    let db = Firestore.firestore()
    
    let auth = Auth.auth()
    
    unowned let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
   
    
    
    
    func sync(){
        
        guard appDelegate.connected == true else { return }
        
       
        
        var itemSet: [OwnObservation] = []
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OwnObservation")
        fetchRequest.predicate = NSPredicate(format: "uid = %@", uid!)
        
        do{
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [OwnObservation] {
                itemSet.append(data)
            }
        }
        catch {
            print("own data retrieve failed")
            return
        }
        
        if itemSet.isEmpty {
            print("ITEMSET WAS EMPTY IN SYNC")
            var remoteItemSet: [MainItem] = []
            
            observationRef.whereField("uid", isEqualTo: uid!).getDocuments(){
                (querySnapshot, err) in
                if let err = err {
                    print("error getting documents: \(err)")
                }
                else {
                    print("Downloading documents")
                    if let querySnapshot = querySnapshot {
                        for doc in querySnapshot.documents{
                            let data = doc.data()
                            remoteItemSet.append(Observation(data))
                        }
                    }
                    var saveRun = 0
                    for item in remoteItemSet{
                        DispatchQueue.global().async {
                        let documentsPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
                        
                        let picturePath = documentsPath.appendingPathComponent("\(item.id!).jpeg")
                            
                        let soundPath = documentsPath.appendingPathComponent("\(item.id!).m4a")
                        
                        let videoPath = documentsPath.appendingPathComponent("\(item.id!).mp4")
                        
                        self.fileManager.createFile(atPath: picturePath, contents: try!(Data(contentsOf: URL(string: item.pictureUrl!)!)), attributes: nil)
                        
                        if item.soundUrl! != "" {
                            self.fileManager.createFile(atPath: soundPath, contents: try!(Data(contentsOf: URL(string: item.soundUrl!)!)), attributes: nil)
                        }
                        
                        if item.videoUrl! != "" {
                            self.fileManager.createFile(atPath: videoPath, contents: try!(Data(contentsOf: URL(string: item.videoUrl!)!)), attributes: nil)
                        }
                        
                        let observationEntity = NSEntityDescription.entity(forEntityName: "OwnObservation", in: managedContext)
                        
                        let observation = NSManagedObject(entity: observationEntity!, insertInto: managedContext)
                        
                        let soundAndVideo = (Bool(item.soundUrl! != ""), Bool(item.videoUrl! != ""))
                        
                        switch soundAndVideo{
                        
                            
                        case (false, false):
                            observation.setValuesForKeys(["species": item.species!, "rarity": item.rarity!, "rarityNumber": item.rarityNumber, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "uploaded": true, "uploading": false, "pictureUrl": "\(item.id!).jpeg", "soundUrl": "", "videoUrl": "", "lat": item.lat, "long": item.long])
                        
                            
                            
                        case (true, false):
                        observation.setValuesForKeys(["species": item.species!, "rarity": item.rarity!, "rarityNumber": item.rarityNumber, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "uploaded": true, "uploading": false, "pictureUrl": "\(item.id!).jpeg", "soundUrl": "\(item.id!).m4a", "videoUrl": "", "lat": item.lat, "long": item.long])
                        
                            
                            
                        case (false, true):
                             observation.setValuesForKeys(["species": item.species!, "rarity": item.rarity!, "rarityNumber": item.rarityNumber, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "uploaded": true, "uploading": false, "pictureUrl": "\(item.id!).jpeg", "soundUrl": "", "videoUrl": "\(item.id!).mp4", "lat": item.lat, "long": item.long])
                        
                            
                            
                        case (true, true):
                            observation.setValuesForKeys(["species": item.species!, "rarity": item.rarity!, "rarityNumber": item.rarityNumber, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "uploaded": true, "uploading": false, "pictureUrl": "\(item.id!).jpeg", "soundUrl": "\(item.id!).m4a", "videoUrl": "\(item.id!).mp4", "lat": item.lat, "long": item.long])
                         
                        }
                        
                        do {
                            try managedContext.save()
                            print("save done")
                        }
                        catch let error as NSError {
                            print("Error occurred: \(error)")
                        }
                            
                            saveRun += 1
                            if saveRun == remoteItemSet.count{
                                DispatchQueue.main.async {
                                
                                if self.appDelegate.window?.rootViewController?.restorationIdentifier == "mainNavigationController"{
                                    
                                    let nvc = self.appDelegate.window?.rootViewController as! UINavigationController
                                    let vc = nvc.viewControllers[0] as! MainViewController
                                    vc.viewModel.getOwnObservations()
                                    }
                                }
                                
                            }
                    }
                        
                    }
                
                  
                    
                
                    
                
            }
        }
        }
            
            
            
        else{
            print("ITEMSET WAS NOT EMPTY IN SYNC")
            var localItemSet: [MainItem] = []
            
            fetchRequest.predicate = NSPredicate(format: "uploaded = %@", NSNumber(value: false))
            
            do{
                let result = try managedContext.fetch(fetchRequest)
                for data in result as! [NSManagedObject] {
                    
                    let obs = data as! OwnObservation
                    
                    localItemSet.append(obs)
                }
            }
            catch {
                print("own data retrieve failed")
            }
            print("\(localItemSet.count) item(s) to sync")
            
            guard localItemSet.count != 0 else { return }
            
            let item = localItemSet[0]
            
          
            
            
                fetchRequest.predicate = NSPredicate(format: "id = %@", item.id!)
                
                do {
                    let fetched = try managedContext.fetch(fetchRequest)
                    
                    let objectUpdate = fetched[0] as! NSManagedObject
                    objectUpdate.setValue(true, forKey: "uploading")
                    
                    do{
                        try managedContext.save()
                    }
                    catch{
                        print(error)
                        return
                    }
                }
                catch {
                    print(error)
                    return
                }
                
                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask)[0]
                
                let pictureFileUrl = documentsUrl.appendingPathComponent("\(item.id!).jpeg")
              
                let pictureFileRef = pictureRef.child("\(item.id!).jpeg")
                
                let soundFileUrl = documentsUrl.appendingPathComponent("\(item.id!).m4a")
                
                let soundFileRef = soundRef.child("\(item.id!).m4a")
                
                let videoFileUrl = documentsUrl.appendingPathComponent("\(item.id!).mp4")
                
                let videoFileRef = videoRef.child("\(item.id!).mp4")
                
                let soundAndVideo = (Bool(item.soundUrl! != ""), Bool(item.videoUrl! != ""))
                
                
                
                switch soundAndVideo {
                    
                case (true, true):
                    
                    var pictureTask: StorageUploadTask!
                    
                    var soundTask: StorageUploadTask!
                    
                    var videoTask: StorageUploadTask!
                    
                    let pictureGroup = DispatchGroup()
                    
                    var success = true
                    
                    var pictureUrl = URL(string: "www.example.com")
                    
                    var soundUrl = URL(string: "www.example.com")
                    
                    var videoUrl = URL(string: "www.example.com")
                    
                    pictureGroup.enter()
                    
                    pictureTask = pictureFileRef.putFile(from: pictureFileUrl, metadata: StorageMetadata()) { (metadata, error) in
                        guard metadata != nil else {
                            print("Upload error")
                            return
                        }
                        
                        pictureFileRef.downloadURL { url, error in
                            if let error = error {
                                print("DownloadURL error: \(error)")
                                return
                            } else {
                                if let urlTemp = url{
                                    pictureUrl = urlTemp
                                    pictureGroup.leave()
                                }
                            }
                        }
                    }
                    
                    pictureTask.observe(.failure){ snapShot in
                        success = false
                        pictureGroup.leave()
                    }
                    
                    pictureTask.observe(.success){ snapShot in
                     
                        print("picture success (in both)")
                        
                    }
                    
                    pictureGroup.notify(queue: .global()){
                        
                        if success == false { return }
                        
                        let soundGroup = DispatchGroup()
                        soundGroup.enter()
                        
                        soundTask = soundFileRef.putFile(from: soundFileUrl, metadata: StorageMetadata()) { (metadata, error) in
                            guard metadata != nil else {
                                print("Upload error")
                                return
                            }
                            soundFileRef.downloadURL { url, error in
                                if let error = error {
                                    print(error)
                                    return
                                } else {
                                    if let urlTemp = url{
                                        soundUrl = urlTemp
                                        soundGroup.leave()
                                    }
                                }
                            }
                        }
                        
                        soundTask.observe(.failure){ snapShot in
                            success = false
                            soundGroup.leave()
                        }
                        
                        soundTask.observe(.success){ snapShot in
                            
                            print("sound success (in both)")
                            
                        }
                        
                        soundGroup.notify(queue: .global()){
                            
                            if success == false { return }
                            
                            let videoGroup = DispatchGroup()
                            videoGroup.enter()
                            
                            videoTask = videoFileRef.putFile(from: videoFileUrl, metadata: StorageMetadata()) { (metadata, error) in
                                guard metadata != nil else {
                                    print("Upload error")
                                    return
                                }
                                videoFileRef.downloadURL { url, error in
                                    if let error = error {
                                        print("error in downloadurl \(error)")
                                        return
                                    } else {
                                        if let urlTemp = url{
                                            videoUrl = urlTemp
                                            videoGroup.leave()
                                        }
                                    }
                                }
                            }
                            
                            videoTask.observe(.failure){ snapShot in
                                success = false
                                videoGroup.leave()
                            }
                            
                            videoTask.observe(.success){ snapShot in
                                print("video success (in both)")
                                
                            }
                            
                            videoGroup.notify(queue: .global()){
                                
                                if success == false { return }
                                
                             
                                self.observationRef.document(item.id!).setData(["species": item.species!, "rarity": item.rarity!, "rarityNumber": item.rarityNumber, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "pictureUrl": pictureUrl!.absoluteString, "soundUrl": soundUrl!.absoluteString, "videoUrl": videoUrl!.absoluteString, "lat": item.lat, "long": item.long]){  err in
                                    if let err = err {
                                        print("Error writing document: \(err)")
                                    } else {
                                        print("Document successfully written! in both")
                                        
                                        fetchRequest.predicate = NSPredicate(format: "id = %@", item.id!)
                                        
                                        do {
                                            let fetched = try managedContext.fetch(fetchRequest)
                                            
                                            let objectUpdate = fetched[0] as! NSManagedObject
                                            objectUpdate.setValue(true, forKey: "uploaded")
                                            objectUpdate.setValue(false, forKey: "uploading")
                                            
                                            do{
                                                try managedContext.save()
                                            }
                                            catch{
                                                print(error)
                                            }
                                        }
                                        catch {
                                            print(error)
                                        }
                                        if localItemSet.count > 1 { self.sync() }
                                    }
                                }
                                
                                
                                
                            }
                            
                        }
                        
                    }
                    
                    
                case (true, false):
                    
                    
                    var pictureTask: StorageUploadTask!
                    
                    var soundTask: StorageUploadTask!
                    
                    let pictureGroup = DispatchGroup()
                    
                    var success = true
                    
                    var pictureUrl = URL(string: "www.example.com")
                    
                    var soundUrl = URL(string: "www.example.com")
                    
                    pictureGroup.enter()
                    
                    pictureTask = pictureFileRef.putFile(from: pictureFileUrl, metadata: StorageMetadata()) { (metadata, error) in
                        guard metadata != nil else {
                            print("Upload error")
                            return
                        }
                        
                        pictureFileRef.downloadURL { url, error in
                            if let error = error {
                                print("DownloadURL error: \(error)")
                                return
                            } else {
                                if let urlTemp = url{
                                    pictureUrl = urlTemp
                                    pictureGroup.leave()
                                }
                            }
                        }
                    }
                    
                    pictureTask.observe(.failure){ snapShot in
                        success = false
                        pictureGroup.leave()
                    }
                    
                    pictureTask.observe(.success){ snapShot in
                        
                        print("picture success")
                        
                    }
                    
                    pictureGroup.notify(queue: .global()){
                        
                        if success == false { return }
                        
                        let soundGroup = DispatchGroup()
                        soundGroup.enter()
                        
                        soundTask = soundFileRef.putFile(from: soundFileUrl, metadata: StorageMetadata()) { (metadata, error) in
                            guard metadata != nil else {
                                print("Upload error")
                                return
                            }
                            soundFileRef.downloadURL { url, error in
                                if let error = error {
                                    print(error)
                                    return
                                } else {
                                    if let urlTemp = url{
                                        soundUrl = urlTemp
                                        soundGroup.leave()
                                    }
                                }
                            }
                        }
                        
                        soundTask.observe(.failure){ snapShot in
                            success = false
                            soundGroup.leave()
                        }
                        
                        soundTask.observe(.success){ snapShot in
                            
                            print("sound success")
                            
                        }
                        
                        soundGroup.notify(queue: .global()){
                            
                            if success == false { return }
                            
                            self.observationRef.document(item.id!).setData(["species": item.species!, "rarity": item.rarity!, "rarityNumber": item.rarityNumber, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "pictureUrl": pictureUrl!.absoluteString, "soundUrl": soundUrl!.absoluteString, "videoUrl": "", "lat": item.lat, "long": item.long]){  err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                } else {
                                    print("Document successfully written! in only sound")
                                    
                                    fetchRequest.predicate = NSPredicate(format: "id = %@", item.id!)
                                    
                                    do {
                                        let fetched = try managedContext.fetch(fetchRequest)
                                        
                                        let objectUpdate = fetched[0] as! NSManagedObject
                                        objectUpdate.setValue(true, forKey: "uploaded")
                                        objectUpdate.setValue(false, forKey: "uploading")
                                        
                                        do{
                                            try managedContext.save()
                                        }
                                        catch{
                                            print(error)
                                        }
                                    }
                                    catch {
                                        print(error)
                                    }
                                    if localItemSet.count > 1 { self.sync() }
                                }
                            }
                            }
                        }
                        
                    
                case (false, true):
                    
                    var pictureTask: StorageUploadTask!
                    
                    var videoTask: StorageUploadTask!
                    
                    let pictureGroup = DispatchGroup()
                    
                    var success = true
                    
                    var pictureUrl = URL(string: "www.example.com")
                    
                    var videoUrl = URL(string: "www.example.com")
                    
                    pictureGroup.enter()
                    
                    pictureTask = pictureFileRef.putFile(from: pictureFileUrl, metadata: StorageMetadata()) { (metadata, error) in
                        guard metadata != nil else {
                            print("Upload error")
                            return
                        }
                        
                        pictureFileRef.downloadURL { url, error in
                            if let error = error {
                                print("DownloadURL error: \(error)")
                                return
                            } else {
                                if let urlTemp = url{
                                    pictureUrl = urlTemp
                                    pictureGroup.leave()
                                }
                            }
                        }
                    }
                    
                    pictureTask.observe(.failure){ snapShot in
                        success = false
                        pictureGroup.leave()
                    }
                    
                    pictureTask.observe(.success){ snapShot in
                        
                        print("picture success")
                        
                    }
                    
                    pictureGroup.notify(queue: .global()){
                        
                        if success == false { return }
                        
                        let videoGroup = DispatchGroup()
                        videoGroup.enter()
                        
                        videoTask = videoFileRef.putFile(from: videoFileUrl, metadata: StorageMetadata()) { (metadata, error) in
                            guard metadata != nil else {
                                print("Upload error")
                                return
                            }
                            videoFileRef.downloadURL { url, error in
                                if let error = error {
                                    print(error)
                                    return
                                } else {
                                    if let urlTemp = url{
                                        videoUrl = urlTemp
                                        videoGroup.leave()
                                    }
                                }
                            }
                        }
                        
                        videoTask.observe(.failure){ snapShot in
                            success = false
                            videoGroup.leave()
                        }
                        
                        videoTask.observe(.success){ snapShot in
                            print("video success")
                            
                        }
                        
                        videoGroup.notify(queue: .global()){
                            
                            if success == false { return }
                            
                            self.observationRef.document(item.id!).setData(["species": item.species!, "rarity": item.rarity!, "rarityNumber": item.rarityNumber, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "pictureUrl": pictureUrl!.absoluteString, "soundUrl": "", "videoUrl": videoUrl!.absoluteString, "lat": item.lat, "long": item.long]){  err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                } else {
                                    print("Document successfully written! in only video")
                                    
                                    fetchRequest.predicate = NSPredicate(format: "id = %@", item.id!)
                                    
                                    do {
                                        let fetched = try managedContext.fetch(fetchRequest)
                                        
                                        let objectUpdate = fetched[0] as! NSManagedObject
                                        objectUpdate.setValue(true, forKey: "uploaded")
                                        objectUpdate.setValue(false, forKey: "uploading")
                                        
                                        do{
                                            try managedContext.save()
                                        }
                                        catch{
                                            print(error)
                                        }
                                    }
                                    catch {
                                        print(error)
                                    }
                                    if localItemSet.count > 1 { self.sync() }
                                }
                            }
                        }
                        }
                        
                    
                    
                case (false, false):
                    
                    var pictureTask: StorageUploadTask!
                    
                    let pictureGroup = DispatchGroup()
                    
                    var success = true
                    
                    var pictureUrl = URL(string: "www.example.com")
                    
                    pictureGroup.enter()
                    
                    pictureTask = pictureFileRef.putFile(from: pictureFileUrl, metadata: StorageMetadata()) { (metadata, error) in
                        guard metadata != nil else {
                            print("Upload error")
                            return
                        }
                        
                        pictureFileRef.downloadURL { url, error in
                            if let error = error {
                                print("DownloadURL error: \(error)")
                                return
                            } else {
                                if let urlTemp = url{
                                    pictureUrl = urlTemp
                                    pictureGroup.leave()
                                }
                            }
                        }
                    }
                    
                    pictureTask.observe(.failure){ snapShot in
                        success = false
                        pictureGroup.leave()
                    }
                    
                    pictureTask.observe(.success){ snapShot in
                        
                        print("picture success")
                        
                    }
                    
                    pictureGroup.notify(queue: .global()){
                        
                        if success == false { return }
                        
                        self.observationRef.document(item.id!).setData(["species": item.species!, "rarity": item.rarity!, "rarityNumber": item.rarityNumber, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "pictureUrl": pictureUrl!.absoluteString, "soundUrl": "", "videoUrl": "", "lat": item.lat, "long": item.long]){  err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written! in neither")
                                
                                fetchRequest.predicate = NSPredicate(format: "id = %@", item.id!)
                                
                                do {
                                    let fetched = try managedContext.fetch(fetchRequest)
                                    
                                    let objectUpdate = fetched[0] as! NSManagedObject
                                    objectUpdate.setValue(true, forKey: "uploaded")
                                    objectUpdate.setValue(false, forKey: "uploading")
                                    
                                    do{
                                        try managedContext.save()
                                    }
                                    catch{
                                        print(error)
                                    }
                                }
                                catch {
                                    print(error)
                                }
                                if localItemSet.count > 1 { self.sync() }
                            }
                        }
                    }
                }
                
            
            }
        
        }
    
    
    func checkLocalValidity(){
        
        let remoteGroup = DispatchGroup()
        
         var remoteItemSet: [Observation] = []
        
         var itemSet: [OwnObservation] = []
              
        remoteGroup.enter()
        
        observationRef.whereField("uid", isEqualTo: uid!).getDocuments(){
            (querySnapShot, err) in
            if let err = err{
                print(err)
                return
            }
            else{
                if let querySnapShot = querySnapShot{
                for document in querySnapShot.documents{
                    let data = document.data()
                    remoteItemSet.append(Observation(data))
                    }
                    
                }
            }
            remoteGroup.leave()
        }
        
        remoteGroup.notify(queue: .global()){
        
            let managedContext = self.appDelegate.persistentContainer.viewContext
               
               let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OwnObservation")
            fetchRequest.predicate = NSPredicate(format: "uid = %@", self.uid!)
               
               do{
                   let result = try managedContext.fetch(fetchRequest)
                   for data in result as! [OwnObservation] {
                       itemSet.append(data)
                   }
               }
               catch {
                   print("own data retrieve failed")
                return
               }
        
            let remoteIdSet: [String] = remoteItemSet.map({ $0.id! })
        
        for item in itemSet{
            
            if !remoteIdSet.contains(item.id!) && item.uploaded == true{
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OwnObservation")
                fetchRequest.predicate = NSPredicate(format: "id = %@", item.id!)
                
                do{
                    let fetched = try managedContext.fetch(fetchRequest)
                    
                    let objectToDelete = fetched[0] as! NSManagedObject
                    managedContext.delete(objectToDelete)
                    
                    do{
                        try managedContext.save()
                    }
                    catch {
                        print(error)
                        return
                    }
                }
                catch {
                    print(error)
                    return
                }
                
            }
        }
        }
    }
    
    
    }

