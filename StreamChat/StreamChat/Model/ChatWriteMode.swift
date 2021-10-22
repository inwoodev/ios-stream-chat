//
//  ChatWriteMode.swift
//  StreamChat
//
//  Created by James on 2021/10/21.
//

import Foundation

enum ChatWriteMode {
    case join, send, leave
    
    func format(text: String) -> String {
        switch self {
        case .join:
            return "USR_NAME::\(text)::END"
        case .send:
            return "MSG::\(text)::END"
        case .leave:
            return "LEAVE::::END"
        }
    }
}
