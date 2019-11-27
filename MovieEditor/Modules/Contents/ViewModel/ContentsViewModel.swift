//
//  ContentsViewModel.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/11/24.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation

class ContentsViewModel {
    struct Dependency {
        let wireframe: ContentsWireframeInput
        let usecase: ContentsUseCaseInput
    }
    
    struct Input {
        let itemSelected: ControlEvent<IndexPath>
    }
    
    struct Output {
        let contentCellModels: Observable<[ContentCellViewModel]>
    }
    
    struct State {
        let contentCellModels: [ContentCellViewModel]
    }
    var currentState: State {
        return State(contentCellModels: _contentCellModels.value)
    }
    
    private let dependency: Dependency
    private let input: Input
    let output: Output
    
    private let disposeBag = DisposeBag()
    
    private let _contentCellModels: BehaviorRelay<[ContentCellViewModel]>
    
    init(dependency: Dependency, input: Input) {
        self.dependency = dependency
        self.input = input
        
        _contentCellModels = BehaviorRelay<[ContentCellViewModel]>(value: [])
        
        // output
        let contentCellModels = _contentCellModels.asObservable()
        
        let output = Output(contentCellModels: contentCellModels)
        self.output = output
        
        // input
        input.itemSelected
            .map { [weak self] in
                self?.getMovieContent(from: $0)
            }
            .filterNil()
            .switchLatest()
            .subscribe(onNext: { [weak self] in
                self?.dependency.wireframe.presentEditorView(with: $0)
            })
            .disposed(by: disposeBag)
        
        // setup
        fetch()
    }
    
    private func fetch() {
        dependency.usecase
            .fetchContents()
            .map { $0.map { ContentCellViewModel(content: $0) } }
            .bind(to: _contentCellModels)
            .dispose()
    }
    
    private func getMovieContent(from indexPath: IndexPath) -> Observable<MovieContent> {
        let selectedContent = currentState.contentCellModels[indexPath.row].currentState.content
        guard var movie = selectedContent as? MovieContent else {
            return Observable.empty()
        }
        
        return dependency.usecase
            .requestURLAsset(from: movie.asset)
            .observeOn(MainScheduler.instance)
            .map {
                movie.urlAsset = $0
                return movie
            }
    }
}
