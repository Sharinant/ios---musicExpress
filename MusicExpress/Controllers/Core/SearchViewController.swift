//
//  SearchViewController.swift
//  MusicExpress
//
//  Created by Лексус on 21.04.2021.
//

import UIKit

// View окна Search


class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    
    let searchController : UISearchController = {
        let vc = UISearchController(searchResultsController: SearchResultViewController())
        vc.searchBar.placeholder = "Песни, Альбомы и Исполнители..."
        vc.searchBar.tintColor = .white
        vc.searchBar.searchBarStyle = .minimal
        vc.definesPresentationContext = true
        return vc
        
    }()
    
    let letsSearchImage : UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "letsFindSomeThingImage.png")
        imageView.image = image
        imageView.frame = CGRect(x: 50, y: 200, width: 250, height: 200)
        
        return imageView
    }()
    
    let letsSearchLabel: UILabel = {
        let label = UILabel()
        label.text = "Давайте что-нибудь поищем!"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        label.frame = CGRect(x: 100, y:420 , width: 250, height: 50)
        return label
        
    }()
    
    let noFoundItems : UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено("
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        label.frame = CGRect(x: 100, y:420 , width: 250, height: 50)
        label.isHidden = true
        return label
    }()
    
    // Коллекция под строкой поиска
    
/*    private let collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: {_,_ -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 2,
                leading: 2,
                bottom: 2,
                trailing: 2)
        
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(150)),
                subitem: item, count: 2)
            
            group.contentInsets = NSDirectionalEdgeInsets(
                top: 10,
                leading: 0,
                bottom: 10,
                trailing: 0)
            
            return NSCollectionLayoutSection(group: group)
    }))
    */

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        view.addSubview(letsSearchImage)
        view.addSubview(letsSearchLabel)
    //    view.addSubview(noFoundItems)
        
        // collectionView.delegate = self
        // collectionView.dataSource = self
    
     //   view.addSubview(collectionView)
     //   collectionView.register(UICollectionViewCell.self,forCellWithReuseIdentifier: "cell")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
      //  collectionView.frame = view.bounds
    }
    
    var searched : SearchReslutResponse?
    
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let resultsController = searchController.searchResultsController as? SearchResultViewController, let query = searchBar.text,
            !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        //API CALLER
        //SEARCH
        resultsController.delegate = self
        
       APICaller.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let results):
                    self.searched = results
                    resultsController.update(with: results)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
      //  self.noFoundItems.isHidden = true
        self.letsSearchImage.isHidden = false
        self.letsSearchLabel.isHidden = false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let resultsController = searchController.searchResultsController as? SearchResultViewController,
              let query = searchController.searchBar.text,
            !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        //API CALLER
        //SEARCH
        
        resultsController.delegate = self
        
       
        
       
        
       APICaller.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let results):
                //    self.noFoundItems.isHidden = true
                    self.letsSearchImage.isHidden = false
                    self.letsSearchLabel.isHidden = false
                    self.searched = results
                    if results.albums == nil,
                       results.artists == nil,
                       results.tracks == nil {
                        print("No found items")
                        // view hidden 
                        resultsController.noResults()
                        self.letsSearchImage.isHidden = true
                        self.letsSearchLabel.isHidden = true
                        
                    } else {
                        resultsController.update(with: results)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension SearchViewController: SearchResultViewControllerDelegate{
    func showResult(_ controller: UIViewController) {
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .systemGreen
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}



