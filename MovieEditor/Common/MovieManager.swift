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

class MovieManager {
    
    let movie: AVURLAsset
    let playerItem: AVPlayerItem
    let player: AVPlayer
    let playerLayer: AVPlayerLayer
    
    init(with movie: AVURLAsset) {
        self.movie = movie
        self.playerItem = AVPlayerItem(asset: movie)
        self.player = AVPlayer(playerItem: self.playerItem)
        self.playerLayer = AVPlayerLayer(player: self.player)
    }
}

extension MovieManager {
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
}
