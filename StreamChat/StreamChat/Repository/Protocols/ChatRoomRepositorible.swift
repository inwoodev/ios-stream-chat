//
//  ChatRoomNetworkable.swift
//  StreamChat
//
//  Created by James on 2021/10/21.
//

import Foundation

protocol ChatRoomRepositorible: AnyObject {
    func connect()
    func readAvailableBytes(stream: InputStream)
    func writeWithUnsafeBytes(using data: Data)
    func disconnect()
}
