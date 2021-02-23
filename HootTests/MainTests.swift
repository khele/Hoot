//
//  MainTests.swift
//  HootTests
//
//  Created by Kristian Helenius on 05/09/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import XCTest
import Firebase
import CoreData

@testable import Hoot
class MainTests: XCTestCase {

   

    
    func testSetupUserDefaults(){
        
       
            
            
            let vm = MainViewModel()
            
            vm.uid = "test"
            
            vm.setupUserDefaults()
            
            XCTAssert(UserDefaults.standard.object(forKey: "sort") == nil)
            
            UserDefaults.standard.set("testSort", forKey: "sort")
            
            UserDefaults.standard.removeObject(forKey: "uid")
            
            vm.setupUserDefaults()
            
            XCTAssert(UserDefaults.standard.object(forKey: "sort") == nil)
            
            UserDefaults.standard.set("testSort", forKey: "sort")
            
            vm.setupUserDefaults()
            
            XCTAssert(vm.selectedSort == "testSort" && vm.selectedSortTemp == "testSort")
            
            UserDefaults.standard.removeObject(forKey: "uid")
            UserDefaults.standard.removeObject(forKey: "sort")
            
        
        
    }
    
    func testGetOwnObs(){
        
        
        let vm = MainViewModel()
        
        vm.uid = "test"
        
        let managedContext = vm.appDelegate.persistentContainer.viewContext
        
        vm.getOwnObservations()
        
        
        XCTAssert(vm.ownItemSet.count == 0)
        
        
        let observationEntity = NSEntityDescription.entity(forEntityName: "OwnObservation", in: managedContext)
        
        let observation = NSManagedObject(entity: observationEntity!, insertInto: managedContext)
        
        observation.setValuesForKeys(["species": "testspecies", "rarity": "Common", "rarityNumber": 1, "notes": "testnotes", "created": Int(Date().timeIntervalSince1970), "id": "testid", "uid": "test", "dname": "testname", "uploaded": false, "uploading": false, "pictureUrl": "", "soundUrl": "", "videoUrl": "", "lat": 12.1, "long": 12.2])
        
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Error occurred: \(error)")
        }
        
        vm.getOwnObservations()
        print(vm.ownItemSet.count)
        
        let e = expectation(description: "wait for core data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            e.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssert(vm.ownItemSet.count == 1)
        
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
        
        
        
    }
    

    func testGetWorldObs() {
        
        
        
        let vm = MainViewModel()
        
        let loginExpectation = expectation(description: "Wait for login")
        
        vm.auth.signIn(withEmail: "stagelife2@hotmail.com", password: "password") {  user, error in
            
            XCTAssert(user != nil)
            
            loginExpectation.fulfill()
            
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        
        vm.uid = "testOther"
        
        vm.observationsRef = vm.db.collection("test")
        
        let docExpectation = expectation(description: "Wait for doc download")
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            docExpectation.fulfill()
        }
        
        vm.getWorldObservations()
        
        
        self.waitForExpectations(timeout: 2, handler: nil)
        XCTAssert(vm.worldItemSet.count > 0)
        
        let anotherDocexpectation = expectation(description: "Wait for doc download")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            anotherDocexpectation.fulfill()
        }
        
        vm.getOwnObservations()
        
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssert(vm.worldItemSet.count == 1)
        
        
        do {
            try vm.auth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
}
        


   

}
