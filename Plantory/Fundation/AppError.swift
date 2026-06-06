//
//  AppError.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI

enum AppError: LocalizedError {
    case empty
    case custom(String)
    
    var title: LocalizedStringKey {
        switch self {
        case .empty:
            "The content is empty."
        case .custom(let string):
            "Failed"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .empty:
            "The content is empty."
        case .custom(let string):
            string
        }
    }
    
    var systemImage: String {
        switch self {
        case .empty:
            "tray.fill"
        case .custom(let string):
            "exclamationmark.circle.fill"
        }
    }
}

extension Error {
    var title: LocalizedStringKey {
        if let appError = self as? AppError {
            appError.title
        } else {
            "Failed"
        }
    }
    
    var systemImage: String {
        if let appError = self as? AppError {
            appError.systemImage
        } else {
            "exclamationmark.circle.fill"
        }
    }
}
