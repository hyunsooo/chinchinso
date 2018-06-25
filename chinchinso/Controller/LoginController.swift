//
//  LoginController.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 11. 27..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import LBTAComponents
import Alamofire
import CryptoSwift

class LoginController: UIViewController {
    
    let emailTextField: UITextField = {
        let tf = PaddingTextField()
        tf.title = "이메일"
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = PaddingTextField()
        tf.title = "패스워드"
        tf.security = true
        return tf
    }()
    
    lazy var loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("로그인", for: .normal)
        btn.backgroundColor = .white
        btn.layer.borderColor = Color.shared.orangeYellow.cgColor
        btn.layer.borderWidth = 1
        btn.setTitleColor(Color.shared.font, for: .normal)
        btn.addTarget(self, action: #selector(login), for: .touchUpInside)
        return btn
    }()
    
    lazy var joinButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("회원가입", for: .normal)
        btn.backgroundColor = .white
        btn.layer.borderColor = Color.shared.orangeYellow.cgColor
        btn.layer.borderWidth = 1
        btn.setTitleColor(Color.shared.font, for: .normal)
        btn.addTarget(self, action: #selector(join), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.shared.background
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(joinButton)
        
        emailTextField.anchor(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 60, bottomConstant: 0, rightConstant: 60, widthConstant: 0, heightConstant: 50)
        emailTextField.anchorCenterYToSuperview()
        passwordTextField.anchor(emailTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 60, bottomConstant: 0, rightConstant: 60, widthConstant: 0, heightConstant: 50)
        loginButton.anchor(passwordTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 60, bottomConstant: 0, rightConstant: 60, widthConstant: 0, heightConstant: 50)
        joinButton.anchor(loginButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 60, bottomConstant: 0, rightConstant: 60, widthConstant: 0, heightConstant: 50)
        // Do any additional setup after loading the view.
    }

}

class PaddingTextField: UITextField {
    var title: String? {
        didSet {
            placeholder = title ?? ""
        }
    }
    
    var security: Bool? {
        didSet {
            isSecureTextEntry = security ?? false
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 50))
        leftView = leftPaddingView
        leftViewMode = .always
        font = UIFont.systemFont(ofSize: 15, weight: .medium)
        textColor = Color.shared.font
        backgroundColor = Color.shared.transparentOrangeYellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoginController {
    @objc fileprivate func login() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        App.api.login(email: email, password: password) {
            SlideMenu.shared.refresh()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) { self.dismiss(animated: true, completion: nil) }
        }
    }
    
    @objc fileprivate func join() {
        self.present(JoinController(), animated: true, completion: nil)
    }
}
