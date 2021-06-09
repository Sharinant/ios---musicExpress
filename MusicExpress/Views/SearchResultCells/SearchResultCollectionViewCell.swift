//
//  SearchResultCollectionViewCell.swift
//  MusicExpress
//
//  Created by Лексус on 17.05.2021.
//

import UIKit

class SearchResultCollectionViewCell: UITableViewCell {
    static let identifier = "SearchResultDefaultTableViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()
    
    private let secondLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(secondLabel)
        contentView.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.frame = CGRect(x: 10, y: 2.5, width: contentView.height - 5, height: contentView.height - 5)
        iconImageView.layer.cornerRadius = (contentView.height - 5) / 2
        iconImageView.layer.masksToBounds = true
        secondLabel.frame = CGRect(
            x: iconImageView.right + 10,
            y: 17,
            width: contentView.width - iconImageView.right - 15,
            height: contentView.height - 10
        )
        secondLabel.textColor = .gray
        label.frame = CGRect(
            x: iconImageView.right + 10,
            y: 0,
            width: contentView.width - iconImageView.right - 15,
            height: contentView.height - 10
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        secondLabel.text = nil
    }
    
    func configure(width viewModel: SearchResultDefaultTableVeiewCellViewModel) {
        label.text = viewModel.title
        secondLabel.text = viewModel.artist
        //print(viewModel.artist)
        
            guard let url = URL(string: "https://musicexpress.sarafa2n.ru" + viewModel.imageUrl) else {
                return
            }
            
            iconImageView.sd_setImage(with: url, completed: nil)
        
    }
}
