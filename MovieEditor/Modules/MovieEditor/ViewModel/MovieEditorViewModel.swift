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

class MovieEditorViewModel {
    struct Dependency {
        let wireframe: MovieEditorWireframeInput
        let usecase: MovieEditorUseCaseInput
    }
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    struct State {
        let movie: MovieContent
    }
    var currentState: State {
        return State(movie: _movie.value)
    }
    
    private let dependency: Dependency
    private let input: Input
    let output: Output
    
    private let disposeBag = DisposeBag()
    
    private let _movie: BehaviorRelay<MovieContent>
    
    init(dependency: Dependency, input: Input, movie: MovieContent) {
        self.dependency = dependency
        self.input = input
        
        _movie = BehaviorRelay<MovieContent>(value: movie)
        let output = Output()
        self.output = output
    }
}
