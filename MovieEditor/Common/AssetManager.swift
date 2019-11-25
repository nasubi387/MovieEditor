//
//  AssetManager.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/11/24.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import RxSwift

enum AssetError: Error {
    case unknown
    case noImage
    case noMovie
}

class AssetManager {
    static func fetch(_ mediaType: PHAssetMediaType) -> Observable<[Content]> {
        
        return Observable.create { observer in
            var assets: [PHAsset] = []
            let options = PHFetchOptions()
            options.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]
            PHAsset
                .fetchAssets(with: mediaType, options: options)
                .enumerateObjects { (asset, index, stop) -> Void in
                    assets.append(asset)
            }
            switch mediaType {
            case .video:
                let movies = assets.map { asset -> MovieContent in
                    var movie: MovieContent!
                    let disposeBag = DisposeBag()
                    let semaphore = DispatchSemaphore(value: 0)
                    AssetManager.requestImage(from: asset)
                        .map {
                            MovieContent(thumbnail: $0, asset: asset)
                        }
                        .subscribe(onNext: {
                            movie = $0
                            semaphore.signal()
                        })
                        .disposed(by: disposeBag)
                    semaphore.wait()
                    return movie
                }
                observer.onNext(movies)
                observer.onCompleted()
            default:
                observer.onError(AssetError.unknown)
            }
            
            return Disposables.create()
        }
    }
    
    static func requestImage(from asset: PHAsset) -> Observable<UIImage> {
        return Observable.create { observer in
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            
            manager.requestImage(for: asset,
                                 targetSize: CGSize(width: 200, height: 200),
                                 contentMode: .aspectFill,
                                 options: options) { (image, info) in
                                    guard let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool,
                                        isDegraded == false,
                                        let image = image else {
                                            return
                                    }
                                    observer.onNext(image)
                                    observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    static func requestMovie(from asset: PHAsset) -> Observable<AVURLAsset> {
        return Observable.create { observer in
            let manager = PHImageManager.default()
            let options = PHVideoRequestOptions()
            options.deliveryMode = .automatic
            options.version = .original
            
            manager.requestAVAsset(forVideo: asset, options: nil) { urlAsset, audioMix, info  in
                if let error = info?[PHImageErrorKey] as? NSError {
                    print(error.debugDescription)
                    return
                }
                guard let urlAsset = urlAsset as? AVURLAsset else {
                    observer.onError(AssetError.noMovie)
                    return
                }
                print(urlAsset.url)
                observer.onNext(urlAsset)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
