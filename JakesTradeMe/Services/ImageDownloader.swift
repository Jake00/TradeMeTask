//
//  ImageDownloader.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import UIKit
import BoltsSwift

class ImageDownloader {
    
    typealias LoadCallback = (UIImage?) -> Void
    
    static let shared = ImageDownloader()
    let session: URLSession
    
    var isMemoryCachingEnabled = true {
        didSet {
            if !isMemoryCachingEnabled {
                cache.removeAllObjects()
            }
        }
    }
    
    private let queue = DispatchQueue(label: "jrb.JakesTradeMe.ImageDownloader.queue")
    private var requests: [String: Request] = [:]
    private let maximumActiveDownloads = 4
    private var currentActiveDownloads = 0
    private var queuedRequests: [Request] = []
    private var cache = NSCache<NSString, UIImage>()
    
    struct Request: Hashable {
        let url: URL
        let task: URLSessionDataTask
        var completors: [LoadCallback]
        
        static func == (lhs: Request, rhs: Request) -> Bool {
            return lhs.url.absoluteString == rhs.url.absoluteString
        }
        var hashValue: Int { return url.absoluteString.hashValue }
    }
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(
            memoryCapacity: 0,
            diskCapacity: 100 * 1024 * 1024,  // 100 MB
            diskPath: "jrb.JakesTradeMe.ImageDownloader"
        )
        self.session = URLSession(configuration: configuration)
    }
    
    func load(url: URL, completion: @escaping LoadCallback) {
        /* 1. Check in memory cache for an existing image. */
        if isMemoryCachingEnabled, let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
            return
        }
        
        /* 2. Check for an existing request, append the completion handler if it exists. */
        let existingRequest = queue.sync { () -> Request? in
            if var request = requests[url.absoluteString], !request.completors.isEmpty {
                request.completors.append(completion)
                requests[url.absoluteString] = request
                return request
            }
            return nil
        }
        if let _ = existingRequest {
            return
        }
        
        /* 3. Create new task to download the image. */
        let task = session.dataTask(with: url) { data, _, error in
            let image = data.flatMap(UIImage.init)?.inflated
            image?.loadedFromURL = url
            if let image = image, self.isMemoryCachingEnabled {
                self.cache.setObject(
                    image,
                    forKey: url.absoluteString as NSString,
                    cost: Int(image.size.width * image.size.height))
            }
            self.queue.sync {
                let request = self.remove(url: url)
                self.startNextRequestIfNeeded()
                DispatchQueue.main.async {
                    request?.completors.forEach { $0(image) }
                }
            }
        }
        let request = Request(url: url, task: task, completors: [completion])
        queue.sync {
            requests[url.absoluteString] = request
            
            /* 4. Either start the request or enqueue it depending on other concurrent downloads. */
            if currentActiveDownloads < maximumActiveDownloads {
                start(request)
            } else {
                queuedRequests.append(request)
            }
        }
    }
    
    func load(url: URL) -> Task<UIImage?> {
        let completion = TaskCompletionSource<UIImage?>()
        load(url: url, completion: completion.set)
        return completion.task
    }
    
    func cancelRequest(url: URL) {
        queue.sync {
            remove(url: url)?.task.cancel()
            startNextRequestIfNeeded()
        }
    }
    
    private func remove(url: URL) -> Request? {
        if currentActiveDownloads > 0 {
            currentActiveDownloads -= 1
        }
        return requests.removeValue(forKey: url.absoluteString)
    }
    
    private func startNextRequestIfNeeded() {
        guard currentActiveDownloads < maximumActiveDownloads else { return }
        
        while !queuedRequests.isEmpty {
            let request = queuedRequests.removeFirst()
            if request.task.state == .suspended {
                start(request)
            }
        }
    }
    
    private func start(_ request: Request) {
        request.task.resume()
        currentActiveDownloads += 1
    }
}

private extension UIImage {
    
    var inflated: UIImage {
        // Converted from SDWebImage, original at: swiftlint:disable:next line_length
        // https://github.com/rs/SDWebImage/blob/aa3cd28401af44afcad01ebc27f3f29fa4bcc64f/SDWebImage/SDWebImageDecoder.m#L18
        guard let cgImage = cgImage else { return self }
        
        let frame       = CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height)
        let colorSpace  = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo  = cgImage.bitmapInfo
        let infoMask    = bitmapInfo.intersection(.alphaInfoMask).rawValue
        let anyNonAlpha = infoMask == CGImageAlphaInfo.none.rawValue
            ||            infoMask == CGImageAlphaInfo.noneSkipFirst.rawValue
            ||            infoMask == CGImageAlphaInfo.noneSkipLast.rawValue
        
        // CGBitmapContextCreate doesn't support kCGImageAlphaNone with RGB.
        // https://developer.apple.com/library/mac/#qa/qa1037/_index.html
        if infoMask == CGImageAlphaInfo.none.rawValue && colorSpace.numberOfComponents > 1 {
            bitmapInfo.remove(.alphaInfoMask)
            bitmapInfo.insert(CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue))
        } else if !anyNonAlpha && colorSpace.numberOfComponents == 3 {
            bitmapInfo.remove(.alphaInfoMask)
            bitmapInfo.insert(CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue))
        }
        
        guard let context = CGContext(
            data:             nil,
            width:            cgImage.width,
            height:           cgImage.height,
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow:      0,
            space:            colorSpace,
            bitmapInfo:       bitmapInfo.rawValue)
            else { return self }
        
        context.draw(cgImage, in: frame)
        guard let decompressed = context.makeImage() else { return self }
        return UIImage(cgImage: decompressed, scale: scale, orientation: imageOrientation)
    }
    
    var loadedFromURL: URL? {
        get { return objc_getAssociatedObject(self, &loadedFromURLKey) as? URL }
        set { objc_setAssociatedObject(self, &loadedFromURLKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
}

private var loadedFromURLKey = 666
private var activeImageLoadURLKey = 777
private var activityIndicatorViewKey = 888

extension UIImageView {
    
    var activeImageLoadURL: URL? {
        get { return objc_getAssociatedObject(self, &activeImageLoadURLKey) as? URL }
        set { objc_setAssociatedObject(self, &activeImageLoadURLKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
    
    struct SetImageOptions: OptionSet {
        let rawValue: Int
        static let fade = SetImageOptions(rawValue: 1 << 0)
        static let load = SetImageOptions(rawValue: 1 << 1)
    }
    
    typealias SetImageCallback = (UIImageView, UIImage?) -> Void
    
    func setImage(
        url: URL?,
        options: SetImageOptions = [.fade, .load],
        placeholder: UIImage? = nil,
        completion: SetImageCallback? = nil
        ) {
        if url != nil, url == image?.loadedFromURL {
            return
        }
        if let activeImageLoadURL = activeImageLoadURL {
            if url?.absoluteString == activeImageLoadURL.absoluteString {
                return
            } else {
                ImageDownloader.shared.cancelRequest(url: activeImageLoadURL)
            }
        }
        image = placeholder
        activeImageLoadURL = url
        guard let url = url else { return }
        if options.contains(.load) {
            showLoader()
        }
        ImageDownloader.shared.load(url: url) { [weak self] image in
            guard let s = self else { return }
            let setImage = { s.image = image }
            if options.contains(.fade) {
                UIView.transition(
                    with: s,
                    duration: 0.2,
                    options: .transitionCrossDissolve,
                    animations: setImage,
                    completion: nil)
            } else {
                setImage()
            }
            s.activeImageLoadURL = nil
            s.activityIndicatorView?.stopAnimating()
            completion?(s, image)
        }
    }
    
    private var activityIndicatorView: UIActivityIndicatorView? {
        get { return objc_getAssociatedObject(self, &activityIndicatorViewKey) as? UIActivityIndicatorView }
        set { objc_setAssociatedObject(self, &activityIndicatorViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private func showLoader() {
        let activityIndicatorView = self.activityIndicatorView ?? {
            let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            self.activityIndicatorView = activityIndicatorView
            addSubview(activityIndicatorView)
            NSLayoutConstraint.activate([
                centerYAnchor.constraint(equalTo: activityIndicatorView.centerYAnchor),
                centerXAnchor.constraint(equalTo: activityIndicatorView.centerXAnchor)
                ])
            return activityIndicatorView
            }()
        activityIndicatorView.startAnimating()
    }
}
