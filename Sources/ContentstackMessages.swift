//
//  ContentstackMessages.swift
//  Contentstack
//
//  Created by Contentstack on 16/12/25.
//

import Foundation

/// Centralized location for all user-facing messages in the Contentstack SDK.
/// This includes error messages, validation messages, and informational messages.
internal enum ContentstackMessages {
    
    // MARK: - UID Required Messages
    
    static let assetUIDRequired = "Asset UID is required. Provide a valid Asset UID and try again."
    static let contentTypeUIDRequired = "Content Type UID is required. Provide a valid Content Type UID and try again."
    static let entryUIDRequired = "Entry UID is required. Provide a valid Entry UID and try again."
    static let globalFieldUIDRequired = "Global Field UID is required. Provide a valid Global Field UID and try again."
    
    // MARK: - URL Validation Messages
    
    static let invalidURLString = "The URL string is not valid. Provide a valid URL and try again."
    
    // MARK: - Sync Messages
    
    static let syncTokenConflict = "Sync Token and Pagination Token cannot be used together. Provide only one token and try again."
    
    // MARK: - Image Transform Messages
    
    static let qualityParameterRange = """
        The value for Quality parameters can be entered in \
        any whole number (taken as a percentage) between 1 and 100.
        """
    
    static let dprParameterRange = """
        The value for dpr parameter could be a whole number (between 0 and 10000) \
        or any decimal number (between 0.0 and 9999.9999...).
        """
    
    static let blurParameterRange = """
        The value for blur parameter could be a whole decimal number (between 1 and 1000).
        """
    
    static let saturationParameterRange = """
        The value for saturation parameter could be a whole decimal number (between -100 and 100).
        """
    
    static let contrastParameterRange = """
        The value for contrast parameter could be a whole decimal number (between -100 and 100).
        """
    
    static let brightnessParameterRange = """
        The value for brightness parameter could be a whole decimal number (between -100 and 100).
        """
    
    static let sharpenParameterRange = """
        The value for `amount` parameter could be a whole decimal number (between 0 and 10). \
        The value for `radius` parameter could be a whole decimal number (between 1 and 1000). \
        The value for `threshold` parameter could be a whole decimal number (between 0 and 255).
        """
    
    static let cropAspectRatioRequired = """
        Along with the crop parameter aspect-ration, \
        you also need to specify either the width or height parameter or both \
        in the API request to return an output image with the correct dimensions.
        """
    
    static let canvasAspectRatioRequired = """
        Along with the canvas parameter aspect-ration, \
        you also need to specify either the width or height parameter or both \
        in the API request to return an output image with the correct dimensions.
        """
    
    static let invalidHexColor = """
        Invalid Hexadecimal value, \
        it should be 3-digit or 6-digit hexadecimal value.
        """
    
    static let invalidRGBColor = """
        Invalid Red or Blue or Green or alpha value, \
        the value ranging anywhere between 0 and 255 for each.
        """
    
    static let invalidRGBAColor = """
        Invalid Red or Blue or Green or alpha value, \
        the value ranging anywhere between 0 and 255 for each \
        and the alpha value with 0.0 being fully transparent \
        and 1.0 being completely opaque.
        """
    
    static let duplicateImageTransform = """
        Cannot specify two instances of ImageTransform of the same case.\
        i.e. `[.format(.png), .format(.jpg)]` is invalid.
        """
    
    static let invalidImageOptions = """
        The SDK was unable to generate a valid URL for the given ImageOptions. \
        Please contact the maintainer on Github with a copy of the query
        """
    
    // MARK: - Internal/Debug Messages
    
    static let unsupportedEndpointType = "Unsupported endpoint type encountered during response decoding"
}

