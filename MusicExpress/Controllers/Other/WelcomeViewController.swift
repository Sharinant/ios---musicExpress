//
//  WelcomeViewController.swift
//  MusicExpress
//
//  Created by Лексус on 21.04.2021.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    
    private let welcomeImage : UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "welcomeImage.jpg")
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton()

        button.backgroundColor = .blue
        button.setTitle("Sign In", for: .normal)
        
        button.setTitleColor(.white, for: .normal)

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "MusicExpress"
        
       // view.backgroundColor = .systemGreen
        welcomeImage.frame = view.bounds
        view.addSubview(welcomeImage)
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signInButton.frame = CGRect(
            x: 20,
            y: view.bottom - 100 ,
            width: view.width - 40,
            height: 50
        )
    }
    
    @objc func didTapSignIn() {
        let vc = AuthViewController()
        vc.completionHandler = { [weak self] success in
            DispatchQueue.main.async {
                self?.handleSignIn(success: success)
            }
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
      
    }
    
    private func handleSignIn(success: Bool) {
       if !success {
            let alert = UIAlertController(
                title: "Alert",
                message: "Wrong login or password",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let mainAppTabBarVC = TabBarViewController()
        mainAppTabBarVC.modalPresentationStyle = .fullScreen
        present(mainAppTabBarVC, animated: true)
    }
}
