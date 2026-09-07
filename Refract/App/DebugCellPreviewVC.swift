// Bikin file testing sementara, misal DebugCellPreviewVC.swift
final class DebugCellPreviewVC: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.07, alpha: 1)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(ModuleCardCell.self, forCellReuseIdentifier: ModuleCardCell.reuseIdentifier)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3 // dummy count, biar keliatan 3 card
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ModuleCardCell.reuseIdentifier, for: indexPath) as! ModuleCardCell
        cell.configure(title: "Dummy Module \(indexPath.row + 1)", durationMinutes: 5)
        return cell
    }
}