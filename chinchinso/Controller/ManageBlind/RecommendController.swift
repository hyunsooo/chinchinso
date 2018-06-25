//
//  RecommendController.swift
//  chinchinso
//
//  Created by hyunsu han on 2018. 2. 5..
//  Copyright © 2018년 hyunsu han. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RecommendController: UIViewController {

    var manageBlindControllerDelegate: ManageBlindControllerDelegate?
    let textView: UITextView = {
        let tv = UITextView()
        tv.layer.cornerRadius = 5
        tv.layer.masksToBounds = true
        tv.layer.borderWidth = 3
        tv.layer.borderColor = Color.shared.darkGreen.cgColor
        tv.backgroundColor = .white
        tv.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        tv.textColor = Color.shared.font
        tv.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
        tv.allowsEditingTextAttributes = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initViews()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initNavigationBar() {
        title = "내 친구는요"
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = Color.shared.background
        self.navigationController?.navigationBar.tintColor = .darkGray
        self.navigationController?.navigationBar.clipsToBounds = true               // bottom line hide
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-back").fillColor(.darkGray), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
        
        let uploadButton = UIButton(type: .system)
        uploadButton.backgroundColor = .white
        uploadButton.layer.borderColor = Color.shared.font.cgColor
        uploadButton.setTitleColor(Color.shared.font, for: .normal)
        uploadButton.setTitle("저장", for: .normal)
        uploadButton.layer.masksToBounds = true
        uploadButton.layer.cornerRadius = 15
        uploadButton.addTarget(self, action: #selector(uploadRecommend), for: .touchUpInside)
        uploadButton.frame = CGRect(x: 0, y: 0, width: 60, height: 35)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uploadButton)
    }
    
    fileprivate func initViews() {
        view.backgroundColor = Color.shared.background
        view.addSubview(textView)
        textView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 20, leftConstant: 10, bottomConstant: 20, rightConstant: 10, widthConstant: 0, heightConstant: 0)
    }
}

extension RecommendController {
    @objc fileprivate func back() { self.navigationController?.popViewController(animated: true) }
    @objc fileprivate func uploadRecommend() {
        guard let deleagte = self.manageBlindControllerDelegate else { return }
        App.api.uploadRecommend(recommend: self.textView.text) { [weak self] (dataResponse: DataResponse<JSON>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(_):
                deleagte.refresh()
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
