//
//  TabBarViewController.swift
//  MusicExpress
//
//  Created by Лексус on 21.04.2021.
//

import UIKit

class TabBarViewController: UITabBarController {
   

    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        let vc1 = HomeViewController()
        let vc2 = SearchViewController()
        let vc3 = FavoriteViewController()
        let vc4 = PlaylistsViewController()
       

    
        vc1.title = "Главная"
        vc2.title = "Поиск"
        vc3.title = "Избранное"
        vc4.title = "Плейлисты"

        vc1.navigationItem.largeTitleDisplayMode = .always
        vc2.navigationItem.largeTitleDisplayMode = .always
        vc3.navigationItem.largeTitleDisplayMode = .always
        vc4.navigationItem.largeTitleDisplayMode = .always
        // Do any additional setup after loading the view.
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        vc1.navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        UITabBar.appearance().tintColor = .systemPink
        
        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        let nav3 = UINavigationController(rootViewController: vc3)
        let nav4 = UINavigationController(rootViewController: vc4)
        
        nav1.navigationBar.titleTextAttributes = textAttributes
        
        nav1.navigationBar.tintColor = .systemPink
        nav1.navigationItem.titleView?.tintColor = .systemPink
        nav1.navigationBar.tintColor = .systemPink
        
        nav2.navigationBar.tintColor = .systemPink
        nav2.navigationItem.titleView?.tintColor = .systemPink
        nav2.navigationBar.tintColor = .systemPink
        
        nav3.navigationBar.tintColor = .systemPink
        nav3.navigationItem.titleView?.tintColor = .systemPink
        nav3.navigationBar.tintColor = .systemPink
        
        nav4.navigationBar.tintColor = .systemPink
        nav4.navigationItem.titleView?.tintColor = .systemPink
        nav4.navigationBar.tintColor = .systemPink


        // Так можно менять иконки в таббаре
        nav1.tabBarItem = UITabBarItem(title: "Главная", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Поиск", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        nav3.tabBarItem = UITabBarItem(title: "Избранное", image: UIImage(systemName: "music.note.house"), tag: 1)
        nav4.tabBarItem = UITabBarItem(title: "Плейлисты", image: UIImage(systemName: "play.rectangle.fill"), tag: 1)
        
        
        nav2.tabBarItem.badgeColor = .systemPink
        nav3.tabBarItem.badgeColor = .systemPink
        nav4.tabBarItem.badgeColor = .systemPink


        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        nav4.navigationBar.prefersLargeTitles = true
            
        setViewControllers([nav1, nav2, nav3,nav4], animated: false)
        
       
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
        

    }
    
    


