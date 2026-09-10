//
//  ModuleCardCell.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

import UIKit

final class ModuleCardCell: UITableViewCell {
    static let reuseIdentifier = "ModuleCardCell" // untuk render/dequeue cell dan registrasi cell ke table view serta hemat memori (bisa di recycle)

    private enum Palette {
        static let cardBackground = UIColor(white: 0.13, alpha: 1)
        static let cardBackgroundComplete = UIColor(red: 0.09, green: 0.16, blue: 0.12, alpha: 1)
        static let title = UIColor.white
        static let subtitle = UIColor(white: 0.62, alpha: 1)
        static let accent = UIColor.systemBlue
        static let complete = UIColor.systemGreen
    }

    private let cardView = UIView()

    // setengah foto asli (before), setengah lagi hasil grading (after)
    private let thumbnailContainer = UIView()
    private let beforeImageView = UIImageView()
    private let afterImageView = UIImageView()
    private let dividerLine = UIView()
    private let completeBadge = UIImageView()

    private let titleLabel = UILabel()
    private let durationLabel = UILabel()
    private let completePill = UILabel()

    // ganti dari badge "START" (teks, berat) jadi chevron icon (ringan, ngajak tap tanpa maksa)
    private let chevronIcon = UIImageView()

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
        cardView.layer.cornerRadius = 20
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.22
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.addSubview(cardView) // contentView sebagai wadah dari UITableViewCell/UICollectionViewCell

        setupThumbnail()
        setupTextColumn()
        setupChevron()

        let textColumn = UIStackView(arrangedSubviews: [titleLabel, metaRow()])
        textColumn.axis = .vertical
        textColumn.spacing = 6

        let row = UIStackView(arrangedSubviews: [thumbnailContainer, textColumn, chevronIcon])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14
        row.translatesAutoresizingMaskIntoConstraints = false
        row.isLayoutMarginsRelativeArrangement = true // agar pake padding dalem UIStackView pas bikin komponennya
        row.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
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

    private func setupThumbnail() {
        thumbnailContainer.layer.cornerRadius = 14
        thumbnailContainer.clipsToBounds = true
        thumbnailContainer.translatesAutoresizingMaskIntoConstraints = false
        thumbnailContainer.widthAnchor.constraint(equalToConstant: 64).isActive = true
        thumbnailContainer.heightAnchor.constraint(equalToConstant: 64).isActive = true

        [beforeImageView, afterImageView].forEach {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.backgroundColor = UIColor(white: 0.28, alpha: 1)
            $0.translatesAutoresizingMaskIntoConstraints = false
            thumbnailContainer.addSubview($0)
        }

        dividerLine.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        dividerLine.translatesAutoresizingMaskIntoConstraints = false
        thumbnailContainer.addSubview(dividerLine)

        completeBadge.image = UIImage(systemName: "checkmark.circle.fill")
        completeBadge.tintColor = Palette.complete
        completeBadge.backgroundColor = Palette.cardBackground
        completeBadge.layer.cornerRadius = 10
        completeBadge.isHidden = true
        completeBadge.translatesAutoresizingMaskIntoConstraints = false
        thumbnailContainer.addSubview(completeBadge)

        NSLayoutConstraint.activate([
            // before = separuh kiri foto asli
            beforeImageView.leadingAnchor.constraint(equalTo: thumbnailContainer.leadingAnchor),
            beforeImageView.topAnchor.constraint(equalTo: thumbnailContainer.topAnchor),
            beforeImageView.bottomAnchor.constraint(equalTo: thumbnailContainer.bottomAnchor),
            beforeImageView.widthAnchor.constraint(equalTo: thumbnailContainer.widthAnchor, multiplier: 0.5),

            // after = separuh kanan, hasil parameter yang diajarin di module ini
            afterImageView.trailingAnchor.constraint(equalTo: thumbnailContainer.trailingAnchor),
            afterImageView.topAnchor.constraint(equalTo: thumbnailContainer.topAnchor),
            afterImageView.bottomAnchor.constraint(equalTo: thumbnailContainer.bottomAnchor),
            afterImageView.widthAnchor.constraint(equalTo: thumbnailContainer.widthAnchor, multiplier: 0.5),

            dividerLine.centerXAnchor.constraint(equalTo: thumbnailContainer.centerXAnchor),
            dividerLine.topAnchor.constraint(equalTo: thumbnailContainer.topAnchor),
            dividerLine.bottomAnchor.constraint(equalTo: thumbnailContainer.bottomAnchor),
            dividerLine.widthAnchor.constraint(equalToConstant: 1.5),

            completeBadge.widthAnchor.constraint(equalToConstant: 20),
            completeBadge.heightAnchor.constraint(equalToConstant: 20),
            completeBadge.trailingAnchor.constraint(equalTo: thumbnailContainer.trailingAnchor, constant: -4),
            completeBadge.bottomAnchor.constraint(equalTo: thumbnailContainer.bottomAnchor, constant: -4)
        ])
    }

    private func setupTextColumn() {
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = Palette.title

        durationLabel.font = .systemFont(ofSize: 12)
        durationLabel.textColor = Palette.subtitle

        completePill.text = "  Completed  "
        completePill.font = .systemFont(ofSize: 11, weight: .semibold)
        completePill.textColor = Palette.complete
        completePill.backgroundColor = Palette.complete.withAlphaComponent(0.16)
        completePill.layer.cornerRadius = 8
        completePill.clipsToBounds = true
        completePill.isHidden = true
        completePill.setContentHuggingPriority(.required, for: .horizontal)
    }

    private func metaRow() -> UIStackView {
        let row = UIStackView(arrangedSubviews: [durationLabel, completePill])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        return row
    }

    private func setupChevron() {
        chevronIcon.image = UIImage(systemName: "chevron.right.circle.fill")
        chevronIcon.tintColor = Palette.accent
        chevronIcon.translatesAutoresizingMaskIntoConstraints = false
        chevronIcon.widthAnchor.constraint(equalToConstant: 28).isActive = true
        chevronIcon.heightAnchor.constraint(equalToConstant: 28).isActive = true
        chevronIcon.setContentHuggingPriority(.required, for: .horizontal)
    }

    func configure(title: String, durationMinutes: Int, beforeImage: UIImage?, afterImage: UIImage?, isComplete: Bool) {
        titleLabel.text = title
        durationLabel.text = "\(durationMinutes) mins"
        beforeImageView.image = beforeImage
        afterImageView.image = afterImage ?? beforeImage

        completeBadge.isHidden = !isComplete
        completePill.isHidden = !isComplete
        cardView.backgroundColor = isComplete ? Palette.cardBackgroundComplete : Palette.cardBackground
        cardView.layer.borderWidth = isComplete ? 1 : 0
        cardView.layer.borderColor = isComplete ? Palette.complete.withAlphaComponent(0.4).cgColor : nil
    }
}
