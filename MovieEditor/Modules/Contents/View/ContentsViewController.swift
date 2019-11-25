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
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 8
        collectionView.collectionViewLayout = layout
    }
    
    func bind(to viewModel: ContentsViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.contentCellModels
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension ContentsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.currentState.contentCellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = viewModel.currentState.contentCellModels[indexPath.row]
        let cell = collectionView.dequeue(with: ContentCell.self, for: indexPath)
        
        cell.bind(to: cellViewModel)
        
        return cell
    }
}

extension ContentsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = view.frame.width / 4 - 4
        return CGSize(width: size, height: size)
    }
}
