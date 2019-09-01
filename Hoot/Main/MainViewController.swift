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


class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
   
    
    @IBOutlet var canvasView: UIView!
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var ownSwitch: UISwitch!
    
    @IBOutlet weak var switchLabel: UILabel!
    
    @IBOutlet weak var offlineLabel: UILabel!
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
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
        
        
    }

    
    func setupLayout(){
        
        canvasView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 1, alpha: 1)
        mainCollectionView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 1, alpha: 1)
        
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
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "main", for: indexPath)
        
        return cell
        
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}
