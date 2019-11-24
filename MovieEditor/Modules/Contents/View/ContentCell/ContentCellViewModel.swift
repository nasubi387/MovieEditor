//
//  ContentCellViewModel.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/11/24.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ContentCellViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    private let input: Input
    let output: Output
    
    private let disposeBag = DisposeBag()
    
    init(input: Input) {
        self.input = input
        
        let output = Output()
        self.output = output
    }
}
