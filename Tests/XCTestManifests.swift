import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ContentstackTests.allTests),
        testCase(ErrorTest.allTests),
        testCase(ParameterEncodingTest.allTests),
        testCase(QueryableRangeTest.allTests),
        testCase(QueryOperationTest.allTests),
        testCase(QueryParameterTest.allTests),
        testCase(EndPointTest.allTests),
        testCase(DecodableTest.allTests),
        testCase(CSDefinitionsTest.allTests),
        testCase(ImageTransformErrorTest.allTests),
        testCase(ContentstackTest.allTests),
        testCase(StackInitializationTest.allTests),
        testCase(TaxonomyUnitTest.allTests)
    ]
}
#endif
