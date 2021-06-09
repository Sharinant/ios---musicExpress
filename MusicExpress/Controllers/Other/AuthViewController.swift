//
//  AuthViewController.swift
//  MusicExpress
//
//  Created by Лексус on 21.04.2021.
//

import UIKit
import WebKit
import SDWebImage

class AuthViewController: UIViewController, WKNavigationDelegate {
    
    private let login: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.layer.cornerRadius = 5
        tf.backgroundColor = UIColor(red: 70 / 255, green: 70 / 255, blue: 70 / 255, alpha: 70 / 255)
        tf.textColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 255 / 255)
        tf.font = UIFont.systemFont(ofSize: 17)
        tf.autocorrectionType = .no
        tf.clearsOnBeginEditing = false
        tf.autocapitalizationType = .none

        var placeholder = NSMutableAttributedString()
        placeholder = NSMutableAttributedString(
            attributedString: NSAttributedString(
                string: "Login",
                attributes: [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
                    .foregroundColor: UIColor(white: 1, alpha: 0.7)
                ]
            )
        )

        tf.attributedPlaceholder = placeholder
        
        let paddingView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 10,
                height: tf.frame.size.height
            )
        )
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        return tf
    }()
    
    private let password: UITextField = {
        let tf = UITextField()
        
        tf.borderStyle = .none
        tf.layer.cornerRadius = 5
        tf.backgroundColor = UIColor(red: 70 / 255, green: 70 / 255, blue: 70 / 255, alpha: 70 / 255)
        tf.textColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 255 / 255)
        tf.font = UIFont.systemFont(ofSize: 17)
        tf.autocorrectionType = .no
        tf.clearsOnBeginEditing = false
        tf.autocapitalizationType = .none


        var placeholder = NSMutableAttributedString()
        placeholder = NSMutableAttributedString(
            attributedString: NSAttributedString(
                string: "Password",
                attributes: [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
                    .foregroundColor: UIColor(white: 1, alpha: 0.7)
                ]
            )
        )
        
        tf.attributedPlaceholder = placeholder
        
        let paddingView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 10,
                height: tf.frame.size.height
            )
        )
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        return tf
    }()
    
    let loginButton: UIButton = {
        let button = UIButton()
        let attributedString = NSMutableAttributedString(
            attributedString: NSAttributedString(
                string: "Login",
                attributes: [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
                    .foregroundColor: UIColor.white
                ]
            )
        )
        
        button.setAttributedTitle(attributedString, for: .normal)
        button.backgroundColor = UIColor(red: 70 / 255, green: 70 / 255, blue: 70 / 255, alpha: 70 / 255)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        
        button.layer.borderColor = CGColor(
            red: 5 / 255,
            green: 7 / 255,
            blue: 8 / 255,
            alpha: 4 / 10
        )
        
        return button
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 13,weight: .bold)
        label.numberOfLines = 1
        label.textColor = .red

        return label
    }()
    
    public var completionHandler: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sign In"
        view.backgroundColor = .systemBackground
        
        let stackView = mainStackView()
        view.addSubview(stackView)
        stackView.frame = CGRect(
            x: 20,
            y: view.height / 2,
            width: view.width - 40,
            height: 150
        )
        
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func mainStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [messageLabel, login, password, loginButton])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        
        
        return stackView
    }
    
    @objc func didTapLogin() {
        
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk(onCompletion: nil)
        
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.loginButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    self.loginButton.transform = CGAffineTransform.identity
                }
            }
        )

        APICaller.shared.login(login: login.text ?? "", password: password.text ?? "") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let credentials):
                    AuthManager.shared.setAccessToken(credentials_: credentials)
                    self.completionHandler?(true)
                    break
                case .failure(_):
                    self.completionHandler?(false)
                    self.messageLabel.text = "Wrong login or password"
                    break
                }
            }
        }
    }
}
