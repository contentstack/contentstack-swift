//
//  Utils.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 17/03/20.
//

import Foundation

public extension Dictionary {
    internal var jsonString: String? {
        if let data = try? JSONSerialization.data(withJSONObject: self,
                                                  options: JSONSerialization.WritingOptions.prettyPrinted),
            let string = String(data: data, encoding: String.Encoding.utf8) {
            return string
        }
        return nil
    }
}

internal extension String {
    // Will make a `URL` from the current `String` instance if possible.
    func toURL() throws -> URL {
        guard var urlComponents = URLComponents(string: self) else {
            throw ImageTransformError(message: "Invalid URL String: \(self)")
        }

        // Append https scheme if not present.
        if urlComponents.scheme == nil {
            urlComponents.scheme = "https"
        }

        guard let url = urlComponents.url else {
            throw ImageTransformError(message: "Invalid URL String: \(self)")
        }
        return url
    }

    /// The URL for the underlying media file with additional options for server side manipulations
    /// such as format changes, resizing, cropping, and focusing on different areas including on faces,
    /// among others.
    ///
    /// - Parameter imageTransform: The image operation to transform the image on the server-side.
    /// - Returns: A `URL` for the image with query parameters corresponding to server-side image transformations.
    /// - Throws: An `ImageTransformError` if the SDK is unable to generate a valid URL with the desired ImageOptions.
    func url(with imageTransform: ImageTransform) throws -> URL {

        // Check that there are no two image options that specifiy the same query parameter.
        // https://stackoverflow.com/a/27624476/4068264z
        // A Set is a collection of unique elements, so constructing them will invoke the Equatable implementation
        // and unique'ify the elements in the array.
        let imageOperation = imageTransform.imageOperation
        let uniqueImageOptions = Array(Set<ImageOperation>(imageOperation))
        guard uniqueImageOptions.count == imageOperation.count else {
            throw ImageTransformError(message: "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
        }

        guard !imageOperation.isEmpty else {
            return try toURL()
        }

        let urlString = try toURL().absoluteString
        guard var urlComponents = URLComponents(string: urlString) else {
            throw ImageTransformError(message: "The url string is not valid: \(urlString)")
        }

        urlComponents.queryItems = try imageOperation.flatMap { option in
            try option.urlQueryItem()
        }

        guard let url = urlComponents.url else {
            let message = """
            The SDK was unable to generate a valid URL for the given ImageOptions.
            Please contact the maintainer on Github with a copy of the query \(urlString)
            """
            throw ImageTransformError(message: message)
        }
        return url
    }
    
    func isHexColor() -> Bool {
        let hexColorRegex3Deci = "[0-9A-Fa-f]{3}"
        let hexColorPred3Deci = NSPredicate(format:"SELF MATCHES %@", hexColorRegex3Deci)

        let hexColorRegex = "[0-9A-Fa-f]{6}"
        let hexColorPred = NSPredicate(format:"SELF MATCHES %@", hexColorRegex)
        return hexColorPred.evaluate(with: self) || hexColorPred3Deci.evaluate(with: self)
    }
}
