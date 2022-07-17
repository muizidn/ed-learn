import XCTest

extension XCTestCase {
     func trackMemory(_ instance: AnyObject, file: StaticString, line: UInt) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated potential memory leak", file: file, line: line)
        }
    }
}
