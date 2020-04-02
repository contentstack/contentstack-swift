//
//  ImageTransformTest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 30/03/20.
//

import XCTest
@testable import Contentstack
#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#endif

class ImageTransformTest: XCTestCase {
    let urlString = "https://images.contentstack.io/v3/assets/blteae40eb499811073/bltc5064f36b5855343/59e0c41ac0eddd140d5a8e3e/download"
    let width: UInt = 100
    let height: UInt = 150

    func testAuto() {
        let imageTransform = makeImageTransformSUT().auto()
        do {
            let url = try urlString.url(with: imageTransform)
            XCTAssertEqual(url.absoluteString, urlString + "?auto=webp")
        } catch {
            XCTAssertFalse(true)
        }
    }

    func testQualiity_InRange_ReturnURL() {
        let quality: UInt = 40
        let imageTransform = makeImageTransformSUT().qualiy(quality)
        do {
            let url = try urlString.url(with: imageTransform)
            XCTAssertEqual(url.absoluteString, urlString + "?quality=\(quality)")
        } catch {
            XCTAssertFalse(true)
        }
    }

    func testQualiity_OutofRange_ThrowsError() {
        let quality: UInt = 101
        let imageTransform = makeImageTransformSUT().qualiy(quality)
        let message = """
        The value for Quality parameters can be entered in
        any whole number (taken as a percentage) between 1 and 100.
        """
        do {
            let url = try urlString.url(with: imageTransform)
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.debugDescription, message)
            }
        }
    }

    func testFormat_ReturnURL() {
        do {
            let gifUrl = try urlString.url(with: makeImageTransformSUT().format(Format.gif))
            let pngUrl = try urlString.url(with: makeImageTransformSUT().format(Format.png))
            let pjpgUrl = try urlString.url(with: makeImageTransformSUT().format(Format.pjpg))
            let jpegUrl = try urlString.url(with: makeImageTransformSUT().format(Format.jpeg))
            let webpUrl = try urlString.url(with: makeImageTransformSUT().format(Format.webp))
            let webpllUrl = try urlString.url(with: makeImageTransformSUT().format(Format.webpll))
            let webplyUrl = try urlString.url(with: makeImageTransformSUT().format(Format.webply))
            XCTAssertEqual(gifUrl.absoluteString, urlString + "?format=gif")
            XCTAssertEqual(pngUrl.absoluteString, urlString + "?format=png")
            XCTAssertEqual(pjpgUrl.absoluteString, urlString + "?format=pjpg")
            XCTAssertEqual(jpegUrl.absoluteString, urlString + "?format=jpg")
            XCTAssertEqual(webpUrl.absoluteString, urlString + "?format=webp")
            XCTAssertEqual(webpllUrl.absoluteString, urlString + "?format=webpll")
            XCTAssertEqual(webplyUrl.absoluteString, urlString + "?format=webply")
        } catch {
            XCTAssertFalse(true)
        }
    }

    func testResize_ReturnURL() {
        do {
            let urlWidth = try urlString.url(with: makeImageTransformSUT()
                .resize(
                    Resize(size:
                        Size(width: width)
                    )
                )
            )
            let urlheight = try urlString
                .url(with: makeImageTransformSUT()
                    .resize(
                        Resize(size:
                            Size(height: height)
                    )
                )
            )
            let urlboth = try urlString
                .url(with: makeImageTransformSUT()
                    .resize(
                        Resize(size:
                            Size(width: width, height: height)
                    )
                )
            )
            let urlBothDisable = try urlString
                .url(with: makeImageTransformSUT()
                    .resize(
                        Resize(size:
                            Size(width: width, height: height),
                               disableUpscale: true
                    )
                )
            )
            XCTAssertEqual(urlWidth.absoluteString, urlString + "?width=\(width)")
            XCTAssertEqual(urlheight.absoluteString, urlString + "?height=\(height)")
            XCTAssertEqual(urlboth.absoluteString, urlString + "?width=\(width)&height=\(height)")
            XCTAssertEqual(urlBothDisable.absoluteString,
                           urlString + "?width=\(width)&height=\(height)&disable=upscale")
        } catch {
            XCTAssertFalse(true)
        }
    }

    func testCropCanvasDefault_ReturnURL() {
        do {
            let defaultCropUrl = try urlString.url(with: makeImageTransformSUT()
                .crop(
                    .default(width: width, height: height)
                )
            )
            XCTAssertEqual(defaultCropUrl.absoluteString, urlString + "?crop=\(width),\(height)")
            let defaultCanvasUrl = try urlString.url(with: makeImageTransformSUT()
                .canvas(
                    .default(width: width, height: height)
                )
            )
            XCTAssertEqual(defaultCanvasUrl.absoluteString, urlString + "?canvas=\(width),\(height)")
        } catch {
            XCTAssertFalse(true)
        }
    }

    func testCropAspectRatio_withoutMode() {
        do {
            let ratioCropUrl = try urlString.url(with: makeImageTransformSUT()
                .crop(
                    .aspectRatio(
                        Size(width: width, height: height),
                        ratio: "1:2"
                    )
                )
            )
            XCTAssertEqual(ratioCropUrl.absoluteString, urlString + "?width=\(width)&height=\(height)&crop=1:2")
           } catch {
               XCTAssertFalse(true)
           }
    }

    func testCropCanvasAspectRatio_AllValues() {
        let ratio = "1:2"
        do {
            let ratioCropUrl = try urlString.url(with: makeImageTransformSUT()
                .crop(
                    .aspectRatio(
                        Size(width: width, height: height),
                        ratio: ratio,
                        mode: .safe
                    )
                )
            )
            XCTAssertEqual(ratioCropUrl.absoluteString,
                           urlString + "?width=\(width)&height=\(height)&crop=\(ratio),\(Mode.safe.value!)")
        } catch {
            XCTAssertFalse(true)
        }
        do {
            let ratioCanvasUrl = try urlString.url(with: makeImageTransformSUT()
                .canvas(
                    .aspectRatio(
                        Size(height: height),
                        ratio: ratio
                    )
                )
            )

            XCTAssertEqual(ratioCanvasUrl.absoluteString, urlString + "?height=\(height)&canvas=\(ratio)")
        } catch {
            XCTAssertFalse(true)
        }
    }

    func testCropCanvasAspectRatio_NoSizeSpecified_Throws() {
        let ratio = "1:2"
        let cropMessage = """
        Along with the crop parameter aspect-ration,
        you also need to specify either the width or height parameter or both
        in the API request to return an output image with the correct dimensions.
        """
        let canvasMessage = """
        Along with the canvas parameter aspect-ration,
        you also need to specify either the width or height parameter or both
        in the API request to return an output image with the correct dimensions.
        """

        do {
            let ratioCropUrl = try urlString.url(with: makeImageTransformSUT()
                .crop(
                    .aspectRatio(
                        Size(),
                        ratio: ratio,
                        mode: .safe
                    )
                )
            )
            XCTAssertNil(ratioCropUrl)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, cropMessage)
            }
        }

        do {
            let ratioCanvasUrl = try urlString.url(with: makeImageTransformSUT()
                .canvas(
                    .aspectRatio(
                        Size(),
                        ratio: ratio
                    )
                )
            )
            XCTAssertNil(ratioCanvasUrl)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, canvasMessage)
            }

        }
    }

    func testCropCanvas_Region() {
        let xRegion = 0.5
        let yRegion = 0.7
        do {
            let ratioCropUrl = try urlString.url(with: makeImageTransformSUT()
                .crop(
                    .region(width: width, height: height, xRegion: xRegion, yRegion: yRegion, mode: .smart)
                )
            )
            XCTAssertEqual(ratioCropUrl.absoluteString,
                           urlString + "?crop=\(width),\(height),x\(xRegion),y\(yRegion),smart")
        } catch {
            XCTAssertFalse(true)
        }
        do {
            let ratioCropUrl = try urlString.url(with: makeImageTransformSUT()
                .canvas(
                    .region(width: width, height: height, xRegion: xRegion, yRegion: yRegion)
                )
            )
            XCTAssertEqual(ratioCropUrl.absoluteString, urlString + "?canvas=\(width),\(height),x\(xRegion),y\(yRegion)")
        } catch {
            XCTAssertFalse(true)
        }
    }

    func testCrop_Region_withoutMode() {
        let xRegion = 0.5
        let yRegion = 0.6
        do {
            let ratioCropUrl = try urlString.url(with: makeImageTransformSUT()
                .crop(
                    .region(width: width, height: height, xRegion: xRegion, yRegion: yRegion)
                )
            )
            XCTAssertEqual(ratioCropUrl.absoluteString, urlString + "?crop=\(width),\(height),x\(xRegion),y\(yRegion)")
        } catch {
            XCTAssertFalse(true)
        }
    }

    func testCropCanvas_Offset() {
        let xOffset = 0.5
        let yOffset = 0.7
        do {
            let offsetCropUrl = try urlString.url(with: makeImageTransformSUT()
                .crop(
                    .offset(width: width, height: height, xOffset: xOffset, yOffset: yOffset, mode: .safe)
                )
            )
            XCTAssertEqual(offsetCropUrl.absoluteString,
                           urlString + "?crop=\(width),\(height),offset-x\(xOffset),offset-y\(yOffset),safe")
        } catch {
            XCTAssertFalse(true)
        }
        do {
            let offsetCanvasUrl = try urlString.url(with: makeImageTransformSUT()
                .canvas(
                    .offset(width: width, height: height, xOffset: xOffset, yOffset: yOffset)
                )
            )
            XCTAssertEqual(offsetCanvasUrl.absoluteString,
                           urlString + "?canvas=\(width),\(height),offset-x\(xOffset),offset-y\(yOffset)")
        } catch {
            XCTAssertFalse(true)
        }
    }

    func testCrop_Offset_withoutMode() {
        let xOffset = 0.5
        let yOffset = 0.7
        do {
            let offsetCropUrl = try urlString.url(with: makeImageTransformSUT()
                .crop(
                    .offset(width: width, height: height, xOffset: xOffset, yOffset: yOffset)
                )
            )
            XCTAssertEqual(offsetCropUrl.absoluteString,
                           urlString + "?crop=\(width),\(height),offset-x\(xOffset),offset-y\(yOffset)")
        } catch {
            XCTAssertFalse(true)
        }
    }

    func testFit() {
        do {
            let fitUrl = try urlString.url(with: makeImageTransformSUT()
                .fit(
                    .bounds(
                        Size(width: width, height: height)
                    )
                )
            )
            XCTAssertEqual(fitUrl.absoluteString,
                           urlString + "?width=\(width)&height=\(height)&fit=bounds")
        } catch {
            XCTAssertFalse(true)
        }
        do {
            let fitUrl = try urlString.url(with: makeImageTransformSUT()
                .fit(
                    .crop(
                        Size(width: width, height: height)
                    )
                )
            )
            XCTAssertEqual(fitUrl.absoluteString,
                           urlString + "?width=\(width)&height=\(height)&fit=crop")
        } catch {
            XCTAssertFalse(true)
        }
    }

    func testTrim() {
        #if os(iOS) || os(tvOS) || os(watchOS)
        let edgeInset = UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20)
        #elseif os(macOS)
        let edgeInset = NSEdgeInsets(top: 50, left: 20, bottom: 50, right: 20)
        #endif
        do {
            let trimUrl = try urlString.url(with: makeImageTransformSUT()
                .trim(edgeInset)
            )
            XCTAssertEqual(trimUrl.absoluteString,
                           urlString
                            +
                "?trim=\(edgeInset.top),\(edgeInset.right),\(edgeInset.bottom),\(edgeInset.left)")
        } catch {
            XCTAssertFalse(true)
        }
    }
    func testOrient() {
        do {
            let orientDefaultUrl = try urlString.url(with: makeImageTransformSUT()
                .orient(.default))
            let flipHorizontalUrl = try urlString.url(with: makeImageTransformSUT()
                .orient(.flipHorizontal))
            let flipHorizontalVerticalUrl = try urlString.url(with: makeImageTransformSUT()
                .orient(.flipHorizontalVertical))
            let flipVerticleUrl = try urlString.url(with: makeImageTransformSUT()
                .orient(.flipVerticle))
            let flipHorizontalLeftUrl = try urlString.url(with: makeImageTransformSUT()
                .orient(.flipHorizontalLeft))
            let rightUrl = try urlString.url(with: makeImageTransformSUT()
                .orient(.right))
            let flipHorizontalRightUrl = try urlString.url(with: makeImageTransformSUT()
                .orient(.flipHorizontalRight))
            let leftUrl = try urlString.url(with: makeImageTransformSUT()
                .orient(.left))
            XCTAssertEqual(orientDefaultUrl.absoluteString,
                           urlString + "?orient=1")
            XCTAssertEqual(flipHorizontalUrl.absoluteString,
                           urlString + "?orient=2")
            XCTAssertEqual(flipHorizontalVerticalUrl.absoluteString,
                           urlString + "?orient=3")
            XCTAssertEqual(flipVerticleUrl.absoluteString,
                           urlString + "?orient=4")
            XCTAssertEqual(flipHorizontalLeftUrl.absoluteString,
                           urlString + "?orient=5")
            XCTAssertEqual(rightUrl.absoluteString,
                           urlString + "?orient=6")
            XCTAssertEqual(flipHorizontalRightUrl.absoluteString,
                           urlString + "?orient=7")
            XCTAssertEqual(leftUrl.absoluteString,
                           urlString + "?orient=8")
        } catch {
            XCTAssertFalse(true)
        }
    }
}

func makeImageTransformSUT() -> ImageTransform {
    return ImageTransform()
}
