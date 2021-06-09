//
//  ArtistViewController.swift
//  MusicExpress
//
//  Created by Антон Шарин on 20.05.2021.
//

import UIKit
import SDWebImage

class ArtistViewController: UIViewController {
    
    private let artist : Song?
    
    private let collectionViewSongs = UICollectionView(frame: .zero,
                                                  collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _,_ -> NSCollectionLayoutSection?  in
            let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .absolute(8)
                                                )
                                                )
                                                    
                                        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

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
                            heightDimension: .fractionalWidth(1.5)),
                            elementKind: UICollectionView.elementKindSectionHeader,
                            alignment: .top)
                                                    ]
        
        return section
            })
    )
    
    
    
    init(artist: Song?) {
        self.artist = artist
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private var viewModels = [TopSongsCellViewModel]()
    private var tracks = [Song] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = artist?.name
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionViewSongs)
        collectionViewSongs.delegate = self
        collectionViewSongs.dataSource = self
        
        collectionViewSongs.register(TopTracksCollectionViewCell.self,
                                     forCellWithReuseIdentifier: TopTracksCollectionViewCell.identifier)
        collectionViewSongs.register(ArtistHeaderCollectionReusableView.self,
                                  forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: ArtistHeaderCollectionReusableView.identifier)
        collectionViewSongs.backgroundColor = .systemBackground
        
        
        APICaller.shared.getArtistsTracks(
            artist_id: artist?.artist_id ?? artist?.id ?? 0
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let model):
                    self?.tracks = model
                    self?.viewModels = model.compactMap({
                        return TopSongsCellViewModel(
                            id: $0.id ?? 0,
                            title: $0.title ?? "",
                            duration: $0.duration ?? 0,
                            artist: $0.artist ?? "",
                            album_poster: $0.album_poster ?? "",
                            artist_id: $0.artist_id ?? 0,
                            isLiked: $0.is_liked ?? false,
                            isPlus: $0.is_favorite ?? false,
                            audio: $0.audio ?? ""
                        )
                    })
                    self?.collectionViewSongs.reloadData()

                case .failure(let error):
                    print("failed to get artists tracks,", error)
                }
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionViewSongs.frame = view.bounds
    }
    
    
}
    

extension ArtistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopTracksCollectionViewCell.identifier,
                                                            for: indexPath) as? TopTracksCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: viewModels[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ArtistHeaderCollectionReusableView.identifier,
                for: indexPath) as? ArtistHeaderCollectionReusableView,
               kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let headerViewModel = ArtistHeaderCellViewModel(artistName: artist?.name ?? "",
                                                        poster: artist?.poster ?? "",
                                                        description: "",
                                                        artist_id: artist?.artist_id ?? artist?.id ?? 0,
                                                        avatar: artist?.avatar ?? ""
        )
        
        
        header.configure(with: headerViewModel)
        header.delegate = self

        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
      //  let index = indexPath.row
      //  let track = tracks[index]
        
       // PlayBackPresenter.shared.startPlaybackWithSong(from: self, track: track)
        
        PlayBackPresenter.shared.playSongBySong(from: self, songs: tracks, currentItemIndex: indexPath.row)
        
    }
}
extension ArtistViewController: ArtistHeaderCollectionReusableViewDelegate {
    func didTapPlayAllArtist(_ header:
                                ArtistHeaderCollectionReusableView) {
        print("Play all - artist")
        PlayBackPresenter.shared.playSongBySong(from: self, songs: tracks, currentItemIndex: 0)
    }
    
    
    
   
    
    
}
    

   



