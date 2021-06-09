//
//  AlbumViewController.swift
//  MusicExpress
//
//  Created by Антон Шарин on 13.05.2021.
//

import UIKit
import SDWebImage

class AlbumViewController: UIViewController {
    
    private var currentArtistId: Int?
    private let album: Song?
    private var descriptionText: Song?
    
    private let collectionViewSongs = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(
            sectionProvider: {
                _,_ -> NSCollectionLayoutSection?  in
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(8)
                    )
                )
                                                    
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 1, bottom: 2, trailing: 1)

                let firstGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(60)
                    ),
                    subitem: item,
                    count: 1
                )
                                                    
                let section = NSCollectionLayoutSection(group: firstGroup)
                                                  
                section.boundarySupplementaryItems = [
                    NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalWidth(1.7)
                        ),
                        elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .top
                    )
                ]
        
                return section
            }
        )
    )
    
    init(album: Song?) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private var viewModels = [TopSongsCellViewModel]()
    private var tracks = [Track]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = album?.title
        view.backgroundColor = .systemBackground
        view.addSubview(collectionViewSongs)

        collectionViewSongs.register(
            TopTracksCollectionViewCell.self,
            forCellWithReuseIdentifier: TopTracksCollectionViewCell.identifier
        )
        collectionViewSongs.register(
            AlbumHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: AlbumHeaderCollectionReusableView.identifier
        )
        collectionViewSongs.backgroundColor = .systemBackground
        collectionViewSongs.delegate = self
        collectionViewSongs.dataSource = self
        
        
        APICaller.shared.getAlbumDetails(
            for: album
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let model):
                    
                    self?.currentArtistId = model.artist_id ?? 0
                    self?.tracks = model.tracks?.compactMap({
                        return Track(album_id: 0,
                                     album_poster: $0.album_poster ?? "",
                                     artist: $0.artist ?? "",
                                     artist_id: $0.artist_id ?? 0,
                                     audio: $0.audio ?? "",
                                     duration: $0.duration ?? 0,
                                     id: 0,
                                     index: 0,
                                     is_favorite: $0.is_favorite ?? nil,
                                     is_liked: $0.is_liked ?? nil,
                                     title: $0.title ?? "")
                    }) ?? [Track]()
                    
        //            self?.tracks = model.tracks ?? []
                    
                    self?.viewModels = model.tracks?.compactMap({
                        return TopSongsCellViewModel(
                            id: $0.id ?? 0,
                            title: $0.title ?? "",
                            duration: $0.duration ?? 0,
                            artist: $0.artist ?? "",
                            album_poster: $0.album_poster ?? "",
                            artist_id: $0.artist_id ?? 0,
                            isLiked: $0.is_liked ?? false,
                            isPlus:$0.is_favorite ?? false,
                            audio: $0.audio ?? ""
                        )
                    }) ?? [TopSongsCellViewModel]()
                    
                    
                    APICaller.shared.getDescription(
                        artist_id: self?.currentArtistId ?? 0
                    ) { [weak self] result in
                        DispatchQueue.main.async {
                            switch result{
                            case .success(let Gotdescription):
                                self?.descriptionText = Gotdescription
                                break
                            case.failure(let error):
                                print("failed to get descriptionText", error)
                                break
                            }
                        }
                    }
                    self?.collectionViewSongs.reloadData()
                case.failure(let error):
                    print("failed to get album details", error)
                    break
                }
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(didTapShare)
        )
        UITabBar.appearance().tintColor = .systemPink
    }

    @objc private func didTapShare () {
        print("current album share")
        let vc = UIActivityViewController(
            activityItems: ["Foo"],
            applicationActivities: []
        )
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionViewSongs.frame = view.bounds
    }
}


extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TopTracksCollectionViewCell.identifier,
            for: indexPath
        ) as? TopTracksCollectionViewCell else {
            return UICollectionViewCell ()
        }
        
        cell.configure(with: viewModels[indexPath.row])
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: AlbumHeaderCollectionReusableView.identifier,
            for: indexPath
        ) as? AlbumHeaderCollectionReusableView
            , kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let headerViewModel = AlbumHeaderCellViewModel(
            albumName: album?.title ?? "",
            artistName: album?.artist_name ?? "",
            poster: album?.poster ?? "",
            description:  descriptionText?.description ?? "",
            artist_id: album?.artist_id ?? 0
        )
        header.configure(with: headerViewModel)
        header.delegate = self
        return header
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // play song
       // let index = indexPath.row
       // let track = tracks[index]
     //   PlayBackPresenter.shared.startPlaybackWithTrack(from: self, track: track)
        PlayBackPresenter.shared.playSongByTrack(from: self, tracks: tracks, currentItemIndex: indexPath.row)
        
    }
}

extension AlbumViewController: AlbumHeaderCollectionReusableViewDelegate {
    func albumHeaderCollectionReusableViewDidTapPlayAll(_ header: AlbumHeaderCollectionReusableView) {
        print("Playing all")
        PlayBackPresenter.shared.playSongByTrack(from: self, tracks: tracks, currentItemIndex: 0)
    }
}
