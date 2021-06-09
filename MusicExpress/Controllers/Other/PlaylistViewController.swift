//
//  PlaylistViewController.swift
//  MusicExpress
//
//  Created by Лексус on 21.04.2021.
//

import UIKit
import SDWebImage

class PlaylistViewController: UIViewController {
    
    private var currentArtistId: Int?
    private let album: Song?
    private var descriptionText: Song?
    private var viewModels = [TopSongsCellViewModel]()
    private var tracks = [Track]()
    
    private let collectionViewSongs = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(
            sectionProvider: {
                _,_ -> NSCollectionLayoutSection?  in
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0)
                    )
                )
                                                    
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

                let firstGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(80)
                    ),
                    subitem: item,
                    count: 1
                )
                                                    
                let section = NSCollectionLayoutSection(group: firstGroup)
                                                  
                section.boundarySupplementaryItems = [
                    NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalWidth(0.9)
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
            PlaylistHeaderCollectionView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PlaylistHeaderCollectionView.identifier
        )
        collectionViewSongs.backgroundColor = .systemBackground
        collectionViewSongs.delegate = self
        collectionViewSongs.dataSource = self
        
        APICaller.shared.getPlaylist(
            number: album?.id ?? 0
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let model):
                    let playlist = model.playlist
    
                    self?.tracks = playlist.tracks ?? []

                    self?.viewModels = self?.tracks.compactMap({
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


extension PlaylistViewController: UICollectionViewDelegate, UICollectionViewDataSource{
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
            withReuseIdentifier: PlaylistHeaderCollectionView.identifier,
            for: indexPath
        ) as? PlaylistHeaderCollectionView
            , kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let headerViewModel = PlaylistHeaderCellViewModel(
            name: album?.title ?? "",
            poster: "/1c3581a20a2ee22664efa57d66250202.png"
        )

        header.configure(with: headerViewModel)
        header.delegate = self

        return header
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // play song
        let index = indexPath.row
        let track = tracks[index]
        PlayBackPresenter.shared.playSongByTrack(from: self, tracks: tracks, currentItemIndex: index)
    }
}

extension PlaylistViewController: PlaylistHeaderCollectionViewDelegate {
    func albumHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionView) {
        print("Playing all")
        PlayBackPresenter.shared.playSongByTrack(
            from: self,
            tracks: tracks,
            currentItemIndex: 0
        )
    }
}

