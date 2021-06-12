//
//  PlaylistCollectionViewCell.swift
//  MusicExpress
//
//  Created by Антон Шарин on 12.06.2021.
//

import UIKit

class PlaylistCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PlaylistCollectionViewCell"
    
    
    private let playlistImage: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "playlist.png")
        imageView.contentMode = .scaleToFill
        return imageView
        
    }()
    
    
    private let playlistName : UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .light)
        
        return label
    }()
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(playlistName)
        contentView.addSubview(playlistImage)

    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playlistName.sizeToFit()
        playlistImage.frame = CGRect(
            x: 1,
            y: 1 ,
         //   (contentView.bottom+contentView.top)/2 - contentView.height*4/10
            width: contentView.height - 1,
            height: contentView.height - 1)
        
        playlistName.frame = CGRect(x: playlistImage.right + 10,
                                    y: contentView.height/2 - 10,
                                    width: playlistName.width,
                                    height: 20)
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistName.text = nil
        playlistImage.image = nil
    }
    
    func configure(with viewmodel: PlaylistCellViewModel)  {
        
        playlistName.text = viewmodel.title
        playlistImage.image = UIImage(named: viewmodel.poster)
        
    }
}
