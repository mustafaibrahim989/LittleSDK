//
//  ChatController.swift
//  Little
//
//  Created by Gabriel John on 20/07/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import FirebaseCore
import MessageKit
import FirebaseDatabase
import FirebaseAuth
import IQKeyboardManagerSwift

class ChatController: UIViewController {
    
    let am = SDKAllMethods()
    
    var ref = Database.database().reference(withPath: "fcQDCpI7H7HNMnUQ")
    var app: FirebaseApp?
    
    var sdkBundle: Bundle?
    
    @IBOutlet weak var txtMessage: UITextView!
    @IBOutlet weak var txtPlaceHolder: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var noMessagesView: UIView!
    @IBOutlet weak var lblNoMessages: UILabel!
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tableTop: NSLayoutConstraint!
    
    var doneToolBar: UIToolbar = UIToolbar()
    
    var trip_id = ""
    var messagesArr: [ChatMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkBundle = Bundle(for: Self.self)
        
        self.view.createLoadingNormal()
        
        let cellNib = UINib(nibName: "ChatFromCell", bundle: sdkBundle!)
        tableView.register(cellNib, forCellReuseIdentifier: "chatFromCell")
        
        let cellNib1 = UINib(nibName: "ChatToCell", bundle: sdkBundle!)
        tableView.register(cellNib1, forCellReuseIdentifier: "chatToCell")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditSDK))
        self.view.addGestureRecognizer(tap)
        
        trip_id = "\(am.EncryptDataMD5(DataToSend: am.getTRIPID()!))"
        
        btnSend.isEnabled = false
        btnSend.alpha = 0.6
        
        self.title = "\(am.getDRIVERNAME() ?? "Driver Chat")"
        
        lblNoMessages.text = "Send a message to \(am.getDRIVERNAME() ?? "your driver") by typing it out below and hitting send 😁"
        
        self.setupChatListeners()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        IQKeyboardManager.shared.enableAutoToolbar = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidDisappear), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidAppear), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enableAutoToolbar = true
        NotificationCenter.default.removeObserver(self)
        dismissSwiftAlert()
        updateIsTyping(bool: false)
    }
    
    @objc func keyboardDidAppear() {
//        tableTop.constant = 0
//        UIView.animate(withDuration: 0.1, animations: {
//            self.tableView.layoutIfNeeded()
//        }) { completed in
//            self.scrollToBottom()
//        }
    }

    @objc func keyboardDidDisappear() {
//        tableTop.constant = 0
//        tableView.layoutIfNeeded()
    }
    
    @IBAction func btnSendMessagePressed(_ sender: UIButton) {
        if txtMessage.text != "" {
            sender.createLoadingNormal()
            sendMessage(message: txtMessage.text!)
        }
    }
    
    func setupChatListeners() {
        ref.child(trip_id).child("AkXRrKhLyQJHQl77").observe(DataEventType.value, with: { (snapshot) in
            self.messagesArr.removeAll()
            if let messages = snapshot.value as? [String: AnyObject] {
                for message in messages {
                    let theMessage = message.value as? NSDictionary
                    let theId = theMessage?["vzra0puhTcj9Q6uo"] as? String ?? ""
                    let theCodebase = theMessage?["HMleGmzrq5TJaTRL"] as? String ?? ""
                    let thePhoneNumber = theMessage?["IJeuMtTyUu0675f6"] as? String ?? ""
                    let theDateTime = theMessage?["qoKqsPPgGGMbZlVN"] as? String ?? ""
                    let theText = theMessage?["v4b1RhYa7BOeqcSA"] as? String ?? ""
                    let theType = theMessage?["svSNDCpJGp68X0ag"] as? String ?? ""
                    let theIsRead = theMessage?["zPjl9dc88jPug8qj"] as? Bool ?? false
                    self.messagesArr.append(ChatMessage(id: self.am.DecryptDataKC(DataToSend: theId) as String, mid: message.key, codebase: self.am.DecryptDataKC(DataToSend: theCodebase) as String, phoneNumber: self.am.DecryptDataKC(DataToSend: thePhoneNumber) as String, dateTime: self.am.DecryptDataKC(DataToSend: theDateTime) as String, text: self.am.DecryptDataKC(DataToSend: theText) as String, type: self.am.DecryptDataKC(DataToSend: theType) as String, isread: theIsRead))
                    
                }
                
                printVal(object: self.messagesArr)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                self.messagesArr = self.messagesArr.sorted { dateFormatter.date(from: $0.dateTime!)! < dateFormatter.date(from: $1.dateTime!)! }
            
            }
            
            printVal(object: self.messagesArr)
            self.tableView.reloadData()
            
            if self.messagesArr.count > 0 {
                self.noMessagesView.isHidden = true
            } else {
                self.noMessagesView.isHidden = false
            }
            self.tableView.removeAnimation()
            
            self.adjustTableHeight()
            self.view.removeAnimation()
        })
        
        ref.child(trip_id).child("Du27S4li10B9EhgT").observe(DataEventType.value) { (snapshot) in
            if let status = snapshot.value as? NSDictionary {
                let statusText = status["TO0dypFCiThzooC8"] as? String
                if statusText != nil && statusText != "" {
                    typingStatus(text: self.am.DecryptDataKC(DataToSend: statusText!) as String)
                } else {
                    self.dismissSwiftAlert()
                }
            }
            self.adjustTableHeight()
        }
    }
    
    func sendMessage(message: String) {
        
        let update = ["vzra0puhTcj9Q6uo": am.EncryptDataKC(DataToSend: NSUUID().uuidString), "HMleGmzrq5TJaTRL": am.EncryptDataKC(DataToSend: "apple"), "IJeuMtTyUu0675f6": am.EncryptDataKC(DataToSend: am.getPhoneNumber()!), "qoKqsPPgGGMbZlVN": am.EncryptDataKC(DataToSend: "\(Date())"), "v4b1RhYa7BOeqcSA": am.EncryptDataKC(DataToSend: message), "svSNDCpJGp68X0ag": am.EncryptDataKC(DataToSend: "rider"), "zPjl9dc88jPug8qj": false] as [String : Any]
        
        ref.child(trip_id).child("AkXRrKhLyQJHQl77").childByAutoId().setValue(update)
        txtMessage.isEditable = true
        txtMessage.text = ""
        btnSend.removeAnimation()
    }
    
    func updateIsTyping(bool: Bool) {
        var update = ""
        if bool {
            update = "\(am.EncryptDataKC(DataToSend: "typing..."))"
        } else {
            update = ""
        }
        ref.child(trip_id).child("Du27S4li10B9EhgT").child("rvywLiFBCxEBCKkz").setValue(update)
    }
    
    func updateIsRead(bool: Bool, mid: String) {
        ref.child(trip_id).child("AkXRrKhLyQJHQl77").child(mid).child("zPjl9dc88jPug8qj").setValue(bool)
    }

    func adjustTableHeight() {
        var totalHeight = 0.0
        tableView.layoutIfNeeded()
        for i in (0..<messagesArr.count) {
            let frame = tableView.rectForRow(at: IndexPath(item: i, section: 0))
            printVal(object: frame.size.height)
            totalHeight = totalHeight + Double((frame.size.height))
        }
        tableHeight.constant = CGFloat(totalHeight)
        
        scrollToBottom()
    }
    
    func scrollToBottom() {
        if self.messagesArr.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(item:self.messagesArr.count-1, section: 0), at: .bottom, animated: true)
        }
    }
}

extension ChatController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        txtPlaceHolder.isHidden = true
        updateIsTyping(bool: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            txtPlaceHolder.isHidden = false
        }
        updateIsTyping(bool: false)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            btnSend.isEnabled = false
            btnSend.alpha = 0.6
        } else {
            btnSend.isEnabled = true
            btnSend.alpha = 1.0
        }
    }
    
    func textFieldShouldReturn(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        textView.isEditable = false
        sendMessage(message: textView.text!)
        return true
    }

}

extension ChatController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArr.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messagesArr[indexPath.item]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let dateTime = dateFormatter.date(from: message.dateTime ?? "")
        
        let color = cn.littleSDKThemeColor
        
        if message.type == "rider" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatToCell") as! ChatToCell
            
            cell.lblMessage.text = message.text
            if dateTime != nil {
                cell.lblDateTime.text = dateTime?.timeAgoDisplay()
            }
            cell.lblStatus.text = "✓✓"
            if message.isread ?? false {
                cell.lblStatus.textColor = color
            } else {
                cell.lblStatus.textColor = UIColor(named: "littleLabelColor")?.withAlphaComponent(0.6)
            }
            cell.lblMessage.textColor = UIColor(named: "chat_text_color_sent")
            cell.changeImage("chat_bubble_sent")
            cell.imgBubble.tintColor = UIColor(named: "chat_bubble_color_sent")
            cell.imgUser.sd_setImage(with: URL(string: am.getPicture()), placeholderImage: getImage(named: "default", bundle: sdkBundle!))
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatFromCell") as! ChatFromCell
            
            cell.lblMessage.text = message.text
            if dateTime != nil {
                cell.lblDateTime.text = dateTime?.timeAgoDisplay()
            }
            cell.lblStatus.text = ""
            cell.lblMessage.textColor = UIColor(named: "chat_text_color_received")
            cell.changeImage("chat_bubble_received")
            cell.imgBubble.tintColor = UIColor(named: "chat_bubble_color_received")
            cell.imgUser.sd_setImage(with: URL(string: am.getDRIVERPICTURE()), placeholderImage: getImage(named: "default", bundle: sdkBundle!))
            
            updateIsRead(bool: true, mid: message.mid ?? "")
            
            return cell
        }
        
    }
    
}

struct ChatMessage: Identifiable {
    
    var id: String
    var mid: String?
    var codebase: String?
    var phoneNumber: String?
    var dateTime: String?
    var text: String?
    var type: String?
    var isread: Bool?
    
    init(id: String, mid: String, codebase: String?, phoneNumber: String?, dateTime: String?, text: String?, type: String?, isread: Bool?) {
        self.id = id
        self.mid = mid
        self.codebase = codebase
        self.phoneNumber = phoneNumber
        self.dateTime = dateTime
        self.text = text
        self.type = type
        self.isread = isread
    }
    
}


