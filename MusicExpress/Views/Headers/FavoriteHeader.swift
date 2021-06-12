//
//  FavoriteHeader.swift
//  MusicExpress
//
//  Created by Антон Шарин on 10.06.2021.
//

import UIKit


protocol FavoriteHeaderCollectionReusableViewDelegate : AnyObject {
    func didTapPlayAll(_ header : FavoriteHeaderCollectionReusableView)
    func didTapShuffleAll()
}

class FavoriteHeaderCollectionReusableView: UICollectionReusableView {
    
    static let identifier = "FavoriteHeaderCollectionReusableView"
    
    weak var delegate : FavoriteHeaderCollectionReusableViewDelegate?
    
    private let label: UILabel = {
        
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 22, weight: .regular)
        return label
    }()
    
    private let playAllButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemRed
        button.setImage(UIImage(systemName:"play.fill"), for: .normal)
        button.tintColor = .white
        
        button.layer.masksToBounds = true
        
        return button
    }()
    
    private let shuffleAllButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemRed
        button.setImage(UIImage(systemName:"shuffle"), for: .normal)
        button.tintColor = .white
        
        button.layer.masksToBounds = true
        
        return button
    }()
    
  
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(playAllButton)
        addSubview(shuffleAllButton)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 10, y: 0, width: width-20, height: height)
        playAllButton.frame = CGRect(x: right/10, y: height/6.1, width: width/7, height: width/7)
        shuffleAllButton.frame = CGRect(x: right*9/10 - width/7, y: height/6.1, width: width/7, height: width/7)
        playAllButton.layer.cornerRadius = 0.5 * playAllButton.bounds.size.width
        shuffleAllButton.layer.cornerRadius = 0.5 * shuffleAllButton.bounds.size.width
        playAllButton.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside)
        shuffleAllButton.addTarget(self, action: #selector(didTapShuffleAll), for: .touchUpInside)

    }
    
    func configure(with title: String){
        label.text = title
    }
    
    
    @objc private func didTapPlayAll () {
        delegate?.didTapPlayAll(self)
    }
    
    @objc private func didTapShuffleAll () {
        delegate?.didTapShuffleAll()
    }
    
}
