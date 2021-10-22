//
//  ChatRoomServicable.swift
//  StreamChat
//
//  Created by James on 2021/10/21.
//

import Foundation

protocol ChatRoomServiceable {
    func convertToData(mode: ChatWriteMode, using message: Message) throws
}
