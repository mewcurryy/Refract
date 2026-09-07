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
    private let completedBadgeLabel = UILabel()
    
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
    
#if DEBUG // for reset progress
    private let debugResetButton = UIButton(type: .system)
#endif
    
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
        bindViewModel()
        configureStaticContent()
        viewModel.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshFromStore()
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
        
#if DEBUG
        setupDebugResetButton()
#endif
    }
    
    private func setupHeaderRow() {
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = Palette.primaryText
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        screenTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        screenTitleLabel.textColor = Palette.primaryText
        //        screenTitleLabel.text = viewModel.paramsInfo.title
        
        completedBadgeLabel.text = "✓ COMPLETED"
        completedBadgeLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        completedBadgeLabel.textColor = .systemGreen
        completedBadgeLabel.isHidden = true
        
        let spacer = UIView()
        
        let headerRow = UIStackView(arrangedSubviews: [backButton, screenTitleLabel, spacer, completedBadgeLabel])
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
        
        // fill untuk progress
        progressFillView.backgroundColor = Palette.primaryText
        progressFillView.layer.cornerRadius = 3
        progressFillView.translatesAutoresizingMaskIntoConstraints = false
        progressTrackView.addSubview(progressFillView)
        
        progressFillWidthConstraint = progressFillView.widthAnchor.constraint(equalToConstant: 0) // dijadiin 0 dulu karena progress dimulai dari 0
        NSLayoutConstraint.activate([
            progressFillView.leadingAnchor.constraint(equalTo: progressTrackView.leadingAnchor),
            progressFillWidthConstraint,
            progressFillView.topAnchor.constraint(equalTo: progressTrackView.topAnchor),
            progressFillView.bottomAnchor.constraint(equalTo: progressTrackView.bottomAnchor),
        ])
        
        contentStackView.addArrangedSubview(progressTrackView)
    }
    
    private func setupPreviewSection() {
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        previewImageView.layer.cornerRadius = 12
        previewImageView.backgroundColor = Palette.cardBackground
        previewImageView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        
        contentStackView.addArrangedSubview(previewImageView)
        
        parameterNameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        parameterNameLabel.textColor = Palette.primaryText
        
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        valueLabel.textColor = Palette.secondaryText
        valueLabel.textAlignment = .right
        
        let nameValueRow = UIStackView(arrangedSubviews: [parameterNameLabel, valueLabel])
        nameValueRow.axis = .horizontal
        contentStackView.addArrangedSubview(nameValueRow)
        
        slider.minimumTrackTintColor = Palette.primaryText
        slider.maximumTrackTintColor = Palette.progressTrack
        //        slider.thumbTintColor = .blue
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
            $0.heightAnchor.constraint(equalToConstant: 120).isActive = true
        }
        [extremeLowLabel, extremeHighLabel].forEach {
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = Palette.secondaryText
            $0.textAlignment = .center
        }
        extremeLowLabel.text = "LOW"
        extremeHighLabel.text = "HIGH"
        
        let lowColumn = UIStackView(arrangedSubviews: [extremeLowImageView, extremeLowLabel])
        lowColumn.axis = .vertical
        lowColumn.spacing = 4
        let highColumn = UIStackView(arrangedSubviews: [extremeHighImageView, extremeHighLabel])
        highColumn.axis = .vertical
        highColumn.spacing = 4
        
        // gabungin keduanya
        extremeStack.axis = .horizontal
        extremeStack.spacing = 12
        extremeStack.distribution = .fillEqually // biar ketengah kotaknya
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
        
        //        let dummyModules = GradingParameterCatalog.all
        //        upcomingStack.addArrangedSubview(makeUpcomingRow(for: viewModel.upcomingModules.first!))
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
        titleLabel.text = module.cardTitle
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = Palette.primaryText
        
        let durationLabel = UILabel()
        durationLabel.text = "Duration: \(module.durationMinutes) mins"
        durationLabel.font = .systemFont(ofSize: 12)
        durationLabel.textColor = Palette.secondaryText
        
        let textColumn = UIStackView(arrangedSubviews: [titleLabel, durationLabel])
        textColumn.axis = .vertical
        textColumn.spacing = 4
        
        let startBadge = UILabel()
        startBadge.text = "START"
        startBadge.font = .systemFont(ofSize: 12, weight: .semibold)
        startBadge.textColor = Palette.secondaryText
        startBadge.backgroundColor = Palette.progressTrack
        startBadge.textAlignment = .center
        startBadge.layer.cornerRadius = 16
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
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(upcomingRowTapped(_:)))
        container.addGestureRecognizer(tap) // sama aja kayak addTarget cuma buat UIView
        container.isUserInteractionEnabled = true
        container.accessibilityIdentifier = module.id.rawValue // dipakai untuk identifikasi row mana yang di-tap (misal contrast kah/brightness)
        return container
    }
    
    private func setupShareButton() {
        var shareConfig = UIButton.Configuration.filled()
        shareConfig.baseForegroundColor = .white
        shareConfig.baseBackgroundColor = .systemGreen
        shareConfig.title = "SHARE PROGRESS 🎉"
        shareConfig.cornerStyle = .large
        shareButton.configuration = shareConfig
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        shareButton.isHidden = true
        shareButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        contentStackView.addArrangedSubview(shareButton)
    }
#if DEBUG
    private func setupDebugResetButton() {
        debugResetButton.setTitle("[DEBUG] Reset All Progress", for: .normal)
        debugResetButton.setTitleColor(.systemRed, for: .normal)
        debugResetButton.titleLabel?.font = .systemFont(ofSize: 12)
        debugResetButton.addTarget(self, action: #selector(debugResetTapped), for: .touchUpInside)
        contentStackView.addArrangedSubview(debugResetButton)
        
        // biar button debug ga kebawahan
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
    }
    
    @objc private func debugResetTapped() {
        ModuleProgressStore.shared.resetAllProgress()
        viewModel.resetCompletionState()
        progressPercentageLabel.text = "\(Int(viewModel.progressFraction * 100))% Complete"
        view.setNeedsLayout()
        view.layoutIfNeeded()
        navigationController?.popToRootViewController(animated: true)
    }
    private func refreshProgressDisplay() {
        progressPercentageLabel.text = "\(Int(viewModel.progressFraction * 100))% Complete"
        completedBadgeLabel.isHidden = !viewModel.isModuleCompleted
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
#endif // DEBUG
    
    // MARK: - Static content
    private func configureStaticContent() {
        screenTitleLabel.text = viewModel.paramsInfo.cardTitle
        positionLabel.text = viewModel.positionLabel
        progressPercentageLabel.text = "\(Int(viewModel.progressFraction * 100))% Complete"
        
        parameterNameLabel.text = viewModel.paramsInfo.title
        extremeLowLabel.text = "\(viewModel.paramsInfo.extremeLowLabel)"
        extremeLowLabel.numberOfLines = 0
        extremeHighLabel.text = "\(viewModel.paramsInfo.extremeHighLabel)"
        extremeHighLabel.numberOfLines = 0
        
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
        viewModel.onExtremePreviewsReady = { [weak self] extremeLow, extremeHigh in
            self?.extremeLowImageView.image = extremeLow
            self?.extremeHighImageView.image = extremeHigh
        }
        viewModel.onCompletedBadgeVisibilityChanged = { [weak self] isVisible in
            self?.completedBadgeLabel.isHidden = !isVisible
        }
        viewModel.onProgressUpdated = { [weak self] in
            guard let self else {return}
            self.progressPercentageLabel.text = "\(Int(self.viewModel.progressFraction * 100))% Complete"
            DispatchQueue.main.async {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded() // trigger viewDidLayoutSubviews biar progressFillWidthConstraint ke-update
            }
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let fullWidth = progressTrackView.bounds.width
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
    
    // pindah ke halaman module lain tanpa balik ke home
    @objc private func upcomingRowTapped(_ gesture: UITapGestureRecognizer) { // UITapGestureRecognizer untuk detect tap pada component yang gabisa diclick
        guard let rawID = gesture.view?.accessibilityIdentifier, let id = GradingParameterID(rawValue: rawID), let module = viewModel.upcomingModules.first(where: {$0.id == id}) else { return }
        let nextViewModel = viewModel.makeDetailViewModel(for: module)
        let nextVC = TutorialModuleViewController(viewModel: nextViewModel)
        navigationController?.pushViewController(nextVC, animated: true)
    }
}
