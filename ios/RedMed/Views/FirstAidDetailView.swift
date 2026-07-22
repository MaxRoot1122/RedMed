import SwiftUI

struct FirstAidDetailView: View {
    let topic: FirstAidTopic

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 14) {
                    IconWell(systemName: topic.icon, size: 52)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(topic.title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(AppTheme.ink)
                        Text("Until EMS arrives")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.muted)
                    }
                }

                detailCard(title: "Symptoms", tint: AppTheme.accent, soft: AppTheme.accentSoft, items: topic.symptoms)
                detailCard(title: "Temporary care", tint: AppTheme.medical, soft: AppTheme.medicalSoft, items: topic.temporaryCare)

                if topic.title == "CPR" {
                    CPRTimerView(embedded: true)
                }
            }
            .padding(AppTheme.screenPad)
            .padding(.bottom, 24)
        }
        .screenAtmosphere()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailCard(title: String, tint: Color, soft: Color, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionEyebrow(text: title, tint: tint)
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(index == 0 ? Color.white : tint)
                            .frame(width: 22, height: 22)
                            .background(index == 0 ? AnyShapeStyle(LinearGradient(colors: [Color(red: 1, green: 0.45, blue: 0.55), AppTheme.accent], startPoint: .top, endPoint: .bottom)) : AnyShapeStyle(soft))
                            .clipShape(Circle())
                        Text(CopyHighlight.attributed(item))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(index == 0 ? AppTheme.accentSoft.opacity(0.55) : Color.white.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(index == 0 ? AppTheme.accent.opacity(0.16) : AppTheme.line, lineWidth: 1)
                    )
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }
}

#Preview {
    NavigationStack {
        FirstAidDetailView(topic: FirstAidLibrary.topics[0])
    }
}
