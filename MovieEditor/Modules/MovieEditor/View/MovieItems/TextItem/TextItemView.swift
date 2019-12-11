//
//  TextItemView.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/12/11.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TextItemView: UIView, NibLoadable {
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var textField: UITextField!
    var panViewGesture: UIPanGestureRecognizer!
    var orgOrigin: CGPoint = .zero
    var orgParentPoint : CGPoint = .zero
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadNib()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
        setup()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
}

extension TextItemView {
    func bind() {
        textField.rx.editingDidEnd
            .drive(onNext:{ [weak self] in
                guard self?.textField.isFirstResponder == true else {
                    return
                }
                self?.textField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        panViewGesture.rx.event
            .flatMap { [weak self] gesture -> Observable<CGPoint> in
                guard let self = self else {
                    return Observable.empty()
                }
                switch gesture.state {
                case .began:
                    self.orgOrigin = self.frame.origin
                    return Observable.just(self.orgOrigin)
                case .changed:
                    let newPoint = gesture.translation(in: self)
                    return Observable.just(self.orgOrigin + newPoint)
                default:
                    return Observable.empty()
                }
            }
            .bind(to: self.rx.origin)
            .disposed(by: disposeBag)
    }
    
    func setup() {
        backgroundColor = UIColor.clear
        
        panViewGesture = UIPanGestureRecognizer(target: nil, action: nil)
        addGestureRecognizer(panViewGesture)
    }
}
