//
//  Task.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/6.
//

import SwiftUI

enum LoadState {
    case loading
    case loaded
    case failed(Error)
}

struct LoadModifier: ViewModifier {
    let action: (() async throws -> Void)
    @State private var state: LoadState = .loading
    
    func body(content: Content) -> some View {
        content
            .overlay {
                switch state {
                case .loading:
                    PixelProgressView()
                case .failed(let error):
                    PixelContentUnavailableView(error: error) {
                        Button("Retry", systemImage: "arrow.circlepath") {
                            Task {
                                await task()
                            }
                        }
                        .buttonStyle(.pixelRoundedRectangle)
                    }
                    .scenePadding()
                case .loaded:
                    EmptyView()
                }
            }
        .task(task)
    }
    
    private func task() async {
        do {
            state = .loading
            try await action()
            state = .loaded
        } catch {
            state = .failed(error)
        }
    }
}

extension View {
    func load(_ action: @escaping (() async throws -> Void)) -> some View {
        modifier(
            LoadModifier(action: action)
        )
    }
}

#Preview {
    PixelPageBackground()
        .load {
            try await Task.sleep(for: .seconds(1))
            throw AppError.custom("mock error")
        }
}
