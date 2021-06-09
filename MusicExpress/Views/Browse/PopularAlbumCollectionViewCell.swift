//
//  PopularAlbumCollectionViewCell.swift
//  MusicExpress
//
//  Created by Антон Шарин on 11.05.2021.
//

import UIKit

class PopularAlbumCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PopularAlbumCollectionViewCell"
    
    
    private let albumImage: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    
    private let artistNameLabel : UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .light)
        
        return label
    }()
    
    private let albumNameLabel : UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 23, weight: .bold)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(albumImage)

        
        // contentView.addSubview(ArtistNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        albumNameLabel.sizeToFit()
        artistNameLabel.sizeToFit()

        
        
        albumImage.frame = CGRect(x: 0, y: 0, width: contentView.width, height: contentView.width)
        artistNameLabel.frame = CGRect(x: 40, y: 5, width: artistNameLabel.width, height: 20)
        albumNameLabel.frame = CGRect(x: 40, y: 20, width: albumNameLabel.width, height: 20)
        
        
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumNameLabel.text = nil
        artistNameLabel.text = nil
        albumImage.image = nil
    }
    
    
    
    
    func configure(with viewmodel: RecomendedAlbumCellViewModel)  {
        
        artistNameLabel.text = viewmodel.title
        albumNameLabel.text = viewmodel.artist
        

        guard let url = URL(string: "https://musicexpress.sarafa2n.ru" + viewmodel.poster) else {
            return
        }
        
        albumImage.sd_setImage(with: url, completed: nil)
        
    }
    
}

