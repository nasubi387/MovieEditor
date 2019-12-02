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
    }
    
    struct Output {
        let playerLayer: Observable<AVPlayerLayer>
        let isHiddenPlayImageView: Observable<Bool>
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
    
    init(dependency: Dependency, input: Input, movie: MovieContent) {
        self.dependency = dependency
        self.input = input
        
        _movie = BehaviorRelay<MovieContent>(value: movie)
        
        _playStatus = BehaviorRelay<PlayStatus>(value: .paused)
        
        // output
        let playerLayer = Observable.just(dependency.movieManager.playerLayer)
        
        let isHiddenPlayImageView = _playStatus.map { $0 == .playing }.share()
        
        let output = Output(playerLayer: playerLayer,
                            isHiddenPlayImageView: isHiddenPlayImageView)
        self.output = output
        
        // input
        input.didTapCloseButton
            .subscribe(onNext: { [weak self] in
                self?.dependency.wireframe.dismissMovieEditor()
            })
            .disposed(by: disposeBag)
        
        input.didTapPlayerView
            .subscribe(onNext: { [weak self] _ in
                let nextStatus: PlayStatus = self?.currentState.playStatus == .paused ? .playing : .paused
                self?._playStatus.accept(nextStatus)
                
                switch nextStatus {
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
