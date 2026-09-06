//
//  TutorialModuleViewController.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

import UIKit

final class TutorialModuleViewController: UIViewController {
    
    private let viewModel: TutorialModuleViewModel
    
    private enum Palette {
        static let background = UIColor(white: 0.07, alpha: 1)
        static let cardBackground = UIColor(white: 0.13, alpha: 1)
        static let primaryText = UIColor.white
        static let secondaryText = UIColor(white: 0.6, alpha: 1)
        static let progressTrack = UIColor(white: 0.25, alpha: 1)
    }
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let backButton = UIButton(type: .system)
    private let screenTitleLabel = UILabel()
    private let positionLabel = UILabel()
    private let progressPercentageLabel = UILabel()
    
    private let progressTrackView = UIView()
    private let progressFillView = UIView()
    private var progressFillWidthConstraint: NSLayoutConstraint! // untuk atur panjang bar sesuai progressnya -> jadi var karena nilainya terus berubah
    
    private let previewImageView = UIImageView() // foto yang besar
    private let parameterNameLabel = UILabel()
    private let valueLabel = UILabel()
    private let slider = UISlider()
    private let tryThisButton = UIButton(type: .system)
    
    private let extremeStack = UIStackView()
    private let extremeLowImageView = UIImageView()
    private let extremeHighImageView = UIImageView()
    private let extremeLowLabel = UILabel()
    private let extremeHighLabel = UILabel()
    
    private let upcomingSectionLabel = UILabel()
    private let upcomingStack = UIStackView()
    private let shareButton = UIButton(type: .system)
    
    // print UIKit component -> for learning
    private var hasPrintedDebugInfo = false
    
    init(viewModel: TutorialModuleViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = Palette.background
        //        contentStackView.backgroundColor = .white
        setupLayout()
        configureStaticContent()
        bindViewModel()
        viewModel.viewDidLoad()
    }
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false // agar ga buat constraint bawaan
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 32),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        setupHeaderRow()
        setupProgressBar()
        setupPreviewSection()
        setupExtremeSection()
        setupUpcomingSection()
        setupShareButton()
        
    }
    
    private func setupHeaderRow() {
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = Palette.primaryText
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        screenTitleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        screenTitleLabel.textColor = Palette.primaryText
//        screenTitleLabel.text = viewModel.paramsInfo.title
        
        let spacer = UIView()
        
        let headerRow = UIStackView(arrangedSubviews: [backButton, screenTitleLabel, spacer])
        headerRow.axis = .horizontal
        headerRow.spacing = 15
        headerRow.alignment = .center
        contentStackView.addArrangedSubview(headerRow) // untuk masukkin component ke dalam UIStackView secara rapi
        
        positionLabel.font = .systemFont(ofSize: 14)
        positionLabel.textColor = Palette.secondaryText
//        positionLabel.text = viewModel.positionLabel
        
        progressPercentageLabel.font = .systemFont(ofSize: 14)
        progressPercentageLabel.textColor = Palette.secondaryText
        progressPercentageLabel.textAlignment = .right
        
        let positionRow = UIStackView(arrangedSubviews: [positionLabel, progressPercentageLabel])
        positionRow.axis = .horizontal
        contentStackView.addArrangedSubview(positionRow)
    }
    
    private func setupProgressBar() {
        progressTrackView.backgroundColor = Palette.progressTrack
        progressTrackView.layer.cornerRadius = 3
        progressTrackView.translatesAutoresizingMaskIntoConstraints = false
        progressTrackView.heightAnchor.constraint(equalToConstant: 6).isActive = true
        
        progressFillView.backgroundColor = Palette.primaryText
        progressFillView.layer.cornerRadius = 3
        progressFillView.translatesAutoresizingMaskIntoConstraints = false
        progressTrackView.addSubview(progressFillView)
        
        progressFillWidthConstraint = progressFillView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            progressFillView.leadingAnchor.constraint(equalTo: progressTrackView.leadingAnchor),
            progressFillView.topAnchor.constraint(equalTo: progressTrackView.topAnchor),
            progressFillView.bottomAnchor.constraint(equalTo: progressTrackView.bottomAnchor),
            progressFillWidthConstraint,
        ])
        
        contentStackView.addArrangedSubview(progressTrackView)
    }
    
    
    private func setupPreviewSection() {
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.layer.cornerRadius = 12
        previewImageView.clipsToBounds = true
        previewImageView.backgroundColor = Palette.cardBackground
        previewImageView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        contentStackView.addArrangedSubview(previewImageView)
        
        parameterNameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        parameterNameLabel.textColor = Palette.primaryText
        
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 15, weight: .medium)
        valueLabel.textColor = Palette.secondaryText
        valueLabel.textAlignment = .right
        
        let nameValueRow = UIStackView(arrangedSubviews: [parameterNameLabel, valueLabel])
        nameValueRow.axis = .horizontal
        contentStackView.addArrangedSubview(nameValueRow)
        
        slider.minimumTrackTintColor = Palette.primaryText
        slider.maximumTrackTintColor = Palette.progressTrack
        slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        contentStackView.addArrangedSubview(slider)
        
        var tryThisConfig = UIButton.Configuration.plain()
        tryThisConfig.title = "TRY THIS"
        tryThisConfig.baseForegroundColor = Palette.primaryText
        tryThisConfig.background.strokeColor = Palette.progressTrack
        tryThisConfig.background.strokeWidth = 1
        tryThisConfig.background.cornerRadius = 10
        tryThisConfig.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)
        tryThisButton.configuration = tryThisConfig
        tryThisButton.addTarget(self, action: #selector(tryThisTapped), for: .touchUpInside)
        contentStackView.addArrangedSubview(tryThisButton)
    }
    
    private func setupExtremeSection() {
        [extremeLowImageView, extremeHighImageView].forEach {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 10
            $0.backgroundColor = Palette.cardBackground
            $0.heightAnchor.constraint(equalToConstant: 100).isActive = true
        }
        [extremeLowLabel, extremeHighLabel].forEach {
            $0.font = .systemFont(ofSize: 11)
            $0.textColor = Palette.secondaryText
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        extremeLowLabel.text = "low"
        extremeHighLabel.text = "high"
        
        let lowColumn = UIStackView(arrangedSubviews: [extremeLowImageView, extremeLowLabel])
        lowColumn.axis = .vertical
        lowColumn.spacing = 4
        let highColumn = UIStackView(arrangedSubviews: [extremeHighImageView, extremeHighLabel])
        highColumn.axis = .vertical
        highColumn.spacing = 4
        
        extremeStack.axis = .horizontal
        extremeStack.spacing = 12
        extremeStack.distribution = .fillEqually
        extremeStack.addArrangedSubview(lowColumn)
        extremeStack.addArrangedSubview(highColumn)
        contentStackView.addArrangedSubview(extremeStack)
    }
    
    private func setupUpcomingSection() {
        upcomingSectionLabel.text = "UPCOMING LESSONS"
        upcomingSectionLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        upcomingSectionLabel.textColor = Palette.secondaryText
        contentStackView.addArrangedSubview(upcomingSectionLabel)
        
        upcomingStack.axis = .vertical
        upcomingStack.spacing = 10
        contentStackView.addArrangedSubview(upcomingStack)
        
        for module in viewModel.upcomingModules {
            let row = makeUpcomingRow(for: module)
            upcomingStack.addArrangedSubview(row)
        }
    }
    
    private func makeUpcomingRow(for module: GradingParameter) -> UIView {
        let container = UIView()
        container.backgroundColor = Palette.cardBackground
        container.layer.cornerRadius = 12
        
        let titleLabel = UILabel()
        titleLabel.text = module.title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = Palette.primaryText
        
        let durationLabel = UILabel()
        durationLabel.text = "Duration: \(module.durationMinutes) mins"
        durationLabel.font = .systemFont(ofSize: 12)
        durationLabel.textColor = Palette.secondaryText
        
        let textColumn = UIStackView(arrangedSubviews: [titleLabel, durationLabel])
        textColumn.axis = .vertical
        textColumn.spacing = 4
        
        let startBadge = UILabel()
        startBadge.text = "Start"
        startBadge.font = .systemFont(ofSize: 13, weight: .semibold)
        startBadge.textColor = Palette.secondaryText
        startBadge.backgroundColor = Palette.progressTrack
        startBadge.textAlignment = .center
        startBadge.layer.cornerRadius = 18
        startBadge.clipsToBounds = true
        startBadge.translatesAutoresizingMaskIntoConstraints = false
        startBadge.widthAnchor.constraint(equalToConstant: 60).isActive = true
        startBadge.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        let row = UIStackView(arrangedSubviews: [textColumn, startBadge])
        row.axis = .horizontal
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        
        container.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        
        // Buat seluruh row bisa di-tap, kita pasang UITapGestureRecognizer di container
        let tap = UITapGestureRecognizer(target: self, action: #selector(upcomingRowTapped(_:)))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        container.accessibilityIdentifier = module.id.rawValue // dipakai buat identifikasi row mana yang di-tap
        
        return container
    }
    
    private func setupShareButton() {
        var shareConfig = UIButton.Configuration.filled()
        shareConfig.title = "SHARE PROGRESS 🎉"
        shareConfig.baseBackgroundColor = .systemGreen
        shareConfig.baseForegroundColor = .white
        shareConfig.cornerStyle = .large
        shareButton.configuration = shareConfig
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        shareButton.isHidden = true
        contentStackView.addArrangedSubview(shareButton)
    }
    
    // MARK: - Static content
    
    private func configureStaticContent() {
        screenTitleLabel.text = "Color Grading Basics"
        positionLabel.text = viewModel.positionLabel
        progressPercentageLabel.text = "\(Int(viewModel.progressFraction * 100))% Complete"
        
        parameterNameLabel.text = viewModel.paramsInfo.title
        extremeLowLabel.text = "\(viewModel.paramsInfo.extremeLowLabel)"
        extremeHighLabel.text = "\(viewModel.paramsInfo.extremeHighLabel)"
        
        slider.minimumValue = viewModel.paramsInfo.sliderRange.lowerBound
        slider.maximumValue = viewModel.paramsInfo.sliderRange.upperBound
        slider.value = viewModel.currentSliderValue
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        viewModel.onPreviewUpdated = { [weak self] image in
            self?.previewImageView.image = image
        }
        viewModel.onValueLabelUpdated = { [weak self] text in
            self?.valueLabel.text = text
        }
        viewModel.onShareButtonVisibilityChanged = { [weak self] isVisible in
            self?.shareButton.isHidden = !isVisible
        }
        viewModel.onExtremePreviewsReady = { [weak self] low, high in
            self?.extremeLowImageView.image = low
            self?.extremeHighImageView.image = high
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let fullWidth = progressTrackView.bounds.width // update lebar progress bar
        progressFillWidthConstraint.constant = fullWidth * CGFloat(viewModel.progressFraction)
    }
    
    
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sliderChanged(_ sender: UISlider) {
        viewModel.sliderDidChange(to: sender.value)
    }
    
    @objc private func tryThisTapped() {
        let target = viewModel.tryThisTapped()
        slider.setValue(target, animated: true)
    }
    
    @objc private func shareTapped() {
        let items = viewModel.buildShareItems(extremeHighImage: extremeHighImageView.image)
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil) // untuk share sheetnya
        present(activityVC, animated: true) // show dari bawah ke atas kayak modal
    }
    
    // pindah ke halaman module lain
    @objc private func upcomingRowTapped(_ gesture: UITapGestureRecognizer) { // UITapGestureRecognizer untuk detect tap pada component yang gabisa diclick
        guard let rawID = gesture.view?.accessibilityIdentifier, let id = GradingParameterID(rawValue: rawID), let module = viewModel.upcomingModules.first(where: {$0.id == id}) else { return }
        let nextViewModel = viewModel.makeDetailViewModel(for: module)
        let nextVC = TutorialModuleViewController(viewModel: nextViewModel)
        navigationController?.pushViewController(nextVC, animated: true)
    }
}
