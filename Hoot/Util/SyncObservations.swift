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
                            observation.setValuesForKeys(["species": item.species!, "rarity": item.rarity!, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "uploaded": true, "pictureUrl": "\(item.id!).jpeg", "soundUrl": "", "videoUrl": "", "lat": item.lat, "long": item.long])
                        }
                            
                            
                            
                        if item.soundUrl! != "" && item.videoUrl! == "" {
                        observation.setValuesForKeys(["species": item.species!, "rarity": item.rarity!, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "uploaded": true, "pictureUrl": "\(item.id!).jpeg", "soundUrl": "\(item.id!).m4a", "videoUrl": "", "lat": item.lat, "long": item.long])
                        }
                            
                            
                        if item.soundUrl! == "" && item.videoUrl != "" {
                             observation.setValuesForKeys(["species": item.species!, "rarity": item.rarity!, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "uploaded": true, "pictureUrl": "\(item.id!).jpeg", "soundUrl": "", "videoUrl": "\(item.id!).mp4", "lat": item.lat, "long": item.long])
                        }
                            
                            
                            
                        if item.soundUrl! != "" && item.videoUrl! != "" {
                             observation.setValuesForKeys(["species": item.species!, "rarity": item.rarity!, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "uploaded": true, "pictureUrl": "\(item.id!).jpeg", "soundUrl": "\(item.id!).m4a", "videoUrl": "\(item.id!).mp4", "lat": item.lat, "long": item.long])
                        }
                            
                        do {
                            try managedContext.save()
                        }
                        catch let error as NSError {
                            print("Error occurred: \(error)")
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
            print(localItemSet.count)
            for item in localItemSet {
                
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
                
                var pictureUrl = URL(string: "www.example.com")
                
                var soundUrl = URL(string: "www.example.com")
                
                var videoUrl = URL(string: "www.example.com")
                
                let pictureFileUrl = documentsUrl.appendingPathComponent("\(item.id!).jpeg")
              
                let pictureFileRef = pictureRef.child("\(item.id!).jpeg")
                
                let soundFileUrl = documentsUrl.appendingPathComponent("\(item.id!).m4a")
                
                let soundFileRef = soundRef.child("\(item.id!).m4a")
                
                let videoFileUrl = documentsUrl.appendingPathComponent("\(item.id!).mp4")
                
                let videoFileRef = videoRef.child("\(item.id!).mp4")
                
                let soundAndVideo = (Bool(item.soundUrl! != ""), Bool(item.videoUrl! != ""))
                
                var soundTask: StorageUploadTask?
                
                var videoTask: StorageUploadTask?
                
                switch soundAndVideo {
                    
                case (true, true):
                    
                    pictureFileRef.putFile(from: pictureFileUrl, metadata: StorageMetadata()) { (metadata, error) in
                        guard metadata != nil else {
                            print("Upload error")
                            return
                        }
                        
                        
                        pictureFileRef.downloadURL { url, error in
                            if let error = error {
                                print("DownloadURL error: \(error)")
                            } else {
                                if let urlTemp = url{
                                    pictureUrl = urlTemp
                                        
                                        soundTask = soundFileRef.putFile(from: soundFileUrl, metadata: StorageMetadata()) { (metadata, error) in
                                            guard metadata != nil else {
                                                print("Upload error")
                                                return
                                            }
                                            soundFileRef.downloadURL { url, error in
                                                if let error = error {
                                                    print(error)
                                                } else {
                                                    if let urlTemp = url{
                                                        soundUrl = urlTemp
                                                            
                                                            videoTask =  videoFileRef.putFile(from: videoFileUrl, metadata: StorageMetadata()) { (metadata, error) in
                                                                guard metadata != nil else {
                                                                    print("Upload error")
                                                                    return
                                                                }
                                                                videoFileRef.downloadURL { url, error in
                                                                    if let error = error {
                                                                        print(error)
                                                                    } else {
                                                                        if let urlTemp = url{
                                                                            videoUrl = urlTemp
                                                                            
                                                                            self.db.collection("observation").document(item.id!).setData(["species": item.species!, "rarity": item.rarity!, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "pictureUrl": pictureUrl!.absoluteString, "soundUrl": soundUrl!.absoluteString, "videoUrl": videoUrl!.absoluteString, "lat": item.lat, "long": item.long]){  err in
                                                                                if let err = err {
                                                                                    print("Error writing document: \(err)")
                                                                                } else {
                                                                                    
                                                                                    fetchRequest.predicate = NSPredicate(format: "id = %@", item.id!)
                                                                                    
                                                                                    do {
                                                                                        let fetched = try managedContext.fetch(fetchRequest)
                                                                                        
                                                                                        let objectUpdate = fetched[0] as! NSManagedObject
                                                                                        objectUpdate.setValue(true, forKey: "uploaded")
                                                                                        
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
                                                                                    print("Document successfully written!")
                                                                                    
                                                                                   
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                        }
                                                    }
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                    
                case (true, false):
                    
                    pictureFileRef.putFile(from: pictureFileUrl, metadata: StorageMetadata()) { (metadata, error) in
                        guard metadata != nil else {
                            print("Upload error")
                            return
                        }
                        
                        
                        pictureFileRef.downloadURL { url, error in
                            if let error = error {
                                print("DownloadURL error: \(error)")
                            } else {
                                if let urlTemp = url{
                                    pictureUrl = urlTemp
                                    
                                    soundTask = soundFileRef.putFile(from: soundFileUrl, metadata: StorageMetadata()) { (metadata, error) in
                                        guard metadata != nil else {
                                            print("Upload error")
                                            return
                                        }
                                        soundFileRef.downloadURL { url, error in
                                            if let error = error {
                                                print(error)
                                            } else {
                                                if let urlTemp = url{
                                                    soundUrl = urlTemp
                                                                    
                                                                    self.db.collection("observation").document(item.id!).setData(["species": item.species!, "rarity": item.rarity!, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "pictureUrl": pictureUrl!.absoluteString, "soundUrl": soundUrl!.absoluteString, "videoUrl": "", "lat": item.lat, "long": item.long]){  err in
                                                                        if let err = err {
                                                                            print("Error writing document: \(err)")
                                                                        } else {
                                                                            
                                                                            fetchRequest.predicate = NSPredicate(format: "id = %@", item.id!)
                                                                            
                                                                            do {
                                                                                let fetched = try managedContext.fetch(fetchRequest)
                                                                                
                                                                                let objectUpdate = fetched[0] as! NSManagedObject
                                                                                objectUpdate.setValue(true, forKey: "uploaded")
                                                                                
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
                                                                            print("Document successfully written!")
                                                                            
                                                                            
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                    
                case (false, true):
                    
                    pictureFileRef.putFile(from: pictureFileUrl, metadata: StorageMetadata()) { (metadata, error) in
                        guard metadata != nil else {
                            print("Upload error")
                            return
                        }
                        
                        
                        pictureFileRef.downloadURL { url, error in
                            if let error = error {
                                print("DownloadURL error: \(error)")
                            } else {
                                if let urlTemp = url{
                                    pictureUrl = urlTemp
                                                    
                                                    videoTask =  videoFileRef.putFile(from: videoFileUrl, metadata: StorageMetadata()) { (metadata, error) in
                                                        guard metadata != nil else {
                                                            print("Upload error")
                                                            return
                                                        }
                                                        videoFileRef.downloadURL { url, error in
                                                            if let error = error {
                                                                print(error)
                                                            } else {
                                                                if let urlTemp = url{
                                                                    videoUrl = urlTemp
                                                                    
                                                                    self.db.collection("observation").document(item.id!).setData(["species": item.species!, "rarity": item.rarity!, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "pictureUrl": pictureUrl!.absoluteString, "soundUrl": "", "videoUrl": videoUrl!.absoluteString, "lat": item.lat, "long": item.long]){  err in
                                                                        if let err = err {
                                                                            print("Error writing document: \(err)")
                                                                        } else {
                                                                            
                                                                            fetchRequest.predicate = NSPredicate(format: "id = %@", item.id!)
                                                                            
                                                                            do {
                                                                                let fetched = try managedContext.fetch(fetchRequest)
                                                                                
                                                                                let objectUpdate = fetched[0] as! NSManagedObject
                                                                                objectUpdate.setValue(true, forKey: "uploaded")
                                                                                
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
                                                                            print("Document successfully written!")
                                                                           
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                    
                case (false, false):
                    
                    pictureFileRef.putFile(from: pictureFileUrl, metadata: StorageMetadata()) { (metadata, error) in
                        guard metadata != nil else {
                            print("Upload error")
                            return
                        }
                        
                        
                        pictureFileRef.downloadURL { url, error in
                            if let error = error {
                                print("DownloadURL error: \(error)")
                            } else {
                                if let urlTemp = url{
                                    pictureUrl = urlTemp
                                    
                                                                    
                                                                    self.db.collection("observation").document(item.id!).setData(["species": item.species!, "rarity": item.rarity!, "notes": item.notes!, "created": item.created, "id": item.id!, "uid": item.uid!, "dname": item.dname!, "pictureUrl": pictureUrl!.absoluteString, "soundUrl": "", "videoUrl": "", "lat": item.lat, "long": item.long]){  err in
                                                                        if let err = err {
                                                                            print("Error writing document: \(err)")
                                                                        } else {
                                                                            
                                                                            fetchRequest.predicate = NSPredicate(format: "id = %@", item.id!)
                                                                            
                                                                            do {
                                                                                let fetched = try managedContext.fetch(fetchRequest)
                                                                                
                                                                                let objectUpdate = fetched[0] as! NSManagedObject
                                                                                objectUpdate.setValue(true, forKey: "uploaded")
                                                                                
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
                                                                            print("Document successfully written!")
                                                                            
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                    
                }
                
                let soundAndAudioTasks = (Bool(soundTask != nil), Bool(videoTask != nil))
                
                var soundUploaded = false
                
                var videoUploaded = false
                
                switch soundAndAudioTasks {
                    
                case (true, true):
                    
                    soundTask?.observe(.failure){ snapShot in
                        
                        do {
                            let fetched = try managedContext.fetch(fetchRequest)
                            
                            let objectUpdate = fetched[0] as! NSManagedObject
                            objectUpdate.setValue(false, forKey: "uploading")
                            objectUpdate.setValue(false, forKey: "uploaded")
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
                    }
                    
                    videoTask?.observe(.failure){ snapShot in
                        
                        do {
                            let fetched = try managedContext.fetch(fetchRequest)
                            
                            let objectUpdate = fetched[0] as! NSManagedObject
                            objectUpdate.setValue(false, forKey: "uploading")
                            objectUpdate.setValue(false, forKey: "uploaded")
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
                        
                        self.db.collection("observation").document(item.id!).delete()
                    }
                    
                    soundTask?.observe(.success){ snapShot in
                        soundUploaded = true
                        
                        if videoUploaded == true {
                        
                        fetchRequest.predicate = NSPredicate(format: "id = %@", item.id!)
                        
                        do {
                            let fetched = try managedContext.fetch(fetchRequest)
                            
                            let objectUpdate = fetched[0] as! NSManagedObject
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
                        }
                        
                    }
                    
                    videoTask?.observe(.success){ snapShot in
                        videoUploaded = true
                        
                        if soundUploaded == true {
                            
                            fetchRequest.predicate = NSPredicate(format: "id = %@", item.id!)
                            
                            do {
                                let fetched = try managedContext.fetch(fetchRequest)
                                
                                let objectUpdate = fetched[0] as! NSManagedObject
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
                        }
                        
                    }
                    
                case (true, false):
                    
                    soundTask?.observe(.success){ snapShot in
                        
                        fetchRequest.predicate = NSPredicate(format: "id = %@", item.id!)
                        
                        do {
                            let fetched = try managedContext.fetch(fetchRequest)
                            
                            let objectUpdate = fetched[0] as! NSManagedObject
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
                        
                    }
                    
                case (false, true):
                    
                    videoTask?.observe(.success){ snapShot in
                        
                        fetchRequest.predicate = NSPredicate(format: "id = %@", item.id!)
                        
                        do {
                            let fetched = try managedContext.fetch(fetchRequest)
                            
                            let objectUpdate = fetched[0] as! NSManagedObject
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
                        
                    }
                    
                case (false, false):
                    
                    fetchRequest.predicate = NSPredicate(format: "id = %@", item.id!)
                    
                    do {
                        let fetched = try managedContext.fetch(fetchRequest)
                        
                        let objectUpdate = fetched[0] as! NSManagedObject
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
                    
                }
                
                if soundTask != nil {
                    
                    soundTask?.observe(.success) { snapshot in
                        
                        soundUploaded = true
                        
                        if videoUrl != nil && videoUploaded == true {
                            
                            fetchRequest.predicate = NSPredicate(format: "id = %@", item.id!)
                            
                            do {
                                let fetched = try managedContext.fetch(fetchRequest)
                                
                                let objectUpdate = fetched[0] as! NSManagedObject
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
                            
                        }
                        if videoUrl == nil {
                            
                            fetchRequest.predicate = NSPredicate(format: "id = %@", item.id!)
                            
                            do {
                                let fetched = try managedContext.fetch(fetchRequest)
                                
                                let objectUpdate = fetched[0] as! NSManagedObject
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
                            
                        }
                    }
                    
                    
                    
                }
                
               
                
            }
        }
    }
}
