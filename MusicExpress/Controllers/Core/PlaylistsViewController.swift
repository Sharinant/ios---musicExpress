//
//  PlaylistsViewController.swift
//  MusicExpress
//
//  Created by Антон Шарин on 20.05.2021.
//
import UIKit

class PlaylistsViewController: UIViewController {
    public var selectionHandler: ((Song) -> Void)?

    private let noPlaylistsImage : UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "No-playlists-image.png")
        imageView.image = image
        imageView.contentMode = .scaleToFill
        
        return imageView
    }()
    
   private let letsChangeItLabel: UILabel = {
        let label = UILabel()
        label.text = "У вас пока что нет плейлистов.\nМожет, пора это исправить?"
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .systemBlue

        return label
    }()
    
    private let collectionViewSongs = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(
            sectionProvider: {
                _,_ -> NSCollectionLayoutSection?  in
                let supplementaryViews = [
                    NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(50)
                        ),
                        elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .top
                    )
                ]

                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0)
                    )
                )
                
                item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 0, trailing: 3)

                let secondGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(1)
                    ),
                    subitem: item,
                    count: 1
                )

                let section = NSCollectionLayoutSection(group: secondGroup)

                // свойство для горизонтальных групп
                section.orthogonalScrollingBehavior = .continuous
                section.boundarySupplementaryItems = supplementaryViews
                
                return section
            }
        )
    )
    
    private func drawEmpty() {
        view.addSubview(noPlaylistsImage)
        view.addSubview(letsChangeItLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionViewSongs.frame = view.bounds
    }
    
    private var viewModels = [RecomendedAlbumCellViewModel]()
    private var albums = [Song]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .done,
            target: self,
            action: #selector(didTapCreatePlaylistButton)
        )
        
        let imageSize: CGFloat = 250
        
        noPlaylistsImage.frame = CGRect(
            x: (view.width - imageSize) / 2,
            y: (view.height - imageSize) / 4,
            width: imageSize,
            height: imageSize
        )
        
        letsChangeItLabel.frame = CGRect(
            x: noPlaylistsImage.frame.minX,
            y: noPlaylistsImage.frame.minY + noPlaylistsImage.height,
            width: letsChangeItLabel.intrinsicContentSize.width,
            height: 50
        )
        
        view.addSubview(collectionViewSongs)
        
        collectionViewSongs.register(
            PopularAlbumCollectionViewCell.self,
            forCellWithReuseIdentifier: PopularAlbumCollectionViewCell.identifier
        )

        collectionViewSongs.backgroundColor = .systemBackground
        collectionViewSongs.delegate = self
        collectionViewSongs.dataSource = self
        
        APICaller.shared.getPlaylists {
            [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    if model.count == 0 {
                        self?.drawEmpty()
                        return
                    }
                    self?.albums = model
                    self?.viewModels = model.compactMap({
                        print($0)
                        return RecomendedAlbumCellViewModel(
                            title: $0.title ?? "",
                            artist: $0.artist ?? "",
                            poster: "/1c3581a20a2ee22664efa57d66250202.png"
                        )
                    })
                    self?.collectionViewSongs.reloadData()
                case.failure(let error):
                    print("failed to get album details", error)
                    break
                }
            }
        }
        
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(didTapClose)
            )
        }
    }
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapCreatePlaylistButton () {
        let alert = UIAlertController(
            title: "Новый плейлист",
            message: "Введите имя плейлиста",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Базука"
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Создать", style: .default, handler: { _ in
            guard let field = alert.textFields?.first,
                  let text = field.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            
            APICaller.shared.postPlaylist(with: text) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        break
                    case .failure(let error):
                        print(error)
                        break
                    }
                }
            }
        }))
        
        present(alert, animated: true)
    }
}

extension PlaylistsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PopularAlbumCollectionViewCell.identifier,
            for: indexPath
        ) as? PopularAlbumCollectionViewCell else {
            return UICollectionViewCell ()
        }
        
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard selectionHandler == nil else {
            self.selectionHandler?(albums[indexPath.row])
            dismiss(animated: true, completion: nil)
            return
        }
        
        let album = viewModels[indexPath.row]
        let vc = PlaylistViewController(album: albums[indexPath.row])

        vc.title = album.title
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
