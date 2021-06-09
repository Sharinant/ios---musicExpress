//
//  TeamNameCollectionViewCell.swift
//  MusicExpress
//
//  Created by Антон Шарин on 11.05.2021.
//

import UIKit

class TeamNameCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TeamNameCollectionViewCell"
    
      let teamNameLabel : UILabel = {
        let label = UILabel()
        label.text = "Project MusicExpress by @CodeExpress for Technopark Mail.ru"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 10, weight: .light)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(teamNameLabel)

        
        // contentView.addSubview(ArtistNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
            //   teamNameLabel.frame = CGRect(x: 4  , y: 4, width: teamNameLabel.width, height: 40)
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    
}
