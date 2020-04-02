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
public class ImageTransform {
    internal var imageOperation = [ImageOperation]()

    ///The `auto` parameter lets you enable the functionality that automates certain image optimization features.
    ///See [Automate Optimization](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#automate-optimization)
    public func auto() -> ImageTransform {
        self.imageOperation.append(.auto)
        return self
    }

    ///The `quality` parameter lets you control the compression level of images that have Lossy file format.
    ///The value for this parameters can be entered in any whole number (taken as a percentage) between 1 and 100.
    ///See [Control Quality](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#control-quality)
    public func qualiy(_ quality: UInt) -> ImageTransform {
        self.imageOperation.append(.qualiy(quality))
        return self
    }

    ///The `format` parameter lets you converts a given image from one format to another.
    ///See [Convert Formats](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#convert-formats)
    public func format(_ format: Format) -> ImageTransform {
        self.imageOperation.append(.format(format))
        return self
    }

    ///The `width` parameter lets you dynamically resize the width of the image by specifying pixels or percentage.
    ///The `height` parameter lets you dynamically resize the height of the image by specifying pixels or percentage.
    ///The `disable` parameter disables the functionality that is enabled by default.
    ///See [Resize Images](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#resize-images)
    public func resize(_ resize: Resize) -> ImageTransform {
        self.imageOperation.append(.resize(resize))
        return self
    }

    ///The `crop` parameter allows you to remove pixels from an image.
    ///See [Crop Images](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#crop-images)
    public func crop(_ crop: Crop) -> ImageTransform {
        self.imageOperation.append(.crop(crop))
        return self
    }

    ///The `canvas` parameter allows you to increase the size of the canvas that surrounds an image.
    ///See [Canvas](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#canvas)
    public func canvas(_ canvas: Canvas) -> ImageTransform {
        self.imageOperation.append(.canvas(canvas))
        return self
    }
    ///The `fit` parameter enables you to fit the given image properly within the specified `height` and `width`.
    ///You need to provide values for the `height`, `width` and `fit` parameters.
    ///See [Fit Mode](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#fit-mode)
    public func fit(_ fit: Fit) -> ImageTransform {
        self.imageOperation.append(.fit(fit))
        return self
    }
    ///The `trim` parameter lets you trim an image from the edges.
    ///See [Trim Images](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#trim-images)
    public func trim(_ edgeInset: NSEdgeInsets) -> ImageTransform {
        self.imageOperation.append(.trim(edgeInset))
        return self
    }
    ///The `orient` parameter lets you control the cardinal orientation of the given image.
    ///See [Reorient Images](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#reorient-images)
    public func orient(_ orient: Orientation) -> ImageTransform {
        self.imageOperation.append(.orient(orient))
        return self
    }
    ///The `overlay` parameter allows you to put one image on top of another.
    ///You need to specify the relative URL of the image as value for this parameter.
    ///See[Overlay Settings](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#overlay-settings)
    public func overlay(relativeUrl: String, overlayTypes: [OverlayType] = []) -> ImageTransform {
        self.imageOperation.append(.overlay(relativeUrl, overlayTypes))
        return self

    }
    ///The `overlay-pad` parameter allows you to add padding pixels to the edges of an overlay image.
    ///You need to specify the relative URL of the image as value for this parameter.
    ///See [Overlay Pad](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#overlay-pad)
    public func overlay(relativeUrl: String, padding: NSEdgeInsets) -> ImageTransform {
        _ = self.overlay(relativeUrl: relativeUrl)
        self.imageOperation.append(.overlayPad(padding))
        return self
    }
    ///The `pad` parameter lets you add extra pixels to the edges of an image.
    ///This is useful if you want to add whitespace or border to an image.
    ///The value for this parameter can be given in pixels or percentage.
    ///See [Pad](https://www.contentstack.com/docs/developers/apis/image-delivery-api/#pad)
    public func pad(_ padding: NSEdgeInsets) -> ImageTransform {
           self.imageOperation.append(.pad(padding))
           return self
    }
}
