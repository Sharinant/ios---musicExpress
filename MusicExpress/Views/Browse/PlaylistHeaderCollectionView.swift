//
//  PlaylistHeaderCollectionView.swift
//  MusicExpress
//
//  Created by Лексус on 31.05.2021.
//
import UIKit
import SDWebImage

protocol PlaylistHeaderCollectionViewDelegate : AnyObject {
    func albumHeaderCollectionReusableViewDidTapPlayAll(_ header : PlaylistHeaderCollectionView)
}

final class PlaylistHeaderCollectionView: UICollectionReusableView {
    static let identifier = "PlaylistHeaderCollectionView"

    weak var delegate : PlaylistHeaderCollectionViewDelegate?

    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)

        return label
    }()

    private let albumImage : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "photo")

        return imageView
    }()

    private let playAllButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemRed
        button.setImage(UIImage(systemName:"play.fill"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true

        return button
    }()

    override init(frame: CGRect) {
        super .init(frame: frame)

        addSubview(albumImage)
        addSubview(albumNameLabel)
        addSubview(playAllButton)

        playAllButton.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc private func didTapPlayAll () {
        delegate?.albumHeaderCollectionReusableViewDidTapPlayAll(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize:CGFloat = height

        albumImage.frame = CGRect(x: (width - imageSize)/2, y: 10, width: imageSize, height: imageSize)
        albumNameLabel.frame = CGRect(x: 10, y: albumImage.bottom - 110, width: width - 20, height: 44)
        playAllButton.frame = CGRect(x: width - 70, y: albumImage.bottom - 110, width: 50, height: 50)
    }

    func configure(with viewModel: PlaylistHeaderCellViewModel) {
        albumNameLabel.text = viewModel.name

        guard let url = URL(string: "https://musicexpress.sarafa2n.ru" + viewModel.poster) else {
            return
        }

        albumImage.sd_setImage(with: url, completed: nil)
    }
}
