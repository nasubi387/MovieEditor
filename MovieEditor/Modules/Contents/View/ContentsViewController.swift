//
//  ContentsViewController.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/11/24.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol ContentsViewInput where Self: UIViewController {
    func bind(to viewModel: ContentsViewModel)
}

class ContentsViewController: UIViewController {
    private(set) var viewModel: ContentsViewModel!
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension ContentsViewController: ContentsViewInput {
    
    private func setup() {
        collectionView.register(cellType: ContentCell.self)
    }
    
    func bind(to viewModel: ContentsViewModel) {
        self.viewModel = viewModel
    }
}
