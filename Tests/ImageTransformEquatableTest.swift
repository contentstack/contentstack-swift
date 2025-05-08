//
//  ImageTransformEquatableTest.swift
//  Contentstack iOS Tests
//
//  Created by Uttam Ukkoji on 03/04/20.
//

import XCTest
@testable import ContentstackSwift
class ImageTransformEquatableTest: XCTestCase {
    let urlString = "https://images.contentstack.io/v3/assets/uid_136download"

    func testSharpen_invalidParams_shouldThrowError() {
        let message = """
        The value for `amount` parameter could be a whole decimal number (between 0 and 10).
        The value for `radius` parameter could be a whole decimal number (between 1 and 1000).
        The value for `threshold` parameter could be a whole decimal number (between 0 and 255).
        """
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .sharpen(amount: 11, radius: 2, threshold: 100))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .sharpen(amount: 10, radius: 0, threshold: 100))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .sharpen(amount: 11, radius: 2, threshold: 300))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
    }

    func testSharpen_validParameter() {
        let amount: UInt = 1, radius: UInt = 2, threshold: UInt = 100
        do {
            let sharpenUrl = try urlString.url(with: makeImageTransformSUT()
                .sharpen(amount: amount, radius: radius, threshold: threshold))
            XCTAssertEqual(sharpenUrl.absoluteString, urlString + "?sharpen=a\(amount),r\(radius),t\(threshold)")
        } catch {}
    }

    func testResizeFilter() {
        let width: UInt = 100
        let height: UInt = 150
        do {
            let resizeFilterNearest = try urlString.url(with: makeImageTransformSUT()
                .resize(Resize(size: Size(width: width, height: height), filter: .nearest)))
            let resizeFilterBilinare = try urlString.url(with: makeImageTransformSUT()
                .resize(Resize(size: Size(width: width, height: height), filter: .bilinare)))
            let resizeFilterBicubic = try urlString.url(with: makeImageTransformSUT()
                .resize(Resize(size: Size(width: width, height: height), filter: .bicubic)))
            let resizeFilterLanczos3 = try urlString.url(with: makeImageTransformSUT()
                .resize(Resize(size: Size(width: width, height: height), filter: .lanczos3)))
            let resizeFilterLanczos2 = try urlString.url(with: makeImageTransformSUT()
                .resize(Resize(size: Size(width: width, height: height), filter: .lanczos2)))
            XCTAssertEqual(resizeFilterNearest.absoluteString,
                           urlString
                            +
                "?width=\(width)&height=\(height)&resize-filter=nearest")
            XCTAssertEqual(resizeFilterBilinare.absoluteString,
                           urlString
                            +
                "?width=\(width)&height=\(height)&resize-filter=bilinare")
            XCTAssertEqual(resizeFilterBicubic.absoluteString, urlString
                +
                "?width=\(width)&height=\(height)&resize-filter=bicubic")
            XCTAssertEqual(resizeFilterLanczos3.absoluteString, urlString
                +
                "?width=\(width)&height=\(height)&resize-filter=lanczos3")
            XCTAssertEqual(resizeFilterLanczos2.absoluteString, urlString
                +
                "?width=\(width)&height=\(height)&resize-filter=lanczos2")
        } catch {
            XCTAssertFalse(true)
        }
    }

    func testImageTransform_Equatable() {
        do {
            let url = try urlString.url(with: makeImageTransformSUT().auto().auto())
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }
        do {
            let url = try urlString.url(with: makeImageTransformSUT().qualiy(1).qualiy(1))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }

        do {
            let url = try urlString.url(with: makeImageTransformSUT().format(.gif).format(.jpeg))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }

        do {
            let url = try urlString.url(with: makeImageTransformSUT().resize(Resize(size: Size())).resize(Resize(size: Size())))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }

        do {
            let url = try urlString.url(with: makeImageTransformSUT().crop(.default(width: 12, height: 12)).crop(.default(width: 12, height: 12)))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }

        do {
            let url = try urlString.url(with: makeImageTransformSUT().canvas(.default(width: 12, height: 12)).canvas(.default(width: 12, height: 12)))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }

        do {
            let url = try urlString.url(with: makeImageTransformSUT().fit(.bounds(Size())).fit(.bounds(Size())))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }

        do {
            let url = try urlString.url(with: makeImageTransformSUT().trim(NSEdgeInsets()).trim(NSEdgeInsets()))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }
    }

    func testImageTransform_Equatables() {
        do {
            let url = try urlString.url(with: makeImageTransformSUT().orient(.flipHorizontal).orient(.flipHorizontalLeft))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }

        do {
            let url = try urlString.url(with: makeImageTransformSUT().overlay(relativeUrl: "ppp", overlayTypes: []).overlay(relativeUrl: "ppp", overlayTypes: []))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }

        do {
            let url = try urlString.url(with: makeImageTransformSUT().overlay(relativeUrl: "ppp", padding: NSEdgeInsets()).overlay(relativeUrl: "ppp", padding: NSEdgeInsets()))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }

        do {
            let url = try urlString.url(with: makeImageTransformSUT().pad(NSEdgeInsets()).pad(NSEdgeInsets()))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }

        do {
            let url = try urlString.url(with: makeImageTransformSUT().backgroundColor(.hex("AAA")).backgroundColor(.hex("AAA")))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }

        do {
            let url = try urlString.url(with: makeImageTransformSUT().dpr(2, resize: Resize(size: Size())).dpr(2, resize: Resize(size: Size())))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }

        do {
            let url = try urlString.url(with: makeImageTransformSUT().blur(3).blur(4))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }

        do {
            let url = try urlString.url(with: makeImageTransformSUT().saturation(3).saturation(4))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }

        do {
            let url = try urlString.url(with: makeImageTransformSUT().contrast(3).contrast(4))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }
        do {
            let url = try urlString.url(with: makeImageTransformSUT().brightness(3).brightness(4))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }
        do {
            let url = try urlString.url(with: makeImageTransformSUT().fetchFirstFrame().fetchFirstFrame())
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }
        do {
            let url = try urlString.url(with: makeImageTransformSUT().sharpen(amount: 1, radius: 1, threshold: 1).sharpen(amount: 1, radius: 1, threshold: 1))
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }
    }
}
