import XCTest

import QALintTests

var tests = [XCTestCaseEntry]()
tests += QALintTests.allTests()
XCTMain(tests)
