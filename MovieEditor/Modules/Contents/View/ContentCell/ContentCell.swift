//
//  ContentCell.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/11/24.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ContentCell: UICollectionViewCell {
    private var viewModel: ContentCellViewModel!
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var thumbnailMaskView: UIView!
    @IBOutlet weak var playTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
}

extension ContentCell {
    
    private func setup() {
        layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = thumbnailMaskView.frame
        gradientLayer.colors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.6)
        gradientLayer.endPoint = CGPoint(x: 0.5, y:1.0)
        
        thumbnailMaskView.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func bind(to viewModel: ContentCellViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.thumbnailImage
            .bind(to: thumbnailImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.output.durationText
            .bind(to: playTimeLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
