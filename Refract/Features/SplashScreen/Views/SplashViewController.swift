//
//  SplashViewController.swift
//  Refract
//
//  Created by Davin P on 09/09/26.
//


import UIKit

final class SplashViewController: UIViewController {
    
    private let logoImageView = UIImageView(image: UIImage(named: "refract_logo"))
    private let titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.07, alpha: 1)
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateAndProceed()
    }
    
    private func setupViews() {
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.layer.cornerRadius = 24
        logoImageView.clipsToBounds = true
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.alpha = 0
        logoImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        titleLabel.text = "Refract"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.alpha = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func animateAndProceed() {
        UIView.animate(
            withDuration: 1.2, delay: 0.1,
            usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5,
            options: [], animations: {
                self.logoImageView.alpha = 1
                self.logoImageView.transform = .identity
            }
        )
        UIView.animate(withDuration: 0.6, delay: 0.3, animations: {
            self.titleLabel.alpha = 1
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.proceedToHome()
            }
        })
    }
    
    private func proceedToHome() {
        let homeVC = HomeViewController()
        let nav = UINavigationController(rootViewController: homeVC)
        nav.modalTransitionStyle = .crossDissolve
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}
