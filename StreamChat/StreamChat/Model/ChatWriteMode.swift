//
//  ChatWriteMode.swift
//  StreamChat
//
//  Created by James on 2021/10/21.
//

import Foundation

enum ChatWriteMode {
    case join, send, leave
    
    func format(text: String?) -> String {
        guard let validText = text else {
            return ""
            
        }
        
        switch self {
        case .join:
            return "USR_NAME::\(validText)::END"
        case .send:
            return "MSG::\(validText)::END"
        case .leave:
            return "LEAVE::::END"
        }
    }
}
