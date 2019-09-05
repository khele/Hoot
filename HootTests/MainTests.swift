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
        
       
            
            
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
            
            vc.uid = "test"
            
            let _ = vc.view
            
            vc.setupUserDefaults()
            
            XCTAssert(UserDefaults.standard.object(forKey: "sort") == nil)
            
            UserDefaults.standard.set("testSort", forKey: "sort")
            
            UserDefaults.standard.removeObject(forKey: "uid")
            
            vc.setupUserDefaults()
            
            XCTAssert(UserDefaults.standard.object(forKey: "sort") == nil)
            
            UserDefaults.standard.set("testSort", forKey: "sort")
            
            vc.setupUserDefaults()
            
            XCTAssert(vc.selectedSort == "testSort" && vc.selectedSortTemp == "testSort" && vc.sortTextField.text == "testSort")
            
            UserDefaults.standard.removeObject(forKey: "uid")
            UserDefaults.standard.removeObject(forKey: "sort")
            
        
        
    }
    
    func testGetOwnObs(){
        
        
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
        
        vc.uid = "test"
        
        let _ = vc.view
        
        let managedContext = vc.appDelegate.persistentContainer.viewContext
        
        vc.getOwnObservations()
        
        
        XCTAssert(vc.ownItemSet.count == 0)
        
        
        let observationEntity = NSEntityDescription.entity(forEntityName: "OwnObservation", in: managedContext)
        
        let observation = NSManagedObject(entity: observationEntity!, insertInto: managedContext)
        
        observation.setValuesForKeys(["species": "testspecies", "rarity": "Common", "rarityNumber": 1, "notes": "testnotes", "created": Int(Date().timeIntervalSince1970), "id": "testid", "uid": "test", "dname": "testname", "uploaded": false, "uploading": false, "pictureUrl": "", "soundUrl": "", "videoUrl": "", "lat": 12.1, "long": 12.2])
        
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Error occurred: \(error)")
        }
        
        vc.getOwnObservations()
        print(vc.ownItemSet.count)
        
        let e = expectation(description: "wait for core data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            e.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssert(vc.ownItemSet.count == 1)
        
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
        
        
        
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
        
        let loginExpectation = expectation(description: "Wait for login")
        
        vc.auth.signIn(withEmail: "stagelife2@hotmail.com", password: "password") {  user, error in
            
            XCTAssert(user != nil)
            
            loginExpectation.fulfill()
            
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        
        vc.uid = "testOther"
        
        vc.observationsRef = vc.db.collection("test")
        
        let _ = vc.view
        
        
        let docExpectation = expectation(description: "Wait for doc download")
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            docExpectation.fulfill()
        }
        
        vc.getWorldObservations()
        
        
        self.waitForExpectations(timeout: 2, handler: nil)
        XCTAssert(vc.worldItemSet.count > 0)
        
        let anotherDocexpectation = expectation(description: "Wait for doc download")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            anotherDocexpectation.fulfill()
        }
        
        vc.getOwnObservations()
        
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssert(vc.worldItemSet.count == 1)
        
        
        do {
            try vc.auth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
}
        


   

}
