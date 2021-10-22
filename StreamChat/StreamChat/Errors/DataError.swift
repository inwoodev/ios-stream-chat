//
//  DataError.swift
//  StreamChat
//
//  Created by James on 2021/10/19.
//

import Foundation

enum DataError: Error {
    case unableToReadGivenData
    case unableToWriteGivenData
    case unknownError
}
