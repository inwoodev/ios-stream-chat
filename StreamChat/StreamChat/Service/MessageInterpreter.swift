//
//  MessageInterpreter.swift
//  StreamChat
//
//  Created by James on 2021/10/21.
//

import Foundation

struct MessageInterpreter: MessageInterpretable {
    private let prohibitedUserInputTexts = ["::END", "USR_NAME::", "LEAVE::", "MSG::"]
    
    func interpret(_ mode: ChatWriteMode, checking message: Message) -> Data? {
        var data: Data?
        switch mode {
        case .join:
            data = mode.format(text: message.senderUsername).data(using: .utf8)
        case .send:
            if !prohibitedUserInputTexts.contains(where: {message.content.contains($0)}) {
                data = mode.format(text: message.content).data(using: .utf8)
            }
        case .leave:
            data = mode.format(text: "").data(using: .utf8)
        }
        return data
    }
}
