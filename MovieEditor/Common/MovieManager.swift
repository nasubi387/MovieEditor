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
    
    let movie: AVURLAsset
    let playerItem: AVPlayerItem
    let player: AVPlayer
    let playerLayer: AVPlayerLayer
    
    //let _player: BehaviorRelay<AVPlayer>
    lazy var frameImageList = Observable<[UIImage]>.just(getFrameImageList())
    
    init(with movie: AVURLAsset) {
        self.movie = movie
        playerItem = AVPlayerItem(asset: movie)
        player = AVPlayer(playerItem: self.playerItem)
        playerLayer = AVPlayerLayer(player: self.player)
        
        //_player = BehaviorRelay<AVPlayer>(value: player)
    }
    
    private func getFrameImageList() -> [UIImage] {
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
}

extension MovieManager {
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func updatePlayTime(_ parcentage: Double) {
        let duration = self.playerItem.asset.duration
        let durationSeconds = CMTimeGetSeconds(duration)
        let toTimeSeconds = durationSeconds * parcentage
        let toTime = CMTimeMakeWithSeconds(toTimeSeconds, preferredTimescale: duration.timescale)
        let tolerance = CMTime.zero
        
        self.player.seek(to: toTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
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
}

extension Reactive where Base: AVPlayerItem {
    var duration: Observable<CMTime> {
        return self.observe(CMTime.self, #keyPath(AVPlayerItem.duration)).debug().filterNil()
    }
}
