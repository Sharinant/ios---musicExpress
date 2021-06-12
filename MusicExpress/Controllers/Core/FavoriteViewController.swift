//
//  LibraryViewController.swift
//  MusicExpress
//
//  Created by Лексус on 21.04.2021.
//

import UIKit

class FavoriteViewController: UIViewController {
    
    @objc func didTapPlayer() {
       
 
        guard let vc = PlayerContext.context else {
            return
        }
        present(vc , animated: true, completion: nil)
    }
    
    @objc func playerButtonEnable()  {
        playerButton.isEnabled = true
       
    }
    
    private var favoriteSongs : [Song] = []
    
    
    
    private let collectionViewSongs = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(
            sectionProvider: {
                _,_ -> NSCollectionLayoutSection?  in
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(80)
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
                let supplementaryViews = [NSCollectionLayoutBoundarySupplementaryItem(
                                            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                               heightDimension: .fractionalWidth(0.3)),
                                            elementKind: UICollectionView.elementKindSectionHeader,
                                            alignment: .top)]
                
                section.boundarySupplementaryItems = supplementaryViews

                return section
            }
        )
    )
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FavoriteHeaderCollectionReusableView.identifier, for: indexPath) as? FavoriteHeaderCollectionReusableView,kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
            
        
        header.configure(with: "123")
        header.delegate = self
        return header
    }

    private let noFavoriteImage : UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "No-Favorite-image.png")
        imageView.image = image
        imageView.contentMode = .scaleToFill
        
        return imageView
    }()
    
    private  let letsChangeItLabel: UILabel = {
        let label = UILabel()
        label.text = "У вас пока что нет любимых треков.\nМожет, пора это исправить?"
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white

        return label
        
    }()
    
    private var viewModels = [TopSongsCellViewModel]()
    
    private func drawEmpty() {
        noFavoriteImage.isHidden = false
        letsChangeItLabel.isHidden = false
    }
    
    private func drawNotEmpty() {
        noFavoriteImage.isHidden = true
        letsChangeItLabel.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionViewSongs.frame = view.bounds
    }
    
    let playerButton = UIBarButtonItem(image: UIImage(systemName: "music.note"),
                                       style: .done,
                                       target: nil,
                                       action: #selector(didTapPlayer))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerButton.target = self

        NotificationCenter.default.addObserver(self, selector: #selector(playerButtonEnable), name: Notification.Name("playerOn"), object: nil)
        noFavoriteImage.frame = CGRect(
            x: (view.width - 300) / 2,
            y: (view.height - 300) / 4,
            width: 300,
            height: 300
        )
        navigationItem.rightBarButtonItem = playerButton
        if PlayerContext.context == nil {
            playerButton.isEnabled = false
        } else {
            playerButton.isEnabled = true

        }
        letsChangeItLabel.frame = CGRect(
            x: (view.width - 300) / 2,
            y: (view.height - 300) / 1.3,
            width: letsChangeItLabel.intrinsicContentSize.width,
            height: 50
        )
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionViewSongs)
        view.addSubview(noFavoriteImage)
        view.addSubview(letsChangeItLabel)
        
        collectionViewSongs.register(
            TopTracksCollectionViewCell.self,
            forCellWithReuseIdentifier: TopTracksCollectionViewCell.identifier
        )
        
        collectionViewSongs.register(FavoriteHeaderCollectionReusableView.self,
                                     forSupplementaryViewOfKind:  UICollectionView.elementKindSectionHeader,
                                     withReuseIdentifier: FavoriteHeaderCollectionReusableView.identifier)

        collectionViewSongs.backgroundColor = .systemBackground
        collectionViewSongs.delegate = self
        collectionViewSongs.dataSource = self
        
        APICaller.shared.getFavoriteTracks {
            [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    if model.count == 0 {
                        self?.drawEmpty()
                        self?.collectionViewSongs.isHidden = true
                        return
                    } else {
                        self?.drawNotEmpty()
                        self?.collectionViewSongs.isHidden = false
                    self?.favoriteSongs = model
                    self?.viewModels = model.compactMap({
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
                    })
                        self?.collectionViewSongs.reloadData()
                    }
                case.failure(let error):
                    print("failed to get album details", error)
                    self?.drawEmpty()
                    break
                }
            }
         //   self?.collectionViewSongs.reloadData()

        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFavorite), name: Notification.Name("reload favorite"), object: nil)
        
        addLongTapGesture()
    }
    @objc func reloadFavorite() {
        APICaller.shared.getFavoriteTracks {
            [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    if model.count == 0 {
                        self?.drawEmpty()
                        self?.collectionViewSongs.isHidden = true
                        return
                    } else {
                        self?.drawNotEmpty()
                        self?.collectionViewSongs.isHidden = false
                    self?.favoriteSongs = model
                    self?.viewModels = model.compactMap({
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
                    })
                        self?.collectionViewSongs.reloadData()
                    
                    }
                case.failure(let error):
                    print("failed to get album details", error)
                    break
                }
            }
      //      self?.collectionViewSongs.reloadData()

        }
    }
    private func addLongTapGesture() {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_ :)))
            collectionViewSongs.addGestureRecognizer(gesture)
        }

        @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else {
                return
            }

            let touchPoint = gesture.location(in: collectionViewSongs)

            guard let indexPath = collectionViewSongs.indexPathForItem(at: touchPoint) else {
                return
            }

            let model = favoriteSongs[indexPath.row]
            print(model)
            let actionSheet = UIAlertController(
                title: model.title,
                message: "Хотите добавить в плейлист?",
                preferredStyle: .actionSheet
            )

            actionSheet.addAction(
                UIAlertAction(
                    title: "Отмена",
                    style: .cancel,
                    handler: nil
                )
            )

            actionSheet.addAction(
                UIAlertAction(
                    title: "Добавить",
                    style: .default,
                    handler: { [weak self] _ in
                        DispatchQueue.main.async {
                            let vc = PlaylistsViewController()
                            vc.selectionHandler = { playlist in
                                APICaller.shared.postSongToPlaylist(
                                    trackNumber: model.id ?? 0,
                                    playlistNumber: playlist.id ?? 0
                                ) { result in
                                    switch result{
                                    case .success(_):
                                        break
                                    case .failure(let error):
                                        print(error)
                                        break
                                    }
                                }
                            }
                            vc.title = "Выберите плейлист"
                            self?.present(
                                UINavigationController(rootViewController: vc),
                                animated: true,
                                completion: nil
                            )
                        }
                    }
                )
            )

            present(actionSheet, animated: true)
        }
    
}

extension FavoriteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // play song
        
        PlayBackPresenter.shared.playSongBySong(from: self, songs: favoriteSongs, currentItemIndex: indexPath.row)

    }
}

extension FavoriteViewController : FavoriteHeaderCollectionReusableViewDelegate {
    func didTapPlayAll(_ header: FavoriteHeaderCollectionReusableView) {
        PlayBackPresenter.shared.playSongBySong(from: self, songs: favoriteSongs, currentItemIndex: 0)
    }
    
    func didTapShuffleAll() {
        PlayBackPresenter.shared.playShuffleBySong(from: self, songs: favoriteSongs)
    }
    
    
}
