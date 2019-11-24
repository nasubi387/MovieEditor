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
    private var viewModel: ContentsViewModel!
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var thumbnailMaskView: UIView!
    @IBOutlet weak var playTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
}

extension ContentCell {
    
    private func setup() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = thumbnailMaskView.frame
        gradientLayer.colors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y:1)
        
        thumbnailMaskView.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func bind(to viewModel: ContentsViewModel) {
        self.viewModel = viewModel
    }
}
