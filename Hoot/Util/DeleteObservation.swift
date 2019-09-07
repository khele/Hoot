//
//  DeleteObservation.swift
//  Hoot
//
//  Created by Kristian Helenius on 07/09/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import Foundation
import Firebase
import CoreData

struct DeleteObservation{

    init(observationToDelete: MainItem){
        observation = observationToDelete
        
    }
    
    // Firebase
    
    let db = Firestore.firestore()
    
    var observationRef = Firestore.firestore().collection("observation")
    
    var pictureFireRef = Storage.storage().reference().child("picture")
    
    var soundFireRef = Storage.storage().reference().child("sound")
    
    var videoFireRef = Storage.storage().reference().child("video")
    
    let storageRef = Storage.storage().reference()
    
    var uid = Auth.auth().currentUser?.uid
    
    
    
    weak var delegate: DeleteObservationDelegate?

    var observation: MainItem

    let fileManager = FileManager.default
    
    unowned let appDelegate = UIApplication.shared.delegate as! AppDelegate

    


    
    

    func deleteObservation(){
        
        let obs = observation as! OwnObservation
        
        var checkObs: OwnObservation?
        
        let soundAndVideo = (Bool(obs.soundUrl != ""), Bool(obs.videoUrl != ""))
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let documentsUrl = fileManager.urls(for: .documentDirectory, in:.userDomainMask)[0]
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        
        let checkFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OwnObservation")
        checkFetchRequest.predicate = NSPredicate(format: "id = %@", observation.id!)
        
        do{
            let result = try managedContext.fetch(checkFetchRequest)
            for data in result as! [NSManagedObject] {
                checkObs = data as? OwnObservation
            }
        }
        catch{
            print(error)
            delegate?.deleteObservationDidRun(result: .failure)
            return
        }
        
        guard checkObs!.uploading != true else {  delegate?.deleteObservationDidRun(result: .uploading); return }
        
        
        
        if obs.uploaded == true {
            
            let objectId = obs.id!
            
            switch soundAndVideo{
                
            case (true, true):
                
                pictureFireRef.child("\(obs.id!).jpeg").delete(){ error in
                    if let error = error {
                        print("error deleting image: \(error)")
                        self.delegate?.deleteObservationDidRun(result: .failure)
                        return
                    } else {
                        print("image deleted successfully")
                    
                        self.soundFireRef.child("\(obs.id!).m4a").delete(){ error in
                            if let error = error {
                                print("error deleting sound: \(error)")
                            } else {
                                print("sound deleted successfully")
                            }
                                self.videoFireRef.child("\(obs.id!).mp4").delete(){ error in
                                    if let error = error {
                                        print("error deleting video: \(error)")
                                    } else {
                                        print("video deleted successfully")
                                    }
                                        self.observationRef.document(obs.id!).delete(){ err in
                                            if let err = err {
                                                print("error deleting document: \(err)")
                                                self.delegate?.deleteObservationDidRun(result: .failure)
                                                return
                                            } else {
                                                print("document deleted successfully")
                                                
                                                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OwnObservation")
                                                fetchRequest.predicate = NSPredicate(format: "id = %@", obs.id!)
                                                
                                                do{
                                                    let fetched = try managedContext.fetch(fetchRequest)
                                                    
                                                    let objectToDelete = fetched[0] as! NSManagedObject
                                                    managedContext.delete(objectToDelete)
                                                    
                                                    do{
                                                        try managedContext.save()
                                                    }
                                                    catch {
                                                        print(error)
                                                        self.delegate?.deleteObservationDidRun(result: .failure)
                                                        return
                                                    }
                                                }
                                                catch {
                                                    print(error)
                                                    self.delegate?.deleteObservationDidRun(result: .failure)
                                                    return
                                                }
                                                
                                                try? self.fileManager.removeItem(atPath: documentsPath.appendingPathComponent("\(objectId).jpeg"))
                                                try? self.fileManager.removeItem(atPath: documentsPath.appendingPathComponent("\(objectId).m4a"))
                                                try? self.fileManager.removeItem(atPath: documentsPath.appendingPathComponent("\(objectId).mp4"))
                                                self.delegate?.deleteObservationDidRun(result: .success)
                                            }
                                        }
                                    
                                }
                            
                        }
                }
                }
                
            case (true, false):
                
                pictureFireRef.child("\(obs.id!).jpeg").delete(){ error in
                    if let error = error {
                        print("error deleting image: \(error)")
                        self.delegate?.deleteObservationDidRun(result: .failure)
                        return
                    } else {
                        print("image deleted successfully")
                        
                        self.soundFireRef.child("\(obs.id!).m4a").delete(){ error in
                            if let error = error {
                                print("error deleting sound: \(error)")
                            } else {
                                print("sound deleted successfully")
                            }
                                self.observationRef.document(obs.id!).delete(){ err in
                                    if let err = err {
                                        print("error deleting document: \(err)")
                                        self.delegate?.deleteObservationDidRun(result: .failure)
                                        return
                                    } else {
                                        print("document deleted successfully")
                                        
                                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OwnObservation")
                                        fetchRequest.predicate = NSPredicate(format: "id = %@", obs.id!)
                                        
                                        do{
                                            let fetched = try managedContext.fetch(fetchRequest)
                                            
                                            let objectToDelete = fetched[0] as! NSManagedObject
                                            managedContext.delete(objectToDelete)
                                            
                                            do{
                                                try managedContext.save()
                                            }
                                            catch {
                                                print(error)
                                                self.delegate?.deleteObservationDidRun(result: .failure)
                                                return
                                            }
                                        }
                                        catch {
                                            print(error)
                                            self.delegate?.deleteObservationDidRun(result: .failure)
                                            return
                                        }
                                        
                                        try? self.fileManager.removeItem(at: documentsUrl.appendingPathComponent("\(objectId).jpeg"))
                                        try? self.fileManager.removeItem(at: documentsUrl.appendingPathComponent("\(objectId).m4a"))
                                        self.delegate?.deleteObservationDidRun(result: .success)
                                    }
                                }
                            
                        }
                    }
                }
                
                
                
            case (false, true):
                
                pictureFireRef.child("\(obs.id!).jpeg").delete(){ error in
                    if let error = error {
                        print("error deleting image: \(error)")
                        self.delegate?.deleteObservationDidRun(result: .failure)
                        return
                    } else {
                        print("image deleted successfully")
                        
                        self.videoFireRef.child("\(obs.id!).mp4").delete(){ error in
                            if let error = error {
                                print("error deleting video: \(error)")
                            } else {
                                print("video deleted successfully")
                            }
                                self.observationRef.document(obs.id!).delete(){ err in
                                    if let err = err {
                                        print("error deleting document: \(err)")
                                        self.delegate?.deleteObservationDidRun(result: .failure)
                                        return
                                    } else {
                                        print("document deleted successfully")
                                        
                                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OwnObservation")
                                        fetchRequest.predicate = NSPredicate(format: "id = %@", obs.id!)
                                        
                                        do{
                                            let fetched = try managedContext.fetch(fetchRequest)
                                            
                                            let objectToDelete = fetched[0] as! NSManagedObject
                                            managedContext.delete(objectToDelete)
                                            
                                            do{
                                                try managedContext.save()
                                            }
                                            catch {
                                                print(error)
                                                self.delegate?.deleteObservationDidRun(result: .failure)
                                                return
                                            }
                                        }
                                        catch {
                                            print(error)
                                            self.delegate?.deleteObservationDidRun(result: .failure)
                                            return
                                        }
                                        
                                        try? self.fileManager.removeItem(at: documentsUrl.appendingPathComponent("\(objectId).jpeg"))
                                        try? self.fileManager.removeItem(at: documentsUrl.appendingPathComponent("\(objectId).mp4"))
                                        self.delegate?.deleteObservationDidRun(result: .success)
                                    }
                                }
                            
                        }
                    }
                }
                
                
            case (false, false):
                
                pictureFireRef.child("\(obs.id!).jpeg").delete(){ error in
                    if let error = error {
                        print("error deleting image: \(error)")
                        self.delegate?.deleteObservationDidRun(result: .failure)
                        return
                    } else {
                        print("image deleted successfully")
                        
                        self.observationRef.document(obs.id!).delete(){ err in
                            if let err = err {
                                print("error deleting document: \(err)")
                                self.delegate?.deleteObservationDidRun(result: .failure)
                                return
                            } else {
                                print("document deleted successfully")
                                
                                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OwnObservation")
                                fetchRequest.predicate = NSPredicate(format: "id = %@", obs.id!)
                                
                                do{
                                    let fetched = try managedContext.fetch(fetchRequest)
                                    
                                    let objectToDelete = fetched[0] as! NSManagedObject
                                    managedContext.delete(objectToDelete)
                                    
                                    do{
                                        try managedContext.save()
                                    }
                                    catch {
                                        print(error)
                                        self.delegate?.deleteObservationDidRun(result: .failure)
                                        return
                                    }
                                }
                                catch {
                                    print(error)
                                    self.delegate?.deleteObservationDidRun(result: .failure)
                                    return
                                }
                                
                                try? self.fileManager.removeItem(at: documentsUrl.appendingPathComponent("\(objectId).jpeg"))
                                self.delegate?.deleteObservationDidRun(result: .success)
                            }
                        }
                    }
                }
            }
        }
            
        else {
            
            let objectId = obs.id!
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OwnObservation")
            fetchRequest.predicate = NSPredicate(format: "id = %@", obs.id!)
            
            do{
                let fetched = try managedContext.fetch(fetchRequest)
                
                let objectToDelete = fetched[0] as! NSManagedObject
                managedContext.delete(objectToDelete)
                
                do{
                    try managedContext.save()
                }
                catch {
                    print(error)
                    self.delegate?.deleteObservationDidRun(result: .failure)
                    return
                }
            }
            catch {
                print(error)
                self.delegate?.deleteObservationDidRun(result: .failure)
                return
            }
            
            
            switch soundAndVideo{
                
            case (true, true):
                
                try? fileManager.removeItem(at: documentsUrl.appendingPathComponent("\(objectId).jpeg"))
                try? fileManager.removeItem(at: documentsUrl.appendingPathComponent("\(objectId).m4a"))
                try? fileManager.removeItem(at: documentsUrl.appendingPathComponent("\(objectId).mp4"))
                delegate?.deleteObservationDidRun(result: .success)
            case (true, false):
                
                try? fileManager.removeItem(at: documentsUrl.appendingPathComponent("\(objectId).jpeg"))
                try? fileManager.removeItem(at: documentsUrl.appendingPathComponent("\(objectId).m4a"))
                delegate?.deleteObservationDidRun(result: .success)
            case (false, true):
                
                try? fileManager.removeItem(at: documentsUrl.appendingPathComponent("\(objectId).jpeg"))
                try? fileManager.removeItem(at: documentsUrl.appendingPathComponent("\(objectId).mp4"))
                delegate?.deleteObservationDidRun(result: .success)
            case (false, false):
                
                try? fileManager.removeItem(at: documentsUrl.appendingPathComponent("\(objectId).jpeg"))
                delegate?.deleteObservationDidRun(result: .success)
            }
            
            
        }
        
        
    }

    }

    

