//
//  ImageOperation.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 31/03/20.
//

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
    public typealias NSEdgeInsets = UIEdgeInsets
#endif

/// The Image Delivery API is used to retrieve, manipulate and/or convert image
/// files of your Contentstack account and deliver it to your web or mobile properties
/// See [Image Delivery API](https://www.contentstack.com/docs/developers/apis/image-delivery-api)
internal enum ImageOperation: Equatable, Hashable {

    /// The `auto` parameter lets you enable the functionality that automates certain image optimization features.
    /// See [Automate Optimization](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#automate-optimization)
    case auto
    /// The `quality` parameter lets you control the compression level of images that have Lossy file format.
    /// The value for this parameters can be entered in any whole number (taken as a percentage) between 1 and 100.
    /// See [Control Quality](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#control-quality)
    case qualiy(UInt)
    /// The `format` parameter lets you converts a given image from one format to another.
    /// See [Convert Formats](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#convert-formats)
    case format(Format)
    /// The `width` parameter lets you dynamically resize the width of the image by specifying pixels or percentage.
    /// The `height` parameter lets you dynamically resize the height of the image by specifying pixels or percentage.
    /// The `disable` parameter disables the functionality that is enabled by default.
    /// See [Resize Images](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#resize-images)
    case resize(Resize)
    /// The `crop` parameter allows you to remove pixels from an image.
    /// See [Crop Images](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#crop-images)
    case crop(Crop)
    /// The `canvas` parameter allows you to increase the size of the canvas that surrounds an image.
    /// See [Canvas](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#canvas)
    case canvas(Canvas)
    /// The `fit` parameter enables you to fit the given image properly within the specified `height` and `width`.
    /// You need to provide values for the `height`, `width` and `fit` parameters.
    /// See [Fit Mode](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#fit-mode)
    case fit(Fit)
    /// The `trim` parameter lets you trim an image from the edges.
    /// See [Trim Images](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#trim-images)
    case trim(NSEdgeInsets)
    /// The `orient` parameter lets you control the cardinal orientation of the given image.
    /// See [Reorient Images](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#reorient-images)
    case orient(Orientation)
    /// The `overlay` parameter allows you to put one image on top of another.
    /// You need to specify the relative URL of the image as value for this parameter.
    /// See[Overlay Settings](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#overlay-settings)
    case overlay(String, [OverlayType])
    /// The `overlay-pad` parameter allows you to add padding pixels to the edges of an overlay image.
    /// You need to specify the relative URL of the image as value for this parameter.
    /// See [Overlay Pad](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#overlay-pad)
    case overlayPad(NSEdgeInsets)
    /// The `pad` parameter lets you add extra pixels to the edges of an image.
    /// This is useful if you want to add whitespace or border to an image.
    /// The value for this parameter can be given in pixels or percentage.
    /// See [Pad](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#pad)
    case pad(NSEdgeInsets)
    /// The `bg-color` parameter lets you set a backgroud color for the given image.
    /// See [Background Color](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#background-color)
    case color(Color)
    /// The `dpr` parameter lets you deliver images with appropriate size
    /// to devices that come with a defined device pixel ratio.
    /// See [Device Pixel Ratio](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#device-pixel-ratio)
    case dpr(UInt)
    /// The `blur` parameter allows you to decrease the focus and clarity of a given image.
    /// See [Blur](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#blur)
    case blur(UInt)
    /// The `saturation` parameter allows you to increase or decrease
    /// the intensity of the colors in a given image.
    /// See [Saturation](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#saturation)
    case saturation(Double)
    /// The `contrast` parameter allows you to increase or decrease
    /// the difference between the darkest and lightest tones in a given image.
    /// See [Contrast](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#contrast)
    case contrast(Double)
    /// The `brightness` parameter allows you to increase or decrease
    /// the intensity with which an image reflects or radiates perceived light.
    /// See [Brightness](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#brightness)
    case brightness(Double)
    /// The frame parameter fetches the first frame from an animated GIF
    /// (Graphics Interchange Format) file that comprises a sequence of moving images.
    /// See [Fetch first frame](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#fetch-first-frame)
    case fetchFirstFrame
    /// The `sharpen` parameter allows you to increase the definition of the edges of objects in an image.
    /// See [Sharpen](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#sharpen)
    case sharpen(amount: UInt, radius: UInt, threshold: UInt)
    internal func urlQueryItem() throws -> [URLQueryItem] {
        switch self {
        case .auto:
            return [URLQueryItem(name: ImageParameter.auto, value: "webp")]
        case .format(let format):
            return [URLQueryItem(name: ImageParameter.format, value: format.value)]
        case .qualiy(let quality) where quality > 0 && quality <= 100:
            return [URLQueryItem(name: ImageParameter.quality, value: String(quality))]
        case .qualiy:
            let message = """
            The value for Quality parameters can be entered in
            any whole number (taken as a percentage) between 1 and 100.
            """
            throw ImageTransformError(message: message)
        case .resize(let resize):
            return resize.urlQueryItem()
        case .crop(let crop):
            return try crop.urlQueryItem()
        case .canvas(let canvas):
            return try canvas.urlQueryItem()
        case .fit(let fit):
            return try fit.urlQueryItem()
        case .trim(let edgeInset):
            return [URLQueryItem(name: ImageParameter.trim,
                                 value: "\(edgeInset.top),\(edgeInset.right),\(edgeInset.bottom),\(edgeInset.left)")]
        case .orient(let orient):
            return try orient.urlQueryItem()
        case .overlay(let url, let overlayTypes):
            var queryItems = [URLQueryItem]()
            queryItems.append(URLQueryItem(name: ImageParameter.overlay, value: url))
            for overlayType in overlayTypes {
                overlayType.urlQueryItem(queryItems: &queryItems)
            }
            return queryItems
        case .overlayPad(let edgeInset):
            return [URLQueryItem(name: ImageParameter.overlayPad,
                                 value: "\(edgeInset.top),\(edgeInset.right),\(edgeInset.bottom),\(edgeInset.left)")]
        case .pad(let edgeInset):
            return [URLQueryItem(name: ImageParameter.pad,
                                 value: "\(edgeInset.top),\(edgeInset.right),\(edgeInset.bottom),\(edgeInset.left)")]
        case .color(let color):
            return try color.urlQueryItem()
        case .dpr(let dprValue) where dprValue >= 0 && dprValue < 10000:
            return [URLQueryItem(name: ImageParameter.dpr, value: String(dprValue))]
        case .dpr:
            let message = """
            The value for dpr parameter could be a whole number (between 0 and 10000)
            or any decimal number (between 0.0 and 9999.9999...).
            """
            throw ImageTransformError(message: message)
        case .blur(let blurvalue) where blurvalue >= 1 && blurvalue < 1000:
            return [URLQueryItem(name: ImageParameter.blur, value: String(blurvalue))]
        case .blur:
            let message = """
            The value for blur parameter could be a whole decimal number (between 1 and 1000).
            """
            throw ImageTransformError(message: message)
        case .saturation(let value) where value >= -100 && value <= 100:
            return [URLQueryItem(name: ImageParameter.saturation, value: value.stringValue)]
        case .saturation:
            let message = """
            The value for saturation parameter could be a whole decimal number (between -100 and 100).
            """
            throw ImageTransformError(message: message)
        case .contrast(let value) where value >= -100 && value <= 100:
            return [URLQueryItem(name: ImageParameter.contrast, value: value.stringValue)]
        case .contrast:
            let message = """
            The value for contrast parameter could be a whole decimal number (between -100 and 100).
            """
            throw ImageTransformError(message: message)
        case .brightness(let value) where value >= -100 && value <= 100:
            return [URLQueryItem(name: ImageParameter.brightness, value: value.stringValue)]
        case .brightness:
            let message = """
            The value for brightness parameter could be a whole decimal number (between -100 and 100).
            """
            throw ImageTransformError(message: message)
        case .fetchFirstFrame:
            return [URLQueryItem(name: ImageParameter.frame, value: "1")]
        case .sharpen(amount: let amount, radius: let radius, threshold: let threshold)
            where amount >= 0 && amount <= 10
                && radius >= 1 && radius <= 1000
                && threshold >= 0 && threshold <= 255:
            return [URLQueryItem(name: ImageParameter.sharpen, value: "a\(amount),r\(radius),t\(threshold)")]
        case .sharpen:
            let message = """
            The value for `amount` parameter could be a whole decimal number (between 0 and 10).
            The value for `radius` parameter could be a whole decimal number (between 1 and 1000).
            The value for `threshold` parameter could be a whole decimal number (between 0 and 255).
            """
            throw ImageTransformError(message: message)
        }
    }

    // MARK: <Hashable>

    // Used to unique'ify an Array of ImageOption instances by converting to a Set.
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .auto:                 hasher.combine(0)
        case .format:               hasher.combine(1)
        case .qualiy:               hasher.combine(2)
        case .resize:               hasher.combine(3)
        case .crop:                 hasher.combine(4)
        case .canvas:               hasher.combine(5)
        case .fit:                  hasher.combine(6)
        case .trim:                 hasher.combine(7)
        case .orient:               hasher.combine(8)
        case .overlay:              hasher.combine(9)
        case .overlayPad:           hasher.combine(10)
        case .pad:                  hasher.combine(11)
        case .color:                hasher.combine(12)
        case .dpr:                  hasher.combine(13)
        case .blur:                 hasher.combine(14)
        case .saturation:           hasher.combine(14)
        case .contrast:             hasher.combine(15)
        case .brightness:           hasher.combine(16)
        case .fetchFirstFrame:      hasher.combine(17)
        case .sharpen:              hasher.combine(18)
        }
    }
}

/// Equatable implementation for `ImageOperation`
internal func == (lhs: ImageOperation, rhs: ImageOperation) -> Bool {
    switch (lhs, rhs) {
    case (.auto, .auto): return true
    case (.format, .format): return true
    case (.qualiy, .qualiy): return true
    case (.resize, .resize): return true
    case (.crop, .crop): return true
    case (.canvas, .canvas): return true
    case (.fit, .fit): return true
    case (.trim, .trim): return true
    case (.orient, .orient): return true
    case (.overlay, .overlay): return true
    case (.overlayPad, .overlayPad): return true
    case (.pad, .pad): return true
    case (.color, .color): return true
    case (.dpr, .dpr): return true
    case (.blur, .blur): return true
    case (.saturation, .saturation): return true
    case (.contrast, .contrast): return true
    case (.brightness, .brightness): return true
    case (.fetchFirstFrame, .fetchFirstFrame): return true
    case (.sharpen, .sharpen): return true
    default: return false
    }
}
