//
//  ProfileScreenView.swift
//  BeAnywhere
//
//  Created by Jimin Kim on 10/25/24.
//

import UIKit

class ProfileScreenView: UIView {
    
    var profilePic: UIImageView!
    
    var userInfo: UIStackView!
    var bio: UIStackView!
    
    var name: UILabel!
    var username: UILabel!
    var venmo: UILabel!

    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupStack()
        setupLabels()
        setupProfilePic()
        initConstraints()
    }
    
    func setupStack() {
        userInfo = UIStackView()
        userInfo.axis = .horizontal
        userInfo.spacing = 16
        userInfo.alignment = .leading
        userInfo.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(userInfo)
        
        bio = UIStackView()
        bio.axis = .vertical
        bio.spacing = 16
        bio.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupProfilePic() {
        profilePic = UIImageView()
        //profilePic.image = UIImage(systemName: "person.circle")
        profilePic.layer.cornerRadius = 20
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        userInfo.addArrangedSubview(profilePic)
        userInfo.addArrangedSubview(bio)
    }
    
    func setupLabels() {
        name = UILabel()
        name.textColor = .black
        name.font = .systemFont(ofSize: 16, weight: .bold)
        name.translatesAutoresizingMaskIntoConstraints = false
        bio.addArrangedSubview(name)
        
        username = UILabel()
        username.textColor = .black
        username.translatesAutoresizingMaskIntoConstraints = false
        bio.addArrangedSubview(username)
        
        venmo = UILabel()
        venmo.textColor = .black
        venmo.translatesAutoresizingMaskIntoConstraints = false
        bio.addArrangedSubview(venmo)
        
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            userInfo.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16),
            userInfo.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            userInfo.widthAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
            
            profilePic.widthAnchor.constraint(equalTo: userInfo.widthAnchor, multiplier: 0.25),
            profilePic.heightAnchor.constraint(equalTo: profilePic.widthAnchor),
            profilePic.leadingAnchor.constraint(equalTo: userInfo.leadingAnchor),
            profilePic.centerYAnchor.constraint(equalTo: userInfo.centerYAnchor),
            
            bio.leadingAnchor.constraint(equalTo: profilePic.trailingAnchor, constant: 20)
        ])
    }
}
