//
//  PixelReminderTimePickerPanel.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/5.
//

import SwiftUI

struct PixelReminderTimePickerPanel: View {
    @Binding var reminderDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        PixelRoundedRectangleCard(title: "Reminder Time", systemImage: "clock.fill") {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "clock.badge.checkmark.fill")
                        .font(.title2.weight(.black))
                        .foregroundStyle(.pixelLeaf)
                    Text(reminderDate, format: .dateTime.hour().minute())
                        .font(.pixel(.largeTitle))
                        .foregroundStyle(.pixelInk)
                        .contentTransition(.numericText())
                        .animation(.smooth, value: reminderDate)
                }
                
                VStack(spacing: 12) {
                    PixelStepper(value: hourBinding, in: 0...23) {
                        PixelTimeStepperLabel(
                            title: "Hour",
                            value: hour
                        )
                    }
                    
                    PixelStepper(value: minuteBinding, in: 0...59, step: 5) {
                        PixelTimeStepperLabel(
                            title: "Minute",
                            value: minute
                        )
                    }
                }
                .padding(12)
                .background(.pixelCream, in: .rect(cornerRadius: 4))
                .overlay {
                    Rectangle()
                        .stroke(Color.pixelPaperShadow.opacity(0.62), lineWidth: 2)
                }
                
                Button("Done", systemImage: "checkmark") {
                    dismiss()
                }
                .buttonStyle(.pixelRoundedRectangle(width: .expanded))
            }
        }
        .padding()
        .frame(width: 320)
        .background(.pixelPaper)
    }
}

#Preview {
    @Previewable @State var reminderDate = Date.now
    
    PixelReminderTimePickerPanel(reminderDate: $reminderDate)
}

private struct PixelTimeStepperLabel: View {
    let title: LocalizedStringKey
    let value: Int
    
    var body: some View {
        HStack(spacing: 10) {
            Text(value, format: .number.precision(.integerLength(2)))
                .font(.pixel(.title3))
                .foregroundStyle(.white)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.smooth, value: value)
                .padding(.horizontal, 8)
                .background(.pixelLeafDark, in: .rect(cornerRadius: 4))
                .overlay {
                    Rectangle()
                        .stroke(Color.pixelInk.opacity(0.58), lineWidth: 2)
                }
            
            Text(title)
                .font(.pixel(.headline))
                .foregroundStyle(.pixelInk)
        }
    }
}

private extension PixelReminderTimePickerPanel {
    var calendar: Calendar {
        .current
    }
    
    var hour: Int {
        calendar.component(.hour, from: reminderDate)
    }
    
    var minute: Int {
        calendar.component(.minute, from: reminderDate)
    }

    var hourBinding: Binding<Int> {
        Binding(
            get: { hour },
            set: { updateDate(hour: $0, minute: minute) }
        )
    }
    
    var minuteBinding: Binding<Int> {
        Binding(
            get: { minute },
            set: { updateDate(hour: hour, minute: $0) }
        )
    }
    
    func updateDate(hour: Int, minute: Int) {
        reminderDate = calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: reminderDate
        ) ?? reminderDate
    }
}
