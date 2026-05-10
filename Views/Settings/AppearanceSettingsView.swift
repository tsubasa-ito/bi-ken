import SwiftUI

struct AppearanceSettingsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header

            Rectangle()
                .fill(Color.appBorder)
                .frame(height: 1.5)

            List {
                Section {
                    ForEach(AppColorScheme.allCases, id: \.self) { scheme in
                        Button {
                            settings.colorScheme = scheme
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: scheme.icon)
                                    .font(.body)
                                    .foregroundStyle(.appPrimary)
                                    .frame(width: 28, height: 28)

                                Text(scheme.displayName)
                                    .foregroundStyle(.appText)

                                Spacer()

                                if settings.colorScheme == scheme {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.appPrimary)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } footer: {
                    Text("「デフォルト」はスマートフォンの外観設定に従います。")
                        .font(.caption)
                        .foregroundStyle(.appTextSecondary)
                }
                .listRowBackground(Color.appCardBG)
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var header: some View {
        ZStack {
            Color.appBackground

            HStack {
                Button { dismiss() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("設定")
                            .font(.system(size: 16))
                    }
                    .foregroundStyle(.appPrimary)
                }
                .padding(.leading, 16)

                Spacer()

                Text("外観")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundStyle(.appText)

                Spacer()

                Color.clear.frame(width: 70)
            }
            .frame(height: 60)
            .padding(.top, 44)
        }
        .frame(height: 104)
    }
}
