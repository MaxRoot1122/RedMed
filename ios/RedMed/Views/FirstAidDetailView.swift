import SwiftUI

struct FirstAidDetailView: View {
    @Environment(\.layoutMetrics) private var layout
    @Environment(\.dismiss) private var dismiss

    let topic: FirstAidTopic

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    EditSectionLabel(text: "Recognize", isFirst: true)

                    EditCard {
                        ForEach(Array(topic.symptoms.enumerated()), id: \.offset) { index, symptom in
                            Text(symptom)
                                .font(.system(size: layout.s(15)))
                                .foregroundStyle(AppTheme.ink)
                                .lineSpacing(layout.s(3))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, layout.screenPad)
                                .padding(.vertical, layout.s(13))
                            if index < topic.symptoms.count - 1 {
                                EditCardDivider()
                            }
                        }
                    }
                    .padding(.bottom, layout.s(22))

                    EditSectionLabel(text: "What to do")

                    EditCard {
                        ForEach(Array(topic.temporaryCare.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: layout.s(12)) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: layout.s(10), weight: .bold))
                                    .foregroundStyle(AppTheme.accent)
                                    .padding(.top, layout.s(4))
                                Text(CopyHighlight.attributed(step))
                                    .font(.system(size: layout.s(15)))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, layout.screenPad)
                            .padding(.vertical, layout.s(13))
                            if index < topic.temporaryCare.count - 1 {
                                EditCardDivider()
                            }
                        }
                    }
                    .padding(.bottom, layout.s(24))

                    if topic.title == "CPR" {
                        CPRTimerView(embedded: true)
                            .padding(.bottom, layout.spaceMD)
                    }

                    Call911Button()
                }
                .padding(.horizontal, layout.screenPad)
                .padding(.top, layout.s(4))
                .padding(.bottom, layout.s(32))
            }
            .background(ArtifactChrome.editSheetBg)
            .navigationTitle(topic.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: layout.s(5)) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: layout.s(13), weight: .semibold))
                            Text("Aid")
                        }
                        .foregroundStyle(AppTheme.accent)
                    }
                }
            }
        }
    }
}

#Preview {
    FirstAidDetailView(topic: FirstAidLibrary.topics[0])
        .withLayoutMetrics()
}
