import Foundation
import KeychainSwift
import LocalAuthentication
import Sodium

typealias AuthFunc = () -> Bool

func localAuth() -> Bool {
    let context = LAContext()
    var error: NSError?
    guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
        return false
    }

    var res = false
    let sem = DispatchSemaphore(value: 0)
    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authenticate") { success, _ in
        res = success
        sem.signal()
    }
    sem.wait()

    return res
}

/**
  create generates new public/private key pair, storing the private key in the keychain and returning the Base64
     encoded public key
 - Throws: `Keying.failedToCreateKeyPair`
 - Throws: `Keying.failedToEncodePublicKey`
 - Throws: `Keying.failedToSaveToKeychain`
 - Returns:
     Base64 encoded public key of generated key pair

  */
@_cdecl("create")
public func create() -> UnsafePointer<CChar> {
    UnsafePointer<CChar>(_create(auth: localAuth))
}

func _create(auth: AuthFunc) -> String {
    guard auth() else {
        return ""
    }

    let sodium = Sodium()

    guard let kp = sodium.box.keyPair() else {
        return ""
    }

    guard let pks: String = sodium.utils.bin2base64(kp.publicKey) else {
        return ""
    }

    let keychain = KeychainSwift()
    guard keychain.set(Data(_: kp.secretKey), forKey: pks, withAccess: .accessibleWhenPasscodeSetThisDeviceOnly) else {
        return ""
    }

    return pks
}

/**
  sign returns Base64 encoded signature for data (msg) by looked up private key via keychain from public key (pk)
  - Parameters:
     - msg: Base64 data to be encoded
     - pk:  Base64 Encoded public key used to look up signing secret key
 - Throws: `Keying.failedToCreateKeyPair`
 - Throws: `Keying.failedToEncodePublicKey`
 - Throws: `Keying.failedToSaveToKeychain`
 - Returns:
     Base64 encoded signature
  */
@_cdecl("sign")
public func sign(msg: UnsafePointer<CChar>, pk: UnsafePointer<CChar>) -> UnsafePointer<CChar> {
    UnsafePointer<CChar>("sign")
}
