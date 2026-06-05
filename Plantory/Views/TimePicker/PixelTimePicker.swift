//
//  PixelReminderTimeRow.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/5.
//

import SwiftUI

struct PixelTimePicker: View {
    let title: String?
    let systemImage: String?
    @Binding var reminderDate: Date
    @State private var isPickerPresented = false
    
    init(reminderDate: Binding<Date>) {
        self.title = nil
        self.systemImage = nil
        _reminderDate = reminderDate
    }
    
    init(_ title: String, systemImage: String, reminderDate: Binding<Date>) {
        self.title = title
        self.systemImage = systemImage
        _reminderDate = reminderDate
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let title, let systemImage {
                Label(title, systemImage: systemImage)
                    .font(.pixel(.headline))
                    .foregroundStyle(.pixelInk)
                
                Spacer(minLength: 8)
            }
            
            Button {
                isPickerPresented = true
            } label: {
                HStack(spacing: 8) {
                    Text(reminderTimeText)
                        .font(.pixel(.title3))
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.black))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
            }
            .buttonStyle(.pixelRectangle(fill: .pixelLeafDark, padding: 4))
            .popover(isPresented: $isPickerPresented, arrowEdge: .trailing) {
                PixelReminderTimePickerPanel(reminderDate: $reminderDate)
                    .presentationCompactAdaptation(.popover)
            }
        }
    }
}

#Preview {
    @Previewable @State var reminderDate = Date.now
    PixelTimePicker(
        "Reminder Time",
        systemImage: "clock.fill",
        reminderDate: $reminderDate
    )
    .padding()
}

private extension PixelTimePicker {
    var reminderTimeText: String {
        reminderDate.formatted(date: .omitted, time: .shortened)
    }
}
