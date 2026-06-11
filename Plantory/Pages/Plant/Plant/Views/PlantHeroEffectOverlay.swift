import SwiftUI

struct PlantHeroEffect: Equatable, Identifiable {
    static let displayDuration: Duration = .seconds(2.4)

    let id = UUID()
    let actionType: RecordActionType
}

struct PlantHeroEffectOverlay: View {
    let effect: PlantHeroEffect

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            switch effect.actionType {
            case .watering:
                WateringEffect(isAnimating: isAnimating)
            case .fertilizing:
                FloatingSymbolEffect(
                    symbols: ["leaf.fill", "sparkle", "leaf.fill"],
                    color: .pixelLeaf,
                    isAnimating: isAnimating
                )
            case .pestControl:
                PestControlEffect(isAnimating: isAnimating)
            case .pruning:
                PruningEffect(isAnimating: isAnimating)
            case .repotting:
                RepottingEffect(isAnimating: isAnimating)
            }
        }
        .frame(height: 300)
        .frame(maxWidth: .infinity)
        .id(effect.id)
        .allowsHitTesting(false)
        .onAppear {
            isAnimating = false
            withAnimation(.easeInOut(duration: 1.15)) {
                isAnimating = true
            }
        }
    }
}

private struct WateringEffect: View {
    let isAnimating: Bool

    @State private var isRaining = false

    private let rainLines: [RainLine] = [
        RainLine(xOffset: -140, length: 38, delay: 0.00),
        RainLine(xOffset: -98, length: 30, delay: 0.08),
        RainLine(xOffset: -56, length: 42, delay: 0.03),
        RainLine(xOffset: -14, length: 34, delay: 0.13),
        RainLine(xOffset: 28, length: 40, delay: 0.06),
        RainLine(xOffset: 70, length: 32, delay: 0.17),
        RainLine(xOffset: 112, length: 38, delay: 0.10),
        RainLine(xOffset: 154, length: 34, delay: 0.20)
    ]

    var body: some View {
        ZStack {
            ForEach(rainLines) { line in
                RainLineView(line: line, isRaining: isRaining && isAnimating)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 0.72).repeatForever(autoreverses: false)) {
                isRaining = true
            }
        }
    }
}

private struct RainLineView: View {
    let line: RainLine
    let isRaining: Bool

    var body: some View {
        Capsule()
            .fill(.blue.opacity(0.86))
            .frame(width: 4, height: line.length)
            .rotationEffect(.degrees(18))
            .offset(
                x: isRaining ? line.xOffset - 82 : line.xOffset + 82,
                y: isRaining ? 190 : -190
            )
            .animation(
                .linear(duration: 0.72).delay(line.delay).repeatForever(autoreverses: false),
                value: isRaining
            )
    }
}

private struct FloatingSymbolEffect: View {
    let symbols: [String]
    let color: Color
    let isAnimating: Bool

    var body: some View {
        HStack(spacing: 34) {
            ForEach(Array(symbols.enumerated()), id: \.offset) { index, symbol in
                Image(systemName: symbol)
                    .font(.system(size: index == 1 ? 24 : 18, weight: .black))
                    .foregroundStyle(color.opacity(isAnimating ? 0 : 0.9))
                    .scaleEffect(isAnimating ? 1.25 : 0.75)
                    .offset(y: isAnimating ? -52 : 24)
                    .animation(
                        .easeOut(duration: 0.85).delay(Double(index) * 0.08),
                        value: isAnimating
                    )
            }
        }
        .offset(y: -10)
    }
}

private struct PestControlEffect: View {
    let isAnimating: Bool

    @State private var phase = ShieldPhase.hidden

    var body: some View {
        Image("PixelShieldIcon")
            .resizable()
            .scaledToFit()
            .frame(width: 72, height: 72)
            .opacity(phase.opacity)
            .scaleEffect(phase.scale)
            .onChange(of: isAnimating, initial: true) { _, newValue in
                guard newValue else {
                    phase = .hidden
                    return
                }
                playAnimation()
            }
    }
}

private enum ShieldPhase {
    case hidden
    case visible
    case fading

    var opacity: Double {
        switch self {
        case .hidden, .fading: 0
        case .visible: 1
        }
    }

    var scale: CGFloat {
        switch self {
        case .hidden: 0.55
        case .visible: 1.15
        case .fading: 1.28
        }
    }
}

private struct PruningEffect: View {
    let isAnimating: Bool

    var body: some View {
        ZStack {
            Image(systemName: "scissors")
                .font(.system(size: 44, weight: .black))
                .foregroundStyle(.pixelInk.opacity(isAnimating ? 0 : 0.9))
                .rotationEffect(.degrees(isAnimating ? -18 : 22))
                .offset(x: isAnimating ? 86 : -86, y: isAnimating ? -22 : 42)
                .animation(.easeInOut(duration: 0.76), value: isAnimating)

            ForEach(LeafChip.all) { chip in
                Image(systemName: "leaf.fill")
                    .font(.system(size: chip.size, weight: .bold))
                    .foregroundStyle(.pixelLeaf.opacity(isAnimating ? 0 : 0.86))
                    .rotationEffect(.degrees(isAnimating ? chip.rotation + 42 : chip.rotation))
                    .offset(
                        x: isAnimating ? chip.xOffset + chip.flyX : chip.xOffset,
                        y: isAnimating ? chip.yOffset + chip.flyY : chip.yOffset
                    )
                    .animation(.easeOut(duration: 0.82).delay(chip.delay), value: isAnimating)
            }
        }
    }
}

private struct RepottingEffect: View {
    let isAnimating: Bool

    var body: some View {
        ZStack {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 56, weight: .black))
                .foregroundStyle(.mint.opacity(isAnimating ? 0 : 0.86))
                .rotationEffect(.degrees(isAnimating ? 220 : -18))
                .scaleEffect(isAnimating ? 1.2 : 0.8)
                .animation(.easeInOut(duration: 0.92), value: isAnimating)

            ForEach(SoilBlock.all) { block in
                RoundedRectangle(cornerRadius: 2)
                    .fill(.pixelWood.opacity(isAnimating ? 0 : 0.88))
                    .frame(width: block.size, height: block.size)
                    .rotationEffect(.degrees(isAnimating ? block.rotation + 36 : block.rotation))
                    .offset(
                        x: block.xOffset,
                        y: isAnimating ? block.yOffset - 52 : block.yOffset + 28
                    )
                    .animation(.easeOut(duration: 0.8).delay(block.delay), value: isAnimating)
            }
        }
    }
}

private struct RainLine: Identifiable {
    let id = UUID()
    let xOffset: CGFloat
    let length: CGFloat
    let delay: TimeInterval
}

private struct LeafChip: Identifiable {
    static let all: [LeafChip] = [
        LeafChip(xOffset: -32, yOffset: 8, flyX: -34, flyY: -44, size: 13, rotation: -24, delay: 0.18),
        LeafChip(xOffset: 6, yOffset: -6, flyX: 28, flyY: -36, size: 11, rotation: 18, delay: 0.22),
        LeafChip(xOffset: 38, yOffset: 18, flyX: 22, flyY: 34, size: 12, rotation: 34, delay: 0.26)
    ]

    let id = UUID()
    let xOffset: CGFloat
    let yOffset: CGFloat
    let flyX: CGFloat
    let flyY: CGFloat
    let size: CGFloat
    let rotation: Double
    let delay: TimeInterval
}

private struct SoilBlock: Identifiable {
    static let all: [SoilBlock] = [
        SoilBlock(xOffset: -42, yOffset: 46, size: 10, rotation: 8, delay: 0.08),
        SoilBlock(xOffset: -12, yOffset: 58, size: 8, rotation: -16, delay: 0.16),
        SoilBlock(xOffset: 24, yOffset: 50, size: 11, rotation: 22, delay: 0.24),
        SoilBlock(xOffset: 48, yOffset: 62, size: 7, rotation: -8, delay: 0.30)
    ]

    let id = UUID()
    let xOffset: CGFloat
    let yOffset: CGFloat
    let size: CGFloat
    let rotation: Double
    let delay: TimeInterval
}

private extension PestControlEffect {
    func playAnimation() {
        phase = .hidden
        withAnimation(.easeOut(duration: 0.72)) {
            phase = .visible
        }

        Task {
            try? await Task.sleep(for: .seconds(1.35))
            withAnimation(.easeIn(duration: 0.45)) {
                phase = .fading
            }
        }
    }
}

#Preview("Watering") {
    PlantHeroEffectPreviewContainer(actionType: .watering)
}

#Preview("Fertilizing") {
    PlantHeroEffectPreviewContainer(actionType: .fertilizing)
}

#Preview("Pest Control") {
    PlantHeroEffectPreviewContainer(actionType: .pestControl)
}

#Preview("Pruning") {
    PlantHeroEffectPreviewContainer(actionType: .pruning)
}

#Preview("Repotting") {
    PlantHeroEffectPreviewContainer(actionType: .repotting)
}

private struct PlantHeroEffectPreviewContainer: View {
    let actionType: RecordActionType

    var body: some View {
        PixelRectangleCard {
            ZStack {
                Image(.Plants.monsteraHealthy)
                    .pixelate()
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)

                PlantHeroEffectOverlay(effect: PlantHeroEffect(actionType: actionType))
            }
            .clipped()
        }
        .padding()
    }
}
