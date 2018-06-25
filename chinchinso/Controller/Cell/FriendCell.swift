//
//  FriendCell.swift
//  chinchinso
//
//  Created by hyunsu han on 2018. 2. 5..
//  Copyright © 2018년 hyunsu han. All rights reserved.
//

import UIKit
import LBTAComponents
import AlamofireImage

class FriendCell: UICollectionViewCell {
    
    let profile: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 25
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let name: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 20)
        lb.textColor = Color.shared.font
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profile)
        addSubview(name)
        profile.anchor(nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        profile.anchorCenterYToSuperview()
        name.anchor(nil, left: profile.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 50)
        name.anchorCenterYToSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension FriendCell: CellProtocol {
    typealias Item = Model.User
    func update(data user: Model.User) {
        if let url = user.profileUrl { profile.af_setImage(withURL: url) }
        name.text = user.name
    }
}


