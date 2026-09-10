//
//  PracticeModeViewController.swift
//  Refract
//
//  Created by Davin P on 08/09/26.
//

import UIKit

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
    private let sliderStack = UIStackView()
    
    private let resultBadgeView = UIView()
    private let resultBadgeLabel = UILabel()
    private let submitButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    
    // simpan referensi slider & label per parameter, biar bisa reset tanpa rebuild UI
    private var sliderRefs: [GradingParameterID : UISlider] = [:]
    private var valueLabelRefs: [GradingParameterID : UILabel] = [:]
    private var resultIconRefs: [GradingParameterID: UIImageView] = [:]
    
    init(viewModel: PracticeModeViewModel = PracticeModeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Practice Mode"
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = Palette.background
        setupLayout()
        bindViewModel()
        setupNavigationBarAppearance()
        viewModel.loadSampleImage()
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
        
        sliderStack.axis = .vertical
        sliderStack.spacing = 16
        for params in GradingParameterID.allCases {
            sliderStack.addArrangedSubview(makeSliderRow(for: params))
        }
        
        resetButton.setTitle("Reset Sliders", for: .normal)
        resetButton.tintColor = Palette.secondaryText
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        setupResultBadge()
        setupSubmitButton()
        submitButton.isEnabled = true
        
        [previewImageView, sliderStack, resetButton, submitButton, resultBadgeView].forEach {
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
        
        let resultIcon = UIImageView(image: UIImage(systemName: "circle"))
        resultIcon.tintColor = Palette.secondaryText
        resultIcon.translatesAutoresizingMaskIntoConstraints = false
        resultIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        resultIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        resultIconRefs[parameter] = resultIcon
        
        let nameRow = UIStackView(arrangedSubviews: [nameLabel, resultIcon])
        nameRow.axis = .horizontal
        nameRow.spacing = 8
        
        let valueLabel = UILabel()
        valueLabel.textColor = Palette.secondaryText
        valueLabel.text = "0.00"
        //        row.addArrangedSubview(valueLabel)
        
        
        let slider = UISlider()
        slider.minimumValue = -5
        slider.maximumValue = 5
        slider.value = 0
        
        // cara baru dari addTarget
        slider.addAction(UIAction { [weak self, weak slider, weak valueLabel, weak resultIcon] _ in
            guard let self, let slider else { return } // unwrap weak reference
            self.viewModel.sliderDidChange(parameter: parameter, value: slider.value) // update currentValues dengan nilai slider terbaru
            valueLabel?.text = String(format: "%.2f", slider.value)
            resultIcon?.image = UIImage(systemName: "circle")
            resultIcon?.tintColor = Palette.secondaryText
        }, for: .valueChanged)
        
        row.addArrangedSubview(nameRow)
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
        }
        viewModel.onResultsUpdated = { [weak self] results, correctCount, total in
                    guard let self else { return }
                    for (parameter, isCorrect) in results {
                        let icon = self.resultIconRefs[parameter]
                        icon?.image = UIImage(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        icon?.tintColor = isCorrect ? Palette.okText : Palette.warningText
                    }
                    if correctCount == total {
                        self.resultBadgeLabel.text = "🎉 Perfect! Semua parameter udah pas."
                        self.resultBadgeLabel.textColor = Palette.okText
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } else {
                        self.resultBadgeLabel.text = "Benar \(correctCount)/\(total). Cek icon ❌ di slider yang masih salah."
                        self.resultBadgeLabel.textColor = Palette.warningText
                        UINotificationFeedbackGenerator().notificationOccurred(.warning)
                    }
                    self.resultBadgeView.isHidden = false
                }
    }
    
    @objc private func resetTapped() {
            viewModel.resetValues()
            for (parameter, slider) in sliderRefs {
                slider.setValue(0, animated: true)
                valueLabelRefs[parameter]?.text = "0.00"
                resultIconRefs[parameter]?.image = UIImage(systemName: "circle")
                resultIconRefs[parameter]?.tintColor = Palette.secondaryText
            }
            resultBadgeView.isHidden = true
        }
    
    @objc private func submitTapped() {
        viewModel.submitForFeedback()
    }
    
}
