import SwiftUI

/// Demonstração visual de um único patch. Nenhum handler aplica ou restaura conteúdo.
struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                statusCard
                patchCard

                Text("Demonstração visual — ativação e desativação indisponíveis.")
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
                Text("Patches")
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
                    systemName: "shippingbox.fill",
                    tint: AppTheme.accent,
                    symbolSize: 20,
                    frameSize: 42
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text("1 patch")
                        .font(.headline)

                    Text("Este é o único patch listado.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                Text("ÚNICO")
                    .font(.caption2.weight(.bold))
                    .tracking(0.4)
                    .foregroundStyle(AppTheme.accent)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(AppTheme.accent.opacity(0.12), in: Capsule())
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var patchCard: some View {
        panel {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 13) {
                    AppRowIcon(
                        systemName: "shippingbox",
                        tint: AppTheme.accent,
                        symbolSize: 21,
                        frameSize: 42
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("HS-PESCO-O-2-2")
                            .font(.headline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        Text("Pacote .3105 incluído no app")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 4)
                }

                HStack(spacing: 10) {
                    disabledActionButton(
                        title: "Ativar",
                        symbol: "power",
                        accent: true
                    )

                    disabledActionButton(
                        title: "Desativar",
                        symbol: "stop.circle.fill",
                        accent: false
                    )
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func disabledActionButton(
        title: String,
        symbol: String,
        accent: Bool
    ) -> some View {
        Button(action: {}) {
            HStack(spacing: 7) {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .foregroundStyle(accent ? Color.white : AppTheme.accent)
            .background(
                accent ? AppTheme.accent : AppTheme.accent.opacity(0.12),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(true)
        .opacity(0.58)
        .accessibilityHint("Desativado nesta demonstração.")
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
