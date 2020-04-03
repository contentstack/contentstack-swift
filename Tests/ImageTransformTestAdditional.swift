//
//  ImageTransformTestAdditional.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 02/04/20.
//

import XCTest
@testable import Contentstack
#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#endif

class ImageTransformTestAdditional: XCTestCase {
    let urlString = "https://images.contentstack.io/v3/assets/blteae40eb499811073/bltc5064f36b5855343/59e0c41ac0eddd140d5a8e3e/download"
    let width: UInt = 100
    let height: UInt = 150
    #if os(iOS) || os(tvOS) || os(watchOS)
    let edgeInset = UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20)
    #elseif os(macOS)
    let edgeInset = NSEdgeInsets(top: 50, left: 20, bottom: 50, right: 20)
    #endif

    func testOverlay() {
        let relativeUrl = "/v3/assets/blteae40eb499811073/bltb21dacdd20d0e24c/59e0c401462a293417405f34/download"
        do {
            let overlayUrl = try urlString.url(with: makeImageTransformSUT()
                .overlay(relativeUrl: relativeUrl))
            let overlayAlignUrl = try urlString.url(with: makeImageTransformSUT()
                .overlay(relativeUrl: relativeUrl, overlayTypes: [
                    .align(.left),
                    .repeat(.both),
                    .size(Size(width: width, height: height))]))
            XCTAssertEqual(overlayUrl.absoluteString,
                           urlString + "?overlay=\(relativeUrl)")
            XCTAssertEqual(overlayAlignUrl.absoluteString,
                           urlString +
                "?overlay="
                + relativeUrl +
                "&overlay-align=left&overlay-repeat=both&overlay-width=\(width)&overlay-height=\(height)")
        } catch {
            XCTAssertFalse(true)
        }
    }

    func testOverlayAlign() {
        let relativeUrl = "/v3/assets/blteae40eb499811073/bltb21dacdd20d0e24c/59e0c401462a293417405f34/download"
        do {
            let overlayAlignTopUrl = try urlString.url(with: makeImageTransformSUT()
                .overlay(relativeUrl: relativeUrl, overlayTypes: [.align(.top)]))
            XCTAssertEqual(overlayAlignTopUrl.absoluteString, urlString + "?overlay=\(relativeUrl)&overlay-align=top")
            let overlayAlignBottomUrl = try urlString.url(with: makeImageTransformSUT()
                .overlay(relativeUrl: relativeUrl, overlayTypes: [.align(.bottom)]))
            XCTAssertEqual(overlayAlignBottomUrl.absoluteString,
                           urlString + "?overlay=\(relativeUrl)&overlay-align=bottom")
            let overlayAlignRoghtUrl = try urlString.url(with: makeImageTransformSUT()
                .overlay(relativeUrl: relativeUrl, overlayTypes: [.align(.right)]))
            XCTAssertEqual(overlayAlignRoghtUrl.absoluteString,
                           urlString + "?overlay=\(relativeUrl)&overlay-align=right")
            let overlayAlignMiddleUrl = try urlString.url(with: makeImageTransformSUT()
                .overlay(relativeUrl: relativeUrl, overlayTypes: [.align(.middel)]))
            XCTAssertEqual(overlayAlignMiddleUrl.absoluteString,
                           urlString + "?overlay=\(relativeUrl)&overlay-align=middel")
            let overlayAligncenterUrl = try urlString.url(with: makeImageTransformSUT()
                .overlay(relativeUrl: relativeUrl, overlayTypes: [.align(.center)]))
            XCTAssertEqual(overlayAligncenterUrl.absoluteString,
                           urlString + "?overlay=\(relativeUrl)&overlay-align=center")
            let overlayAligntopLeftUrl = try urlString.url(with: makeImageTransformSUT()
                .overlay(relativeUrl: relativeUrl, overlayTypes: [.align(.topLeft)]))
            XCTAssertEqual(overlayAligntopLeftUrl.absoluteString,
                           urlString + "?overlay=\(relativeUrl)&overlay-align=top,left")
            let overlayAligntopRightUrl = try urlString.url(with: makeImageTransformSUT()
                .overlay(relativeUrl: relativeUrl, overlayTypes: [.align(.topRight)]))
            XCTAssertEqual(overlayAligntopRightUrl.absoluteString,
                           urlString + "?overlay=\(relativeUrl)&overlay-align=top,right")
            let overlayAlignbottomLeftUrl = try urlString.url(with: makeImageTransformSUT()
                .overlay(relativeUrl: relativeUrl, overlayTypes: [.align(.bottomLeft)]))
            XCTAssertEqual(overlayAlignbottomLeftUrl.absoluteString,
                           urlString + "?overlay=\(relativeUrl)&overlay-align=bottom,left")
            let overlayAlignbottomRightUrl = try urlString.url(with: makeImageTransformSUT()
                .overlay(relativeUrl: relativeUrl, overlayTypes: [.align(.bottomRight)]))
            XCTAssertEqual(overlayAlignbottomRightUrl.absoluteString,
                           urlString + "?overlay=\(relativeUrl)&overlay-align=bottom,right")
        } catch {XCTAssertFalse(true)}
    }

    func testOverlayRepeat() {
        let relativeUrl = "/v3/assets/blteae40eb499811073/bltb21dacdd20d0e24c/59e0c401462a293417405f34/download"
        do {
            let overlayrepeatUrl = try urlString.url(with: makeImageTransformSUT()
                .overlay(relativeUrl: relativeUrl, overlayTypes: [.repeat(.horizontal)]))
            XCTAssertEqual(overlayrepeatUrl.absoluteString,
                           urlString + "?overlay=\(relativeUrl)&overlay-repeat=x")
            let overlayrepeatverticleUrl = try urlString.url(with: makeImageTransformSUT()
                .overlay(relativeUrl: relativeUrl, overlayTypes: [.repeat(.verticle)]))
            XCTAssertEqual(overlayrepeatverticleUrl.absoluteString,
                           urlString + "?overlay=\(relativeUrl)&overlay-repeat=y")
        } catch {XCTAssertFalse(true)}
    }

    func testOverlayPadding() {
        let relativeUrl = "/v3/assets/blteae40eb499811073/bltb21dacdd20d0e24c/59e0c401462a293417405f34/download"
        do {
            let overlayUrl = try urlString.url(with: makeImageTransformSUT()
                .overlay(relativeUrl: relativeUrl, padding: edgeInset))
            XCTAssertEqual(overlayUrl.absoluteString,
                           urlString + "?overlay="
                + relativeUrl +
                            "&overlay-pad=\(edgeInset.top),\(edgeInset.right),\(edgeInset.bottom),\(edgeInset.left)")

        } catch {XCTAssertFalse(true)}
    }

    func testPadding() {
        do {
            let paddingUrl = try urlString.url(with: makeImageTransformSUT()
                .pad(edgeInset))
            XCTAssertEqual(paddingUrl.absoluteString,
                           urlString + "?pad=\(edgeInset.top),\(edgeInset.right),\(edgeInset.bottom),\(edgeInset.left)")

        } catch {XCTAssertFalse(true)}

    }

    func testBackgroundColorHex_withInvalidValues_shouldThrowError() {
        let message = """
        Invalid Hexadecimal value,
        it should be 3-digit or 6-digit hexadecimal value.
        """
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .backgroundColor(.hex("k")))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .backgroundColor(.hex("AAAA")))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .backgroundColor(.hex("AAR")))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .backgroundColor(.hex("AAAA##")))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .backgroundColor(.hex("AAAAAAA")))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }

    }

    func  testBackgroundColorRGB_withInvalidValues_shouldThrowError() {
        let message = """
        Invalid Red or Blue or Green or alpha value,
        the value ranging anywhere between 0 and 255 for each.
        """
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .backgroundColor(.rgb(red: 300, green: 20, blue: 20)))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .backgroundColor(.rgb(red: 30, green: 2000, blue: 20)))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .backgroundColor(.rgb(red: 30, green: 20, blue: 256)))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
    }

    func  testBackgroundColorRGBA_withInvalidValues_shouldThrowError() {
        let message = """
        Invalid Red or Blue or Green or alpha value,
        the value ranging anywhere between 0 and 255 for each
        and the alpha value with 0.0 being fully transparent
        and 1.0 being completely opaque.
        """
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .backgroundColor(.rgba(red: 300, green: 20, blue: 20, alpha: 0.1)))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .backgroundColor(.rgba(red: 30, green: 2000, blue: 20, alpha: 0.1)))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .backgroundColor(.rgba(red: 30, green: 20, blue: 256, alpha: 0.1)))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .backgroundColor(.rgba(red: 30, green: 20, blue: 26, alpha: 2)))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
    }

    func testBackgroundColor_URLQueryParam() {
        let hex = "AAFF00", red: UInt = 23, green: UInt = 253, blue: UInt = 66, alpha = 0.5
        do {
            let hexURL = try urlString.url(with: makeImageTransformSUT()
                .backgroundColor(.hex(hex)))
            XCTAssertEqual(hexURL.absoluteString, urlString + "?bg-color=\(hex)")
            let rgbURL = try urlString.url(with: makeImageTransformSUT()
                .backgroundColor(.rgb(red: red, green: green, blue: blue)))
            XCTAssertEqual(rgbURL.absoluteString, urlString + "?bg-color=\(red)\(green)\(blue)")
            let rgbaURL = try urlString.url(with: makeImageTransformSUT()
                .backgroundColor(.rgba(red: red, green: green, blue: blue, alpha: alpha)))
            XCTAssertEqual(rgbaURL.absoluteString, urlString + "?bg-color=\(red)\(green)\(blue)\(alpha)")

        } catch {
            XCTAssertFalse(true)
        }
    }

    func testDPR_InvalidParam_shouldThrow() {
        let message = """
        The value for dpr parameter could be a whole number (between 0 and 10000)
        or any decimal number (between 0.0 and 9999.9999...).
        """
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .dpr(10000000, resize: Resize(size: Size())))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
    }

    func testDPR_validParam() {
        do {
            let dprValue: UInt = 1000
            let dprUrl = try urlString.url(with: makeImageTransformSUT()
                .dpr(dprValue, resize: Resize(size: Size(width: width))))
            XCTAssertEqual(dprUrl.absoluteString, urlString + "?width=\(width)&dpr=\(dprValue)")
        } catch {
            XCTAssertFalse(true)
        }
    }

    func testBlur_InvalidParam_shouldThrow() {
        let message = """
        The value for blur parameter could be a whole decimal number (between 1 and 1000).
        """
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .blur(10000000))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
    }

    func testBlur_validParam() {
        do {
            let blurValue: UInt = 100
            let blurUrl = try urlString.url(with: makeImageTransformSUT()
                .blur(blurValue))
            XCTAssertEqual(blurUrl.absoluteString, urlString + "?blur=\(blurValue)")
        } catch {
            XCTAssertFalse(true)
        }
    }

    func testSaturation_InvalidParam_shouldThrow() {
        let message = """
        The value for saturation parameter could be a whole decimal number (between -100 and 100).
        """
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .saturation(10000000))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
    }

    func testSaturation_validParam() {
        do {
            let value: Double = 10
            let saturationUrl = try urlString.url(with: makeImageTransformSUT()
                .saturation(value))
            XCTAssertEqual(saturationUrl.absoluteString, urlString + "?saturation=\(value)")
        } catch {
            XCTAssertFalse(true)
        }
    }
    func testContrast_InvalidParam_shouldThrow() {
        let message = """
        The value for contrast parameter could be a whole decimal number (between -100 and 100).
        """
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .contrast(10000000))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
    }

    func testContrast_validParam() {
        do {
            let value: Double = 10
            let contrastUrl = try urlString.url(with: makeImageTransformSUT()
                .contrast(value))
            XCTAssertEqual(contrastUrl.absoluteString, urlString + "?contrast=\(value)")
        } catch {
            XCTAssertFalse(true)
        }
    }

    func testBrightness_InvalidParam_shouldThrow() {
        let message = """
        The value for brightness parameter could be a whole decimal number (between -100 and 100).
        """
        do {
            _ = try urlString.url(with: makeImageTransformSUT()
                .brightness(10000000))
            XCTAssertFalse(true)
        } catch let error {
            if let error = error as? ImageTransformError {
                XCTAssertEqual(error.message, message)
            }
        }
    }

    func testBrightness_validParam() {
        do {
            let value: Double = 10
            let brightnessUrl = try urlString.url(with: makeImageTransformSUT()
                .brightness(value))
            XCTAssertEqual(brightnessUrl.absoluteString, urlString + "?brightness=\(value)")
        } catch {
            XCTAssertFalse(true)
        }
    }
}
