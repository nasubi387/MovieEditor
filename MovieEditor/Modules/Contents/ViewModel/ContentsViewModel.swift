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
    
    let _contentCellModels: BehaviorRelay<[ContentCellViewModel]>
    
    init(dependency: Dependency, input: Input) {
        self.dependency = dependency
        self.input = input
        
        _contentCellModels = BehaviorRelay<[ContentCellViewModel]>(value: [])
        let contentCellModels = _contentCellModels.asObservable()
        
        let output = Output(contentCellModels: contentCellModels)
        self.output = output
        
        fetch()
        
        input.itemSelected
            .map { [weak self] in
                self?.currentState.contentCellModels[$0.row].currentState.content
            }
            .subscribe(onNext: { [weak self] in
                self?.dependency.wireframe.presentEditorView(with: $0 as? MovieContent)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetch() {
        dependency.usecase.fetchContents()
            .map {
                $0.map { ContentCellViewModel(content: $0) }
            }
            .bind(to: _contentCellModels)
            .dispose()
    }
}
