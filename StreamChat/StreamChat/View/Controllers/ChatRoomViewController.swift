//
//  ChatRoomViewController.swift
//  StreamChat
//
//  Created by James on 2021/08/17.
//

import UIKit

class ChatRoomViewController: UIViewController {
    
    // MARK: - Properties
    
    private var bottomConstraint: NSLayoutConstraint?
    private let chatRoomViewModel: ChatRoomViewModel
    
    // MARK: - Views
    
    private let chatMessageView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(OthersMessageViewCell.self, forCellReuseIdentifier: OthersMessageViewCell.identifier)
        tableView.register(MyMessageViewCell.self, forCellReuseIdentifier: MyMessageViewCell.identifier)
        tableView.register(SystemMessageViewCell.self, forCellReuseIdentifier: SystemMessageViewCell.identifier)
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }()
    
    private let messageInputView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private let messageInputTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.backgroundColor = .systemGray5
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGreen
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.setTitle("send", for: .normal)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return button
    }()
    
    private lazy var messageInputStackView: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [ messageInputTextField, sendButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 5
        return stackView
    }()
    
    // MARK: - Methods
    
    init(chatRoomViewModel: ChatRoomViewModel) {
        self.chatRoomViewModel = chatRoomViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatRoomViewModel.joinChat()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        chatRoomViewModel.leaveChat()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChatViews()
        setUpChatRoomViewConstraints()
        setDelegates()
        changeLayoutWhenKeyboardShowsAndHides()
        navigationItem.title = chatRoomViewModel.chatRoomTitle
        updateChat()
        
    }
    
    private func updateChat() {
        chatRoomViewModel.bind { [weak self] in
            DispatchQueue.main.async {
                guard let numberOfChats = self?.chatRoomViewModel.chats.count else { return }
                
                let indexPath = IndexPath(row: numberOfChats - 1, section: 0)
                self?.chatMessageView.insertRows(at: [indexPath], with: .bottom)
                self?.chatMessageView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    private func setDelegates() {
        chatMessageView.dataSource = self
        messageInputTextField.delegate = self
    }
    
    private func changeLayoutWhenKeyboardShowsAndHides() {
        NotificationCenter.default.addObserver(self, selector: #selector(setViewLayoutWhenKeyboardShows), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setViewLayoutWhenKeyboardHides), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func setViewLayoutWhenKeyboardShows(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        bottomConstraint?.constant = -keyboardFrame.height - 8
        
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
            self.scrollToLastChat()
        }
    }
    
    @objc private func setViewLayoutWhenKeyboardHides(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        bottomConstraint?.constant = -30
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc private func sendMessage(_ sender: UIButton) {
        guard let nonEmptytext = messageInputTextField.text else { return }
        prepareToSendMessage(nonEmptytext)
        
        messageInputTextField.text = nil
    }
    
    private func scrollToLastChat() {
        guard !chatRoomViewModel.chats.isEmpty else { return }
        
        let lastIndex = IndexPath(row: chatRoomViewModel.chats.count - 1, section: 0)
        
        chatMessageView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
        
    }
    
    private func addChatViews() {
        self.view.addSubview(messageInputView)
        messageInputView.addSubview(messageInputStackView)
        self.view.addSubview(chatMessageView)
    }
    
    private func setUpChatRoomViewConstraints() {
        NSLayoutConstraint.activate([
            messageInputView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            messageInputView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            messageInputStackView.topAnchor.constraint(equalTo: messageInputView.topAnchor, constant: 5),
            messageInputStackView.leadingAnchor.constraint(equalTo: messageInputView.leadingAnchor, constant: 5),
            messageInputStackView.trailingAnchor.constraint(equalTo: messageInputView.trailingAnchor, constant: -5)
            
        ])
        bottomConstraint = messageInputStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30)
        bottomConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            chatMessageView.topAnchor.constraint(equalTo: self.view.topAnchor),
            chatMessageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            chatMessageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            chatMessageView.bottomAnchor.constraint(equalTo: self.messageInputView.topAnchor)
        ])
    }
    
    private func prepareToSendMessage(_ validText: String) {
        guard chatRoomViewModel.sendChat(with: validText, sender: .myself) else { return alertInvalidTextFieldInputToUser()
            
        }
    }
}

// MARK: - UITableViewDataSource

extension ChatRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRoomViewModel.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = chatRoomViewModel.chats[indexPath.row].message
        
        if message.messageSender == .myself {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MyMessageViewCell.identifier, for: indexPath) as? MyMessageViewCell else {
                return UITableViewCell()
            }
            cell.changeLabelText("\(message.senderUsername) \(message.content)")
            cell.setDateLabelText(Date().formattedString)
            return cell
        } else if message.messageSender == .someoneElse {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OthersMessageViewCell.identifier, for: indexPath) as? OthersMessageViewCell else {
                return UITableViewCell()
            }
            cell.changeLabelText("\(message.senderUsername): \(message.content)")
            cell.setDateLabelText(Date().formattedString)
            return cell
        } else if message.messageSender == .system {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SystemMessageViewCell.identifier, for: indexPath) as? SystemMessageViewCell else {
                return UITableViewCell()
            }
            cell.changeLabelText(message.content)
            return cell
        }
        return UITableViewCell()
        
    }
}

// MARK: - UITextFieldDelegate

extension ChatRoomViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let validText = textField.text else {
            return false
            
        }
        prepareToSendMessage(validText)
        messageInputTextField.text = nil
        
        return true
    }
    
    private func alertInvalidTextFieldInputToUser() {
        let alertViewController = UIAlertController(title: "잘못된 포멧", message: "빈 문자열은 전송할 수 없습니다. 이 중 해당되는 문자가 포함된 문자열 또한 전송할 수 없습니다. [USR_NAME::, LEAVE::, MSG::, LEAVE::] ", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertViewController.addAction(okAction)
        present(alertViewController, animated: true) { [weak self] in
            self?.messageInputTextField.text = nil
            
        }
    }
}
