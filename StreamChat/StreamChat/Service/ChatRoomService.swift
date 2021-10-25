//
//  ChatRoomService.swift
//  StreamChat
//
//  Created by James on 2021/10/18.
//

import Foundation

final class ChatRoomService: DataConvertible, ChatRoomServiceable {
    weak var delegate: MessageReadable?
    private let chatRoomRepository: ChatRoomRepositorible
    private let messageInterpreter: MessageInterpretable
    
    init(chatRoomRepository: ChatRoomRepositorible, messageInterpreter: MessageInterpretable) {
        self.chatRoomRepository = chatRoomRepository
        self.messageInterpreter = messageInterpreter
    }
    
    convenience init() {
        let chatRoomRepository = ChatRoomRepository(streamConnector: StreamFactory())
        self.init(chatRoomRepository: chatRoomRepository, messageInterpreter: MessageInterpreter())
        chatRoomRepository.connect()
        chatRoomRepository.delegate = self
    }

    func convertDataToTexts(_ availableBytes: UnsafeMutablePointer<UInt8>, length: Int) throws {
        guard let textArray = String(bytesNoCopy: availableBytes, length: length, encoding: .utf8, freeWhenDone: true)?.components(separatedBy: "::") else {
            throw DataError.unableToReadGivenData
        }
        delegate?.readTexts(textArray)
    }
    
    func convertToData(mode: ChatWriteMode, using text: String) throws {
        guard let data = messageInterpreter.interpret(mode, checking: text) else {
            throw DataError.unableToWriteGivenData
        }
        
        self.chatRoomRepository.writeWithUnsafeBytes(using: data)
        
    }
}
