//
//  StreamConnector.swift
//  StreamChat
//
//  Created by James on 2021/10/22.
//

import Foundation

final class StreamFactory: StreamCreatable {
    func createPairWithSocketToHost() -> (readStream: CFReadStream, writeStream: CFWriteStream)? {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, StreamInformation.host as CFString, UInt32(StreamInformation.portNumber), &readStream, &writeStream)
        
        guard let readStreamRetainedValue = readStream?.takeRetainedValue(),
              let writeStreamRetainedValue = writeStream?.takeRetainedValue() else {
                  return nil
                  
              }
        
        return (readStreamRetainedValue, writeStreamRetainedValue)
    }
}
