//
// Created by Kevin Griffin on 4/14/22.
//

import KeychainSwift
import Sodium
import XCTest

@testable import keying

final class CreateTests: XCTestCase {
    let sodium = Sodium()

    func badAuth() -> Bool {
        false
    }

    func testCreateAuthFail() {
        XCTAssertEqual(_create(auth: self.badAuth), "")
    }

    func goodAuth() -> Bool {
        true
    }

    func testCreate() {
        let pk = _create(auth: goodAuth, seed: [])
        XCTAssertTrue(pk.count > 0)

        // find key
        let keychain = KeychainSwift()
        let b = keychain.getData(pk)!
        XCTAssertEqual(b.count, 64)

        XCTAssertTrue(keychain.delete(pk))
    }

    func testCreateSeed() {
        let seed = self.sodium.utils.hex2bin("00 11 22 33 44 55 66 77 88 99 aa bb cc dd ee ff 00 11 22 33 44 55 66 77 88 99 aa bb cc dd ee ff", ignore: " ")!
        let pk = _create(auth: goodAuth, seed: seed)
        XCTAssertEqual(pk, "PM0kHP_Js2GARLl9A22GFFk9iwF8NA8d7odzOFUXZUs=")

        let keychain = KeychainSwift()
        let b = keychain.getData(pk)!
        XCTAssertEqual(self.sodium.utils.bin2base64([UInt8](b), variant: .URLSAFE),
                       "ABEiM0RVZneImaq7zN3u_wARIjNEVWZ3iJmqu8zd7v88zSQc_8mzYYBEuX0DbYYUWT2LAXw0Dx3uh3M4VRdlSw==")

        XCTAssertTrue(keychain.delete(pk))
    }

    func testSign() {
        let seed = self.sodium.utils.hex2bin("00 11 22 33 44 55 66 77 88 99 aa bb cc dd ee ff 00 11 22 33 44 55 66 77 88 99 aa bb cc dd ee ff", ignore: " ")!
        let kp = self.sodium.sign.keyPair(seed: seed)!

        let keychain = KeychainSwift()
        XCTAssertTrue(keychain.set(Data(_: kp.secretKey),
                                   forKey: self.sodium.utils.bin2base64(kp.publicKey, variant: .URLSAFE)!,
                                   withAccess: .accessibleWhenPasscodeSetThisDeviceOnly))

        let sig = _sign(message: "c2lnbiBtZQ==", pk: "PM0kHP_Js2GARLl9A22GFFk9iwF8NA8d7odzOFUXZUs=")
        XCTAssertEqual("wS36NW8pmUDaB8UXNMTAX-G7hHon2h4GhlC34-GnfexARB7aejkQ9oYu5TJ90JsfZ_juOENJGe30cSU2WXFCAw==", sig)
    }
}
