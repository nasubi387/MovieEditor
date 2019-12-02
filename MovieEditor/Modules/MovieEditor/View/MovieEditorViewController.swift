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
    
    @IBOutlet weak var moviePalyerView: UIView!
    @IBOutlet weak var playImageView: UIImageView!
    var closeButton: UIBarButtonItem!
    var tapPlayerViewGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension MovieEditorViewController: MovieEditorViewInput {
    
    private func setup() {
        closeButton = UIBarButtonItem(image: R.image.movieEditor_close(), style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItems = [closeButton]
        
        tapPlayerViewGesture = UITapGestureRecognizer(target: nil, action: nil)
        moviePalyerView.addGestureRecognizer(tapPlayerViewGesture)
    }
    
    func bind(to viewModel: MovieEditorViewModel) {
        self.viewModel = viewModel
        
        viewModel.output
            .playerLayer
            .bind { [weak self] layer in
                guard let self = self else { return }
                layer.frame = self.moviePalyerView.bounds
                self.moviePalyerView.layer.insertSublayer(layer, at: 0)
            }
            .disposed(by: disposeBag)
        
        viewModel.output
            .isHiddenPlayImageView
            .bind(to: playImageView.rx.isHidden)
            .disposed(by: disposeBag)
        
    }
}
