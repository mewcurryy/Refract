//
//  ModuleCardCell.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

import UIKit

final class ModuleCardCell: UITableViewCell {
    static let reuseIdentifier = "ModuleCardCell" // untuk render/dequeue cell dan registrasi cell ke table view serta hemat memori (bisa di recycle)
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let durationLabel = UILabel()
    private let startBadge = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        cardView.backgroundColor = UIColor(white: 0.85, alpha: 1)
        cardView.layer.cornerRadius = 20
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)// contentView sebagai wadah dari UITableViewCell/UICollectionViewCell
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .black
        
        durationLabel.font = .systemFont(ofSize: 12)
        durationLabel.textColor = UIColor(white: 0.35, alpha: 1)
        
        let textColumn = UIStackView(arrangedSubviews: [titleLabel, durationLabel])
        textColumn.axis = .vertical
        textColumn.spacing = 6
        
        startBadge.text = "START"
        startBadge.font = .systemFont(ofSize: 14, weight: .semibold)
        startBadge.textColor = .white
        startBadge.backgroundColor = .black
        startBadge.textAlignment = .center
        startBadge.layer.cornerRadius = 30
        startBadge.clipsToBounds = true
        startBadge.translatesAutoresizingMaskIntoConstraints = false
        startBadge.widthAnchor.constraint(equalToConstant: 70).isActive = true
        startBadge.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let row = UIStackView(arrangedSubviews: [textColumn, startBadge])
        row.axis = .horizontal
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        row.isLayoutMarginsRelativeArrangement = true // agar pake padding dalem UIStackView pas bikin komponennya
        row.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        cardView.addSubview(row)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            row.topAnchor.constraint(equalTo: cardView.topAnchor),
            row.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
    }
    
    func configure(title: String, durationMinutes: Int) { // cara isi data ke cell ini, dipanggil dari luar
        titleLabel.text = title
        durationLabel.text = "Duration: \(durationMinutes) mins"
    }
}
