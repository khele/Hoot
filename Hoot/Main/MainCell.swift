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
        // imageView.backgroundColor = UIColor.blue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
   /* var borderLine: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }() */
    
    var itemName: UILabel = {
        let itemLabel = UILabel()
        itemLabel.font = .systemFont(ofSize: 21)
        itemLabel.text = "Test text"
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        return itemLabel
    }()
    
    var itemPrice: UILabel = {
        let itemPrice = UILabel()
        itemPrice.font = .systemFont(ofSize: 24)
        itemPrice.text = "€xx"
        itemPrice.textColor = UIColor.darkGray
        itemPrice.translatesAutoresizingMaskIntoConstraints = false
        return itemPrice
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
    
    var offerImage: UIImageView = {
        let offerImage = UIImageView()
        //offerImage.backgroundColor = UIColor.blue
        offerImage.translatesAutoresizingMaskIntoConstraints = false
      //  offerImage.image = #imageLiteral(resourceName: "item")
        return offerImage
    }()
    
    var chatImage: UIImageView = {
        let chatImage = UIImageView()
        //chatImage.backgroundColor = UIColor.blue
        chatImage.translatesAutoresizingMaskIntoConstraints = false
       // chatImage.image = #imageLiteral(resourceName: "chat3")
        chatImage.alpha = 0
        return chatImage
    }()
    
    var offerNumber: UILabel = {
        let offerNumber = UILabel()
        offerNumber.font = .systemFont(ofSize: 21)
        offerNumber.text = "0"
        offerNumber.textColor = UIColor.darkGray
        offerNumber.translatesAutoresizingMaskIntoConstraints = false
        return offerNumber
    }()
    
    var chatNumber: UILabel = {
        let chatNumber = UILabel()
        chatNumber.font = .systemFont(ofSize: 19)
        chatNumber.text = "0"
        chatNumber.textColor = UIColor.darkGray
        chatNumber.translatesAutoresizingMaskIntoConstraints = false
        chatNumber.alpha = 0
        return chatNumber
    }()
    
    
    func setupViews(){
        
        contentView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 1, alpha: 1)
        
        self.contentView.addSubview(canvasView)
        self.contentView.addSubview(itemView)
        self.contentView.addSubview(itemName)
        self.contentView.addSubview(itemPrice)
        self.contentView.addSubview(offerImage)
        self.contentView.addSubview(chatImage)
        self.contentView.addSubview(offerNumber)
        self.contentView.addSubview(chatNumber)
        
        
        canvasView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        canvasView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        canvasView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9).isActive = true
        canvasView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1).isActive = true
        
        itemView.topAnchor.constraint(equalTo: canvasView.topAnchor).isActive = true
        itemView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        itemView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9).isActive = true
        itemView.heightAnchor.constraint(equalTo: itemView.widthAnchor, multiplier: 1).isActive = true
        
        itemName.topAnchor.constraint(equalTo: itemView.bottomAnchor, constant: 5).isActive = true
        itemName.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        itemName.textAlignment = .left
        
        itemPrice.bottomAnchor.constraint(equalTo: offerNumber.bottomAnchor, constant: 2).isActive = true
        itemPrice.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor, constant: -8).isActive = true
        
        
        offerImage.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor, constant: -5).isActive = true
        offerImage.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor, constant: 16).isActive = true
        offerImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.09).isActive = true
        offerImage.heightAnchor.constraint(equalTo: offerImage.widthAnchor, multiplier: 1).isActive = true
        
        offerNumber.leadingAnchor.constraint(equalTo: offerImage.trailingAnchor, constant: 6).isActive = true
        offerNumber.bottomAnchor.constraint(equalTo: offerImage.bottomAnchor).isActive = true
        
        
        chatImage.topAnchor.constraint(equalTo: offerImage.topAnchor).isActive = true
        chatImage.leadingAnchor.constraint(equalTo: offerNumber.trailingAnchor, constant: 8).isActive = true
        chatImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.07).isActive = true
        chatImage.heightAnchor.constraint(equalTo: offerImage.widthAnchor, multiplier: 1).isActive = true
        
        chatNumber.leadingAnchor.constraint(equalTo: chatImage.trailingAnchor, constant: 6).isActive = true
        chatNumber.bottomAnchor.constraint(equalTo: offerImage.bottomAnchor).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
