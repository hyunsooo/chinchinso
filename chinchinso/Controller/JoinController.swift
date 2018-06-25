//
//  JoinController.swift
//  chinchinso
//
//  Created by hyunsu han on 2018. 2. 26..
//  Copyright © 2018년 hyunsu han. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import Alamofire

class JoinController: UIViewController {

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
    
    let nameTextField: UITextField = {
        let tf = PaddingTextField()
        tf.title = "이름"
        return tf
    }()
    
    let ageTextField: UITextField = {
        let tf = PaddingTextField()
        tf.title = "나이"
        return tf
    }()
    
    let genderTextField: UITextField = {
        let tf = PaddingTextField()
        tf.title = "성별"
        return tf
    }()
    
    let phoneTextField: UITextField = {
        let tf = PaddingTextField()
        tf.title = "전화번호"
        return tf
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
        view.addSubview(nameTextField)
        view.addSubview(ageTextField)
        view.addSubview(genderTextField)
        view.addSubview(phoneTextField)
        view.addSubview(joinButton)
        
        emailTextField.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 50, leftConstant: 60, bottomConstant: 0, rightConstant: 60, widthConstant: 0, heightConstant: 50)
        passwordTextField.anchor(emailTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 60, bottomConstant: 0, rightConstant: 60, widthConstant: 0, heightConstant: 50)
        nameTextField.anchor(passwordTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 60, bottomConstant: 0, rightConstant: 60, widthConstant: 0, heightConstant: 50)
        genderTextField.anchor(nameTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 60, bottomConstant: 0, rightConstant: 60, widthConstant: 0, heightConstant: 50)
        phoneTextField.anchor(genderTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 60, bottomConstant: 0, rightConstant: 60, widthConstant: 0, heightConstant: 50)
        ageTextField.anchor(phoneTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 60, bottomConstant: 0, rightConstant: 60, widthConstant: 0, heightConstant: 50)
        joinButton.anchor(ageTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 60, bottomConstant: 0, rightConstant: 60, widthConstant: 0, heightConstant: 50)
        
    }

    @objc func join() {
        guard let email = emailTextField.text else { alert(message: "이메일을 작성해주세요."); return }
        guard let password = passwordTextField.text else { alert(message: "비밀번호를 작성해주세요."); return }
        guard let name = nameTextField.text else { alert(message: "이름을 작성해주세요."); return }
        guard let gender = genderTextField.text else { alert(message: "성별을 작성해주세요."); return }
        guard let phone = phoneTextField.text else { alert(message: "전화번호를 작성해주세요."); return }
        guard let age = ageTextField.text else { alert(message: "나이를 작성해주세요."); return }
        
        App.api.join(email: email, password: password, name: name, age: Int(age) ?? 0, phone: phone, gender: gender) {
            print("회원가입이 완료되었습니다.")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func alert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
