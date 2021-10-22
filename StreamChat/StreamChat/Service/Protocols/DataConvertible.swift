//
//  ChatRoomReceivable.swift
//  StreamChat
//
//  Created by James on 2021/10/20.
//

import Foundation

protocol DataConvertible: AnyObject {
    func convertDataToTexts(_ availableBytes: UnsafeMutablePointer<UInt8>, length: Int) throws
}
