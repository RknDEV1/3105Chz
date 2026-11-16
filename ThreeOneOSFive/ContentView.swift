import SwiftUI
import Darwin

/// Tela única com visual do projeto e execução ativa.
struct ContentView: View {
    @AppStorage("raki.theme.mode") private var themeMode = RakiThemeMode.dark.rawValue
    @AppStorage("raki.accent.variant") private var accentVariant = RakiAccentVariant.pink.rawValue

    // Estados para controle do processo
    @State private var isRunning = false
    @State private var logOutput = "Aguardando ação...\n"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                statusCard
                patchCard

                // Console de Log
                panel {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Console")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 2)

                        ScrollView {
                            Text(logOutput)
                                .font(.system(.footnote, design: .monospaced))
                                .foregroundStyle(.green)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 120)
                    }
                }
            }
            .padding(.horizontal, AppTheme.pageInset)
            .padding(.top, 24)
            .padding(.bottom, 32)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .background(AppTheme.pageBackground.ignoresSafeArea())
        .tint(AppTheme.accent)
        .preferredColorScheme(
            RakiThemeMode(rawValue: themeMode)?.colorScheme ?? .dark
        )
        .id(accentVariant + themeMode)
    }

    private var header: some View {
        HStack(spacing: 14) {
            AppLogo(size: 54)

            VStack(alignment: .leading, spacing: 4) {
                Text("Patches")
                    .font(.largeTitle.weight(.bold))

                Text("Utilitário local · modo ativo")
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

                    Text(isRunning ? "Executando patch..." : "Pronto para aplicar.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                Text(isRunning ? "RUN" : "SYS")
                    .font(.caption2.weight(.bold))
                    .tracking(0.4)
                    .foregroundStyle(isRunning ? .red : AppTheme.accent)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background((isRunning ? Color.red : AppTheme.accent).opacity(0.12), in: Capsule())
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
                    // BOTÃO ATIVAR DESTRAVADO
                    actionButton(
                        title: isRunning ? "Aplicando..." : "Ativar",
                        symbol: "power",
                        accent: true,
                        action: { executeEngine(args: []) }
                    )
                    .disabled(isRunning)
                    .opacity(isRunning ? 0.6 : 1.0)

                    // BOTÃO DESATIVAR DESTRAVADO
                    actionButton(
                        title: "Desativar",
                        symbol: "stop.circle.fill",
                        accent: false,
                        action: { executeEngine(args: ["--restore"]) }
                    )
                    .disabled(isRunning)
                    .opacity(isRunning ? 0.6 : 1.0)
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func actionButton(
        title: String,
        symbol: String,
        accent: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
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

    // A ENGINE INJETADA
    func executeEngine(args: [String]) {
        isRunning = true
        logOutput = "> Iniciando processo...\n"
        
        // Nome exato do arquivo que o Manus puxou
        guard let bundlePath = Bundle.main.url(forResource: "HS-PESCO-O-2-2", withExtension: "3105")?.path ?? Bundle.main.url(forResource: "HS-PESCO-0-2-2", withExtension: "3105")?.path else {
            logOutput += "> ❌ Erro: Arquivo .3105 não encontrado no bundle.\n"
            isRunning = false
            return
        }
        
        let tempDir = NSTemporaryDirectory()
        let exePath = (tempDir as NSString).appendingPathComponent("patch.bin")
        let fm = FileManager.default
        
        do {
            if fm.fileExists(atPath: exePath) { try fm.removeItem(atPath: exePath) }
            try fm.copyItem(atPath: bundlePath, toPath: exePath)
            chmod(exePath, 0o755)
            logOutput += "> ✅ Binário preparado em /tmp.\n"
        } catch {
            logOutput += "> ❌ Erro ao preparar: \(error.localizedDescription)\n"
            isRunning = false
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var pid: pid_t = 0
            var argv: [UnsafeMutablePointer<CChar>?] = []
            
            argv.append(strdup(exePath))
            for arg in args { argv.append(strdup(arg)) }
            argv.append(nil)
            
            var fileActions: posix_spawn_file_actions_t?
            posix_spawn_file_actions_init(&fileActions)
            
            let status = posix_spawn(&pid, exePath, &fileActions, nil, argv, environ)
            
            posix_spawn_file_actions_destroy(&fileActions)
            for ptr in argv { free(ptr) }
            
            DispatchQueue.main.async {
                if status == 0 {
                    logOutput += "> 🚀 Processo iniciado (PID: \(pid)).\n"
                    var waitStatus: Int32 = 0
                    waitpid(pid, &waitStatus, 0)
                    logOutput += "> ✅ Finalizado com status: \(waitStatus).\n"
                } else {
                    logOutput += "> ❌ Falha no posix_spawn. Código: \(status)\n"
                }
                isRunning = false
            }
        }
    }
}
