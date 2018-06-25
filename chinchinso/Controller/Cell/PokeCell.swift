//
//  PokeCell.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 12. 9..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import AlamofireImage

class PokeCell: UICollectionViewCell {
    
    let pokeProfileImage: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 15
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let pokeName: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lb.textColor = Color.shared.font
        return lb
    }()
    
    lazy var noButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = Color.shared.orangeYellow
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("거절", for: .normal)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 15
        btn.addTarget(self, action: #selector(handleNo), for: .touchUpInside)
        return btn
    }()
    
    lazy var yesButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .white
        btn.layer.borderColor = Color.shared.font.cgColor
        btn.setTitleColor(Color.shared.font, for: .normal)
        btn.setTitle("수락", for: .normal)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 15
        btn.addTarget(self, action: #selector(handleYes), for: .touchUpInside)
        return btn
    }()
    
    var delegate: MyInfoController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(pokeProfileImage)
        addSubview(pokeName)
        addSubview(noButton)
        addSubview(yesButton)
        pokeProfileImage.anchor(nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        pokeProfileImage.anchorCenterYToSuperview()
        pokeName.anchor(nil, left: pokeProfileImage.rightAnchor, bottom: nil, right: yesButton.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 30)
        pokeName.anchorCenterYToSuperview()
        
        noButton.anchor(nil, left: nil, bottom: nil, right: yesButton.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 50, heightConstant: 30)
        yesButton.anchor(nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 50, heightConstant: 30)
        yesButton.anchorCenterYToSuperview()
        noButton.anchorCenterYToSuperview()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PokeCell: CellProtocol {
    typealias Item = Model.Poke
    func update(data poke: Model.Poke) {
        if let url = poke.from.profileUrl { pokeProfileImage.af_setImage(withURL: url) }
        if poke.type == "c" { pokeName.text = "\(poke.from.name) (\(poke.match.name)의 친구)" }
        else { pokeName.text = "\(poke.from.name) (모두의 소개팅)" }
        
    }
    
    @objc fileprivate func handleNo() {
        print("거절")
        guard let delegate = delegate else { return }
        let alert = UIAlertController(title: "", message: "거절하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        delegate.present(alert, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleYes() {
        print("수락")
        guard let delegate = delegate else { return }
        let alert = UIAlertController(title: "", message: "수락하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        delegate.present(alert, animated: true, completion: nil)
    }
}
