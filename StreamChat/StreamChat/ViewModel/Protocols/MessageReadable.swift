//
//  MessageReadable!.swift
//  StreamChat
//
//  Created by James on 2021/10/20.
//

import Foundation

protocol MessageReadable: AnyObject {
    func readTexts(_ texts: [String])
}
