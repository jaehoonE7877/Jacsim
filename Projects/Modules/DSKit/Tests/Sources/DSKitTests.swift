import Foundation
import XCTest

import Quick
import Nimble

@testable import DSKit

final class DSKitTestSpec: QuickSpec {
    override func spec() {
        describe("Given") {
            context("When") {
                it("Then") {
                    expect(1 + 1).to(equal(2))
                    expect(1.2).to(beCloseTo(1.1, within: 0.1))
                    expect(3) > 2
                }
            }
        }
    }
}
