//
//  LoginViewController.swift
//  Hoot
//
//  Created by Kristian Helenius on 31/08/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI


class LoginViewController: UIViewController, FUIAuthDelegate {

    
    @IBOutlet weak var loginButton: UIButton!
    
    lazy var db = Firestore.firestore()
    lazy var uid = Auth.auth().currentUser!.uid
    
    let notice = Notice()
    
    unowned let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

      setupLayout()
        
        
    }
    
    
    
    func setupLayout(){
        
        loginButton.setTitle(NSLocalizedString("Login / Register", comment: ""), for: .normal)
        loginButton.layer.cornerRadius = 21
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.blue.cgColor, UIColor(red:0.00, green:0.47, blue:1.00, alpha:1.0).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: loginButton.intrinsicContentSize.width, height: loginButton.intrinsicContentSize.height)
        
        gradientLayer.cornerRadius = 21
        loginButton.layer.addSublayer(gradientLayer)
    }
   
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if appDelegate.connected == false {
            
            present(notice.networkAlert, animated: true, completion: nil)
            
        }
            
        else {
            
            weak var authUI = FUIAuth.defaultAuthUI()
            weak var authViewController = authUI?.authViewController()
            authUI?.delegate = self
            
            present(authViewController!, animated: true, completion: nil)
            
        }
        
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        
        guard authDataResult != nil else { return }
        
        appDelegate.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainNavigationController")
        
        self.dismiss(animated: false, completion: nil)
        
    }
    
    
}
