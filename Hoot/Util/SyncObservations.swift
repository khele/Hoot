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
    
    let pictureRef = Storage.storage().reference().child("picture")
    
    let soundRef = Storage.storage().reference().child("sound")
    
    let videoRef = Storage.storage().reference().child("video")
    
    let observationRef = Firestore.firestore().collection("observation")
    
    let uid = Auth.auth().currentUser?.uid
    
    let db = Firestore.firestore()
    
    unowned let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
   
    
    
    
    func sync(){
        
        guard appDelegate.connected == true else { return }
        
        print("SYNC RAN")
        
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
        }
        
        if itemSet.isEmpty {
            print("ITEMSET WAS EMPTY IN SYNC")
            var worldItemSet: [MainItem] = []
            
            db.collection("observation").whereField("uid", isEqualTo: uid!).getDocuments(){
                (querySnapshot, err) in
                if let err = err {
                    print("error getting documents: \(err)")
                }
                else {
                    print("Downloading documents")
                    if let querySnapshot = querySnapshot {
                        for doc in querySnapshot.documents{
                            let data = doc.data()
                            worldItemSet.append(Observation(data))
                        }
                    }
            
                    for item in worldItemSet{
                        
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
                        
                        
                            
                        if item.soundUrl! == "" && item.videoUrl == ""{
                            observation.setValuesForKeys(["species": item.species!, "rarity": item.rarity!, "rarityNumber": item.rarityNumber, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "uploaded": true, "pictureUrl": "\(item.id!).jpeg", "soundUrl": "", "videoUrl": "", "lat": item.lat, "long": item.long])
                        }
                            
                            
                            
                        if item.soundUrl! != "" && item.videoUrl! == "" {
                        observation.setValuesForKeys(["species": item.species!, "rarity": item.rarity!, "rarityNumber": item.rarityNumber, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "uploaded": true, "pictureUrl": "\(item.id!).jpeg", "soundUrl": "\(item.id!).m4a", "videoUrl": "", "lat": item.lat, "long": item.long])
                        }
                            
                            
                        if item.soundUrl! == "" && item.videoUrl != "" {
                             observation.setValuesForKeys(["species": item.species!, "rarity": item.rarity!, "rarityNumber": item.rarityNumber, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "uploaded": true, "pictureUrl": "\(item.id!).jpeg", "soundUrl": "", "videoUrl": "\(item.id!).mp4", "lat": item.lat, "long": item.long])
                        }
                            
                            
                            
                        if item.soundUrl! != "" && item.videoUrl! != "" {
                            observation.setValuesForKeys(["species": item.species!, "rarity": item.rarity!, "rarityNumber": item.rarityNumber, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "uploaded": true, "pictureUrl": "\(item.id!).jpeg", "soundUrl": "\(item.id!).m4a", "videoUrl": "\(item.id!).mp4", "lat": item.lat, "long": item.long])
                        }
                            
                        do {
                            try managedContext.save()
                            print("save done")
                        }
                        catch let error as NSError {
                            print("Error occurred: \(error)")
                        }
                    }
                }
                
                if self.appDelegate.window?.rootViewController?.restorationIdentifier == "mainNavigationController"{
                        
                    let nvc = self.appDelegate.window?.rootViewController as! UINavigationController
                    let vc = nvc.viewControllers[0] as! MainViewController
                    vc.getOwnObservations()
                        
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
            print(localItemSet.count)
            
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
                    }
                }
                catch {
                    print(error)
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
                     
                        print("picture success")
                        
                    }
                    
                    pictureGroup.notify(queue: .main){
                        
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
                        
                        soundGroup.notify(queue: .main){
                            
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
                                        print("downloadurl else")
                                        if let urlTemp = url{
                                            print("download url url")
                                            videoUrl = urlTemp
                                            print(urlTemp)
                                            print(videoUrl!)
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
                            
                            videoGroup.notify(queue: .main){
                                
                                if success == false { return }
                                
                                let documentGroup = DispatchGroup()
                                
                                documentGroup.enter()
                                print(videoUrl!)
                                self.db.collection("observation").document(item.id!).setData(["species": item.species!, "rarity": item.rarity!, "rarityNumber": item.rarityNumber, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "pictureUrl": pictureUrl!.absoluteString, "soundUrl": soundUrl!.absoluteString, "videoUrl": videoUrl!.absoluteString, "lat": item.lat, "long": item.long]){  err in
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
                        pictureGroup.leave()
                    }
                    
                    pictureGroup.notify(queue: .main){
                        
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
                            soundGroup.leave()
                        }
                        
                        soundGroup.notify(queue: .main){
                            
                            if success == false { return }
                            
                            let documentGroup = DispatchGroup()
                            
                            documentGroup.enter()
                            
                            self.db.collection("observation").document(item.id!).setData(["species": item.species!, "rarity": item.rarity!, "rarityNumber": item.rarityNumber, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "pictureUrl": pictureUrl!.absoluteString, "soundUrl": soundUrl!.absoluteString, "videoUrl": "", "lat": item.lat, "long": item.long]){  err in
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
                        pictureGroup.leave()
                    }
                    
                    pictureGroup.notify(queue: .main){
                        
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
                                    }
                                }
                            }
                        }
                        
                        videoTask.observe(.failure){ snapShot in
                            success = false
                            videoGroup.leave()
                        }
                        
                        videoTask.observe(.success){ snapShot in
                            print("sound success")
                            videoGroup.leave()
                        }
                        
                        videoGroup.notify(queue: .main){
                            
                            if success == false { return }
                            
                            let documentGroup = DispatchGroup()
                            
                            documentGroup.enter()
                            
                            self.db.collection("observation").document(item.id!).setData(["species": item.species!, "rarity": item.rarity!, "rarityNumber": item.rarityNumber, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "pictureUrl": pictureUrl!.absoluteString, "soundUrl": "", "videoUrl": videoUrl!.absoluteString, "lat": item.lat, "long": item.long]){  err in
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
                        pictureGroup.leave()
                    }
                    
                    pictureGroup.notify(queue: .main){
                        
                        if success == false { return }
                        
                        let documentGroup = DispatchGroup()
                        
                        documentGroup.enter()
                        
                        self.db.collection("observation").document(item.id!).setData(["species": item.species!, "rarity": item.rarity!, "rarityNumber": item.rarityNumber, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "pictureUrl": pictureUrl!.absoluteString, "soundUrl": "", "videoUrl": "", "lat": item.lat, "long": item.long]){  err in
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
    
    
    }

