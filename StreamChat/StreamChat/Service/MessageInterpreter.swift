//
//  MessageInterpreter.swift
//  StreamChat
//
//  Created by James on 2021/10/21.
//

import Foundation

struct MessageInterpreter: MessageInterpretable {
    private let prohibitedUserInputTexts = ["::END", "USR_NAME::", "LEAVE::", "MSG::"]
    
    func interpret(_ mode: ChatWriteMode, checking text: String) -> Data? {
        var data: Data?
        switch mode {
        case .join:
            data = mode.format(text: text).data(using: .utf8)
        case .send:
            if !prohibitedUserInputTexts.contains(where: {text.contains($0)}) {
                data = mode.format(text: text).data(using: .utf8)
            }
        case .leave:
            data = mode.format(text: nil).data(using: .utf8)
        }
        return data
    }
}
