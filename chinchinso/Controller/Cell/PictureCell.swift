//
//  PictureCell.swift
//  chinchinso
//
//  Created by hyunsu han on 2018. 2. 1..
//  Copyright © 2018년 hyunsu han. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage

class PictureCell: UICollectionViewCell {
    
    var delegate: MyPictureControllerDelegate?
    var controller: MyPictureController?
    var sid: Int?
    
    let picture: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        iv.backgroundColor = Color.shared.background
        return iv
    }()
    
    let star: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "star"))
        iv.alpha = 0
        return iv
    }()
    
    lazy var editButton: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "edit").fillColor(.white))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(edit)))
        return iv
    }()
    
    let editBox: UIView = {
        let v = UIView()
        v.backgroundColor = Color.shared.background
        v.alpha = 0
        return v
    }()
    
    lazy var mainButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("대표사진 설정", for: .normal)
        btn.titleLabel?.textAlignment = .left
        btn.setTitleColor(Color.shared.font, for: .normal)
        btn.setTitleColor(.lightGray, for: .focused)
        btn.addTarget(self, action: #selector(updateMainPicture), for: .touchUpInside)
        return btn
    }()
    
    lazy var deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("삭제", for: .normal)
        btn.titleLabel?.textAlignment = .left
        btn.setTitleColor(Color.shared.font, for: .normal)
        btn.setTitleColor(.lightGray, for: .focused)
        btn.addTarget(self, action: #selector(deletePicture), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(picture)
        addSubview(editButton)
        addSubview(editBox)
        addSubview(star)
        editBox.addSubview(mainButton)
        editBox.addSubview(deleteButton)
        picture.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        editButton.anchor(topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 32, heightConstant: 32)
        editBox.anchor(editButton.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 130, heightConstant: 60)
        star.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 5, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 32, heightConstant: 32)
        mainButton.anchor(editBox.topAnchor, left: editBox.leftAnchor, bottom: nil, right: editBox.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 30)
        deleteButton.anchor(mainButton.bottomAnchor, left: editBox.leftAnchor, bottom: nil, right: editBox.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 30)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PictureCell: CellProtocol {
    typealias Item = Model.Picture
    func update(data: Model.Picture) {
        if let url = data.url { picture.af_setImage(withURL: url) }
        sid = data.sid
        star.alpha = data.isMain == 1 ? 1 : 0
    }
    
    @objc fileprivate func edit() {
        editBox.alpha = editBox.alpha == 0 ? 1 : 0
    }
    @objc fileprivate func deletePicture() {
        guard let delegate = delegate, let sid = sid else { return }
        App.api.deletePicture(picture: sid) { [weak self] (dataResponse: DataResponse<JSON>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(_):
                delegate.refresh()
                self.edit()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    @objc fileprivate func updateMainPicture() {
        guard let delegate = delegate, let sid = sid else { return }
        App.api.setMainProfilePicture(picture: sid) { [weak self] (dataResponse: DataResponse<JSON>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(_):
                delegate.refresh()
                self.edit()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
