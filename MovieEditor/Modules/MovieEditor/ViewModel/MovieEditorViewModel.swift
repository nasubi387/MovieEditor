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
        let didTapAddTextItemButton: ControlEvent<()>
    }
    
    struct Output {
        let playerLayer: Observable<AVPlayerLayer>
        let isHiddenPlayImageView: Observable<Bool>
        let frameImageList: Driver<[UIImage]>
        let currentTime: Driver<String>
        let duration: Driver<String>
        let offsetParcentage: Driver<Double>
        let addedMovieItems: Driver<[MovieItem]>
        let removedMovieItems: Driver<[MovieItem]>
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
    private let _movieItems: BehaviorRelay<[MovieItem]>
    
    init(dependency: Dependency, input: Input, movie: MovieContent) {
        self.dependency = dependency
        self.input = input
        
        _movie = BehaviorRelay<MovieContent>(value: movie)
        
        _playStatus = BehaviorRelay<PlayStatus>(value: .paused)
        
        _currentTimeParcentage = PublishRelay<Double>()
        
        _movieItems = BehaviorRelay<[MovieItem]>(value: [])
        
        // output
        let playerLayer = dependency.movieManager.playerLayer
        
        let isHiddenPlayImageView = _playStatus.map { $0 == .playing }.share()
        
        let frameImageList = dependency.movieManager.frameImageList
        
        let currentTime = dependency.movieManager.currentTime
            .map { currentTime -> String in
                let time = CMTimeGetSeconds(currentTime)
                let min = Int(time / 60)
                let sec = Int(time) % 60
                return String(format:"%02d:%02d", min, sec)
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "00:00")
        
        let duration = dependency.movieManager.duration
            .map { durationTime -> String in
                let duration = CMTimeGetSeconds(durationTime)
                let min = Int(duration / 60)
                let sec = Int(duration) % 60
                return String(format:"%02d:%02d", min, sec)
            }
            .asDriver(onErrorJustReturn: "00:00")
        
        let offsetParcentage = Observable.combineLatest(dependency.movieManager.currentTime,
                                                        dependency.movieManager.duration,
                                                        dependency.movieManager.isPlaying)
            .map { (currentTime, durationTime, isPlaying) -> Double? in
                guard isPlaying == true else {
                    return nil
                }
                let time = CMTimeGetSeconds(currentTime)
                let duration = CMTimeGetSeconds(durationTime)
                
                guard duration != 0 else {
                    return nil
                }
                
                return time / duration
            }
            .filterNil()
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0)
        
        let defMovieItems = Observable.zip(_movieItems.asObservable(), _movieItems.asObservable().skip(1))
        let addedMovieItems = defMovieItems.map { (prev, next) -> [MovieItem] in
            return next - prev
        }
        .asDriver(onErrorJustReturn: [])
        
        let removedMovieItems = defMovieItems.map { prev, next -> [MovieItem] in
            return prev - next
        }
        .asDriver(onErrorJustReturn: [])
        
        let output = Output(playerLayer: playerLayer,
                            isHiddenPlayImageView: isHiddenPlayImageView,
                            frameImageList: frameImageList,
                            currentTime: currentTime,
                            duration: duration,
                            offsetParcentage: offsetParcentage,
                            addedMovieItems: addedMovieItems,
                            removedMovieItems: removedMovieItems)
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
        
        input.didTapAddTextItemButton.asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                let newTextItem = self.createNewItem()
                
                var movieItems = self._movieItems.value
                movieItems.append(newTextItem)
                
                self._movieItems.accept(movieItems)
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
    
    private func createNewItem() -> MovieItem {
        let newTextItem = TextItemView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        newTextItem.bind()
        
        newTextItem.deleteButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                var movieItems = self._movieItems.value
                movieItems.removeAll { $0 == newTextItem }
                
                self._movieItems.accept(movieItems)
            })
            .disposed(by: newTextItem.disposeBag)
        
        return newTextItem
    }
}
