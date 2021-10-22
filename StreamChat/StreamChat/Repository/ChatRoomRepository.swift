//
//  ChatNetworkManager.swift
//  StreamChat
//
//  Created by James on 2021/08/17.
//

import Foundation

final class ChatRoomRepository: NSObject, ChatRoomRepositorible {
    private var onInputStreamCompletion: () throws -> Void = { }
    private var outputStream: OutputStream?
    private var inputStream: InputStream?
    weak var delegate: DataConvertible?
    
    func connect() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, StreamInformation.host as CFString, UInt32(StreamInformation.portNumber), &readStream, &writeStream)
        
        guard let readStreamRetainedValue = readStream?.takeRetainedValue(),
              let writeStreamRetainedValue = writeStream?.takeRetainedValue() else { return }
        
        self.inputStream = readStreamRetainedValue
        self.outputStream = writeStreamRetainedValue
        
        self.inputStream?.delegate = self

        self.inputStream?.schedule(in: .current, forMode: .common)
        self.outputStream?.schedule(in: .current, forMode: .common)

        self.inputStream?.open()
        self.outputStream?.open()
    }
    
    func readAvailableBytes(stream: InputStream) {
        let availableBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: ConnectionConfiguration.maximumReadLength)
        
        while stream.hasBytesAvailable {
            guard let numberOfBytesRead = inputStream?.read(availableBytes, maxLength: ConnectionConfiguration.maximumReadLength) else { return }
            
            if numberOfBytesRead < 0,
               let error = stream.streamError {
                NSLog(error.localizedDescription)
                break
            }
            try? delegate?.convertDataToTexts(availableBytes, length: numberOfBytesRead)
        }
    }
    
    func writeWithUnsafeBytes(using data: Data) {
        data.withUnsafeBytes { unsafeBufferPointer in
            guard let buffer = unsafeBufferPointer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                NSLog("error while writing chat")
                return
            }
            outputStream?.write(buffer, maxLength: data.count)
        }
    }
    
    func disconnect() {
        self.inputStream?.close()
        self.outputStream?.close()
    }
}

// MARK: - Stream Delegate

extension ChatRoomRepository: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            guard let inputStream = aStream as? InputStream else { return }
            readAvailableBytes(stream: inputStream)
            NSLog("new message received")
        case .endEncountered:
            disconnect()
            NSLog("socketIsClosed")
        case .errorOccurred:
            NSLog("error occurred")
        case .hasSpaceAvailable:
            NSLog("has space available")
        default:
            NSLog("some other event...")
        }
    }
}
