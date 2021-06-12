//
//  ViewController.swift
//  MusicExpress
//
//  Created by Лексус on 21.04.2021.
//

import UIKit

var groupOfDayString = ""

enum BrowseSectionType {
    case groupOfTheDay(viewModels : [groupOfDayCellViewModel]) //0
    
    case albums(viewModels: [AlbumCellViewModel]) //1
    case newSongs(viewModels : [NewSongsCellViewModel]) //2
    
    case topTracks(viewModels: [TopSongsCellViewModel]) //3
    case topAlbums(viewModels: [RecomendedAlbumCellViewModel]) //4
    
    
    
    
    var title: String {
        
        switch self {
        
        case .albums:
            return "Рекомендованные альбомы"
            
        case .topTracks:
            return "Популярные песни"
            
        case .topAlbums:
            return "Популярные альбомы"
            
        case .groupOfTheDay:
            return "Группа дня - " + groupOfDayString
        case .newSongs:
            return "Новые релизы"
        
        }
    }
    
    
}

class HomeViewController: UIViewController {
    
    
  
    
    private var albums: [Song] = []
    private var tracks: [Song] = []
    private var groupOfDay: [Song] = []
    private var newSongs: [Song] = []
    private var topAlbums: [Song] = []
    
  
    
  

    private var collectionView : UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout{sectionIndex, _ ->NSCollectionLayoutSection? in
            return HomeViewController.createSectionLayout(index : sectionIndex)
        }
    )
    
    private var sections = [BrowseSectionType]()
     
    private let spinner : UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
        
    }()
    
    
    let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                        style: .done,
                                        target: nil,
                                        action: #selector(didTapSettings))
    
    let playerButton = UIBarButtonItem(image: UIImage(systemName: "music.note"),
                                       style: .done,
                                       target: nil,
                                       action: #selector(didTapPlayer))
    
    
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        
        
        title = "Главная"
        
        view.tintColor = .systemPink
        view.backgroundColor = .systemBackground
        
        settingButton.target = self
        playerButton.target = self
        
        
        navigationItem.rightBarButtonItems = [playerButton,settingButton]
        if PlayerContext.context == nil {
            playerButton.isEnabled = false
        } else {
            playerButton.isEnabled = true

        }
        
        configureCollectionView()
        view.addSubview(spinner)
        fetchData()
        NotificationCenter.default.addObserver(self, selector: #selector(playerButtonEnable), name: Notification.Name("playerOn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTracksStates), name: Notification.Name("reload plus buttons states"), object: nil)
        
        addLongTapGesture()
    }
    
    @objc func playerButtonEnable()  {
        playerButton.isEnabled = true
     //   print("enabled")
    }
    
    @objc func reloadTracksStates () {
        
    }
    
    
    private func fetchData() {
        let group = DispatchGroup()
        
        group.enter()
        group.enter()
        group.enter()
        group.enter()
        group.enter()
        
        
        var albums: [Song]?
        var topSongs: [Song]?
        var groupOfDay: [Song]?
        var newSongs: [Song]?
        var topAlbums: [Song]?
        
        APICaller.shared.getTopSongs { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let gotTopSongs):
                topSongs = gotTopSongs
            case .failure(let error):
                print("Can't get top songs", error)
                break
            }
        }

        APICaller.shared.getAlbums{ result in
            defer {
                group.leave()
            }

            switch result {
            case .success(let songs):
                albums = songs 
                break
            case .failure(let error):
                print(error)
                break
            }
        }
        
        APICaller.shared.getGroupOfDay { result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let dayGroup):
                groupOfDay = [dayGroup]
                break
            case .failure(let error):
                print("Can't get group of day",error)
                break
            }
        }
        
        APICaller.shared.getNewSongs { result in
            defer {
                group.leave()
            }
            
            switch result{
            case .success(let gotNewSongs):
                newSongs = gotNewSongs
            
            case .failure(let error):
                print("Can't get new songs", error)
                break
            }
        }
        
        APICaller.shared.getTopAlbums { result in
            defer {
                group.leave()
            }

            switch result {
            case .success(let GottopAlbums):
                topAlbums = GottopAlbums
            case .failure(let error):
                print("Can't get top albums",error)
            }
        }
        
        
        group.notify(queue: .main) {
            guard let albums = albums,
                  let topSongs = topSongs,
                  let groupOfDay = groupOfDay,
                  let newSongs = newSongs,
                  let topAlbums = topAlbums else {
                return
            }
            
            self.configureModels(
                albums: albums,
                tracks: topSongs,
                groupOfDay: groupOfDay,
                newSongs: newSongs,
                topAlbums: topAlbums
            )
        }
    }
    
    @objc func didTapSettings() {
        let vc = SettingsViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapPlayer() {
      //  print("hi")
 
        guard let vc = PlayerContext.context else {
            return
        }
        present(vc , animated: true, completion: nil)
       
    }
    
    private func configureModels(
        albums: [Song],
        tracks: [Song],
        groupOfDay: [Song],
        newSongs: [Song],
        topAlbums: [Song]
    ) {
        
        self.albums = albums
        self.tracks = tracks
        self.groupOfDay = groupOfDay
        self.newSongs = newSongs
        self.topAlbums = topAlbums
        
        
        //Строгий порядок!!!
        
        
        sections.append(.groupOfTheDay(viewModels: groupOfDay.compactMap({
            return groupOfDayCellViewModel(
                name: $0.name ?? "",
                poster: $0.poster ?? "",
                id: $0.id ?? 0)
            
        })))
        sections.append(.albums(viewModels: albums.compactMap({
            return AlbumCellViewModel(
                artistName: $0.artist_name ?? "-",
                title: $0.title ?? "",
                poster: $0.poster ?? ""  
            )
        })))
        sections.append(.newSongs(viewModels: newSongs.compactMap({
            return NewSongsCellViewModel(
                id: $0.id ?? 0,
                title: $0.title ?? "",
                duration: $0.duration ?? 0,
                artist: $0.artist ?? "",
                poster: $0.album_poster ?? "",
                isLiked: $0.is_liked ?? false,
                isPlus: $0.is_favorite ?? false
            )
        })))
        
        sections.append(.topTracks(viewModels: tracks.compactMap({
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
            
        })))
        
        sections.append( .topAlbums(viewModels: topAlbums.compactMap({
            return RecomendedAlbumCellViewModel(
            title: $0.title ?? "",
            artist: $0.artist ?? "",
            poster: $0.poster ?? ""
        )})))
        
        collectionView.reloadData()
        // sections.append(.topAlbums(viewModels: []))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        //регистрация коллекций
        
        collectionView.register(
            TopTracksCollectionViewCell.self,
            forCellWithReuseIdentifier: TopTracksCollectionViewCell.identifier)
        collectionView.register(
            RecommendedAlbumsCollectionViewCell.self,
            forCellWithReuseIdentifier: RecommendedAlbumsCollectionViewCell.identifier
        )
        collectionView.register(
            GroupOfTheDayCVcell.self,
            forCellWithReuseIdentifier: GroupOfTheDayCVcell.identifier
        )
        collectionView.register(
            NewSongsCVCell.self,
            forCellWithReuseIdentifier: NewSongsCVCell.identifier
        )
        collectionView.register(
            TopTracksCollectionViewCell.self,
            forCellWithReuseIdentifier: TopTracksCollectionViewCell.identifier
        )
        collectionView.register(PopularAlbumCollectionViewCell.self, forCellWithReuseIdentifier: PopularAlbumCollectionViewCell.identifier)
        collectionView.register(TeamNameCollectionViewCell.self, forCellWithReuseIdentifier: TeamNameCollectionViewCell.identifier)
        
        
        //регистрация названия коллекций
        collectionView.register(TitleHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        
    }
    
    private static func createSectionLayout(index: Int) -> NSCollectionLayoutSection{
        
        let supplementaryViews = [NSCollectionLayoutBoundarySupplementaryItem(
                                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                       heightDimension: .absolute(70)),
                                    elementKind: UICollectionView.elementKindSectionHeader,
                                    alignment: .top)]
        
        switch index {
        
        //группа дня
        case 0:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 1, bottom: 3, trailing: 1)

            let firstGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(1.2)
                ),
                subitem: item,
                count: 2
            )
            
            let section = NSCollectionLayoutSection(group: firstGroup)

            // свойство для горизонтальных групп
           // section.orthogonalScrollingBehavior = .continuous

            section.boundarySupplementaryItems = supplementaryViews

            return section
            
         //рекомендуемые альбомы
        case 1:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(1.0)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

            let firstGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(1.3)
                ),
                subitem: item,
                count: 2
            )
            
            let secondGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.85),
                    heightDimension: .fractionalWidth(1.1)
                ),
                subitem: firstGroup,
                count: 2
            )

            let section = NSCollectionLayoutSection(group: secondGroup)

            // свойство для горизонтальных групп
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryViews
            return section
            
            //новые песни
        case 2:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 1, bottom: 2, trailing: 1)

            let firstGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(280)
                ),
                subitem: item,
                count: 5
            )
            
            let section = NSCollectionLayoutSection(group: firstGroup)
            // свойство для горизонтальных групп
            
            section.boundarySupplementaryItems = supplementaryViews

            return section
            
            //популярные песни
        case 3:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

            let firstGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(280)
                ),
                subitem: item,
                count: 5
            )
            
            

            let section = NSCollectionLayoutSection(group: firstGroup)
            // свойство для горизонтальных групп
            
            section.boundarySupplementaryItems = supplementaryViews

            return section
           // популярные альбомы
        case 4:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 0, trailing: 3)

          
            
            let secondGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .fractionalWidth(0.9)
                ),
                subitem: item,
                count: 1
            )

            let section = NSCollectionLayoutSection(group: secondGroup)

            // свойство для горизонтальных групп
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryViews
            return section
            
            //team name label
        case 5:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

            let firstGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(70)
                ),
                subitem: item,
                count: 1
            )
            
            let section = NSCollectionLayoutSection(group: firstGroup)

            // свойство для горизонтальных групп
           // section.orthogonalScrollingBehavior = .continuous

            return section
        
            
        default:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

            let firstGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(360)
                ),
                subitem: item,
                count: 2
            )
            
            let secondGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(360)
                ),
                subitem: firstGroup,
                count: 2
            )

            let section = NSCollectionLayoutSection(group: secondGroup)
            // свойство для горизонтальных групп
            section.orthogonalScrollingBehavior = .continuous

            return section
        }
    }
    
   
        
     private func showAlert() {
            let alert = UIAlertController(title: "Alert", message: "Wait Please!", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
        }
        
       
        
    
    
    private func addLongTapGesture() {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_ :)))
            collectionView.addGestureRecognizer(gesture)
        }

        @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
            
             
            
            guard gesture.state == .began else {
                return
            }

            let touchPoint = gesture.location(in: collectionView)
            
            
            guard let indexPath = collectionView.indexPathForItem(at: touchPoint) else {
                return
            }
            let type = sections[indexPath.section]
            
            switch type {
            
            case .newSongs:
                let model = tracks[indexPath.row]
                let actionSheet = UIAlertController(
                    title: model.name,
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
                                    completion: {
                
                                    })
                                
                            }
                            
                            
                        }
                        
                    )
                )
               
                present(actionSheet, animated: true,completion: nil)
                NotificationCenter.default.post(name: NSNotification.Name("playlist reload") , object: nil)
                break
            case .topTracks:
                
                let model = tracks[indexPath.row]
                let actionSheet = UIAlertController(
                    title: model.name,
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
                                    completion: nil)
                            }
                        }
                    )
                )

                present(actionSheet, animated: true)
                break
            default:
                break
            }
        }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // конфигурация названий коллекций
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier, for: indexPath) as? TitleHeaderCollectionReusableView,kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        

        let section = indexPath.section
        
        groupOfDayString = groupOfDay[0].name ?? "nil"
        let title = sections[section].title
        
        header.configure(with: title)
        
        return header
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type {
        case .albums(let model):
            return model.count
        case .topAlbums(let model):
            return model.count
        case .topTracks(let model):
            return model.count
        case .groupOfTheDay:
            return 1
        case .newSongs(let model):
            return model.count
        
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let type = sections[indexPath.section]
        switch type {
        case .albums(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecommendedAlbumsCollectionViewCell.identifier,
                for: indexPath
            ) as? RecommendedAlbumsCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)

            return cell
            
        case .topAlbums(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PopularAlbumCollectionViewCell.identifier,
                for: indexPath
            ) as? PopularAlbumCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)

            return cell
            
        case .topTracks(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TopTracksCollectionViewCell.identifier,
                for: indexPath
            ) as? TopTracksCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)

            return cell
            
        case .groupOfTheDay(let viewModels):
            
            guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: GroupOfTheDayCVcell.identifier,
                    for: indexPath)
                    as? GroupOfTheDayCVcell else {
                return UICollectionViewCell()
            }
            
            let viewModel = viewModels[indexPath.row]
            
            cell.configure(with: viewModel)
            
            return cell
            
        case .newSongs(let viewModels):
            
            guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: NewSongsCVCell.identifier,
                    for: indexPath)
                    as? NewSongsCVCell else {
                return UICollectionViewCell()
            }
            
            let viewModel = viewModels[indexPath.row]
            
            cell.configure(with: viewModel)
            
            return cell
            
        
        }
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let section = sections[indexPath.section]
        
        switch section {
        
        case .groupOfTheDay:
            let artist = groupOfDay[indexPath.row]
            let vc = ArtistViewController(artist: artist)
            vc.title = artist.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
            
            break
        case .albums:
            
            let album = albums[indexPath.row]
            let vc = AlbumViewController(album: album)
            vc.title = album.title
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
            
            break
            
        case .newSongs:
            
            PlayBackPresenter.shared.playSongBySong(from: self, songs: newSongs, currentItemIndex: indexPath.row)
            
        //    let track = newSongs[indexPath.row]
         //   PlayBackPresenter.shared.startPlaybackWithSong(from: self, track: track)
            
        case .topTracks:
            
            PlayBackPresenter.shared.playSongBySong(from: self, songs: tracks, currentItemIndex: indexPath.row)
            
          //  let track = tracks[indexPath.row]
          //  PlayBackPresenter.shared.startPlaybackWithSong(from: self, track: track)
            
        case .topAlbums:
            
            let album = topAlbums[indexPath.row]
            let vc = AlbumViewController(album: album)
            vc.title = album.title
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
            break
        
            
    }
    
}
}


