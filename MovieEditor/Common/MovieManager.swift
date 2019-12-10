//
//  MovieManager.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/11/27.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import AVFoundation
import Photos
import RxSwift
import RxCocoa
import UIKit

class MovieManager {
    let disposeBag = DisposeBag()
    
    let player: Observable<AVPlayer>
    let playerLayer: Observable<AVPlayerLayer>
    let frameImageList: Driver<[UIImage]>
    let currentTime: Observable<CMTime>
    let isPlaying: Observable<Bool>
    let duration: Observable<CMTime>
    
    let _player: BehaviorRelay<AVPlayer>
    
    init(with movie: AVURLAsset) {
        let playerItem = AVPlayerItem(asset: movie)
        let player = AVPlayer(playerItem: playerItem)
        
        _player = BehaviorRelay<AVPlayer>(value: player)
        self.player = _player.asObservable()
        
        self.playerLayer = _player.map { AVPlayerLayer(player: $0) }
        
        self.frameImageList = _player.map { player -> [UIImage] in
            guard let movie = player.currentItem?.asset else {
                return []
            }
            let imageGenerator = AVAssetImageGenerator(asset: movie)
            let seconds = Int(movie.duration.seconds)
            
            let frameImageList = (0..<seconds).compactMap { second -> UIImage? in
                let capturingTime = CMTime(seconds: Double(second), preferredTimescale: 1)
                guard let cgImage = try? imageGenerator.copyCGImage(at: capturingTime, actualTime: nil) else {
                    return nil
                }
                
                return UIImage(cgImage: cgImage)
            }
            
            return frameImageList
        }
        .asDriver(onErrorJustReturn: [])
        
        self.currentTime = _player.flatMap { $0.rx.periodicTimeObserver(interval: CMTime(value: 1, timescale: 100)) }
        
        self.isPlaying = _player.flatMap { $0.rx.isPlaying }
        
        self.duration = _player.flatMap { Observable.just($0.currentItem?.duration ?? .zero) }
    }
}

extension MovieManager {
    
    func play() {
        _player.value.play()
    }
    
    func pause() {
        _player.value.pause()
    }
    
    func updatePlayTime(_ parcentage: Double) {
        guard let duration = _player.value.currentItem?.asset.duration else {
            return
        }
        let durationSeconds = CMTimeGetSeconds(duration)
        let toTimeSeconds = durationSeconds * parcentage
        let toTime = CMTimeMakeWithSeconds(toTimeSeconds, preferredTimescale: duration.timescale)
        let tolerance = CMTime.zero
        
        _player.value.seek(to: toTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
    }
}

extension Reactive where Base: AVPlayer {
    
    func periodicTimeObserver(interval: CMTime) -> Observable<CMTime> {
        return Observable.create { [weak base] observer in
            guard let base = base else {
                return Disposables.create()
            }
            let time = base.addPeriodicTimeObserver(forInterval: interval, queue: nil) { time in
                observer.onNext(time)
            }
            return Disposables.create { base.removeTimeObserver(time) }
        }
    }
    
    var isPlaying: Observable<Bool> {
        return self.observe(Float.self, #keyPath(AVPlayer.rate))
            .map { $0 == 1.0 }
    }
    
    var currentItem: Observable<AVPlayerItem?> {
        return observe(AVPlayerItem.self, #keyPath(AVPlayer.currentItem))
    }
    
    var duration: Observable<CMTime> {
        return Observable.create { [weak base] observer in
            guard let base = base else {
                return Disposables.create()
            }
            
            return base.rx.currentItem
                .subscribe(onNext: { currentItem in
                    guard let currentItem = currentItem else {
                        observer.onNext(.zero)
                        return
                    }
                    observer.onNext(currentItem.duration)
            })
        }
    }
}

extension Reactive where Base: AVPlayerItem {
    var duration: Observable<CMTime> {
        return self.observe(CMTime.self, #keyPath(AVPlayerItem.duration)).map { $0 ?? .zero }
    }
    
    var status: Observable<AVPlayerItem.Status> {
        return self.observe(AVPlayerItem.Status.self, #keyPath(AVPlayerItem.status)).map { $0 ?? .unknown }
    }
}
