//
//  ViewController.swift
//  MosCode
//
//  Created by 4faramita on 2018/6/7.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = label.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in "." }
        
        let slide = label.rx
            .swipeGesture([.left, .right, .up, .down])
            .when(.recognized)
            .map { _ in "-" }
        
        let gestureStream = Observable.of(tap, slide)
            .merge()
        
        let gestureStreamStart = label.rx
            .anyGesture(.tap(), .swipe([.left, .right, .up, .down]))
            .when(.recognized)
            .concatMap { _ in
                return gestureStream
                    .scan("", accumulator: +)
                    .debounce(0.5, scheduler: MainScheduler.instance)
                    .take(1)
            }
        
        gestureStreamStart.subscribe(
            onNext: { [weak self] code in
                let trimedCode = String(code.suffix(5))
                if let char = MorseCodeTable.table[trimedCode] {
                    print(trimedCode, char)
                    self?.label.text = char
                } else {
                    print(trimedCode)
                    self?.label.text = trimedCode
                }
            }
        ).disposed(by: disposeBag)
    }
}
