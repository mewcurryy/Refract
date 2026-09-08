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
    private let practiceModeButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.07, alpha: 1)
        setupTableView()
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
        tableView.tableFooterView = makeFooterView()
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
        helloLabel.font = .systemFont(ofSize: 20)
        
        usernameLabel.text = "\(viewModel.userName)"
        usernameLabel.font = .systemFont(ofSize: 26, weight: .bold)
        usernameLabel.textColor = .white
        
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = UIColor(white: 0.7, alpha: 1)
        subtitleLabel.text = viewModel.greetingSubtitle
        
        let textColumn = UIStackView(arrangedSubviews: [helloLabel, usernameLabel, subtitleLabel])
        textColumn.axis = .vertical
        textColumn.spacing = 4
        
        avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        avatarImageView.tintColor = .black
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.backgroundColor = .white
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let headerRow = UIStackView(arrangedSubviews: [textColumn, avatarImageView])
        headerRow.axis = .horizontal
        headerRow.alignment = .top
        headerRow.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(headerRow)
        
        NSLayoutConstraint.activate([ // constant = margin/jarak
            headerRow.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            headerRow.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            headerRow.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            headerRow.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
        ])
        
        // UITableView.tableHeaderView perlu frame eksplisit, gak bisa autolayout doang
        container.frame = CGRect(x: 0, y: 0, width: 0, height: 150)
        return container
    }

    private func makeFooterView() -> UIView {
        let container = UIView()
        practiceModeButton.setTitle("Practice Mode", for: .normal)
        practiceModeButton.addTarget(self, action: #selector(practiceModeTapped), for: .touchUpInside)
        practiceModeButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(practiceModeButton)
        
        NSLayoutConstraint.activate([
            practiceModeButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            practiceModeButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            practiceModeButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)
        ])
        
        container.frame = CGRect(x: 0, y: 0, width: 0, height: 80)
        return container
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
        let cell = tableView.dequeueReusableCell(withIdentifier: ModuleCardCell.reuseIdentifier, for: indexPath) as! ModuleCardCell
        let module = self.module(at: indexPath)
        cell.configure(title: module.cardTitle, durationMinutes: module.durationMinutes)
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
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
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
