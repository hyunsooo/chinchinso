//
//  HomeCell.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 12. 18..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit

class HomeCell: UICollectionViewCell {
    
    let matchmakerLabel: UILabel = {
        let lb = UILabel()
        lb.text = "주선한친구"
        lb.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lb.textColor = Color.shared.font
        return lb
    }()
    
    let matchmakerName : UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lb.textColor = Color.shared.font
        return lb
    }()
    
    let blindLabel: UILabel = {
        let lb = UILabel()
        lb.text = "소개팅상대"
        lb.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lb.textColor = Color.shared.font
        lb.textAlignment = .right
        return lb
    }()
    
    let blindName : UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lb.textColor = Color.shared.font
        lb.textAlignment = .right
        return lb
    }()
    
    let dateLabel : UILabel = {
        let lb = UILabel()
        lb.font = UIFont.italicSystemFont(ofSize: 15)
        lb.textColor = Color.shared.font
        lb.textAlignment = .center
        return lb
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        addSubview(matchmakerLabel)
        addSubview(matchmakerName)
        addSubview(blindLabel)
        addSubview(blindName)
        addSubview(dateLabel)
        
        dateLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        matchmakerLabel.anchor(dateLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 20)
        matchmakerName.anchor(matchmakerLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 20)
        blindLabel.anchor(dateLabel.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 100, heightConstant: 20)
        blindName.anchor(blindLabel.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 100, heightConstant: 20)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeCell: CellProtocol {
    typealias Item = Model.ChinchinDate
    func update(data date: Model.ChinchinDate) {
        matchmakerName.text = date.matchmaker.name
        blindName.text = date.blind.user.name
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        if let dateAt = date.dateAt { dateLabel.text = format.string(from: dateAt) }
    }
}
