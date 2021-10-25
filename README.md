# 스트림챗 프로젝트

## 목차

1. [프로젝트 개요](#1-프로젝트-개요)
   - [MVVM](#mvvm)
   - [기술스택](#기술스택)
   - [AutoLayout](#autolayout)
2. [요구사항](2-요구사항)
   - [Stream 연결 구축 요구사항](#stream-연결-구축-요구사항)
3. [주요기능](#3-주요기능)
   - [로그인](#로그인)
   - [사용자 참가 메세지 수신](#사용자-참가-메세지-수신)
   - [채팅 발신 / 채팅 수신](#채팅-발신-채팅-수신)
   - [사용자 퇴장 메세지 수신](#사용자-퇴장-메세지-수신)
4. [설계 및 상세구현](4-설계-및-상세구현)
   - [채팅 전송 시나리오](#채팅-전송-시나리오)
   - [채팅 수신 시나리오](#채팅-수신-시나리오)
   - [입력 글자 제한 시나리오](#입력-글자-제한-시나리오)
5. [Trouble shooting을 포함한 학습내용](#5-trouble-shooting을-포함한-학습내용)
   - [Stream, Socket, Port에 대한 애플공식문서 번역](https://velog.io/@inwoodev/Aug-09-2021-TIL-Today-I-Learned-Streams-Sockets-and-Ports)
   - [소켓, Stream, 다양한 방법을 통한 iOS 앱 적용, 그리고 TroubleShooting](https://velog.io/@inwoodev/Oct-25-2021-TIL-Today-I-Learned-소켓-Stream-그리고-iOS앱-적용)
6. [추후 개선사항](6-추후-개선사항)
   - [소켓연결 방식 개선](#소켓연결-방식-개선)
   - [아키텍처 개선](#아키텍처-개선)

## 1. 프로젝트 개요

소켓 통신을 통해 참여자가 실시간 채팅을 할 수 있는 기능을 제공하는 앱입니다.

### MVVM

View와 비즈니스로직을 분리시켜서 추후에 추가 기능 및 수정이 요구되더라도 View와 비즈니스로직을 독립적으로 수정할 수 있다는 장점 때문에 MVVM 아키텍처를 적용하였습니다.

### 기술스택

| Category       | Stack            |
| -------------- | ---------------- |
| UI             | UIKit            |
| Network/Socket | CFStream, Stream |



### AutoLayout

View요소가 어떤 설정을 갖고 있고 View간의 제약사항이 어떻게 구현되어있는지 코드를 통해서 직관적으로 확인할 수 있기 때문에 코드로 UI를 구현하였습니다.

## 2. 요구사항

### Stream 연결 구축 요구사항

- URL : 15.165.55.224
- Port : 5080
- Protocol : TCP

위 정보를 바탕으로 보내고 받는 스트림 연결을 구축합니다. 주고 받는 데이터의 형식은 아래의 형식을 따릅니다.

| 상황                      | 데이터 포멧                 |
| ------------------------- | --------------------------- |
| 나의 채팅참가 알림        | USR_NAME::*{username}*::END |
| 타인의 채팅참가 알림 수신 | *{username}* has joined     |
| 타인의 채팅중단 알림 수신 | *{username}* has left       |
| 메시지 전송               | MSG::*{message}*::END       |
| 메시지 수신               | *{username}:*:*{message}*   |
| 채팅방 나가기             | LEAVE::::END                |

**보내는 메시지는 300자로 길이를 제한**합니다

```
포멧에 사용하는 prefix 및 postfix는 사용자가 입력할 수 없게 해야합니다.
예) 
- `USR_NAME::` 이 포함된 문자열을 입력하지 못하도록,
- `::END` 가 포함된 문자열을 입력하지 못하도록
```



#### [목차로 돌아가기](#목차)

## 3. 주요기능

### 로그인

![Simulator Screen Recording - iPhone 12 Pro - 2021-10-25 at 01.35.18](https://raw.githubusercontent.com/inwoodev/uploadedImages/uploadedFiles/20211025013537.gif)



### 사용자 참가 메세지 수신

**새로운 사용자가 채팅방 참가시 해당 참가자의 참여에 대한 메세지를 수신할 수 있습니다.**

![entryNotification](https://raw.githubusercontent.com/inwoodev/uploadedImages/uploadedFiles/20211026023044.gif)



### 채팅 발신 / 채팅 수신

**사용자 간의 실시간 대화내역이 화면에 표시됩니다.**

![SendAndReceiveChat](https://raw.githubusercontent.com/inwoodev/uploadedImages/uploadedFiles/20211026023521.gif)



### 사용자 퇴장 메세지 수신

**다른 참가자 퇴장시 퇴장하였다는 메세지를 수신할 수 있습니다**

![exitNotification](https://raw.githubusercontent.com/inwoodev/uploadedImages/uploadedFiles/20211026024739.gif)



#### [목차로 돌아가기](#목차)

## 4. 설계 및 상세구현

![Screen Shot 2021-10-25 at 11.20.52 AM](https://raw.githubusercontent.com/inwoodev/uploadedImages/uploadedFiles/20211025112121.png)



### 채팅 전송 시나리오

![Screen Shot 2021-10-25 at 8.47.09 PM](https://raw.githubusercontent.com/inwoodev/uploadedImages/uploadedFiles/20211025204716.png)

```swift
class ChatRoomViewController: UIViewController {
  .
  .
  .
  @objc private func sendMessage(_ sender: UIButton) {
        guard let nonEmptytext = messageInputTextView.text else { return }
        prepareToSendMessage(nonEmptytext)
        .
            .
            .
    }
  private func prepareToSendMessage(_ validText: String) {
        guard chatRoomViewModel.sendChat(with: validText, sender: .myself) else {
            return alertInvalidTextFieldInputToUser()
        }
    }
}
```

send버튼 클릭시 `ChatRoomViewController`는 뷰모델에게 메세지를 보내도록 지시합니다.



```swift
final class ChatRoomViewModel: MessageReadable {
  func sendChat(with userInput: String, sender: MessageSender) -> Bool {
        do {
            try self.chatRoomService.convertToData(mode: .send, using: userInput)
            return true
        } catch {
            NSLog("Error Message : \(error)")
            return false
        }
        
    }
}
```

`뷰모델`은 서비스모델에게 메세지를 데이터로 변환하도록 지시합니다.



```swift
final class ChatRoomService: DataConvertible, ChatRoomServiceable {
  func convertToData(mode: ChatWriteMode, using text: String) throws {
        guard let data = messageInterpreter.interpret(mode, checking: text) else {
            throw DataError.unableToWriteGivenData
        }
        
        self.chatRoomRepository.writeWithUnsafeBytes(using: data)
        
    }
}
```

`서비스모델` 은 전달받은 문자열을 Data로 변환하는 작업 맡게 됩니다. 

문자열을 변환하는 작업은messageInterpreter가 보내는 메세지의 타입을 필터링하여 요구사항에 맞는 데이터를 반환하고

반환된 데이터를 repository를 통해 서버로 데이터를 보낼 수 있게 됩니다.



### 채팅 수신 시나리오

![Screen Shot 2021-10-25 at 9.03.53 PM](https://raw.githubusercontent.com/inwoodev/uploadedImages/uploadedFiles/20211025210400.png)

```swift
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
```

StreamDelegate를 채택하고 있는`레포지토리` 의 `stream()` 메서드를 통해 스트림의 이벤트에 따른 데이터를 처리할 수 있고 `.hasBytesAvailable` 즉 서버로부터 새로 받아드릴 수 있는 데이터가 있는 경우 `readAvailableBytes()` 메서드를 통해 데이터를 수신 받게됩니다.

```swift
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
```

`inputStream`  이 읽어온 데이터에 따른 반환값이 0일 경우 에러로그를 찍으며 읽는 작업이 중지됩니다.

그렇지 않은 경우 대리자를 통해 받은 데이터를 문자열로 변환하는 작업을 수행하게 됩니다.



```swift
final class ChatRoomService: DataConvertible, ChatRoomServiceable {
  func convertDataToTexts(_ availableBytes: UnsafeMutablePointer<UInt8>, length: Int) throws {
        guard let textArray = String(bytesNoCopy: availableBytes, length: length, encoding: .utf8, freeWhenDone: true)?.components(separatedBy: "::") else {
            throw DataError.unableToReadGivenData
        }
        delegate?.readTexts(textArray)
    }
}
```

`ChatRoomService` 가 대리자로서 데이터를 받아서 문자열을 담은 배열을 만들어서 반환하게 됩니다.



```swift
final class ChatRoomViewModel: MessageReadable {
  private (set) var chats: [ChatRoomTableViewCellModel] = [] {
        didSet {
            onUpdate?()
        }
    }
  
  func readTexts(_ texts: [String]) {
        let receivedChatDateText = Date().formattedString
        
        guard let receivedMessage = try? self.examineMessageSender(decodedTexts: texts) else { return }
        
        let chatRoomTableViewCellModel = ChatRoomTableViewCellModel(message: receivedMessage, currentDateRepresentation: receivedChatDateText)
            chats.append(chatRoomTableViewCellModel)
                  
    }
}
```

 뷰모델이 문자열을 대리자로서 처리하여 뷰에 적합한 형태의 데이터로 가공하는 작업을 하게 됩니다.

TableViewCell에 보여지도록 가공을 한 뒤 준비된 데이터를 chats 배열에 넣어줌으로서 새로운 정보를 담은 데이터를 cell에 띄울 준비를 마치게 됩니다.



```swift
final class ChatRoomViewModel: MessageReadable {
  private var onUpdate: (() -> Void)?
  private (set) var chats: [ChatRoomTableViewCellModel] = [] {
        didSet {
            onUpdate?()
        }
    }
  
  func bind(onUpdate: @escaping () -> Void) {
        self.onUpdate = onUpdate
    }
}
```

chats의 정보가 갱신될 경우 `onUpdate?()` 클로저를 호출하게 설정하여 배열이 업데이트 된 후 UI 갱신을 할 수 있도록 설정을 하였습니다.



```swift
class ChatRoomViewController: UIViewController {
  override func viewDidLoad() {
    updateChat()
  }
  
  private func updateChat() {
        chatRoomViewModel.bind { [weak self] in
            DispatchQueue.main.async {
                guard let numberOfChats = self?.chatRoomViewModel.chats.count else { return }
                
                let indexPath = IndexPath(row: numberOfChats - 1, section: 0)
                self?.chatMessageView.insertRows(at: [indexPath], with: .bottom)
                self?.chatMessageView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
}
```

ChatRoomViewController에서 호출되는 viewModel의 bind 메서드를 통해 `updateChat()` 클로저에서 데이터 업데이트에 따른 지속적인 tableView의 cell업데이트 작업이 이루어지도록 설정하였습니다. 위 작업을 통해 새로운 채팅이 화면에 띄워질 수 있게 되었습니다.



### 입력 글자 제한 시나리오

#### 1. [요구사항](#2 요구사항) 에 따라 글자수가 300자가 될 경우:

![Simulator Screen Recording - iPhone 12 - 2021-10-25 at 21.57.37](https://raw.githubusercontent.com/inwoodev/uploadedImages/uploadedFiles/20211025215755.gif)

```swift
extension ChatRoomViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,         replacementText text: String) -> Bool {
              .
              .
              .
        let messageText = (textView.text as         NSString).replacingCharacters(in: range, with: text)
        
        return messageText.count <= textLimit
  }
```

textLimit라는 상수에 정수 300을 할당한 뒤 새로 입력되는 문자를 포함하는 `messageText` 의 문자 갯수가 textLimit의 갯수보다 작거나 같을 때만 새로운 입력값을 받아드릴 수 있도록 설정을 하였습니다. 따라서 사용자가 300자보다 더 많은 문자를 입력하지 못하도록 방지한 뒤



```swift
extension ChatRoomViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
        .
            .
            .
        if textView.text.count == textLimit {
            alertTextLimit()
        }
    }
}
```

 `UITextViewDelegate` 의 텍스트뷰를 감지하는 메서드에서 문자의 갯수가 textLimit과 같아질 경우 경고 메세지를 화면에 띄우도록 하였습니다.



#### 2. [요구사항](#2 요구사항) 에 따라 포함되면 안되는 문자열을 입력할 경우

![Simulator Screen Recording - iPhone 12 - 2021-10-25 at 22.02.25](https://raw.githubusercontent.com/inwoodev/uploadedImages/uploadedFiles/20211025220239.gif)

```swift
class ChatRoomViewController: UIViewController {
  .
  .
  .
  private func prepareToSendMessage(_ validText: String) {
        guard chatRoomViewModel.sendChat(with: validText, sender: .myself) else {
            return alertInvalidTextFieldInputToUser()
        }
    }
}
```

`sendChat()` 의 반환값이 false일 경우 잘못된 포멧에 대한 알림을 화면에 띄우도록 구현하였습니다.



```swift
struct MessageInterpreter: MessageInterpretable {
    private let prohibitedUserInputTexts = ["::END", "USR_NAME::", "LEAVE::", "MSG::"]
    
    func interpret(_ mode: ChatWriteMode, checking text: String) -> Data? {
        var data: Data?
        switch mode {
        case .join:
            data = mode.format(text: text).data(using: .utf8)
        case .send:
            if !prohibitedUserInputTexts.contains(where: {text.contains($0)}) {
                data = mode.format(text: text).data(using: .utf8)
            }
        case .leave:
            data = mode.format(text: nil).data(using: .utf8)
        }
        return data
    }
}
```

잘못된 문자열이 무엇인지는 `MessageInterpreter`가 갖고 있는 `prohibitedInputTexts` 를 통해 확인을 할 수 있습니다. `ChatRoomServiceModel` 에서 텍스트를 데이터로 변환할 때 interpreter가 메세지를 보내는 경우 prohibitedInputTexts 의 요소와 유저입력값을 비교 검증한 뒤 포함되는 경우 nil을 반환하도록 하여 잘못된 문자열을 거를 수 있게 구현하였습니다.

## 5. Trouble shooting을 포함한 학습내용

[Stream, Socket, Port에 대한 애플공식문서 번역](https://velog.io/@inwoodev/Aug-09-2021-TIL-Today-I-Learned-Streams-Sockets-and-Ports)

[소켓, Stream, 다양한 방법을 통한 iOS 앱 적용, 그리고 TroubleShooting](https://velog.io/@inwoodev/Oct-25-2021-TIL-Today-I-Learned-소켓-Stream-그리고-iOS앱-적용)



#### [목차로 돌아가기](#목차)

## 6. 추후 개선사항

### 소켓연결 방식 개선

#### 기존 방식:  `read` 무한 호출

```swift
// ChatNetworkManager의 read() 메서드
func read(completionHandler: @escaping (Result<Data, NetworkError>) -> Void) {
        streamTask?.readData(ofMinLength: ConnectionConfiguration.minimumReadLength, maxLength: ConnectionConfiguration.maximumReadLength, timeout: ConnectionConfiguration.timeOut) { data, _, error in

            guard let data = data else {
                return
            }
            
            completionHandler(.success(data))
            
            // MARK: - Read Log
            NSLog(String(data: data, encoding: .utf8) ?? "no message could be read")
            
            if let readError = error {
                NSLog(readError.localizedDescription)
            }
        }
    }
```

```swift
// chatRoom 모델의 receiveChat() 메서드
func receiveChat() {
        chatNetworkManager.read { [weak self] result in
            switch result {
            case .success(let data):
                defer {
                    self?.receiveChat()
                }
                DispatchQueue.main.async {
                    self?.delegate?.fetchMessageFromServer(data: data)
                }
            case .failure(let error):
                NSLog(error.localizedDescription)
            }
        }
    }
```

`ChatRoom` 모델이 read를 통해 데이터를 읽어온 뒤 매번 메서드가 종료되기 전 `receieveChat()` 메서드를 다시 호출하여 지속적으로 데이터를 읽어오는 방향으로 구현하였습니다.



이렇게 코드를 구현한 이유는 `StreamDelegate` 의 `stream(aStream: , handle)` 와 같이 연결된 소켓의 상태를 지속적으로 관찰 해 주는 메서드가 없기 때문입니다.



그런데 이렇게 코드를 구현하니 데이터를 읽지 않아도 되는 상황에도 불필요한 request와 connection을 생성해야 하는 문제가 생긴다는 점을 캐치하였습니다. 서버로부터 새로운데이터를 받지 않는 상황임에도 지속적으로 통신을 하게되니 채팅앱 사용시 새로운 메세지를 받지 않음에도 지속적으로 서버로부터 데이터를 읽어오는 작업이 끊임없이 실행 되는 것입니다. 이는 자칫하면 무한루프에 빠질 수도 있으니 매우 위험한 방식이라는 생각이 들었습니다.



#### 개선한 부분: StreamDelegate 를 활용한 이벤트 처리

URLStreamTask가 아닌 CFStream을 활용하여 InputStream과 OutputStream을 생성한 뒤 InputStream의 delegate에게 Stream의 이벤트 발생을 감지하여 상황에 맞게 데이터를 읽어오도록 수정을 하였습니다.

```swift
func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: ConnectionConfiguration.maximumReadLength)
        
        while stream.hasBytesAvailable {
            guard let numberOfBytesRead = inputStream?.read(buffer, maxLength: ConnectionConfiguration.maximumReadLength) else { return }
            
            if numberOfBytesRead < 0,
               let error = stream.streamError {
                NSLog(error.localizedDescription)
                break
            }
            try? delegate?.convertDataToTexts(buffer: buffer, length: numberOfBytesRead)
        }
    }
```

```swift
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
```

이와 같이 코드를 수정하니 더 이상 read의 무한루프에 대한 걱정도 할 필요가 없어졌고 실시간 통신 중 서버에 새로운 데이터를 받을 때만 데이터를 읽어올 수 있게 앱을 개선할 수 있었습니다.

### 아키텍처 개선

#### 문제점

기존 ChatRoomViewController에 다음과 같은 프로퍼티를 갖고 있었습니다.

```swift
class ChatRoomViewController: UIViewController {
    
    // MARK: - Properties
    
    var myUserName = ""
    private var chatList: [Message] = []
    private let chatRoom = ChatRoom(chatNetworkManager: ChatNetworkManager())
    private var bottomConstraint: NSLayoutConstraint?
    let prohibitedTexts = ["::END", "USR_NAME::", "LEAVE::", "MSG::"]
}
```

해당 프로퍼티들을 활용하여 ViewController는 다음과 같은 작업을 수행하게 됩니다.

- LoginViewController로부터 받은 myUserName을 cell에 넣어주는 작업

- ChatNetworkManager로 받아온 Message를 분석하여 수신자에 따라 다른 메세지를 TableView 에 적용될 Message 배열에 넣어주는 작업

  ```swift
  extension ChatRoomViewController: ChatReadable {
      func fetchMessageFromServer(data: Data) {
          guard let decodedMessageStringList = String(data: data, encoding: .utf8)?.components(separatedBy: "::"),
                let userName = decodedMessageStringList.first,
                let content = decodedMessageStringList.last else { return }
          if userName != self.myUserName && decodedMessageStringList.count == 2 {
              receiveMessage(username: "\(userName):", content: content)
          } else if userName != self.myUserName && decodedMessageStringList.count == 1 {
              receiveSystemMessage(content: content)
          }
      }
  }
  ```

  

- 사용자 채팅입력 시 포함되면 안되는 문자열을 걸러주는 작업

  ```swift
  extension ChatRoomViewController: UITextFieldDelegate {
      func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          if let text = textField.text,
                text.isEmpty == false,
                !prohibitedTexts.contains(where: {text.contains($0)}) {
              
              chatList.append(Message(content: text, senderUsername: "\(self.myUserName):", messageSender: .myself))
              chatRoom.send(text
      .
      .
      .
                           } else {
                alertInvalidTextFieldInputToUser()
              }
          }
      }
  ```

그렇다 보니 ViewController에게 많은 부하가 가게 되는 문제점을 발견하게 되었습니다.



#### MVVM을 활용한 ViewController의 부하 완화

#### ViewModel이 요청한 데이터를 응답하는 `ChatRoomService` 객체를 구현하였습니다.

- repository 객체가 받아온 bytes를 사용가능한 문자열로 변환하는 작업을 수행합니다.
- 사용자 입력 후 전달받은 Message의 컨텐츠에 포함되지말아야 할 문자열을 `messageInterpreter`를 통해 분석한 뒤 문제 없으면 소켓통신을 담당하는 repository에게 전달하하는 작업을 수행합니다.

```swift
final class ChatRoomService: DataConvertible, ChatRoomServiceable {
    weak var delegate: MessageReadable?
    private let chatRoomRepository: ChatRoomRepositorible
    private let messageInterpreter: MessageInterpretable
  
    init(chatRoomRepository: ChatRoomRepositorible, messageInterpreter: MessageInterpretable) {
        self.chatRoomRepository = chatRoomRepository
        self.messageInterpreter = messageInterpreter
    }
  func convertDataToTexts(_ availableBytes: UnsafeMutablePointer<UInt8>, length: Int) throws {
        guard let textArray = String(bytesNoCopy: availableBytes, length: length, encoding: .utf8, freeWhenDone: true)?.components(separatedBy: "::") else {
            throw DataError.unableToReadGivenData
        }
        delegate?.readTexts(textArray)
    }
    
    func convertToData(mode: ChatWriteMode, using message: Message) throws {
        guard let data = messageInterpreter.interpret(mode, checking: message) else {
            throw DataError.unableToWriteGivenData
        }
        
        self.chatRoomRepository.writeWithUnsafeBytes(using: data)
        
    }
}
```



#### `ChatRoomViewModel` 객체를 구현하여 데이터를 화면에 보여지기 적당한 형태로 **가공하는 역할**을 수행하도록 하였습니다.

```swift
final class ChatRoomViewModel: MessageReadable {
    private (set) var myUserName: String
    private (set) var chatRoomTitle = "개울챗"
    private let chatRoomService: ChatRoomServiceable
    private var onUpdate: (() -> Void)?
    private (set) var chats: [ChatRoomTableViewCellModel] = [] {
        didSet {
            onUpdate?()
        }
    }
    
    init(chatRoomService: ChatRoomServiceable, myUserName: String) {
        self.chatRoomService = chatRoomService
        self.myUserName = myUserName
    }
}
```

`ChatRoomViewModel` 객체를 통해

- `chatRoomService` 로부터 필요한 데이터를 요청하고

- 응답받은 데이터를 TableView의 Cell에 보여지도록 가공하여 저장저장하는 작업을 수행합니다.

  ```swift
  func readTexts(_ texts: [String]) {
          let receivedChatDateText = Date().formattedString
          
          guard let receivedMessage = try? self.examineMessageSender(decodedTexts: texts) else { return }
          
          let chatRoomTableViewCellModel = ChatRoomTableViewCellModel(message: receivedMessage, currentDateRepresentation: receivedChatDateText)
              chats.append(chatRoomTableViewCellModel)
                    
      }
  ```



- 사용자 입력시  `Service모델`에게 데이터를 write하도록 요청을합니다.

  ```swift
  func sendChat(with userInput: String, sender: MessageSender) -> Bool {
          do {
              self.chatRoomService.convertToData(mode: .send, using: userInput)
              return true
          } catch {
              NSLog("Error Message : \(error)")
              return false
          }
          
      }
  ```

  

#### `ChatRoomViewModel` 객체가 필요에 따라 **View에 데이터를 업데이트** 하는 책임을 부여하였습니다.

데이터바인딩은 다음과 같이 구현됩니다.

```swift
final class ChatRoomViewModel: MessageReadable {
  private var onUpdate: (() -> Void)?
     private (set) var chats: [ChatRoomTableViewCellModel] = [] {
      didSet {
          onUpdate?()
      }
    }
  .
  .
  .
  func bind(onUpdate: @escaping () -> Void) {
        self.onUpdate = onUpdate
    }
}
```

`프로퍼티 옵저버(didSet)`를 활용하여 TableViewCell에 띄어줄 컨텐츠를 담은 chats 배열의 값이 변경된 직후 onUpdate 변수를 호출하되도록 구성하여

```swift
class ChatRoomViewController: UIViewController {
  .
  .
  .
  override func viewDidLoad() {
    updateChat()
  }
  
  private func updateChat() {
        chatRoomViewModel.bind { [weak self] in
            DispatchQueue.main.async {
                guard let numberOfChats = self?.chatRoomViewModel.chats.count else { return }
                
                let indexPath = IndexPath(row: numberOfChats - 1, section: 0)
                self?.chatMessageView.insertRows(at: [indexPath], with: .bottom)
                self?.chatMessageView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
}
```

chats 배열의 값이 변경되면 ViewController가 데이터 변경을 `bind()` 메서드를 통해 인지하여 필요한 cell을 insert하게 하여 채팅이 tableView의 cell에 보이게 되도록 설계하였습니다.

#### 개선 결과

위와 같이 View Model에게 사용자에게 보여질 데이터에 해당되는 비즈니스 로직을 분리하였기 때문에 ViewController가 View의 구현, 그리고 수정에만 온전히 집중할 수 있게 되었습니다. 

기존에는 View와 Controller가 밀접하여 입 출력 관련 비즈니스로직을 테스트하기 어려웠지만 ViewModel을 활용한 모듈화를 통해 비즈니스 로직이 ViewModel로 완전히 분리되었기 때문에 추후 테스트에도 용이해지도록 설계할 수 있었습니다.

또한 View 입장에서는 비즈니스 로직을 담은 ViewModel을 각 화면에 따라 선택하여 사용할 수 있는 상황이 되었기 때문에 추후 서버로 부터 받는 데이터의 변경이 있더라도 ViewController와 View를 수정할 필요 없이 ViewModel과 Model을 교체하는 방향으로 설계할 수 있게 되었습니다. 반대로 디자인적인 요소에 변경이 필요할 경우 View와 ViewController를 **독립적**으로 수정하면 됩니다.

이처럼 아키텍처 개선을 통해 더욱 **확장성** 있는 앱으로 설계할 수 있었습니다.



#### [목차로 돌아가기](#목차)
