//
//  MessageCell.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 12. 10..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import LBTAComponents

class MessageCell: UICollectionViewCell {
    
    let messageTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor.clear
        tv.isEditable = false
        return tv
    }()
    
    let bubbleView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 10
        v.layer.masksToBounds = true
        return v
    }()
    
    let profileImage: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        return iv
    }()
    
    lazy var messageImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 10
        iv.layer.masksToBounds = true
        iv.backgroundColor = .clear
        iv.isUserInteractionEnabled = true
//        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        return iv
        
    }()
    
    let dateLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 13, weight: .light)
        lb.textColor = Color.shared.font
        return lb
    }()
    
//    func handleZoomTap(tapGesture: UITapGestureRecognizer) {
//
//        let imageView = tapGesture.view as? UIImageView
//
//        self.chatLogController?.performZoomInForImageView(imageView: imageView!)
//
//
//    }
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    
    var dateRightAnchor: NSLayoutConstraint?
    var dateLeftAnchor: NSLayoutConstraint?
    
    static var estimatedCell: MessageCell = MessageCell()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImage)
        addSubview(bubbleView)
        addSubview(messageTextView)
        addSubview(dateLabel)
        bubbleView.addSubview(messageImageView)
        
        profileImage.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 32, heightConstant: 32)
        
        bubbleView.anchor(topAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleRightAnchor =  bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant : -8)
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: leftAnchor, constant : 48)
        
        messageImageView.anchor(bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        messageTextView.anchor(bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        messageTextView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        dateLabel.anchor(nil, left: nil, bottom: bubbleView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 120, heightConstant: 20)
        dateRightAnchor = dateLabel.rightAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: -5)
        dateLeftAnchor = dateLabel.leftAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: 5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MessageCell: CellProtocol {
    typealias Item = Chat.Message
    func update(data message: Chat.Message) {
        
        let isFile: Bool = message.image_url.count > 0  /* 어떤 메시지인가? */
        let isMyMessage: Bool = message.toId == message.getBlindId()  /* 누가 보낸 메시지인가? */
        
        bubbleWidthAnchor?.constant = isFile ? 200 : estimatedFrameForText(text: message.message).width + 25
        bubbleWidthAnchor?.isActive = true
        
        if isFile { if let fileUrl = URL(string: message.image_url) { messageImageView.af_setImage(withURL: fileUrl); bubbleView.backgroundColor = .white } }
        else { messageTextView.attributedText = NSMutableAttributedString(string: message.message, attributes: [.foregroundColor: UIColor.darkGray]) }
        discernMessage(isFile: isFile, isMyMessage: isMyMessage)
        
        let format = DateFormatter()
        format.dateFormat = "hh:mm a"
        dateLabel.text = format.string(from: Date(timeIntervalSince1970: TimeInterval( Int(truncating: message.timestamp) / 1000)))
    }
    
    func updateBlindProfileUrl(url: URL?) {
        if let url = url { profileImage.af_setImage(withURL: url) }
    }
    
    private func discernMessage(isFile: Bool, isMyMessage: Bool) {
        messageImageView.isHidden = !isFile
        messageTextView.isHidden = isFile
        messageTextView.textColor = isMyMessage ? .darkGray : .white
        bubbleView.backgroundColor = isMyMessage ? .white : Color.shared.transparentOrangeYellow
        profileImage.alpha = isMyMessage ? 0 : 1
        dateLabel.textAlignment = isMyMessage ? .right : .left
        
        guard let bubbleRight = bubbleRightAnchor, let bubbleLeft = bubbleLeftAnchor, let dateLeft = dateLeftAnchor, let dateRight = dateRightAnchor else { return }
        bubbleRight.isActive = isMyMessage
        dateRight.isActive = isMyMessage
        bubbleLeft.isActive = !isMyMessage
        dateLeft.isActive = !isMyMessage
        
        if !isMyMessage { dateLabel.textAlignment = .right }
    }
    
    private func estimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
}
