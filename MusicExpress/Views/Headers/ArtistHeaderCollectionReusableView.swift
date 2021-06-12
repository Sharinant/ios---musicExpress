//
//  ArtistHeaderCollectionReusableView.swift
//  MusicExpress
//
//  Created by Антон Шарин on 20.05.2021.
//

import UIKit
import SDWebImage


protocol ArtistHeaderCollectionReusableViewDelegate : AnyObject {
    func didTapPlayAllArtist(_ header : ArtistHeaderCollectionReusableView)
    func didTapShuffleArtist()
}

final class ArtistHeaderCollectionReusableView: UICollectionReusableView {
    
    static let identifier = "ArtistHeaderCollectionReusableView"
        
     weak var delegate : ArtistHeaderCollectionReusableViewDelegate?

    
    private let atristNameLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 35, weight: .semibold)
        label.textColor = .systemPink
        return label
        
        
    }()
    
    
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
        
        
    }()
    
    private let artistImage : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    private let artistAvatar : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    private let artistPlayAllButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemRed
        button.setImage(UIImage(systemName:"play.fill"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        
        return button
    }()
    
    private let shuffleAllButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemRed
        button.setImage(UIImage(systemName:"shuffle"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        
        return button
    }()
    
    
    // INIT
    
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        
        addSubview(artistImage)
        addSubview(artistAvatar)
        addSubview(descriptionLabel)
        addSubview(atristNameLabel)
        addSubview(artistPlayAllButton)
        addSubview(shuffleAllButton)
        artistPlayAllButton.addTarget(self, action: #selector(didTapPlayAllArtist), for: .touchUpInside)
        shuffleAllButton.addTarget(self, action: #selector(didTapShuffleAllButton), for: .touchUpInside)

    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func didTapPlayAllArtist () {
        //
        delegate?.didTapPlayAllArtist(self)
    }
    
    @objc private func didTapShuffleAllButton () {
        delegate?.didTapShuffleArtist()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       // let imageSize:CGFloat = height/1.7
        artistImage.frame = CGRect(x: 0, y: 0, width: width, height: 400)
        
        atristNameLabel.frame = CGRect(x: 10, y: artistImage.bottom + 15, width: width - 20, height: 44)
    //    artistAvatar.frame = CGRect(x: 10, y: atristNameLabel.bottom - 15, width: width - 20, height: 44)
        descriptionLabel.textAlignment = .natural
        descriptionLabel.frame = CGRect(x: 10, y: atristNameLabel.bottom + 5, width: width - 20, height: 120)
        artistPlayAllButton.frame = CGRect(x: width - 70, y: artistImage.bottom - 70, width: 50, height: 50)
        shuffleAllButton.frame = CGRect(x: left + 20, y: artistImage.bottom - 70, width: 50, height: 50)
    }
    
    func configure(with viewModel:ArtistHeaderCellViewModel) {
        
        atristNameLabel.text = viewModel.artistName
        
        
      APICaller.shared.getDescription(artist_id: viewModel.artist_id ?? 0, completion: { result in
             DispatchQueue.main.async {
                                                                        switch result{
                                                                        
                                                                        case .success(let Gotdescription):
                                                                            self.descriptionLabel.text = Gotdescription.description
                                                                            
                                                                             
                                                                           
                                                                        case.failure(let error):
                                                                            print("failed to get descriptionText", error)
                                                                            break
                                                                        }
                                                                }            }
        )
        atristNameLabel.text = viewModel.artistName
        
        guard let urlImage = URL(string: "https://musicexpress.sarafa2n.ru" + viewModel.poster) else {
            return
        }
        
        artistImage.sd_setImage(with: urlImage, completed: nil)
        
        guard let urlAvatar = URL(string: "https://musicexpress.sarafa2n.ru" + viewModel.avatar) else {
            return
        }
        
        artistAvatar.sd_setImage(with: urlAvatar, completed: nil)

        
        
    }
    
}
