//
//  OpenDateCell.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 11. 27..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import AlamofireImage
import LBTAComponents

class OpenDateCell: UICollectionViewCell {
    
    let blind_profileImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let blind_name: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lb.textColor = .white
        return lb
    }()
    
//    let blind_appeal: UITextView = {
//        let tv = UITextView()
//        tv.font = UIFont.systemFont(ofSize: 15, weight: .medium)
//        tv.contentInset = UIEdgeInsetsMake(10, 0, 10, 0)
//        tv.allowsEditingTextAttributes = false
//        tv.isEditable = false
//        tv.isScrollEnabled = false
//        return tv
//    }()
    
    let matchmaker_profileImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 15
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let matchmaker_name: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lb.textColor = .white
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
        
        self.addSubview(blind_profileImage)
        self.addSubview(blind_name)
//        self.addSubview(blind_appeal)
        self.addSubview(matchmaker_name)
        self.addSubview(matchmaker_profileImage)
        
        blind_profileImage.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: self.bounds.width)
        blind_name.anchor(nil, left: leftAnchor, bottom: blind_profileImage.bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 10, rightConstant: 10, widthConstant: 0, heightConstant: 30)
//        blind_appeal.anchor(blind_profileImage.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: self.bounds.width , heightConstant: 0)
//        blind_appeal.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        
        matchmaker_profileImage.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 15, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        matchmaker_name.anchor(topAnchor, left: matchmaker_profileImage.rightAnchor, bottom: nil, right: nil, topConstant: 15, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 120, heightConstant: 30)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var estimateSizeCell: OpenDateCell = OpenDateCell()
}

// 2018. 02. 28 - 공개소개팅에서 자기 자신을 소개하는 문구 삭제됨에 따라 문구에 따라 사이징 조절되는 부분 삭제
extension OpenDateCell {
//    static func getSize(openDate: Model.OpenDate, width: CGFloat) -> CGSize {
//        OpenDateCell.estimateSizeCell.update(data: openDate)
//        let targetSize  = CGSize(width: width, height: 0)
//        let size = OpenDateCell.estimateSizeCell.blind_appeal.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
//        let width = size.width == 0 ? OpenDateCell.estimateSizeCell.bounds.width : size.width
//        let height = size.height == 0 ? width + 60 : width + size.height
//
//        return CGSize(width: width, height: height)
//    }
}

extension OpenDateCell: CellProtocol {
    typealias Item = Model.OpenDate
    func update(data date: Model.OpenDate) {
        if let blindProfileUrl = date.blind.user.profileUrl { blind_profileImage.af_setImage(withURL: blindProfileUrl) }
        if let matchMakerProfileUrl = date.matchmaker.profileUrl { matchmaker_profileImage.af_setImage(withURL: matchMakerProfileUrl) }
        blind_name.text = date.blind.user.name
//        var appeal = date.blind.appeal
//        if appeal.count > 100 {
//            appeal.removeSubrange( appeal.index(appeal.startIndex, offsetBy: 100)..<appeal.endIndex )
//            appeal += "..."
//        }
//        blind_appeal.text = appeal
        matchmaker_name.text = date.matchmaker.name
    }
}
