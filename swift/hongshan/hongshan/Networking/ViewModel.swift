//
//  ViewModel.swift
//  HongShan
//
//  Created by Jobs Azeroth on 2023/4/4.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform() -> Output
}
class ViewModel: ObservableObject {
    
}
