import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Grebe_FrameworkTests.allTests)
    ]
}
#endif
