#!/bin/sh

#  run-test-cases.sh
#  contentstack
#
#  Created by Uttam Ukkoji on 30/07/19.
#

echo $DATE
echo "Cleaning Build Folder..."
xcodebuild clean -project contentstack-swift.xcodeproj -scheme Contentstack

#Get environment on which test will run
echo "Please select environment from following"
echo "Prod      Stag       Dev     Blz"

read environment

# Test result output folders
TEST_BUNDLE_PATH="./TestCase/Bundle/"
TEST_RESULT_PATH="./TestCase/Result/"
TEST_COVERAGE_PATH="./TestCase/Coverage"

# Date
DATE=$(date +'%v')

FILE_NAME="Contentstack-$environment-$DATE"

# Rmove all temparary Folder/Files
echo "Removing temparary files..."
rm -r "$TEST_RESULT_PATH"
rm -r "$TEST_BUNDLE_PATH"
rm -r "$TEST_COVERAGE_PATH"

mkdir "$TEST_COVERAGE_PATH"
##xcodebuild build-for-testing -workspace contentstack-swift.xcworkspace -scheme Contentstack -destination "id=841529D1-AEC3-4FF7-8AA4-079845D4FD4C"  -derivedDataPath "build"

# Run Contentstack-iOS Test case
echo "Running Test cases on iOS..."
xcodebuild \
    -workspace contentstack-swift.xcworkspace \
    -xcconfig "Supporting Files/$environment-contentstack.xcconfig" \
    -scheme Contentstack-test-iOS \
    test \
    -destination "id=841529D1-AEC3-4FF7-8AA4-079845D4FD4C" \
    -resultBundlePath "$TEST_BUNDLE_PATH/$FILE_NAME-iOS.xcresult" \
        | xcpretty \
            --color \
            --report html \
            --output "$TEST_RESULT_PATH/$FILE_NAME-test-result-iOS.html"

xcrun xccov view "$TEST_BUNDLE_PATH/$FILE_NAME-iOS.xcresult/1_Test/action.xccovreport" > "$TEST_COVERAGE_PATH/$FILE_NAME-iOS.coverage"

 Run Contentstack-tvOS Test case
echo "Running Test cases on tvOS..."

xcodebuild \
    -workspace contentstack-swift.xcworkspace \
    -xcconfig "Supporting Files/$environment-contentstack.xcconfig" \
    -scheme Contentstack-test-tvOS \
    test \
    -destination "id=9DA79524-53BA-4EA2-AA7C-D883EEF7AE4B" \
    -resultBundlePath "$TEST_BUNDLE_PATH/$FILE_NAME-tvOS.xcresult" \
        | xcpretty \
            --color \
            --report html \
            --output  "$TEST_RESULT_PATH/$FILE_NAME-test-result-tvOS.html"

xcrun xccov view "$TEST_BUNDLE_PATH/$FILE_NAME-tvOS.xcresult/1_Test/action.xccovreport" > "$TEST_COVERAGE_PATH/$FILE_NAME-tvOS.coverage"

# Run Contentstack-macOS Test case
echo "Running Test cases on macOS..."

xcodebuild \
    -workspace contentstack-swift.xcworkspace \
    -xcconfig "Supporting Files/$environment-contentstack.xcconfig" \
    -scheme Contentstack-test-macOS \
    test \
    -destination "id=16ED430D-3CA7-57B8-8783-C3EE560F2EF1" \
    -resultBundlePath "$TEST_BUNDLE_PATH/$FILE_NAME-macOS.xcresult" \
        | xcpretty \
            --color \
            --report html \
            --output "$TEST_RESULT_PATH/$FILE_NAME-test-result-macOS.html"

xcrun xccov view "$TEST_BUNDLE_PATH/$FILE_NAME-macOS.xcresult/1_Test/action.xccovreport" > "$TEST_COVERAGE_PATH/$FILE_NAME-macOS.coverage"

