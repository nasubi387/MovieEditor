//
//  MovieEditorViewModel.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/11/25.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional
import AVFoundation

class MovieEditorViewModel {
    struct Dependency {
        let wireframe: MovieEditorWireframeInput
        let usecase: MovieEditorUseCaseInput
        let movieManager: MovieManager
    }
    
    struct Input {
        let didTapCloseButton: ControlEvent<()>
        let didTapPlayerView: ControlEvent<UITapGestureRecognizer>
        let didScrollFrameImage: ControlEvent<Double>
    }
    
    struct Output {
        let playerLayer: Observable<AVPlayerLayer>
        let isHiddenPlayImageView: Observable<Bool>
        let frameImageList: Observable<[UIImage]>
        let currentTime: Driver<String>
        let duration: Driver<String>
        let offsetParcentage: Driver<Double>
    }
    
    struct State {
        let movie: MovieContent
        let playStatus: PlayStatus
    }
    var currentState: State {
        return State(movie: _movie.value,
                     playStatus: _playStatus.value)
    }
    
    private let dependency: Dependency
    private let input: Input
    let output: Output
    
    private let disposeBag = DisposeBag()
    
    private let _movie: BehaviorRelay<MovieContent>
    private let _playStatus: BehaviorRelay<PlayStatus>
    private let _currentTimeParcentage: PublishRelay<Double>
    
    init(dependency: Dependency, input: Input, movie: MovieContent) {
        self.dependency = dependency
        self.input = input
        
        _movie = BehaviorRelay<MovieContent>(value: movie)
        
        _playStatus = BehaviorRelay<PlayStatus>(value: .paused)
        
        _currentTimeParcentage = PublishRelay<Double>()
        
        // output
        let playerLayer = Observable.just(dependency.movieManager.playerLayer)
        
        let isHiddenPlayImageView = _playStatus.map { $0 == .playing }.share()
        
        let frameImageList = dependency.movieManager.frameImageList
        
        let currentTime = dependency.movieManager.player.rx.periodicTimeObserver(interval: CMTime(value: 1, timescale: 100))
            .map { currentTime -> String in
                let time = CMTimeGetSeconds(currentTime)
                let min = Int(time / 60)
                let sec = Int(time) % 60
                return String(format:"%02d:%02d", min, sec)
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "00:00")
        
        let duration = dependency.movieManager.playerItem.rx.duration
            .map { durationTime -> String in
                let duration = CMTimeGetSeconds(durationTime)
                let min = Int(duration / 60)
                let sec = Int(duration) % 60
                return String(format:"%02d:%02d", min, sec)
            }
            .asDriver(onErrorJustReturn: "00:00")
        
        let offsetParcentage = Observable.combineLatest(
            dependency.movieManager.player.rx.periodicTimeObserver(interval: CMTime(value: 1, timescale: 100)),
            Observable.just(dependency.movieManager.playerItem.duration),
            dependency.movieManager.player.rx.isPlaying)
            .flatMap { (currentTime, durationTime, isPlaying) -> Observable<Double> in
                guard isPlaying == true else {
                    return Observable.empty()
                }
                let time = CMTimeGetSeconds(currentTime)
                let duration = CMTimeGetSeconds(durationTime)
                
                return Observable.just(time / duration)
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0)
        
        let output = Output(playerLayer: playerLayer,
                            isHiddenPlayImageView: isHiddenPlayImageView,
                            frameImageList: frameImageList,
                            currentTime: currentTime,
                            duration: duration,
                            offsetParcentage: offsetParcentage)
        self.output = output
        
        // input
        input.didTapCloseButton
            .subscribe(onNext: { [weak self] in
                self?.dependency.wireframe.dismissMovieEditor()
            })
            .disposed(by: disposeBag)
        
        input.didTapPlayerView
            .map { [weak self] _ -> PlayStatus in
                self?.currentState.playStatus == .paused ? .playing : .paused
            }
            .asDriver(onErrorJustReturn: .paused)
            .drive(_playStatus)
            .disposed(by: disposeBag)
        
        input.didScrollFrameImage.asDriver()
            .drive(onNext: { [weak self] parcentage in
                self?._playStatus.accept(.paused)
                self?.dependency.movieManager.updatePlayTime(parcentage)
            })
            .disposed(by: disposeBag)
        
        _playStatus.asDriver()
            .drive(onNext: { [weak self] status in
                switch status {
                case .playing:
                    self?.dependency.movieManager.play()
                case .paused:
                    self?.dependency.movieManager.pause()
                }
            })
            .disposed(by: disposeBag)
    }
}

extension MovieEditorViewModel {
    
    private func fetch() {
        
    }
}
