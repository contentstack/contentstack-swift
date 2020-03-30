//
//  ImageTransform.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 30/03/20.
//

import Foundation

/// The Image Delivery API is used to retrieve, manipulate and/or convert image
/// files of your Contentstack account and deliver it to your web or mobile properties
/// See [Image Delivery API](https://www.contentstack.com/docs/developers/apis/image-delivery-api)
public enum ImageTransform {

    ///The `auto` parameter lets you enable the functionality that automates certain image optimization features.
    ///See [Automate Optimization](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#automate-optimization)
    case auto
    ///The `quality` parameter lets you control the compression level of images that have Lossy file format.
    ///The value for this parameters can be entered in any whole number (taken as a percentage) between 1 and 100.
    ///See [Control Quality](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#control-quality)
    case qualiy(UInt)
    ///The `format` parameter lets you converts a given image from one format to another.
    ///See [Convert Formats](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#convert-formats)
    case format(Format)
    ///The `width` parameter lets you dynamically resize the width of the image by specifying pixels or percentage.
    ///The `height` parameter lets you dynamically resize the height of the image by specifying pixels or percentage..
    ///The `disable` parameter disables the functionality that is enabled by default.
    ///See [Resize Images](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#resize-images)
    case resize(Resize)
    ///The `crop` parameter allows you to remove pixels from an image.
    ///See [Crop Images](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#crop-images)
    case crop(Crop)

    internal func urlQueryItem() throws -> [URLQueryItem] {
        switch self {
        case .auto:
            return [URLQueryItem(name: ImageParameter.auto, value: "webp")]
        case .format(let format):
            return [URLQueryItem(name: ImageParameter.fromat, value: format.value)]
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
        }
    }
}

public struct Resize {
    internal let size: Size
    internal let disableUpscale: Bool = false
    internal func urlQueryItem() -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        size.urlQueryItem(queryItems: &queryItems)
        if disableUpscale {
            queryItems.append(URLQueryItem(name: ImageParameter.disable, value: "upscale"))
        }
        return queryItems
    }
}

public struct Size {
    public var height: UInt?
    public var width: UInt?

    internal func urlQueryItem(queryItems: inout [URLQueryItem]) {
        if let height = height {
            queryItems.append(URLQueryItem(name: ImageParameter.height, value: String(height)))
        }
        if let width = width {
            queryItems.append(URLQueryItem(name: ImageParameter.width, value: String(width)))
        }
    }
}

public enum Mode {
    case none
    ///You can append the safe parameter when cropping an image.
    case safe
    ///You can also specify the smart parameter to crop a given image using content-aware algorithms
    case smart

    internal var value: String? {
        switch self {
        case .none:                     return nil
        case .safe:                     return "safe"
        case .smart:                    return "smart"
        }
    }
}

public enum Format {
    ///Progressive JPEG Format
    case pjpg
    /// JPEG format
    case jpeg
    /// GIF format
    case gif
    /// PNG format
    case png
    /// WEBP format
    case webp
    /// WEBP Lossy format
    case webply
    /// WEBP Lossless format
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

public enum Crop {
    ///Crop by width and height
    case `default`(width: UInt, height: UInt)
    ///Crop by aspect ratio
    case aspectRatio (Size, ratio: String, mode: Mode = .none)
    ///Crop sub region
    case region(width: UInt, height: UInt, xRegion: UInt, yRegion: UInt, mode: Mode = .none)
    ///Crop and offset
    case offset(width: UInt, height: UInt, xOffset: UInt, yOffset: UInt, mode: Mode = .none)

    internal func urlQueryItem() throws -> [URLQueryItem] {
        switch self {
        case .default(let size):
            return [URLQueryItem(name: ImageParameter.crop, value:
                [
                    String(size.width),
                    String(size.height)
                    ].joined(separator: ",") )]

        case .aspectRatio(let sizes, let ratio, let mode):
            var queryItems = [URLQueryItem]()
            sizes.urlQueryItem(queryItems: &queryItems)

            if queryItems.count == 0 {
                let message = """
                Along with the crop parameter aspect-ration,
                you also need to specify either the width or height parameter or both
                in the API request to return an output image with the correct dimensions.
                """
                throw ImageTransformError(message: message)
            }
            var values = [ratio]
            if let value = mode.value {
                values.append(value)
            }
            queryItems.append(URLQueryItem(name: ImageParameter.crop, value: values.joined(separator: ",")))
            return queryItems
        case .region(let region):
            var values = [
                String(region.width),
                String(region.height),
                "x\(String(region.xRegion))",
                "y\(String(region.yRegion))"
            ]
            if let value = region.mode.value {
                values.append(value)
            }
            return [URLQueryItem(name: ImageParameter.crop, value: values.joined(separator: ","))]

        case .offset(let offset):
            var values = [
                String(offset.width),
                String(offset.height),
                "offset-x\(String(offset.xOffset))",
                "offset-y\(String(offset.yOffset))"
            ]
            if let value = offset.mode.value {
                values.append(value)
            }
            return [URLQueryItem(name: ImageParameter.crop, value: values.joined(separator: ",") )]

        }
    }
}
