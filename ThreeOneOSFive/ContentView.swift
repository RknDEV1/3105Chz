import SwiftUI
import Darwin

/// Tela principal do CHZ Inject, baseada na referência visual sem o cartão de diagnóstico.
struct ContentView: View {
    @AppStorage("raki.theme.mode") private var themeMode = RakiThemeMode.dark.rawValue
    @AppStorage("raki.accent.variant") private var accentVariant = RakiAccentVariant.pink.rawValue

    @State private var isRunning = false
    @State private var logOutput = "Aguardando ação...\n"

    private let injectPink = Color(red: 1.00, green: 0.08, blue: 0.55)

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, 12)

            ScrollView {
                VStack(spacing: 22) {
                    statusCard
                    controlsCard
                }
                .padding(.horizontal, 22)
                .padding(.top, 38)
                .padding(.bottom, 28)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }

            footer
                .padding(.top, 12)
                .padding(.bottom, 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .tint(injectPink)
        .preferredColorScheme(
            RakiThemeMode(rawValue: themeMode)?.colorScheme ?? .dark
        )
        .id(accentVariant + themeMode)
    }

    private var header: some View {
        Text("Chz Inject")
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .accessibilityAddTraits(.isHeader)
    }

    private var statusCard: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(isRunning ? injectPink : Color.gray)
                .frame(width: 11, height: 11)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text("HS Pescoço")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(.white)

                Text(isRunning ? "STATUS  •  EXECUTANDO" : "STATUS  •  DESATIVADO")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(Color.white.opacity(0.58))
            }

            Spacer(minLength: 8)

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(injectPink)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(white: 0.12),
            in: RoundedRectangle(cornerRadius: 25, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                .accessibilityHidden(true)
        }
    }

    private var controlsCard: some View {
        VStack(spacing: 12) {
            actionButton(
                title: isRunning ? "APLICANDO..." : "ATIVAR HS",
                symbol: "checkmark.shield.fill",
                accent: true,
                action: { executeEngine(args: []) }
            )
            .disabled(isRunning)

            actionButton(
                title: "DESATIVAR HS",
                symbol: "stop.circle",
                accent: false,
                action: { executeEngine(args: ["--restore"]) }
            )
            .disabled(isRunning)
        }
        .padding(17)
        .background(
            Color(white: 0.035),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(injectPink.opacity(0.34), lineWidth: 1)
                .accessibilityHidden(true)
        }
        .shadow(color: injectPink.opacity(0.13), radius: 22, y: 3)
    }

    private func actionButton(
        title: String,
        symbol: String,
        accent: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .bold))
                Text(title)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .tracking(0.3)
            }
            .frame(maxWidth: .infinity, minHeight: 62)
            .foregroundStyle(accent ? Color.black : Color.white.opacity(0.34))
            .background(
                accent ? injectPink : Color.white.opacity(0.025),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .overlay {
                if !accent {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.055), lineWidth: 1)
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private var footer: some View {
        HStack(spacing: 8) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 13, weight: .bold))
            Text("CHZ INJECT  •  HS PESCOÇO")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .tracking(1.8)
        }
        .foregroundStyle(Color.white.opacity(0.58))
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
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
