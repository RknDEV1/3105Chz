import SwiftUI

/// Tela única demonstrativa. Mantém as cores e os componentes visuais do 3105.
/// Os controles são apenas visuais e permanecem desativados.
struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                statusCard

                VStack(alignment: .leading, spacing: 12) {
                    Text("Ações")
                        .font(.title3.weight(.bold))
                        .padding(.horizontal, 2)

                    actionButton(
                        title: "Aplicar Atualização",
                        detail: "Indisponível nesta demonstração",
                        symbol: "arrow.down.circle.fill"
                    )

                    actionButton(
                        title: "Restaurar",
                        detail: "Indisponível nesta demonstração",
                        symbol: "arrow.uturn.backward.circle.fill"
                    )
                }

                Text("Demonstração visual — nenhuma ação será executada.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 2)
            }
            .padding(.horizontal, AppTheme.pageInset)
            .padding(.top, 24)
            .padding(.bottom, 32)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .background(AppTheme.pageBackground.ignoresSafeArea())
        .tint(AppTheme.accent)
    }

    private var header: some View {
        HStack(spacing: 14) {
            AppLogo(size: 54)

            VStack(alignment: .leading, spacing: 4) {
                Text("Atualização")
                    .font(.largeTitle.weight(.bold))

                Text("Utilitário local · demonstração")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.bottom, 2)
    }

    private var statusCard: some View {
        panel {
            HStack(spacing: 14) {
                AppRowIcon(
                    systemName: "iphone",
                    tint: AppTheme.accent,
                    symbolSize: 21,
                    frameSize: 42
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Modo demonstração")
                        .font(.headline)

                    Text("Os controles estão desativados.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                Text("UI")
                    .font(.caption.weight(.bold))
                    .tracking(0.5)
                    .foregroundStyle(AppTheme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.accent.opacity(0.12), in: Capsule())
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func actionButton(
        title: String,
        detail: String,
        symbol: String
    ) -> some View {
        Button(action: {}) {
            panel {
                HStack(spacing: 13) {
                    AppRowIcon(
                        systemName: symbol,
                        tint: AppTheme.accent,
                        symbolSize: 22,
                        frameSize: 42
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)

                        Text(detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 6)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(true)
        .opacity(0.62)
        .accessibilityHint("Indisponível nesta demonstração.")
    }

    private func panel<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(.vertical, AppTheme.contentCardPadding)
            .padding(.leading, AppTheme.contentCardPadding + 6)
            .padding(.trailing, AppTheme.contentCardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                .thinMaterial,
                in: RoundedRectangle(
                    cornerRadius: AppTheme.contentCardCornerRadius,
                    style: .continuous
                )
            )
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.accent)
                    .frame(width: 3)
                    .padding(.vertical, 10)
                    .padding(.leading, 10)
                    .accessibilityHidden(true)
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: AppTheme.contentCardCornerRadius,
                    style: .continuous
                )
                .strokeBorder(Color(uiColor: .separator).opacity(0.22), lineWidth: 0.5)
                .accessibilityHidden(true)
            }
            .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
    }
}
