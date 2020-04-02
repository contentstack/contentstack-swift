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
}
