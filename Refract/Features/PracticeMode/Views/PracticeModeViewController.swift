//
//  PracticeModeViewController.swift
//  Refract
//
//  Created by Davin P on 08/09/26.
//

import UIKit
import PhotosUI

final class PracticeModeViewController: UIViewController {
    
    private let viewModel: PracticeModeViewModel
    
    private enum Palette {
        static let background = UIColor(white: 0.07, alpha: 1)
        static let cardBackground = UIColor(white: 0.13, alpha: 1)
        static let primaryText = UIColor.white
        static let secondaryText = UIColor(white: 0.6, alpha: 1)
        static let warningText = UIColor.systemOrange
        static let okText = UIColor.systemGreen
        static let accent = UIColor.systemBlue
    }
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let previewImageView = UIImageView()
    private let importButton = UIButton(type: .system)
    private let sliderStack = UIStackView()
    private let feedbackTitleLabel = UILabel()
    private let feedbackStack = UIStackView()
    
    private let resultBadgeView = UIView()
    private let resultBadgeLabel = UILabel()
    private let submitButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    private let previewPlaceholderLabel = UILabel()
    
    // simpan referensi slider & label per parameter, biar bisa reset tanpa rebuild UI
    private var sliderRefs: [GradingParameterID : UISlider] = [:]
    private var valueLabelRefs: [GradingParameterID : UILabel] = [:]
    
    init(viewModel: PracticeModeViewModel = PracticeModeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Practice Mode"
        view.backgroundColor = Palette.background
        setupNavigationBarAppearance()
        setupLayout()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
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
        // contentLayoutGuide (content size dari scroll view) dan frameLayoutGuide (content view itu sendiri), gunanya buat auto constraint
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
        
        previewImageView.backgroundColor = Palette.cardBackground
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.layer.cornerRadius = 12
        previewImageView.clipsToBounds = true
        previewImageView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        
        previewImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(importTapped))
        previewImageView.addGestureRecognizer(tapGesture)
        
        previewPlaceholderLabel.text = "📷  Tap to import photo"
        previewPlaceholderLabel.textColor = Palette.secondaryText
        previewPlaceholderLabel.font = .systemFont(ofSize: 14, weight: .medium)
        previewPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.addSubview(previewPlaceholderLabel)
        
        NSLayoutConstraint.activate([
            previewPlaceholderLabel.centerXAnchor.constraint(equalTo: previewImageView.centerXAnchor),
            previewPlaceholderLabel.centerYAnchor.constraint(equalTo: previewImageView.centerYAnchor)
        ])
        //        var importConfig = UIButton.Configuration.tinted()
        //        importConfig.baseBackgroundColor = Palette.accent
        //        importConfig.baseForegroundColor = Palette.primaryText
        //        importConfig.cornerStyle = .medium
        //        importConfig.imagePadding = 8
        //        importConfig.title = "Import from Gallery"
        //        importConfig.image = UIImage(systemName: "photo.on.rectangle.angled")
        //        importConfig.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
        //        importButton.configuration = importConfig
        //        importButton.addTarget(self, action: #selector(importTapped), for: .touchUpInside)
        
        sliderStack.axis = .vertical
        sliderStack.spacing = 16
        for params in GradingParameterID.allCases {
            sliderStack.addArrangedSubview(makeSliderRow(for: params))
        }
        
        resetButton.setTitle("Reset Sliders", for: .normal)
        resetButton.tintColor = Palette.secondaryText
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        
        feedbackTitleLabel.text = "Feedback"
        feedbackTitleLabel.textColor = Palette.primaryText
        feedbackTitleLabel.font = .boldSystemFont(ofSize: 18)
        feedbackTitleLabel.isHidden = true
        
        feedbackStack.axis = .vertical
        feedbackStack.spacing = 8
        feedbackStack.isHidden = true
        setupResultBadge()
        setupSubmitButton()
        
        [previewImageView, importButton, sliderStack, resetButton, submitButton, resultBadgeView, feedbackTitleLabel, feedbackStack].forEach {
            contentStackView.addArrangedSubview($0)
        }
    }
    
    private func makeSliderRow(for parameter: GradingParameterID) -> UIView {
        let row = UIStackView()
        row.axis = .vertical
        row.spacing = 4
        
        let nameLabel = UILabel()
        nameLabel.text = GradingParameterCatalog.all.first { $0.id == parameter }?.title
        nameLabel.textColor = Palette.primaryText
        
        let valueLabel = UILabel()
        valueLabel.textColor = Palette.secondaryText
        valueLabel.text = "0.00"
        //        row.addArrangedSubview(valueLabel)
        
        let slider = UISlider()
        slider.minimumValue = -5
        slider.maximumValue = 5
        slider.value = 0
        
        // cara baru dari addTarget
        slider.addAction(UIAction { [weak self, weak slider, weak valueLabel] _ in
            guard let self, let slider else { return } // unwrap weak reference
            self.viewModel.sliderDidChange(parameter: parameter, value: slider.value) // update currentValues dengan nilai slider terbaru
            valueLabel?.text = String(format: "%.2f", slider.value)
        }, for: .valueChanged)
        
        row.addArrangedSubview(nameLabel)
        row.addArrangedSubview(slider)
        row.addArrangedSubview(valueLabel)
        
        sliderRefs[parameter] = slider
        valueLabelRefs[parameter] = valueLabel
        
        return row
    }
    
    private func setupResultBadge() {
        resultBadgeView.backgroundColor = Palette.cardBackground
        resultBadgeView.layer.cornerRadius = 12
        resultBadgeView.isHidden = true
        
        resultBadgeLabel.numberOfLines = 0
        resultBadgeLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        resultBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        resultBadgeLabel.textAlignment = .center
        resultBadgeView.addSubview(resultBadgeLabel)
        
        NSLayoutConstraint.activate([
            resultBadgeLabel.topAnchor.constraint(equalTo: resultBadgeView.topAnchor, constant: 16),
            resultBadgeLabel.leadingAnchor.constraint(equalTo: resultBadgeView.leadingAnchor, constant: 16),
            resultBadgeLabel.trailingAnchor.constraint(equalTo: resultBadgeView.trailingAnchor, constant: -16),
            resultBadgeLabel.bottomAnchor.constraint(equalTo: resultBadgeView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupSubmitButton() {
        var config = UIButton.Configuration.filled()
        config.title = "Submit"
        config.baseBackgroundColor = Palette.accent
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        submitButton.configuration = config
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        submitButton.isEnabled = false
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = Palette.background
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func bindViewModel() {
        viewModel.onPreviewUpdated = { [weak self] image in
            self?.previewImageView.image = image
            self?.previewPlaceholderLabel.isHidden = image != nil // hidden kalau ada foto, kalau ga ada foto placeholder muncul
            self?.submitButton.isEnabled = self?.viewModel.hasImportedImage ?? false
        }
        viewModel.onFeedbackUpdated = { [weak self] feedbackMessage in
            self?.feedbackStack.isHidden = false
            self?.feedbackTitleLabel.isHidden = false
            self?.renderFeedback(feedbackMessage)
        }
    }
    
    private func renderFeedback(_ feedbackMessage: [FeedbackMessage]) {
        feedbackStack.arrangedSubviews.forEach { $0.removeFromSuperview() } // bersihin feedback yang lama
        let warnings = feedbackMessage.filter({ $0.severity == .warning })
        
        if warnings.isEmpty {
            feedbackTitleLabel.isHidden = true
            feedbackStack.isHidden = true
            return
        }
        
        for messages in warnings {
            let label = UILabel()
            label.numberOfLines = 0
            label.text = messages.message
            label.textColor = Palette.warningText
            feedbackStack.addArrangedSubview(label)
        }
    }
    
    @objc private func importTapped() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func resetTapped() {
        viewModel.resetValues()
        for (parameter, slider) in sliderRefs {
            slider.setValue(0, animated: true)
            valueLabelRefs[parameter]?.text = "0.00"
        }
        resultBadgeView.isHidden = true
        feedbackStack.isHidden = true
        feedbackTitleLabel.isHidden = true
    }
    
    @objc private func submitTapped() {
        viewModel.submitForFeedback()
        let feedbackMessages = viewModel.feedbackMessages
        let warningCount = feedbackMessages.filter { $0.severity == .warning }.count // itung berapa yang warning
        
        if warningCount == 0 {
            resultBadgeLabel.text = "🎉 Perfect Balance! Grading kamu udah mantap."
            resultBadgeLabel.textColor = Palette.okText
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            let issueWord = warningCount == 1 ? "issue" : "issues"
            resultBadgeLabel.text = " Masih ada \(warningCount) \(issueWord), coba lihat feedback di atas dan sesuaikan lagi!"
            resultBadgeLabel.textColor = Palette.warningText
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
        resultBadgeView.isHidden = false
    }
}

extension PracticeModeViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) // tutup picker
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return } // canLoadObject untuk cek dulu apakah provider ini bisa di-convert jadi UIImage
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async { // untuk jalanin di main thread
                self?.viewModel.imagePicked(image)
            }
        }
    }
}
