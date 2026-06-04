//
//  HomeWeatherState.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

enum ViewState<T> {
    case loading
    case loaded(T)
    case failed(Error)
    
    var value: T? {
        switch self {
        case .loaded(let value):
            value
        default:
            nil
        }
    }
}
