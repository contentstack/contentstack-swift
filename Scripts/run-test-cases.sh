#!/bin/sh

#  run-test-cases.sh
#  contentstack
#
#  Created by Uttam Ukkoji on 30/07/19.
#

echo $DATE
echo "Cleaning Build Folder..."
xcodebuild clean -workspace Contentstack.xcworkspace -scheme "Contentstack iOS"
xcodebuild clean -workspace Contentstack.xcworkspace -scheme "Contentstack tvOS"
xcodebuild clean -workspace Contentstack.xcworkspace -scheme "Contentstack macOS"

# Test result output folders
TEST_BUNDLE_PATH="./TestCase/Bundle/"
TEST_RESULT_PATH="./TestCase/Result/"
TEST_COVERAGE_PATH="./TestCase/Coverage"

# Date
DATE=$(date +'%v')

FILE_NAME="Contentstack-$DATE"

# Rmove all temparary Folder/Files
echo "Removing temparary files..."
rm -r "$TEST_RESULT_PATH"
rm -r "$TEST_BUNDLE_PATH"
rm -r "$TEST_COVERAGE_PATH"
mkdir "./TestCase"
mkdir "$TEST_COVERAGE_PATH"
##xcodebuild build-for-testing -workspace contentstack-swift.xcworkspace -scheme Contentstack -destination "id=841529D1-AEC3-4FF7-8AA4-079845D4FD4C"  -derivedDataPath "build"

# Run Contentstack-iOS Test case
echo "Running Test cases on iOS..."
xcodebuild \
    -workspace Contentstack.xcworkspace \
    -scheme "Contentstack iOS" \
    -enableCodeCoverage YES \
    test \
    -destination "OS=15.5,name=iPhone 13" \
    -resultBundlePath "$TEST_BUNDLE_PATH/$FILE_NAME-iOS.xcresult" \
        | xcpretty \
            --color \
            --report html \
            --output "$TEST_RESULT_PATH/$FILE_NAME-test-result-iOS.html"

xcrun xccov view "$TEST_BUNDLE_PATH/$FILE_NAME-iOS.xcresult/1_Test/action.xccovreport" > "$TEST_COVERAGE_PATH/$FILE_NAME-iOS.coverage"

# Run Contentstack-tvOS Test case
#echo "Running Test cases on tvOS..."
#
#xcodebuild \
#    -workspace Contentstack.xcworkspace \
#    -scheme "Contentstack tvOS" \
#    test \
#    -destination "OS=14.0,name=Apple TV 4K" \
#    -resultBundlePath "$TEST_BUNDLE_PATH/$FILE_NAME-tvOS.xcresult" \
#        | xcpretty \
#            --color \
#            --report html \
#            --output  "$TEST_RESULT_PATH/$FILE_NAME-test-result-tvOS.html"
#
#xcrun xccov view "$TEST_BUNDLE_PATH/$FILE_NAME-tvOS.xcresult/1_Test/action.xccovreport" > "$TEST_COVERAGE_PATH/$FILE_NAME-tvOS.coverage"
#
## Run Contentstack-macOS Test case
#echo "Running Test cases on macOS..."
#
#xcodebuild \
#    -workspace Contentstack.xcworkspace \
#    -scheme "Contentstack macOS" \
#    test \
#    -destination "platform=macOS" \
#    -resultBundlePath "$TEST_BUNDLE_PATH/$FILE_NAME-macOS.xcresult" \
#        | xcpretty \
#            --color \
#            --report html \
#            --output "$TEST_RESULT_PATH/$FILE_NAME-test-result-macOS.html"
#
#xcrun xccov view "$TEST_BUNDLE_PATH/$FILE_NAME-macOS.xcresult/1_Test/action.xccovreport" > "$TEST_COVERAGE_PATH/$FILE_NAME-macOS.coverage"
#
