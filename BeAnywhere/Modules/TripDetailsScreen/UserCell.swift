//
//  UserCell.swift
//  BeAnywhere
//
//  Created by Evelyn Xiao on 11/19/24.
//

import UIKit


//outer table
class UserCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    var wrapperCellView: UIView!
    var userNameLabel: UILabel!
    var innerTable: UITableView!
    var navigationController: UINavigationController!
    var tripId: String!
    
    
    // put this info into inner table
    var submittedStores: [FoodStoreFromDoc] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        setupWrapperCellView()
        setupUserNameLabel()
        setupTable()
        initConstraints()
    }
    
    func setupWrapperCellView() {
        wrapperCellView = UIView()
        wrapperCellView.backgroundColor = .white
        wrapperCellView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(wrapperCellView)
    }
    
    func setupTable() {
        innerTable = UITableView()
        innerTable.backgroundColor = .white
        innerTable.translatesAutoresizingMaskIntoConstraints = false
        innerTable.register(SubmittedStoreCell.self, forCellReuseIdentifier: TableConfigs.submittedStores)
        innerTable.dataSource = self
        innerTable.delegate = self
        innerTable.rowHeight = UITableView.automaticDimension
        innerTable.separatorStyle = .none
        wrapperCellView.addSubview(innerTable)
    }
    
    func setupUserNameLabel() {
        userNameLabel = UILabel()
        userNameLabel.textColor = .black
        userNameLabel.font = .systemFont(ofSize: 16, weight: .regular)
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(userNameLabel)
    }
    
    
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            wrapperCellView.topAnchor.constraint(equalTo: self.topAnchor),
            wrapperCellView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            wrapperCellView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            wrapperCellView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            userNameLabel.topAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: 10),
            userNameLabel.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 20),
            
            
            innerTable.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 0),
            innerTable.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor, constant: 10),
            innerTable.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -10),
            innerTable.bottomAnchor.constraint(equalTo: wrapperCellView.bottomAnchor),
            
            /*
            totalCostLabel.topAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: 2),
            totalCostLabel.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -2),
            
            foodStoreTable.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 2),
            foodStoreTable.bottomAnchor.constraint(equalTo: wrapperCellView.bottomAnchor),
            foodStoreTable.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor, constant: 2),
            foodStoreTable.trailingAnchor.constraint(equalTo: userNameLabel.trailingAnchor),
             */
            ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension UserCell {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("num stores: \(submittedStores.count)")
        return submittedStores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableConfigs.submittedStores, for: indexPath) as! SubmittedStoreCell
        let store = submittedStores[indexPath.row]
        cell.name.text = store.storeName
        cell.date.text = store.dateCreated.formatted()
        // get cost ?
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userItemsVC = UserItemsViewController()
        let store = submittedStores[indexPath.row]
        userItemsVC.store = store
        userItemsVC.tripId = tripId
        navigationController?.pushViewController(userItemsVC, animated: true)
    }
    
    
}