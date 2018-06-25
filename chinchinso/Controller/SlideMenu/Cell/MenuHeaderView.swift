//
//  MenuHeaderView.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 11. 12..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import LBTAComponents
import AlamofireImage

class MenuHeaderView: UICollectionReusableView {
    
    let userImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.layer.cornerRadius = 30
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.clipsToBounds = true
        return iv
    }()
    let userNameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        lb.text = "사용자"
        return lb
    }()
    let heartImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "heart"))
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    var heartCountLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        return lb
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    // MARK: - NSCoding
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    fileprivate func setup() {
        
        self.addSubview(userImageView)
        self.addSubview(userNameLabel)
        self.addSubview(heartImageView)
        self.addSubview(heartCountLabel)
        
        userImageView.anchor(self.safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 45, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 60)
        userNameLabel.anchor(userImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 30)
        heartCountLabel.anchor(nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 45, leftConstant: 0, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 30)
        heartImageView.anchor(nil, left: nil, bottom: nil, right: heartCountLabel.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 30, heightConstant: 30)
        heartCountLabel.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor).isActive = true
        heartImageView.centerYAnchor.constraint(equalTo: heartCountLabel.centerYAnchor).isActive = true
        
    }
    
}

extension MenuHeaderView {
    func update(data: Model.User) {
        userNameLabel.text = data.name
        if let url = data.profileUrl { userImageView.af_setImage(withURL: url) }
        heartCountLabel.text = "\(data.heartCount)"
    }
    
}
