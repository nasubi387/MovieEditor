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
        
    }
    
    struct Output {
        
    }
    
    private let dependency: Dependency
    private let input: Input
    let output: Output
    
    private let disposeBag = DisposeBag()
    
    init(dependency: Dependency, input: Input) {
        self.dependency = dependency
        self.input = input
        
        let output = Output()
        self.output = output
    }
}
