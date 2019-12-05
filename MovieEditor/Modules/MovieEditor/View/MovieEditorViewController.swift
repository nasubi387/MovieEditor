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
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var moviePalyerView: UIView!
    @IBOutlet weak var playImageView: UIImageView!
    var closeButton: UIBarButtonItem!
    var tapPlayerViewGesture: UITapGestureRecognizer!
    
    @IBOutlet weak var frameImageScrollView: UIScrollView!
    @IBOutlet weak var frameImageStackView: UIStackView!
    @IBOutlet weak var frameImageStackViewWidthConstraint: NSLayoutConstraint!
    
    let insetWidth = UIScreen.main.bounds.size.width / 2
    
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
        
        frameImageScrollView.contentInset.left = insetWidth
        frameImageScrollView.contentInset.right = insetWidth
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
        
        viewModel.output
            .frameImageList
            .bind { imageList in
                let width: CGFloat = (self.frameImageStackView.frame.height * 4) / 4
                let height: CGFloat = self.frameImageStackView.frame.height
                
                imageList.forEach { image in
                    let imageView = UIImageView(image: image)
                    imageView.contentMode = .scaleAspectFit
                    imageView.frame.size = CGSize(width: width, height: height)
                    
                    self.frameImageStackView.addArrangedSubview(imageView)
                }
                
                self.frameImageStackViewWidthConstraint.constant = width * CGFloat(imageList.count)
                self.view.layoutIfNeeded()
            }
            .disposed(by: disposeBag)
        
        viewModel.output.duration
            .drive(durationLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.currentTime
            .drive(currentTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.offsetParcentage
            .drive(onNext: { [weak self] parcentage in
                guard let self = self else {
                    return
                }
                var parcentage = parcentage
                parcentage = parcentage < 0 ? 0 : parcentage
                parcentage = parcentage > 1 ? 1 : parcentage
                
                let contentSizeWidth = self.frameImageScrollView.contentSize.width
                let offsetX = contentSizeWidth * CGFloat(parcentage) - self.insetWidth
                let offset = CGPoint(x: offsetX, y: self.frameImageScrollView.contentOffset.y)
                
                self.frameImageScrollView.setContentOffset(offset, animated: false)
            })
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: MovieEditorViewController {
    var didScrollFrameImage: ControlEvent<Double> {
        let source = base.frameImageScrollView.rx
            .didScroll
            .map { [weak base] () -> Double? in
                guard
                    base?.frameImageScrollView.isDragging == true,
                    let offset = base?.frameImageScrollView.contentOffset,
                    let contentWidth = base?.frameImageScrollView.contentSize.width,
                    let insetWidth = base?.insetWidth else {
                        return nil
                }
                let offsetX = offset.x + insetWidth
                var parcentage = Double(offsetX / contentWidth)
                parcentage = parcentage < 0 ? 0 : parcentage
                parcentage = parcentage > 1 ? 1 : parcentage
                
                return round(parcentage * 10000) / 10000
            }
            .filterNil()
        
        return ControlEvent(events: source)
    }
}
