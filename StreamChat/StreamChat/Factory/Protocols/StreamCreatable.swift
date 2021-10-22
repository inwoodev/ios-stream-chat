//
//  StreamConnectable.swift
//  StreamChat
//
//  Created by James on 2021/10/22.
//

import Foundation

protocol StreamCreatable {
    func createPairWithSocketToHost() -> (readStream: CFReadStream, writeStream: CFWriteStream)?
}
