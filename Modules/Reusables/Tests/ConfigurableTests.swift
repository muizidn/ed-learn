import XCTest
@testable import Reusables

final class ConfigurableTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_must_assign_object_property() {
        let object = DummyObject()
        let other = DummyObject()
        object.configure { o in
            o.dummyInt = 1
            o.dummyString = "one"
            o.dummyObject = other
        }
        XCTAssertEqual(object.dummyString, "one")
        XCTAssertEqual(object.dummyInt, 1)
        XCTAssertEqual(object.dummyObject, other)
    }
}


final class DummyObject: NSObject {
    var dummyInt = 0
    var dummyString = ""
    var dummyObject: DummyObject? = nil
}
