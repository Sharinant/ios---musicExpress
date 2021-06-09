//
//  NewSongsCVCell.swift
//  MusicExpress
//
//  Created by Антон Шарин on 08.05.2021.
//

import UIKit

class NewSongsCVCell: UICollectionViewCell {
    static let identifier = "NewSongsCVCell"
    
    private let durationLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 13,weight: .bold)
        label.numberOfLines = 1

        return label
    }()
    
    private let artistLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 11,weight: .bold)
        label.numberOfLines = 1
        
        return label
    }()
    
    private let trackNameLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private let trackImage : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleToFill

        return imageView
    }()
    
    private let likeButton : UIButton = {
        let button = UIButton()
        
        return button
    }()
    
    private let plusButton : UIButton = {
        let button = UIButton()
        
        return button
    }()
    
    private var isLiked : Bool = false
    private var isPlus : Bool = false
    private var trackNumber : Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(durationLabel)
        contentView.addSubview(trackImage)
     //   contentView.addSubview(likeButton)
        contentView.addSubview(plusButton)
        
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(didTapPlus), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        trackNameLabel.sizeToFit()
        artistLabel.sizeToFit()
        durationLabel.sizeToFit()
        
        trackImage.frame = CGRect(
            x: 1,
            y: 1 ,
         //   (contentView.bottom+contentView.top)/2 - contentView.height*4/10
            width: contentView.height - 1,
            height: contentView.height - 1
        )

        artistLabel.frame = CGRect(
            x: trackImage.right + 10,
            y: contentView.height/5,
            width: artistLabel.width,
            height: 15
        )

        trackNameLabel.frame = CGRect(
            x: trackImage.right + 10,
            y: artistLabel.bottom + 3,
            width: contentView.width/2,
            height: 17
        )
        
        plusButton.frame = CGRect(
            x: contentView.right - 100,
            y: (contentView.bottom+contentView.top)/2 - 15,
            width: 30,
            height: 30
        )
        
       

        durationLabel.frame = CGRect(
            x: contentView.right - 45,
            y: (contentView.top+contentView.bottom)/2 - 10,
            width: durationLabel.width,
            height: 20
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        artistLabel.text = nil
        durationLabel.text = nil
        trackImage.image = nil
        trackNumber = 0
    }
    
    func configure(with viewmodel: NewSongsCellViewModel)  {
        var timeString = ""
        let secondsMod = viewmodel.duration % 60

        if secondsMod < 10 {
            timeString = "\(viewmodel.duration/60):0\(secondsMod)"
        } else {
            timeString = "\(viewmodel.duration/60):\(viewmodel.duration%60)"
        }

        trackNumber = viewmodel.id
        durationLabel.text = timeString
        trackNameLabel.text = viewmodel.title
        artistLabel.text = viewmodel.artist
        
        isLiked = viewmodel.isLiked
        setUpLikeButton(isLiked_: isLiked)
        
        isPlus = viewmodel.isPlus
        setUpPlusButton(isPlus_: isPlus)
        
        guard let url = URL(string: "https://musicexpress.sarafa2n.ru" + viewmodel.poster) else {
            return
        }
        
        trackImage.sd_setImage(with: url, completed: nil)
    }
    
    @objc func didTapLike() {
        APICaller.shared.postOrDeleteTrackLike(
            trackNumber: self.trackNumber,
            like: isLiked
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    UIView.animate(
                        withDuration: 0.2,
                        animations: {
                            self.likeButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                        },
                        completion: { _ in
                            UIView.animate(withDuration: 0.2) {
                                self.likeButton.transform = CGAffineTransform.identity
                            }
                        }
                    )

                    self.isLiked = !self.isLiked
                    self.setUpLikeButton(isLiked_: self.isLiked)
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            }
        }
    }
    
    @objc func didTapPlus() {
        APICaller.shared.postOrDeleteTrackFavorite(
            trackNumber: self.trackNumber,
            favorite: isPlus
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    UIView.animate(
                        withDuration: 0.2,
                        animations: {
                            self.plusButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                        },
                        completion: { _ in
                            UIView.animate(withDuration: 0.2) {
                                self.plusButton.transform = CGAffineTransform.identity
                            }
                        }
                    )
                    self.isPlus = !self.isPlus
                    self.setUpPlusButton(isPlus_: self.isPlus)
                    NotificationCenter.default.post(name: Notification.Name("reload favorite"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name("reload plus buttons states"), object: nil)

                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            }
        }
    }
    
    private func setUpLikeButton(isLiked_: Bool) {
        let imageName = isLiked_ ? "heart.fill" : "heart"
        let symbolConfig = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        let image = UIImage(systemName: imageName, withConfiguration: symbolConfig)
        self.likeButton.setImage(image, for: .normal)
        self.likeButton.tintColor = .white
    }
    
    private func setUpPlusButton(isPlus_: Bool) {
        let imageName = isPlus_ ? "plus.circle.fill" : "plus.circle"
        let symbolConfig = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        let image = UIImage(systemName: imageName, withConfiguration: symbolConfig)
        self.plusButton.setImage(image, for: .normal)
        self.plusButton.tintColor = .white
    }
}
