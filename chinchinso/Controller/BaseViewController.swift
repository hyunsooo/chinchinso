//
//  BaseViewController.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 12. 8..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import Firebase
import Contacts
import SwiftyJSON
import Alamofire

class BaseViewController: UIViewController {
    
    let store = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuth()
        view.backgroundColor = Color.shared.background
        initNavigationBar()
        if SlideMenu.shared.user == nil { SlideMenu.shared.refresh() }
    }

    
    fileprivate func initNavigationBar() {
        let titleLogoWidth = 60.0
        let titleLogoHeight = titleLogoWidth * 45 / 129
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "logo_chinchinso").withRenderingMode(.alwaysOriginal).scaleToSize(aSize: CGSize(width: titleLogoWidth, height: titleLogoHeight)))
        titleImageView.contentMode = .bottomLeft
        // 30 * 2 를 빼는 이유는 왼쪽 마진을 30을 주어야 하는데 타이틀뷰는 가운데 정렬이기 때문에 오른쪽 마진도 30을 더 줘야한다. 그래서 가로에서 60을 뺌.
        // 70을 빼는 이유는 우측 아이콘 1개당 35씩 뺌, 각각 가로값이 35일 것이기 때문에 이를 빼주어야 함.
        titleImageView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width) - (30 * 2) - 35, height: Int(titleLogoHeight))
        navigationItem.titleView = titleImageView
        
        let menuButton = UIButton(type: .custom)
        menuButton.setImage(#imageLiteral(resourceName: "menu").withRenderingMode(.alwaysOriginal).scaleToSize(aSize: CGSize(width: 35, height: 40)), for: .normal)
        
        menuButton.addTarget(self, action: #selector(handleMenu), for: .touchUpInside)
        menuButton.frame = CGRect(x: 0, y: 0, width: 35, height: 40)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        let chatButton = UIButton(type: .custom)
        chatButton.setImage(#imageLiteral(resourceName: "heartChat").withRenderingMode(.alwaysOriginal).scaleToSize(aSize: CGSize(width: 35, height: 35))
            .fillColor(Color.shared.orangeYellow), for: .normal)
        
        chatButton.addTarget(self, action: #selector(handleChat), for: .touchUpInside)
        chatButton.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: chatButton)
        
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = Color.shared.background
        self.navigationController?.navigationBar.clipsToBounds = true       // bottom line hide
    }
    
    
    @objc private func handleMenu() {
        SlideMenu.shared.showMenu()
    }
    
    @objc func handleChat() {
        // Chat
        let chatListController = ChatListController()
        self.navigationController?.pushViewController(chatListController, animated: true)
    }
    
    @objc func logout() {
        guard Auth.auth().currentUser != nil else { print("파이어베이스에 연결된 사용자가 없습니다."); return }
        GlobalState.instance.uid = -1
        GlobalState.instance.name = nil
        GlobalState.instance.email = nil
        GlobalState.instance.password = nil
        try! Auth.auth().signOut()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) { [weak self] in
            self?.present(LoginController(), animated: true, completion: nil)
        }
    }
}


// get contacts and fetch to server
extension BaseViewController {
   
    // 권한 확인
    fileprivate func checkAuth() {
        // Contact Fetch
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authorizationStatus {
        case .denied, .notDetermined, .restricted:
            store.requestAccess(for: .contacts, completionHandler: { [weak self] (authorized, error) in
                guard let `self` = self else { return }
                guard authorized, error == nil else { print(error?.localizedDescription ?? "Contacts authorization : denied"); return }
                self.getAndFetchContacts()
            })
        case .authorized:
            getAndFetchContacts()
        }
    }
    
    // 전화번호 갖고 와서 서버에 전송
    fileprivate func getAndFetchContacts() {
//        guard let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey] as? [CNKeyDescriptor] else { return }
        guard let containers = try? store.containers(matching: nil) else { return }
        // 1. 모든 연락처 가져오기
        var contacts = [CNContact]()
        containers.forEach({ (container: CNContainer) in
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            guard let result = try? store.unifiedContacts(matching: fetchPredicate, keysToFetch: [CNContactPhoneNumbersKey as CNKeyDescriptor]) else { return }
            contacts.append(contentsOf: result)
        })
        // 2. 010 또는 011로 시작하는 전화번호 크롤링 후, 문자열 생성
        var phoneNumbers = ""
        contacts.forEach({ (contact) in
            contact.phoneNumbers.forEach({ (data: CNLabeledValue<CNPhoneNumber>) in
                guard let phone = data.value(forKey: "value") as? CNPhoneNumber else { return }
                guard let number = phone.value(forKey: "stringValue") as? String else { return }
                let trimmedNumber = number.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "-", with: "") // 공백, - 제거
                if trimmedNumber.hasPrefix("010") || trimmedNumber.hasPrefix("011") { phoneNumbers.append("\(number),") }
            })
        })
        // 3. 문자열이 있다면 끝자리를 제거 후, 서버로 전송.
        if phoneNumbers != "" {
            phoneNumbers.removeLast()
            App.api.fetchContacts(phones: phoneNumbers)
        }
    }
}
