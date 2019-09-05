//
//  SyncAndDeleteTests.swift
//  HootTests
//
//  Created by Kristian Helenius on 05/09/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import XCTest
import Firebase
import CoreData
@testable import Hoot

class SyncAndDeleteTests: XCTestCase {

    
    func testDelete(){
        
        var sync = SyncObservations()
        
        let managedContext = sync.appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OwnObservation")
        
        do{
            let test = try managedContext.fetch(fetchRequest)
            
            for object in test as! [NSManagedObject]{
                managedContext.delete(object)
            }
            
            do{
                try managedContext.save()
            }
            catch{
                print(error)
            }
        }
        catch{
            print(error)
        }
        
        XCTAssert(1 == 1)
        
    }
    

    func testSyncToDeviceAndDelete() {
      
        
        
        var sync = SyncObservations()
        
        sync.observationRef = sync.db.collection("test")
        
        sync.pictureRef = sync.storage.child("test").child("picture")
        
        sync.soundRef = sync.storage.child("test").child("sound")
        
        sync.videoRef = sync.storage.child("test").child("video")
        
        sync.uid = "test"
        
        let loginExpectation = expectation(description: "Wait for login")
        
        sync.auth.signIn(withEmail: "stagelife2@hotmail.com", password: "password") {  user, error in
            XCTAssert(user != nil)
            loginExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        
        sync.sync()
        
        let documentsPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
        
        let picturePath = documentsPath.appendingPathComponent("zmezAIVVMxkxvAvgUqDL.jpeg")
        
        let soundPath = documentsPath.appendingPathComponent("zmezAIVVMxkxvAvgUqDL.m4a")
        
        let videoPath = documentsPath.appendingPathComponent("zmezAIVVMxkxvAvgUqDL.mp4")
        
        let fileExpectation = expectation(description: "wait for files to be saved locally")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6){
            fileExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 7, handler: nil)
        
        XCTAssert(sync.fileManager.fileExists(atPath: picturePath) && sync.fileManager.fileExists(atPath: soundPath) && sync.fileManager.fileExists(atPath: videoPath))
        
        let managedContext = sync.appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OwnObservation")
       
        do{
           let result = try managedContext.fetch(fetchRequest)
            
            let data = result as! [NSManagedObject]
            
            XCTAssert(!data.isEmpty)
        }
        catch{
            print(error)
            
            try! sync.fileManager.removeItem(atPath: picturePath)
            try! sync.fileManager.removeItem(atPath: soundPath)
            try! sync.fileManager.removeItem(atPath: videoPath)
            XCTFail()
        }
        
        let vc = UIStoryboard(name: "Detail", bundle: Bundle.main).instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
        
        do{
            let result = try managedContext.fetch(fetchRequest)
            
            let data = result as! [NSManagedObject]
            
            let own = data[0] as! OwnObservation
            
            vc.observation = own as MainItem
        }
        catch{
            print(error)
            try! sync.fileManager.removeItem(atPath: picturePath)
            try! sync.fileManager.removeItem(atPath: soundPath)
            try! sync.fileManager.removeItem(atPath: videoPath)
            XCTFail()
        }
        
        let obs = vc.observation as! OwnObservation
        
        obs.uploaded = false
        
        vc.deleteObservation()
        
        let deleteExpectation = expectation(description: "Wait for local delete")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4){
            deleteExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        do{
            let result = try managedContext.fetch(fetchRequest)
            
            let data = result as! [NSManagedObject]
            
            XCTAssert(data.isEmpty)
        }
        catch{
            print(error)
            try! sync.fileManager.removeItem(atPath: picturePath)
            try! sync.fileManager.removeItem(atPath: soundPath)
            try! sync.fileManager.removeItem(atPath: videoPath)
            XCTFail()
        }
        
        do {
            try sync.auth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }

    
    
    func testSyncToFirebaseAndDelete(){
        
        
        var sync = SyncObservations()
        
        sync.observationRef = sync.db.collection("test")
        
        sync.pictureRef = sync.storage.child("test").child("picture")
        
        sync.soundRef = sync.storage.child("test").child("sound")
        
        sync.videoRef = sync.storage.child("test").child("video")
        
        sync.uid = "test"
        
        let loginExpectation = expectation(description: "Wait for login")
        
        sync.auth.signIn(withEmail: "stagelife2@hotmail.com", password: "password") {  user, error in
            XCTAssert(user != nil)
            loginExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        
        sync.sync()
        
        let documentsPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
        
        let picturePath = documentsPath.appendingPathComponent("zmezAIVVMxkxvAvgUqDL.jpeg")
        
        let soundPath = documentsPath.appendingPathComponent("zmezAIVVMxkxvAvgUqDL.m4a")
        
        let videoPath = documentsPath.appendingPathComponent("zmezAIVVMxkxvAvgUqDL.mp4")
        
        let fileExpectation = expectation(description: "wait for files to be saved locally")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6){
            fileExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 7, handler: nil)
        
        XCTAssert(sync.fileManager.fileExists(atPath: picturePath) && sync.fileManager.fileExists(atPath: soundPath) && sync.fileManager.fileExists(atPath: videoPath))
        
        let managedContext = sync.appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OwnObservation")
        
        do{
            let result = try managedContext.fetch(fetchRequest)
            
            let data = result as! [NSManagedObject]
            
            XCTAssert(!data.isEmpty)
        }
        catch{
            print(error)
            
            try! sync.fileManager.removeItem(atPath: picturePath)
            try! sync.fileManager.removeItem(atPath: soundPath)
            try! sync.fileManager.removeItem(atPath: videoPath)
            XCTFail()
        }
        
        
       
        
        do{
            let result = try managedContext.fetch(fetchRequest)
            
            let updateData = result as! [NSManagedObject]
            updateData[0].setValue(false, forKey: "uploaded")
            
        }
        catch{
            print(error)
            XCTFail()
        }
        
        sync.observationRef = sync.db.collection("syncTest")
        
        sync.pictureRef = sync.storage.child("syncTest").child("picture")
        
        sync.soundRef = sync.storage.child("syncTest").child("sound")
        
        sync.videoRef = sync.storage.child("syncTest").child("video")
        
        sync.sync()
        
        let documentExp = expectation(description: "check that doc was uploaded")
        let pictureExp = expectation(description: "check that picture was uploaded")
        let soundExp = expectation(description: "check that sound was uploaded")
        let videoExp = expectation(description: "check that video was uploaded")
        
        sync.observationRef.document("zmezAIVVMxkxvAvgUqDL").getDocument(){
            (document, err) in if let err = err {
                print(err)
           XCTFail()
            }
            else{
                if document != nil{
               documentExp.fulfill()
                }
            }
        }
        
        sync.pictureRef.child("zmezAIVVMxkxvAvgUqDL.jpeg").downloadURL(){ (url, error) in
            if let err = error {
                print(err)
                XCTFail()
            }
            else{
                if url != nil {
                pictureExp.fulfill()
                }
            }
        }
        
        sync.pictureRef.child("zmezAIVVMxkxvAvgUqDL.m4a").downloadURL(){ (url, error) in
            if let err = error {
                print(err)
                XCTFail()
            }
            else{
                if url != nil {
                    soundExp.fulfill()
                }
            }
        }
        
        sync.pictureRef.child("zmezAIVVMxkxvAvgUqDL.mp4").downloadURL(){ (url, error) in
            if let err = error {
                print(err)
                XCTFail()
            }
            else{
                if url != nil {
                    videoExp.fulfill()
                }
            }
        }
        
        
        waitForExpectations(timeout: 10, handler: nil)
        
        
    }
    
    

}
