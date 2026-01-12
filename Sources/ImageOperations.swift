//
//  ImageOperations.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 23/04/20.
//

import Foundation

///The `resize-filter` parameter allows you to use the r
///esizing filter to increase or decrease the number of pixels in a given image.
///See [Resize-filter](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#resize-filter)
public enum ResizeFilter: String {
    /// Default to none allow not to set Resize-filter
    case none
    /// Utilizes the values of the neighboring translated pixels to provide
    /// smoother and quick resizing of a given image.
    case nearest
    /// Utilizes a 2x2 environment of pixels on an average.
    /// This filter blends new interpolated pixels with the original image pixels to
    /// generate a larger image with more detail.
    case bilinare
    /// Utilizes a 4x4 environment of pixels on average.
    /// This filter maintains the innermost pixels and discards all
    /// the extra details from a given image.
    case bicubic
    /// Enhances the ability to identify linear features and
    /// object edges of a given image.
    /// This filter uses the sinc resampling function to reconstruct
    /// the pixelation of an image and improve its quality.
    case lanczos2
    /// Utilizes a better approximation of the sinc resampling function to
    /// generate an image with better reconstruction.
    case lanczos3

    internal func urlQueryItem(queryItems: inout [URLQueryItem]) {
        switch self {
        case .nearest, .bilinare, .bicubic, .lanczos2, .lanczos3:
            queryItems.append(URLQueryItem(name: ImageParameter.resizeFilter, value: self.rawValue))
        default:
            return
        }
    }
}

/// The `width` parameter lets you dynamically resize the width of the image by specifying pixels or percentage.
/// The `height` parameter lets you dynamically resize the height of the image by specifying pixels or percentage.
/// The `disable` parameter disables the functionality that is enabled by default.
/// See [Resize Images](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#resize-images)
public struct Resize {
    /// The `Size` parameter lets you dynamically resize
    /// the width and height of the output image by specifying pixels or percentage values.
    public let size: Size
    /// This `disableUpscale` ensures that even if the specified height or width
    /// is much bigger than the actual image, it will not be rendered disproportionately.
    public var disableUpscale: Bool = false
    ///The `resize-filter` parameter allows you to use the r
    ///esizing filter to increase or decrease the number of pixels in a given image.
    public var filter: ResizeFilter = .none
    internal func urlQueryItem() -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        size.urlQueryItem(queryItems: &queryItems)
        if disableUpscale {
            queryItems.append(URLQueryItem(name: ImageParameter.disable, value: "upscale"))
        }
        self.filter.urlQueryItem(queryItems: &queryItems)
        return queryItems
    }
}

/// The `Size` parameter lets you dynamically resize the
/// width and height of the output image by specifying pixels or percentage values.
public struct Size {
    /// The width parameter lets you dynamically resize
    /// the width of the output image by specifying pixels or percentage values.
    public var width: UInt?
    /// The height parameter lets you dynamically resize
    /// the height of the output image by specifying pixels or percentage values.
    public var height: UInt?

    internal func urlQueryItem(queryItems: inout [URLQueryItem]) {
        if let width = width {
            queryItems.append(URLQueryItem(name: ImageParameter.width, value: String(width)))
        }
        if let height = height {
            queryItems.append(URLQueryItem(name: ImageParameter.height, value: String(height)))
        }
    }
}
/// The `Mode` parameter lets you output image never returns an
/// error due to the specified crop (in `safe`) and preserves the center
/// of an image while cropping (in `smart`).
public enum Mode {
    /// Default mode for cropping an image.
    case none
    /// You can append the safe parameter when cropping an image.
    case safe
    /// You can also specify the smart parameter to crop a given image using content-aware algorithms
    case smart

    internal var value: String? {
        switch self {
        case .none:                     return nil
        case .safe:                     return "safe"
        case .smart:                    return "smart"
        }
    }
}
/// The `format` parameter lets you converts a given image from one format to another.
/// See [Convert Formats](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#convert-formats)
public enum Format {
    /// Progressive JPEG Format
    case pjpg
    ///  JPEG format
    case jpeg
    ///  GIF format
    case gif
    ///  PNG format
    case png
    ///  WEBP format
    case webp
    ///  WEBP Lossy format
    case webply
    ///  WEBP Lossless format
    case webpll

    internal var value: String {
        switch self {
        case .jpeg:                     return "jpg"
        case .pjpg:                     return "pjpg"
        case .gif:                      return "gif"
        case .png:                      return "png"
        case .webp:                     return "webp"
        case .webply:                   return "webply"
        case .webpll:                   return "webpll"
        }
    }
}
/// The `crop` parameter allows you to remove pixels from an image.
/// See [Crop Images](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#crop-images)
public enum Crop {
    /// Crop by width and height
    case `default`(width: UInt, height: UInt)
    /// Crop by aspect ratio
    case aspectRatio (Size, ratio: String, mode: Mode = .none)
    /// Crop sub region
    case region(width: UInt, height: UInt, xRegion: Double, yRegion: Double, mode: Mode = .none)
    /// Crop and offset
    case offset(width: UInt, height: UInt, xOffset: Double, yOffset: Double, mode: Mode = .none)

    internal func urlQueryItem() throws -> [URLQueryItem] {
        var values = [String]()
        var queryItems = [URLQueryItem]()
        switch self {
        case .default(let size):
            values = [
                String(size.width),
                String(size.height)
            ]
        case .aspectRatio(let sizes, let ratio, let mode):
            sizes.urlQueryItem(queryItems: &queryItems)
            if queryItems.count == 0 {
                throw ImageTransformError(message: ContentstackMessages.cropAspectRatioRequired)
            }
            values = [ratio]
            if let value = mode.value {
                values.append(value)
            }
        case .region(let region):
            values = [
                String(region.width),
                String(region.height),
                "x\(String(region.xRegion))",
                "y\(String(region.yRegion))"
            ]
            if let value = region.mode.value {
                values.append(value)
            }
        case .offset(let offset):
            values = [
                String(offset.width),
                String(offset.height),
                "offset-x\(String(offset.xOffset))",
                "offset-y\(String(offset.yOffset))"
            ]
            if let value = offset.mode.value {
                values.append(value)
            }
        }

        if values.count > 0 {
            queryItems.append(URLQueryItem(name: ImageParameter.crop, value: values.joined(separator: ",")))
        }
        return queryItems
    }
}
/// The `canvas` parameter allows you to increase the size of the canvas that surrounds an image.
/// See [Canvas](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#canvas)
public enum Canvas {
    /// Crop by width and height
    case `default`(width: UInt, height: UInt)
    /// Crop by aspect ratio
    case aspectRatio (Size, ratio: String)
    /// Crop sub region
    case region(width: UInt, height: UInt, xRegion: Double, yRegion: Double)
    /// Crop and offset
    case offset(width: UInt, height: UInt, xOffset: Double, yOffset: Double)

    internal func urlQueryItem() throws -> [URLQueryItem] {
        var values = [String]()
        var queryItems = [URLQueryItem]()
        switch self {
        case .default(let size):
            values = [
                String(size.width),
                String(size.height)
            ]
        case .aspectRatio(let sizes, let ratio):
            sizes.urlQueryItem(queryItems: &queryItems)
            if queryItems.count == 0 {
                throw ImageTransformError(message: ContentstackMessages.canvasAspectRatioRequired)
            }
            values = [ratio]
        case .region(let region):
            values = [
                String(region.width),
                String(region.height),
                "x\(String(region.xRegion))",
                "y\(String(region.yRegion))"
            ]
        case .offset(let offset):
            values = [
                String(offset.width),
                String(offset.height),
                "offset-x\(String(offset.xOffset))",
                "offset-y\(String(offset.yOffset))"
            ]
        }
        if values.count > 0 {
            queryItems.append(URLQueryItem(name: ImageParameter.canvas, value: values.joined(separator: ",")))
        }
        return queryItems
    }
}

/// The `fit` parameter enables you to fit the given image properly within the specified `height` and `width`.
/// You need to provide values for the `height`, `width` and `fit` parameters.
/// See [Fit Mode](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#fit-mode)
public enum Fit {
    /// If fit is set to `bounds`, it will constrain the given image into the specified height and width.
    /// See [Fit to bounds](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#fit-to-bounds)
    case bounds(Size)
    /// If fit is set to crop, it will crop the given image to the defined height and width.
    /// See [Fit by cropping](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#fit-by-cropping)
    case crop(Size)

    internal func urlQueryItem() throws -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        switch self {
        case .bounds(let sizes):
            sizes.urlQueryItem(queryItems: &queryItems)
            queryItems.append(URLQueryItem(name: ImageParameter.fit, value: ImageParameter.bounds))

        case .crop(let sizes):
            sizes.urlQueryItem(queryItems: &queryItems)
            queryItems.append(URLQueryItem(name: ImageParameter.fit, value: ImageParameter.crop))
        }
        return queryItems
    }
}
/// The `orient` parameter lets you control the cardinal orientation of the given image.
/// See [Reorient Images](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#reorient-images)
public enum Orientation: Int {
    /// Set image to default
    case `default`                  = 1
    /// Flip image horizontally
    case flipHorizontal
    /// Flip image horizontally and vertically
    case flipHorizontalVertical
    /// Flip image vertically
    case flipVerticle
    /// Flip image horizontally and then rotate 90 degrees towards left
    case flipHorizontalLeft
    /// Rotate image 90 degrees towards right
    case right
    /// Flip image horizontally and then rotate 90 degrees towards right
    case flipHorizontalRight
    /// Rotate image 90 degrees towards left
    case left
    internal func urlQueryItem() throws -> [URLQueryItem] {
        return [URLQueryItem(name: ImageParameter.orient, value: self.rawValue.stringValue)]
    }
}

/// The `overlay` parameter allows you to put one image on top of another.
/// You need to specify the relative URL of the image as value for this parameter.
/// See[Overlay Settings](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#overlay-settings)
public enum OverlayType {
    /// The `overlay-align` parameter lets you define the position of the overlay image.
    case align(OverlayAlign)
    /// The `overlay-repeat` parameter lets you define how the overlay image will be repeated on the given image.
    case `repeat`(OverlayRepeat)
    /// The `overlay-width` parameter lets you define the width of the overlay image.
    /// The` overlay-height` parameter lets you define the height of the overlay image.
    case size(Size)

    internal func urlQueryItem(queryItems: inout [URLQueryItem]) {
        switch self {
        case .align(let align):
            return queryItems.append(align.urlQueryItem())
        case .repeat(let `repeat`):
            return queryItems.append(`repeat`.urlQueryItem())
        case .size(let size):
            if let width = size.width {
                queryItems.append(URLQueryItem(name: ImageParameter.overlayWidth, value: String(width)))
            }
            if let height = size.height {
                queryItems.append(URLQueryItem(name: ImageParameter.overlayHeight, value: String(height)))
            }
        }
    }
}
/// The `overlay-align` parameter lets you define the position of the overlay image.
/// See [Overlay Align](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#overlay-align)
public enum OverlayAlign: String {
    /// Align the overlay image to the top of the actual image.
    case top
    /// Align the overlay image to the bottom of the actual image.
    case bottom
    /// Align the overlay image to the left of the actual image.
    case left
    /// Align the overlay image to the right of the actual image.
    case right
    /// Align the overlay image to the middle (vertically) of the actual image.
    case middel
    /// Align the overlay image to the center (horizontally) of the actual image.
    case center
    /// Align the overlay image to the top-left of the actual image.
    case topLeft        = "top,left"
    /// Align the overlay image to the top-right of the actual image.
    case topRight       = "top,right"
    /// Align the overlay image to the bottom-left of the actual image.
    case bottomLeft     = "bottom,left"
    /// Align the overlay image to the bottom-right of the actual image.
    case bottomRight    = "bottom,right"

    internal func urlQueryItem() -> URLQueryItem {
        return URLQueryItem(name: ImageParameter.overlayAlign, value: self.rawValue)
    }
}
/// The `overlay-repeat` parameter lets you define how the overlay image will be repeated on the given image.
/// See [Overlay Repeat](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#overlay-repeat)
public enum OverlayRepeat: String {
    case both
    case horizontal = "x"
    case verticle   = "y"
    internal func urlQueryItem() -> URLQueryItem {
           return URLQueryItem(name: ImageParameter.overlayRepeat, value: self.rawValue)
       }
}

/// The `bg-color` parameter lets you set a backgroud color for the given image.
/// See [Background Color](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#background-color)
public enum Color {
    /// Hexadecimal valuet should be `3-digit` or `6-digit`.
    case hex(String)
    ///  `Red`, `Blue`, `Green` value which defines the intensity of the corresponding color,
    ///  with the value ranging anywhere between `0` and `255` for each.
    case rgb(red: UInt, green: UInt, blue: UInt)
    ///  `Red`, `Blue`, `Green` value which defines the intensity of the corresponding color,
    ///  with the value ranging anywhere between `0` and `255` for each.
    ///  The `alpha` value defines the transparency, with `0.0` being fully transparent
    ///  and `1.0` being completely opaque.
    case rgba(red: UInt, green: UInt, blue: UInt, alpha: Double)
    internal func urlQueryItem() throws -> [URLQueryItem] {
        switch self {
        case .hex(let hexColor) where hexColor.isHexColor():
            return [URLQueryItem(name: ImageParameter.backgroundColor, value: hexColor)]
        case .rgb(red: let red, green: let green, blue: let blue)
            where red >= 0 && red <= 255 && green >= 0 &&  green <= 255 && blue >= 0 && blue <= 255:
            return [URLQueryItem(name: ImageParameter.backgroundColor, value: "\(red)\(green)\(blue)")]
        case .rgba(red: let red, green: let green, blue: let blue, alpha: let alpha)
            where red >= 0 && red <= 255
                && green >= 0 && green <= 255
                && blue >= 0 && blue <= 255
                && alpha >= 0.0 && alpha <= 1.0:
            return [URLQueryItem(name: ImageParameter.backgroundColor, value: "\(red)\(green)\(blue)\(alpha)")]
        case .hex:
            throw ImageTransformError(message: ContentstackMessages.invalidHexColor)
        case .rgb:
            throw ImageTransformError(message: ContentstackMessages.invalidRGBColor)
        case .rgba:
            throw ImageTransformError(message: ContentstackMessages.invalidRGBAColor)
        }
    }
}
