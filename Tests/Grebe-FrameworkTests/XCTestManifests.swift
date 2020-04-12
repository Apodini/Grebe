import XCTest

#if !canImport(ObjectiveC)
/// All test cases
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(Grebe_FrameworkTests.allTests)
    ]
}
#endif
