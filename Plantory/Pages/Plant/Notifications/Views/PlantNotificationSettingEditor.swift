import SwiftUI

struct PlantNotificationSettingEditor: View {
    @Bindable var setting: PlantNotificationSetting
    let isEnabled: Binding<Bool>
    let recommendation: String
    let onConfigurationChanged: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle(isOn: isEnabled) {
                PlantNotificationToggleLabel(setting: setting)
            }
            .toggleStyle(.pixel)

            VStack(alignment: .leading, spacing: 12) {
                PixelStepper(value: $setting.intervalDays, in: setting.kind.intervalRange) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Interval")
                            .font(.pixel(.headline))
                            .foregroundStyle(.pixelInk)
                        
                        Text(intervalDescription)
                            .font(.pixel(.subheadline))
                            .foregroundStyle(Color.pixelInk.opacity(0.66))
                    }
                }

                PixelTimePicker(
                    "Reminder Time",
                    systemImage: "clock.fill",
                    reminderDate: reminderDateBinding
                )
            }
            .padding(12)
            .background(.pixelCream, in: .rect(cornerRadius: 4))
            .overlay {
                Rectangle()
                    .stroke(Color.pixelPaperShadow.opacity(0.62), lineWidth: 2)
            }
            .disabled(!setting.isEnabled)
            .opacity(setting.isEnabled ? 1 : 0.45)
            .onChange(of: setting.intervalDays) { _, _ in
                onConfigurationChanged()
            }
            .onChange(of: setting.reminderHour) { _, _ in
                onConfigurationChanged()
            }
            .onChange(of: setting.reminderMinute) { _, _ in
                onConfigurationChanged()
            }
            
            Text(recommendation)
                .font(.pixel(.subheadline))
                .foregroundStyle(Color.pixelInk.opacity(0.68))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 12)
    }

}

#Preview {
    PlantNotificationSettingEditor(
        setting: PlantNotificationSetting(kind: .watering, isEnabled: true, intervalDays: 7),
        isEnabled: .constant(true),
        recommendation: "Recommended from the plant's watering level.",
        onConfigurationChanged: { }
    )
    .padding()
    .background(.pixelPaper)
}

private struct PlantNotificationToggleLabel: View {
    @Bindable var setting: PlantNotificationSetting
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: setting.kind.systemImage)
                .font(.subheadline.weight(.black))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(setting.kind.tint, in: .rect(cornerRadius: 4))
                .overlay {
                    Rectangle()
                        .stroke(Color.pixelInk.opacity(0.58), lineWidth: 2)
                }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(setting.kind.title)
                    .font(.pixel(.title3))
                    .foregroundStyle(.pixelInk)
                
                Text(setting.isEnabled ? "Active reminder" : "Paused reminder")
                    .font(.pixel(.footnote))
                    .foregroundStyle(Color.pixelInk.opacity(0.58))
            }
        }
    }
}

private extension PlantNotificationSettingEditor {
    var intervalDescription: LocalizedStringKey {
        if setting.intervalDays == 1 {
            return "Every day"
        }
        return "Every \(setting.intervalDays) days"
    }

    var reminderDateBinding: Binding<Date> {
        Binding(
            get: { setting.reminderDate },
            set: { setting.reminderDate = $0 }
        )
    }
}
