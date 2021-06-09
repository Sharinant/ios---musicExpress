//
//  PlayerPresenterViewController.swift
//  MusicExpress
//
//  Created by Антон Шарин on 02.06.2021.
//

import Foundation
import UIKit

protocol buttonClicked : AnyObject {
    func buttonTabBarClicked()
}


 class PlayerPresenter : UIView {
    
    weak var delegate : buttonClicked?
    
    
    let imageViewPoster : UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 10, y: 10, width: 10, height: 10)
        imageView.backgroundColor = .red
        return imageView
    }()
    
    let nameLabel : UILabel = {
        let label = UILabel()
        label.text = "test"
        label.frame = CGRect(x: 22, y: 10, width: 50, height: 10)
        return label
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(buttonShowPlayer)
        buttonShowPlayer.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let buttonShowPlayer : UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 300, y: 100, width: 50, height: 20)
        button.backgroundColor = .blue

        return button
    }()
    
    func configure(name: String, artist: String, image : String) {
        nameLabel.text = name
       print(nameLabel.text)
    }
    
    @objc private func buttonClick () {
        delegate?.buttonTabBarClicked()
        
    }
}

