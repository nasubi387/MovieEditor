//
//  MovieEditorViewController.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/11/25.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol MovieEditorViewInput where Self: UIViewController {
    func bind(to viewModel: MovieEditorViewModel)
}

class MovieEditorViewController: UIViewController {
    private(set) var viewModel: MovieEditorViewModel!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension MovieEditorViewController: MovieEditorViewInput {
    
    private func setup() {
        
    }
    
    func bind(to viewModel: MovieEditorViewModel) {
        self.viewModel = viewModel
        
    }
}
