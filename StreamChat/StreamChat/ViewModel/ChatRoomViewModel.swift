//
//  ChatRoomService.swift
//  StreamChat
//
//  Created by James on 2021/10/18.
//

import Foundation

final class ChatRoomViewModel: MessageReadable {
    private (set) var myUserName: String
    private (set) var chatRoomTitle = "개울챗"
    private let chatRoomService: ChatRoomServiceable
    private var onUpdate: (() -> Void)?
    private (set) var chats: [ChatRoomTableViewCellModel] = [] {
        didSet {
            onUpdate?()
        }
    }
    
    init(chatRoomService: ChatRoomServiceable, myUserName: String) {
        self.chatRoomService = chatRoomService
        self.myUserName = myUserName
    }
    
    convenience init(myUserName: String) {
        let chatRoomService = ChatRoomService()
        self.init(chatRoomService: chatRoomService, myUserName: myUserName)
        chatRoomService.delegate = self
    }
    
    func bind(onUpdate: @escaping () -> Void) {
        self.onUpdate = onUpdate
    }
    
    func readTexts(_ texts: [String]) {
        let receivedChatDateText = Date().formattedString
        
        guard let receivedMessage = try? self.examineMessageSender(decodedTexts: texts) else { return }
        
        let chatRoomTableViewCellModel = ChatRoomTableViewCellModel(message: receivedMessage, currentDateRepresentation: receivedChatDateText)
            chats.append(chatRoomTableViewCellModel)
                  
    }
    
    func sendChat(with userInput: String, sender: MessageSender) -> Bool {
        let message = Message(content: userInput, senderUsername: myUserName, messageSender: .myself)
        do {
            try self.chatRoomService.convertToData(mode: .send, using: message)
            return true
        } catch {
            NSLog("Error Message : \(error)")
            return false
        }
        
    }
    
    func joinChat() {
        let joinMessage = Message(content: "", senderUsername: myUserName, messageSender: .system)
        try? self.chatRoomService.convertToData(mode: .join, using: joinMessage)
    }
    
    func leaveChat() {
        let leaveMessage = Message(content: "", senderUsername: "", messageSender: .system)
        try? self.chatRoomService.convertToData(mode: .leave, using: leaveMessage)
    }
    
    private func examineMessageSender(decodedTexts: [String]) throws -> Message {
        guard let messageUserName = decodedTexts.first,
              let messageContent = decodedTexts.last else {
                  throw DataError.unableToReadGivenData
              }
        if messageUserName != self.myUserName && decodedTexts.count == 2 {
            return Message(content: messageContent, senderUsername: messageUserName, messageSender: .someoneElse)
        } else if decodedTexts.count == 1 {
            return Message(content: messageContent, senderUsername: "", messageSender: .system)
        } else {
            return Message(content: messageContent, senderUsername: myUserName, messageSender: .myself)
        }
    }
}
