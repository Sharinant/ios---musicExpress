//
//  SearchResultViewController.swift
//  MusicExpress
//
//  Created by Лексус on 21.04.2021.
//

import UIKit
import SDWebImage

struct SearchSection {
    let title: String
    let results: [Song]
}


protocol SearchResultViewControllerDelegate: AnyObject {
    func showResult(_ controller: UIViewController)
}

class SearchResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: SearchResultViewControllerDelegate?
    private var sections: [SearchSection] = []
    
    private let tableView : UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.register(SearchResultCollectionViewCell.self,
                           forCellReuseIdentifier: SearchResultCollectionViewCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = true
        return tableView
    }()
    
    private let showEmptyLabel : UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено("
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }()
    
    private let showEmptyImage : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "NoFoundItems.png")
        imageView.isHidden = true
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
      
        view.addSubview(showEmptyLabel)
        view.addSubview(showEmptyImage)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        showEmptyImage.frame = CGRect(x: 50, y: 200, width: 250, height: 200)
        showEmptyLabel.frame = CGRect(x: 0, y: showEmptyImage.bottom + 15, width: view.width, height: 15)
    }
    
    func update(with results: SearchReslutResponse) {
        
        showEmptyImage.isHidden = true
        showEmptyLabel.isHidden = true
        
        self.sections.removeAll()
        if let artists = results.artists {
            self.sections.append(SearchSection(title: "Artists", results: artists))
        }
        if let albums = results.albums {
            self.sections.append(SearchSection(title: "Albums", results: albums))
        }
        if let tracks = results.tracks {
            self.sections.append(SearchSection(title: "Tracks", results: tracks))
        }

        tableView.reloadData()
        tableView.isHidden = sections.isEmpty
    }
    
    func noResults()  {
        
        tableView.isHidden = true
        showEmptyImage.isHidden = false
        showEmptyLabel.isHidden = false
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.sections[indexPath.section]
        let result = section.results[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchResultCollectionViewCell.identifier,
            for: indexPath
        ) as? SearchResultCollectionViewCell else {
            return UITableViewCell()
        }
        
        var viewModel = SearchResultDefaultTableVeiewCellViewModel(
            title: "",
            imageUrl: "",
            artist: ""
        )

        if section.title == "Artists" {
            viewModel = SearchResultDefaultTableVeiewCellViewModel(
                title: result.name ?? "",
                imageUrl: result.poster ?? "",
                artist: ""
            )
        } else if section.title == "Albums" {
            viewModel = SearchResultDefaultTableVeiewCellViewModel(
                title: result.title ?? "",
                imageUrl: result.poster ?? "",
                artist: result.artist_name ?? ""
            )
        } else if section.title == "Tracks" {
            viewModel = SearchResultDefaultTableVeiewCellViewModel(
                title: result.title ?? "",
                imageUrl: result.album_poster ?? "",
                artist: result.artist ?? ""
            )
        }
        
        cell.configure(width: viewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        HapticsManager.shared.vibrateForSelection()

        let section = self.sections[indexPath.section]
        let result = section.results[indexPath.row]
        
        switch section.title {
        
        case "Artists":
            let artist = result
            let vc = ArtistViewController(artist: artist)
            vc.title = artist.name
            vc.navigationItem.largeTitleDisplayMode = .never
            delegate?.showResult(vc)
            break
            
        case "Albums":
            let album = result
            let vc = AlbumViewController(album: album)
            vc.title = album.title
            delegate?.showResult(vc)
            vc.navigationItem.largeTitleDisplayMode = .never
            break
        case "Tracks":
            
            PlayBackPresenter.shared.playSongBySong(from: self, songs: section.results, currentItemIndex: indexPath.row)
            
            break
        default:
            break

        }
    }
}

