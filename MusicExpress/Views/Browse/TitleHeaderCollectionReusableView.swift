//
//  TitleHeaderCollectionReusableView.swift
//  MusicExpress
//
//  Created by Антон Шарин on 08.05.2021.
//

import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView {
    
    static let identifier = "TitleHeaderCollectionReusableView"
    
    private let label: UILabel = {
        
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 22, weight: .regular)
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(label)
       // addSubview(button)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 10, y: 0, width: width-20, height: height)
        button.frame = CGRect(x: 40, y: 0, width: 10, height: 10)
    }
    
    func configure(with title: String){
        label.text = title
    }
}
