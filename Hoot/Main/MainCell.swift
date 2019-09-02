//
//  MainCell.swift
//  Hoot
//
//  Created by Kristian Helenius on 31/08/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import UIKit

class MainCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    var canvasView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 1, alpha: 1)
        imageView.layer.cornerRadius = 10
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.shadowColor = UIColor.lightGray.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        imageView.layer.shadowOpacity = 0.4
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var itemView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    var species: UILabel = {
        let itemLabel = UILabel()
        itemLabel.font = .systemFont(ofSize: 23)
        itemLabel.text = "Test text"
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        return itemLabel
    }()
    
    var rarity: UILabel = {
        let itemPrice = UILabel()
        itemPrice.font = .systemFont(ofSize: 24)
        itemPrice.text = "€xx"
        itemPrice.textColor = UIColor.darkGray
        itemPrice.translatesAutoresizingMaskIntoConstraints = false
        return itemPrice
    }()
    
    
    var soundImage: UIImageView = {
        let soundImage = UIImageView()
        soundImage.image = #imageLiteral(resourceName: "sound")
        soundImage.translatesAutoresizingMaskIntoConstraints = false
        return soundImage
    }()
    
    var soundIndicatorImage: UIImageView = {
        let soundIndicatorImage = UIImageView()
        soundIndicatorImage.translatesAutoresizingMaskIntoConstraints = false
        return soundIndicatorImage
    }()
    
    var videoImage: UIImageView = {
        let videoImage = UIImageView()
        videoImage.image = #imageLiteral(resourceName: "video")
        videoImage.translatesAutoresizingMaskIntoConstraints = false
        return videoImage
    }()
    
    var videoIndicatorImage: UIImageView = {
        let videoIndicatorImage = UIImageView()
        videoIndicatorImage.translatesAutoresizingMaskIntoConstraints = false
        return videoIndicatorImage
    }()
    
    var notes: UILabel = {
        let notes = UILabel()
        notes.font = .systemFont(ofSize: 21)
        notes.textColor = UIColor.darkGray
        notes.translatesAutoresizingMaskIntoConstraints = false
        return notes
    }()
    
    var locationImage: UIImageView = {
        let locationImage = UIImageView()
        locationImage.image = #imageLiteral(resourceName: "location")
        locationImage.translatesAutoresizingMaskIntoConstraints = false
        return locationImage
    }()
    
    var lat: UILabel = {
        let location = UILabel()
        location.font = .systemFont(ofSize: 19)
        location.textColor = UIColor.darkGray
        location.translatesAutoresizingMaskIntoConstraints = false
        return location
    }()
    
    var long: UILabel = {
        let location = UILabel()
        location.font = .systemFont(ofSize: 19)
        location.textColor = UIColor.darkGray
        location.translatesAutoresizingMaskIntoConstraints = false
        return location
    }()
    
    /* var itemOffers: UIButton = {
     let itemOffers = UIButton()
     itemOffers.setTitle(String("0"), for: .normal)
     itemOffers.backgroundColor = UIColor.green
     itemOffers.titleLabel?.textColor = UIColor.white
     itemOffers.titleLabel?.font = .systemFont(ofSize: 21)
     itemOffers.translatesAutoresizingMaskIntoConstraints = false
     return itemOffers
     }()
     
     var itemSettings: UIButton = {
     let itemSettings = UIButton()
     itemSettings.setTitle("Se", for: .normal)
     itemSettings.backgroundColor = UIColor.green
     itemSettings.titleLabel?.textColor = UIColor.white
     itemSettings.titleLabel?.font = .systemFont(ofSize: 21)
     itemSettings.translatesAutoresizingMaskIntoConstraints = false
     
     return itemSettings
     }() */
    
   
    func setupViews(){
        
        contentView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 1, alpha: 1)
        
        self.contentView.addSubview(canvasView)
        self.contentView.addSubview(itemView)
        self.contentView.addSubview(species)
        self.contentView.addSubview(rarity)
        self.contentView.addSubview(soundImage)
        self.contentView.addSubview(soundIndicatorImage)
        self.contentView.addSubview(videoImage)
        self.contentView.addSubview(videoIndicatorImage)
        self.contentView.addSubview(notes)
        self.contentView.addSubview(lat)
        self.contentView.addSubview(long)
        self.contentView.addSubview(locationImage)
        
        canvasView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        canvasView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        canvasView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9).isActive = true
        canvasView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1).isActive = true
        
        itemView.topAnchor.constraint(equalTo: canvasView.topAnchor).isActive = true
        itemView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        itemView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9).isActive = true
        itemView.heightAnchor.constraint(equalTo: itemView.widthAnchor, multiplier: 1).isActive = true
        
        species.topAnchor.constraint(equalTo: itemView.bottomAnchor, constant: 8).isActive = true
        species.centerXAnchor.constraint(equalTo: canvasView.centerXAnchor).isActive = true
        species.textAlignment = .left
        
        rarity.topAnchor.constraint(equalTo: species.bottomAnchor, constant: 5).isActive = true
        rarity.centerXAnchor.constraint(equalTo: species.centerXAnchor).isActive = true
        
        notes.topAnchor.constraint(equalTo: rarity.bottomAnchor, constant: 10).isActive = true
        notes.centerXAnchor.constraint(equalTo: species.centerXAnchor).isActive = true
        
        soundImage.topAnchor.constraint(equalTo: notes.bottomAnchor, constant: 15).isActive = true
        soundImage.trailingAnchor.constraint(equalTo: soundIndicatorImage.leadingAnchor, constant: -5).isActive = true
        soundImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.09).isActive = true
        soundImage.heightAnchor.constraint(equalTo: soundImage.widthAnchor, multiplier: 1).isActive = true
        
        soundIndicatorImage.topAnchor.constraint(equalTo: soundImage.topAnchor).isActive = true
        soundIndicatorImage.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -10).isActive = true
        soundIndicatorImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.09).isActive = true
        soundIndicatorImage.heightAnchor.constraint(equalTo: soundIndicatorImage.widthAnchor, multiplier: 1).isActive = true
        
        videoImage.topAnchor.constraint(equalTo: notes.bottomAnchor, constant: 15).isActive = true
        videoImage.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 10).isActive = true
        videoImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.09).isActive = true
        videoImage.heightAnchor.constraint(equalTo: videoImage.widthAnchor, multiplier: 1).isActive = true
        
        videoIndicatorImage.topAnchor.constraint(equalTo: videoImage.topAnchor).isActive = true
        videoIndicatorImage.leadingAnchor.constraint(equalTo: videoImage.trailingAnchor, constant: 5).isActive = true
        videoIndicatorImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.09).isActive = true
        videoIndicatorImage.heightAnchor.constraint(equalTo: videoIndicatorImage.widthAnchor, multiplier: 1).isActive = true
        
        locationImage.topAnchor.constraint(equalTo: videoImage.bottomAnchor, constant: 15).isActive = true
        locationImage.centerXAnchor.constraint(equalTo: canvasView.centerXAnchor).isActive = true
        locationImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.09).isActive = true
        locationImage.heightAnchor.constraint(equalTo: locationImage.widthAnchor, multiplier: 1).isActive = true
        
        lat.topAnchor.constraint(equalTo: locationImage.bottomAnchor, constant: 5).isActive = true
        lat.centerXAnchor.constraint(equalTo: locationImage.centerXAnchor).isActive = true
       
        long.topAnchor.constraint(equalTo: lat.bottomAnchor, constant: 2).isActive = true
        long.centerXAnchor.constraint(equalTo: lat.centerXAnchor).isActive = true
        
       
        
        
       
        
       
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
