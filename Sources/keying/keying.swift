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
 - Returns:
     Base64 encoded public key of generated key pair or "1" for error

  */
@_cdecl("create")
public func create() -> UnsafePointer<CChar> {
    UnsafePointer<CChar>(_create(auth: localAuth))
}

func _create(auth: AuthFunc, seed: [UInt8]? = []) -> String {
    guard auth() else {
        return ""
    }

    let sodium = Sodium()

    // force unwrap seed as it defaults to an empty array
    let (pk, sk) = _signKeyPair(seed: seed!)
    if pk.isEmpty || sk.isEmpty {
        return ""
    }

    guard let pks: String = sodium.utils.bin2base64(pk, variant: .URLSAFE) else {
        return ""
    }

    let keychain = KeychainSwift()
    guard keychain.set(Data(_: sk), forKey: pks, withAccess: .accessibleWhenPasscodeSetThisDeviceOnly) else {
        return ""
    }

    return pks
}

private func _signKeyPair(seed: [UInt8] = []) -> ([UInt8], [UInt8]) {
    let sodium = Sodium()
    if seed.isEmpty {
        guard let kp = sodium.sign.keyPair() else {
            return ([], [])
        }
        return (kp.publicKey, kp.secretKey)
    } else {
        guard let kp = sodium.sign.keyPair(seed: seed) else {
            return ([], [])
        }
        return (kp.publicKey, kp.secretKey)
    }
}

/**
  sign returns Base64 encoded signature for data (msg) by looked up private key via keychain from public key (pk)
  - Parameters:
     - msg: Base64 data to be encoded
     - pk:  Base64 Encoded public key used to look up signing secret key
 - Returns:
     Base64 encoded signature or "1" for error
  */
@_cdecl("sign")
public func sign(msg: UnsafePointer<CChar>, pk: UnsafePointer<CChar>) -> UnsafePointer<CChar> {
    UnsafePointer<CChar>(_sign(message: String(cString: msg), pk: String(cString: pk)))
}

func _sign(message: String, pk: String) -> String {
    let keychain = KeychainSwift()
    guard let sk = keychain.getData(pk) else {
        return ""
    }

    let sodium = Sodium()
    guard let bmsg = sodium.utils.base642bin(message, variant: .URLSAFE) else {
        return ""
    }

    guard let sig = sodium.sign.signature(message: bmsg, secretKey: [UInt8](sk)) else {
        return ""
    }

    guard let sigs: String = sodium.utils.bin2base64(sig, variant: .URLSAFE) else {
        return ""
    }

    return sigs
}
