//
// Created by Kevin Griffin on 4/14/22.
//

import XCTest

@testable import keying

final class CreateTests: XCTestCase {
    func badAuth() -> Bool {
        false
    }

    func testCreateAuthFail() {
        // fix throw instead
        XCTAssertEqual(_create(auth: badAuth), "")
    }

    func goodAuth() -> Bool {
        true
    }

    func testCreate() {
        // fix add seed
        let pk = _create(auth: goodAuth)
        XCTAssertTrue(pk.count > 0)
    }
    
    func testLocalAuth() {
//        localAuth()
    }
}

