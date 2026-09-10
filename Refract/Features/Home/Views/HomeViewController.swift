//
//  HomeViewController.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

import UIKit

final class HomeViewController: UIViewController {
    
    private let viewModel = HomeViewModel()
    private let tableView = UITableView(frame: .zero, style: .plain) // .zero karena ikutin AutoLayout nanti
    private let helloLabel = UILabel()
    private let usernameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let avatarImageView = UIImageView()
    private let practiceModeCard = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.07, alpha: 1)
        setupTableView()
        setupPracticeModeCard()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) { // function yang jalan sebelum layar utama muncul, ini bawaan (termasuk juga kalo balik dari layar lain)
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        tableView.reloadData() // refresh badge "complete" saat kembali ke home
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ModuleCardCell.self, forCellReuseIdentifier: ModuleCardCell.reuseIdentifier) // daftarin type cell yang dipakai -> TableView ModuleCardCell
        tableView.tableHeaderView = makeHeaderView()
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func makeHeaderView() -> UIView {
        let container = UIView()
        helloLabel.text = "Hello,"
        helloLabel.textColor = UIColor(white: 0.7, alpha: 1)
        helloLabel.font = .systemFont(ofSize: 18)
        
        usernameLabel.text = "\(viewModel.userName)"
        usernameLabel.font = .systemFont(ofSize: 26, weight: .bold)
        usernameLabel.textColor = .white
        
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = UIColor(white: 0.7, alpha: 1)
        subtitleLabel.text = viewModel.greetingSubtitle
        
        let textColumn = UIStackView(arrangedSubviews: [helloLabel, usernameLabel, subtitleLabel])
        textColumn.axis = .vertical
        textColumn.spacing = 2
        textColumn.translatesAutoresizingMaskIntoConstraints = false
        textColumn.setCustomSpacing(8, after: usernameLabel)
        
        container.addSubview(textColumn)
        
        NSLayoutConstraint.activate([ // constant = margin/jarak
            textColumn.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            textColumn.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            textColumn.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            textColumn.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
        ])
        
        // UITableView.tableHeaderView perlu frame eksplisit, gak bisa autolayout doang
        container.frame = CGRect(x: 0, y: 0, width: 0, height: 110)
        return container
    }
    
    private func setupPracticeModeCard() {
        practiceModeCard.backgroundColor = .systemBlue
        practiceModeCard.layer.cornerRadius = 18
        practiceModeCard.translatesAutoresizingMaskIntoConstraints = false
        practiceModeCard.layer.shadowColor = UIColor.black.cgColor
        practiceModeCard.layer.shadowOpacity = 0.3
        practiceModeCard.layer.shadowRadius = 10
        practiceModeCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        let icon = UIImageView(image: UIImage(systemName: "wand.and.stars"))
        icon.tintColor = .white
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.widthAnchor.constraint(equalToConstant: 22).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.text = "Try Practice Mode"
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .white
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.widthAnchor.constraint(equalToConstant: 14).isActive = true
        
        let spacer = UIView()
        let row = UIStackView(arrangedSubviews: [icon, titleLabel, spacer, chevron])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 14, left: 18, bottom: 14, right: 18)
        practiceModeCard.addSubview(row)
        
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: practiceModeCard.topAnchor),
            row.leadingAnchor.constraint(equalTo: practiceModeCard.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: practiceModeCard.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: practiceModeCard.bottomAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(practiceModeTapped))
        practiceModeCard.addGestureRecognizer(tap)
        practiceModeCard.isUserInteractionEnabled = true
        
        view.addSubview(practiceModeCard)
        NSLayoutConstraint.activate([
            practiceModeCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            practiceModeCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            practiceModeCard.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
        
        // kasih table view bottom inset biar card terakhir di list ga ketutup sama floating card
        tableView.contentInset.bottom = 76
        tableView.verticalScrollIndicatorInsets.bottom = 76
    }
    
    private func bindViewModel() {
        viewModel.onProgressUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc private func practiceModeTapped() {
        let viewModel = viewModel.makePracticeModeViewModel()
        navigationController?.pushViewController(PracticeModeViewController(viewModel: viewModel), animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
// UITableViewDataSource -> mengatur sumber data di dalam table view
// UITableViewDelegate -> mengatur interaksi/tampilan di dalam table view

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { // jumlah section
        viewModel.completedModules.isEmpty ? 1 : 2 // kalau blm ada yg complete cuma 1, kalau udah ada yg complete jadi 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ModuleCardCell.reuseIdentifier, for: indexPath) as? ModuleCardCell else {
            return UITableViewCell() // fallback biar ga crash
        }
        let module = self.module(at: indexPath)
        let sneakPeek = viewModel.sneakPeekImages(for: module)
        cell.configure(
            title: module.cardTitle,
            durationMinutes: module.durationMinutes,
            beforeImage: sneakPeek.before,
            afterImage: sneakPeek.after,
            isComplete: viewModel.isModuleComplete(id: module.id)
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // buat header di setiap section
        let label = UILabel()
        label.text = section == 0 ? "Modules" : "Completed Modules"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIView()
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
        ])
        return container
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // buat nentuin tinggi header
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // apa action saat user tap salah satu cell
        tableView.deselectRow(at: indexPath, animated: true)
        guard let sampleImage = UIImage(named: "sample_photo") else { return }
        let module = self.module(at: indexPath)
        let moduleIndex = GradingParameterCatalog.all.firstIndex {$0.id == module.id} ?? 0
        let detailViewModel = viewModel.makeModuleDetailViewModel(at: moduleIndex, sampleImage: sampleImage)
        let detailViewControlller = TutorialModuleViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailViewControlller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // nentuin jumlah baris di dalam section tersebut
        section == 0 ? viewModel.numberOfModules : viewModel.completedModules.count
    }
    
    private func module(at indexPath: IndexPath) -> GradingParameter { // dari indexPath dijadiin data module
        indexPath.section == 0 ? viewModel.module(at: indexPath.row) : viewModel.completedModules[indexPath.row]
    }
    
}
