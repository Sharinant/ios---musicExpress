//
//  RecommendedAlbumsCollectionViewCell.swift
//  MusicExpress
//
//  Created by Антон Шарин on 23.04.2021.
//

import UIKit


//"title": "Collection remixed",
//    "artist_id": 5,
//    "artist_name": "Apocalyptica",
//    "poster": "./album_posters/44f5aced35a6ef43a24c58bfde47dd1c.jpeg",
class RecommendedAlbumsCollectionViewCell: UICollectionViewCell {
    static let identifier = "RecommendedAlbumsCollectionViewCell"
    
    
    private let albumCoverImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let albumNameLabel : UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .heavy)
        label.numberOfLines = 0
        
        return label
    }()
    private let ArtistNameLabel : UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .ultraLight)
        label.numberOfLines = 0
        return label
    }()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(albumCoverImage)
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(ArtistNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        albumNameLabel.sizeToFit()
        ArtistNameLabel.sizeToFit()
        
        albumCoverImage.frame = CGRect(x: 0, y: 0, width: contentView.width , height: contentView.width)
        
        albumNameLabel.frame = CGRect(x: albumCoverImage.left + 5,
                                      y:albumCoverImage.bottom + ((contentView.bottom - albumCoverImage.bottom)/8),
                                      width: contentView.width,
                                      height: 18)
        albumNameLabel.textAlignment = .left
        
        ArtistNameLabel.frame = CGRect(x: albumCoverImage.left + 5,
                                       y: albumNameLabel.bottom + ((contentView.bottom - albumNameLabel.bottom)/8),
                                      width: contentView.width,
                                      height: 18)
        ArtistNameLabel.textAlignment = .left
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ArtistNameLabel.text = nil
        albumNameLabel.text = nil
        albumCoverImage.image = nil
    }

    
    func configure(with viewmodel: AlbumCellViewModel)  {
        ArtistNameLabel.text = viewmodel.artistName
        albumNameLabel.text = viewmodel.title
        
        guard let url = URL(string: "https://musicexpress.sarafa2n.ru" + viewmodel.poster) else {
            return
        }
        
        albumCoverImage.sd_setImage(with: url, completed: nil)
        
      //  do {
    //        if let image = try APICaller.shared.getAlbumImage(path: viewmodel.poster) {
    //            albumCoverImage.image = UIImage(data: image)!
    //            return
   //         }
   //     } catch {}
        
        // Set default image
    }
    
}
