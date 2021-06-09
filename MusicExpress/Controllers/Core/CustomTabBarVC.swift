//
//  CustomTabBarVC.swift
//  MusicExpress
//
//  Created by Антон Шарин on 02.06.2021.
//

import Foundation
import UIKit




class CustomTabBarVC : UITabBarController, UITabBarControllerDelegate {
    
   
    
    weak var dataSource : PlayerDataSource?
    
    var tabBarHeight : CGFloat = 120
    
    let button : UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        
        return button
    }()
    
    @objc func buttonClick () {
        print("button click")
    }
    
    let playerView = PlayerPresenter()
    
    
    private func configure() {
        playerView.configure(name: dataSource?.songName ?? "",
                             artist: dataSource?.subtitle ?? "",
                             image: dataSource?.imageURLstring ?? "")
       // print(dataSource?.songName)
    }
    
    func refresh() {
        configure()
    }
   
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
    
        tabBar.frame.size.height = tabBarHeight
        button.frame = CGRect(x: 0, y: -30 , width: tabBar.width, height: 50)
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)

        tabBar.addSubview(button)
        tabBar.frame.origin.y = view.frame.height - tabBarHeight
       // playerView.addSubview(songNameLabel)
       
    }
    
    override func viewDidLoad() {
        
        
                
        super.viewDidLoad()
        
        let vc1 = HomeViewController()
        let vc2 = SearchViewController()
        let vc3 = FavoriteViewController()
        let vc4 = PlaylistsViewController()
       
        
       

        

        vc1.title = "Browse"
        vc2.title = "Search"
        vc3.title = "Favorite"
        vc4.title = "Playlists"

        vc1.navigationItem.largeTitleDisplayMode = .always
        vc2.navigationItem.largeTitleDisplayMode = .always
        vc3.navigationItem.largeTitleDisplayMode = .always
        vc4.navigationItem.largeTitleDisplayMode = .always
        // Do any additional setup after loading the view.
        
        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        let nav3 = UINavigationController(rootViewController: vc3)
        let nav4 = UINavigationController(rootViewController: vc4)

        // Так можно менять иконки в таббаре
        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        nav3.tabBarItem = UITabBarItem(title: "Favorite", image: UIImage(systemName: "music.note.house"), tag: 1)
        nav4.tabBarItem = UITabBarItem(title: "Playlists", image: UIImage(systemName: "play.rectangle.fill"), tag: 1)

        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        nav4.navigationBar.prefersLargeTitles = true
            
        setViewControllers([nav1, nav2, nav3,nav4], animated: false)
        
        
        
        
      
    }
    
    
}
