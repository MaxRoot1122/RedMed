import SwiftUI

struct ArtifactTopicDetailView: View {
    let topic: ArtifactAidTopic

    private let pageBg = Color(red: 0.949, green: 0.949, blue: 0.969)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                sectionLabel("Recognize")
                whiteCard {
                    ForEach(Array(topic.symptoms.enumerated()), id: \.offset) { index, symptom in
                        if index > 0 { cardDivider }
                        Text(symptom)
                            .font(.system(size: 15))
                            .foregroundColor(.redmedDark)
                            .lineSpacing(3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                    }
                }
                .padding(.bottom, 22)

                sectionLabel("What to do")
                whiteCard {
                    ForEach(Array(topic.care.enumerated()), id: \.offset) { index, step in
                        if index > 0 { cardDivider }
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.redmedAccent)
                                .padding(.top, 4)
                            Text(step)
                                .font(.system(size: 15))
                                .foregroundColor(.redmedDark)
                                .lineSpacing(3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 13)
                    }
                }
                .padding(.bottom, 20)

                PrimaryButton(title: "Call 911") {
                    if let url = EmergencySummaryBuilder.call911URL {
                        UIApplication.shared.open(url)
                    }
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(pageBg)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ArtifactBrandLockup()
            }
            ToolbarItem(placement: .principal) {
                Text(topic.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.redmedDark)
            }
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(Color(red: 0.42, green: 0.43, blue: 0.48))
            .kerning(0.5)
            .padding(.horizontal, 4)
            .padding(.bottom, 6)
    }

    private var cardDivider: some View {
        Divider().overlay(Color.black.opacity(0.06))
    }

    @ViewBuilder
    private func whiteCard<C: View>(@ViewBuilder content: () -> C) -> some View {
        VStack(spacing: 0) { content() }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        ArtifactTopicDetailView(topic: artifactAidTopics["car-crash"]!)
    }
}
