import SwiftUI

/// Aid topic detail — ports artifact `TopicDetailView.swift` layout.
struct FirstAidDetailView: View {
    @Environment(\.layoutMetrics) private var layout

    let topic: FirstAidTopic

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                EditSectionLabel(title: "Recognize", isFirst: true)
                EditCard {
                    ForEach(Array(topic.symptoms.enumerated()), id: \.offset) { index, symptom in
                        if index > 0 { EditCardDivider(leadingInset: layout.spaceLG) }
                        Text(symptom)
                            .font(.system(size: layout.s(15)))
                            .foregroundStyle(AppTheme.ink)
                            .lineSpacing(3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, layout.spaceLG)
                            .padding(.vertical, layout.s(13))
                    }
                }
                .padding(.bottom, layout.s(22))

                EditSectionLabel(title: "What to do")
                EditCard {
                    ForEach(Array(topic.temporaryCare.enumerated()), id: \.offset) { index, step in
                        if index > 0 { EditCardDivider(leadingInset: layout.spaceLG) }
                        HStack(alignment: .top, spacing: layout.s(12)) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: layout.s(10), weight: .bold))
                                .foregroundStyle(AppTheme.accent)
                                .padding(.top, layout.s(4))
                            Text(CopyHighlight.attributed(step))
                                .font(.system(size: layout.s(15)))
                                .foregroundStyle(AppTheme.ink)
                                .lineSpacing(3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, layout.spaceLG)
                        .padding(.vertical, layout.s(13))
                    }
                }
                .padding(.bottom, layout.spaceLG)

                if topic.title == "CPR" {
                    CPRTimerView(embedded: true)
                        .padding(.bottom, layout.spaceLG)
                }

                Call911Button()
            }
            .padding(.horizontal, layout.screenPad)
            .padding(.bottom, layout.screenBottom)
            .reactiveScrollTrack()
        }
        .reactiveScrollChrome()
        .scrollIndicators(.visible, axes: .vertical)
        .screenAtmosphere()
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FirstAidDetailView(topic: FirstAidLibrary.topics[0])
    }
    .withLayoutMetrics()
}
