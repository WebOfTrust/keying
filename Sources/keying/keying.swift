import Foundation
import KeychainSwift
import LocalAuthentication
import Sodium

@_cdecl("auth")
public func auth(msg: UnsafePointer<CChar>) -> Bool {
    let sodium = Sodium()
    let keychain = KeychainSwift()

    print(sodium)
    print(keychain)

    let context = LAContext()
    var error: NSError?
    guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
        return false
    }

    var res = false
    let sem = DispatchSemaphore(value: 0)
    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: String(cString: msg)) { success, _ in
        res = success
        sem.signal()
    }
    sem.wait()

    guard res else {
        return res
    }

    return res
}

@_cdecl("auth")
public func create(msg: UnsafePointer<CChar>) -> [UInt8] {}
