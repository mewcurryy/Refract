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
    private let positionLabel = UILabel()
    private let progressPercentageLabel = UILabel()
    private let completedBadgeLabel = UILabel()
    
    private let progressTrackView = UIView()
    private let progressFillView = UIView()
    private var progressFillWidthConstraint: NSLayoutConstraint! // untuk atur panjang bar sesuai progressnya -> jadi var karena nilainya terus berubah
    
    private let previewImageView = UIImageView() // foto yang besar
    private let parameterNameLabel = UILabel()
    private let valueLabel = UILabel()
    
    // slider + 2 marker TRY THIS yang di-overlay di atas track-nya
    private let sliderContainer = UIView()
    private let slider = UISlider()
    private let firstTargetMarker = UIImageView()
    private let secondTargetMarker = UIImageView()
    private var firstMarkerCenterXConstraint: NSLayoutConstraint!
    private var secondMarkerCenterXConstraint: NSLayoutConstraint!
    private let tryThisHintLabel = UILabel()
    
    // penjelasan konsep, cuma muncul (dengan animasi) setelah kedua titik TRY THIS kena
    private let explanationCard = UIView()
    private let explanationTitleLabel = UILabel()
    private let explanationBodyLabel = UILabel()
    private let markCompleteButton = UIButton(type: .system)
    
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
        view.backgroundColor = Palette.background
        setupNavigationBarAppearance()
        setupCustomBackButton()
        setupLayout()
        bindViewModel()
        configureStaticContent()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        viewModel.refreshFromStore()
    }
    
    // MARK: - Navigation Bar
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = Palette.background
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupCustomBackButton() {
        var backConfig = UIButton.Configuration.plain()
        backConfig.image = UIImage(systemName: "chevron.backward")
        backConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        backConfig.baseForegroundColor = .white
        backConfig.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        backButton.configuration = backConfig
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        completedBadgeLabel.text = "  ✓ COMPLETED  "
        completedBadgeLabel.font = .systemFont(ofSize: 12, weight: .bold)
        completedBadgeLabel.textColor = .white
        completedBadgeLabel.backgroundColor = .systemGreen
        completedBadgeLabel.layer.cornerRadius = 10
        completedBadgeLabel.clipsToBounds = true
        completedBadgeLabel.isHidden = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
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
        setupTryThisSliderOverlay()
        setupExplanationCard()
        setupExtremeSection()
        setupUpcomingSection()
        setupShareButton()
        
#if DEBUG
        setupDebugResetButton()
#endif
    }
    
    private func setupHeaderRow() {
        positionLabel.font = .systemFont(ofSize: 14)
        positionLabel.textColor = Palette.secondaryText
        
        progressPercentageLabel.font = .systemFont(ofSize: 14)
        progressPercentageLabel.textColor = Palette.secondaryText
        progressPercentageLabel.textAlignment = .right
        
        let positionRow = UIStackView(arrangedSubviews: [positionLabel, progressPercentageLabel])
        positionRow.axis = .horizontal
        contentStackView.addArrangedSubview(positionRow)
        contentStackView.addArrangedSubview(completedBadgeLabel)
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
    }
    
    private func setupTryThisSliderOverlay() {
        sliderContainer.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(sliderContainer)
        
        slider.minimumTrackTintColor = Palette.primaryText
        slider.maximumTrackTintColor = Palette.progressTrack
        slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        sliderContainer.addSubview(slider)
        
        NSLayoutConstraint.activate([
            slider.topAnchor.constraint(equalTo: sliderContainer.topAnchor, constant: 16),
            slider.leadingAnchor.constraint(equalTo: sliderContainer.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: sliderContainer.trailingAnchor),
            slider.bottomAnchor.constraint(equalTo: sliderContainer.bottomAnchor)
        ])
        
        [firstTargetMarker, secondTargetMarker].forEach { marker in
            marker.image = UIImage(systemName: "circle.fill")
            marker.tintColor = Palette.progressTrack
            marker.backgroundColor = Palette.background
            marker.layer.cornerRadius = 7
            marker.translatesAutoresizingMaskIntoConstraints = false
            sliderContainer.addSubview(marker)
            NSLayoutConstraint.activate([
                marker.widthAnchor.constraint(equalToConstant: 14),
                marker.heightAnchor.constraint(equalToConstant: 14),
                marker.centerYAnchor.constraint(equalTo: slider.topAnchor, constant: -6)
            ])
        }
        
        firstMarkerCenterXConstraint = firstTargetMarker.centerXAnchor.constraint(equalTo: slider.leadingAnchor)
        secondMarkerCenterXConstraint = secondTargetMarker.centerXAnchor.constraint(equalTo: slider.leadingAnchor)
        firstMarkerCenterXConstraint.isActive = true
        secondMarkerCenterXConstraint.isActive = true
        
        tryThisHintLabel.text = "🎯 Slide the slider until you hit both points above."
        tryThisHintLabel.font = .systemFont(ofSize: 12)
        tryThisHintLabel.textColor = Palette.secondaryText
        tryThisHintLabel.textAlignment = .center
        tryThisHintLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(tryThisHintLabel)
    }
    
    private func setupExplanationCard() {
        explanationCard.backgroundColor = Palette.cardBackground
        explanationCard.layer.cornerRadius = 14
        explanationCard.alpha = 0
        explanationCard.isHidden = true
        explanationCard.transform = CGAffineTransform(translationX: 0, y: 12)
        
        explanationTitleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        explanationTitleLabel.textColor = Palette.primaryText
        explanationTitleLabel.numberOfLines = 0
        
        explanationBodyLabel.font = .systemFont(ofSize: 14)
        explanationBodyLabel.textColor = Palette.secondaryText
        explanationBodyLabel.numberOfLines = 0
        
        let textColumn = UIStackView(arrangedSubviews: [explanationTitleLabel, explanationBodyLabel])
        textColumn.axis = .vertical
        textColumn.spacing = 6
        textColumn.translatesAutoresizingMaskIntoConstraints = false
        textColumn.isLayoutMarginsRelativeArrangement = true
        textColumn.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        explanationCard.addSubview(textColumn)
        NSLayoutConstraint.activate([
            textColumn.topAnchor.constraint(equalTo: explanationCard.topAnchor),
            textColumn.leadingAnchor.constraint(equalTo: explanationCard.leadingAnchor),
            textColumn.trailingAnchor.constraint(equalTo: explanationCard.trailingAnchor),
            textColumn.bottomAnchor.constraint(equalTo: explanationCard.bottomAnchor)
        ])
        contentStackView.addArrangedSubview(explanationCard)
        
        // tombol ini yang beneran nge-trigger markComplete di ViewModel -> jelas & sengaja (bukan
        // auto-complete diam-diam), dan cuma muncul setelah penjelasan kebuka.
        var markCompleteConfig = UIButton.Configuration.filled()
        markCompleteConfig.title = "Mark as Complete ✓"
        markCompleteConfig.baseBackgroundColor = .systemGreen
        markCompleteConfig.baseForegroundColor = .white
        markCompleteConfig.cornerStyle = .capsule
        markCompleteButton.configuration = markCompleteConfig
        markCompleteButton.addTarget(self, action: #selector(markCompleteTapped), for: .touchUpInside)
        markCompleteButton.isHidden = true
        markCompleteButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        contentStackView.addArrangedSubview(markCompleteButton)
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
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right.circle.fill"))
        chevron.tintColor = .systemBlue
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.widthAnchor.constraint(equalToConstant: 26).isActive = true
        chevron.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        let row = UIStackView(arrangedSubviews: [textColumn, chevron])
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
        shareConfig.cornerStyle = .capsule
        shareButton.configuration = shareConfig
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        shareButton.isHidden = true
        shareButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        contentStackView.addArrangedSubview(shareButton)
    }
#if DEBUG
    private func setupDebugResetButton() {
        debugResetButton.setTitle("Reset All Progress", for: .normal)
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
        slider.setValue(viewModel.currentSliderValue, animated: false)
        progressPercentageLabel.text = "\(Int(viewModel.progressFraction * 100))% Complete"
        view.setNeedsLayout()
        view.layoutIfNeeded()
        navigationController?.popToRootViewController(animated: true)
    }
#endif // DEBUG
    
    // MARK: - Static content
    private func configureStaticContent() {
        title = viewModel.paramsInfo.cardTitle
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
            self.updateProgressLabelEmphasis()
            DispatchQueue.main.async {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded() // trigger viewDidLayoutSubviews biar progressFillWidthConstraint ke-update
            }
        }
        viewModel.onTargetHitStatusChanged = { [weak self] first, second in
            guard let self else { return }
            self.updateMarkerAppearance(self.firstTargetMarker, isHit: first)
            self.updateMarkerAppearance(self.secondTargetMarker, isHit: second)
            
            switch (first, second) {
            case (false, false):
                self.tryThisHintLabel.text = "🎯 Slide the slider until you hit both points above."
                self.hideExplanation(animated: false)
            case (true, false), (false, true):
                self.tryThisHintLabel.text = "🎯 You've hit one point! Find the other!"
            case (true, true):
                self.tryThisHintLabel.text = "Great! Read the explanation, then tap Mark as Complete ⬇️"
            }
        }
        viewModel.onExplanationRevealed = { [weak self] title, body in
            self?.revealExplanation(title: title, body: body)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let fullWidth = progressTrackView.bounds.width
        progressFillWidthConstraint.constant = fullWidth * CGFloat(viewModel.progressFraction)
        updateTargetMarkerPositions()
    }
    
    // MARK: - TRY THIS marker & explanation UI
    
    private func updateTargetMarkerPositions() {
        let range = slider.maximumValue - slider.minimumValue
        guard range > 0, slider.bounds.width > 0 else { return }
        let firstFraction = CGFloat((viewModel.paramsInfo.tryThisLowTarget - slider.minimumValue) / range)
        let secondFraction = CGFloat((viewModel.paramsInfo.tryThisHighTarget - slider.minimumValue) / range)
        firstMarkerCenterXConstraint.constant = slider.bounds.width * firstFraction
        secondMarkerCenterXConstraint.constant = slider.bounds.width * secondFraction
    }
    
    private func updateMarkerAppearance(_ marker: UIImageView, isHit: Bool) {
        let wasAlreadyHit = marker.tintColor == .systemGreen
        marker.image = UIImage(systemName: isHit ? "checkmark.circle.fill" : "circle.fill")
        marker.tintColor = isHit ? .systemGreen : Palette.progressTrack
        
        guard isHit, !wasAlreadyHit else { return }
        marker.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6) {
            marker.transform = .identity
        }
    }
    
    private func revealExplanation(title: String, body: String) {
        explanationTitleLabel.text = title
        explanationBodyLabel.text = body
        explanationCard.isHidden = false
        markCompleteButton.isHidden = false
        markCompleteButton.isEnabled = true
        
        var config = markCompleteButton.configuration
        config?.title = "Mark as Complete ✓"
        config?.baseBackgroundColor = .systemGreen
        markCompleteButton.configuration = config
        
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.4, options: [.curveEaseOut]) {
            self.explanationCard.alpha = 1
            self.explanationCard.transform = .identity
            self.view.layoutIfNeeded()
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    private func hideExplanation(animated: Bool) {
        markCompleteButton.isHidden = true
        let changes = {
            self.explanationCard.alpha = 0
            self.explanationCard.transform = CGAffineTransform(translationX: 0, y: 12)
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: changes) { _ in self.explanationCard.isHidden = true }
        } else {
            changes()
            explanationCard.isHidden = true
        }
    }
    
    private func updateProgressLabelEmphasis() {
        let isAllComplete = viewModel.progressFraction >= 1.0
        progressPercentageLabel.font = .systemFont(ofSize: 14, weight: isAllComplete ? .bold : .regular)
        progressPercentageLabel.textColor = isAllComplete ? .systemGreen : Palette.secondaryText
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sliderChanged(_ sender: UISlider) {
        viewModel.sliderDidChange(to: sender.value)
    }
    
    @objc private func markCompleteTapped() {
        viewModel.markAsComplete()
        markCompleteButton.isEnabled = false
        var config = markCompleteButton.configuration
        config?.title = "Completed ✓"
        config?.baseBackgroundColor = Palette.progressTrack
        markCompleteButton.configuration = config
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
