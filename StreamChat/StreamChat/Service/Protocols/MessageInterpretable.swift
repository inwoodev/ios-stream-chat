//
//  MessageInterpretable.swift
//  StreamChat
//
//  Created by James on 2021/10/21.
//

import Foundation

protocol MessageInterpretable {
    func interpret(_ mode: ChatWriteMode, checking message: Message) -> Data?
}
