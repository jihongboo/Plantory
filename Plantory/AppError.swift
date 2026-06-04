//
//  AppError.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import Foundation

enum AppError: LocalizedError {
    case custom(String)
    
    var errorDescription: String? {
        switch self {
        case .custom(let string):
            string
        }
    }
}
