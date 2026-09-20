import SwiftUI
import WebKit

// MARK: - Colors

private let foldActiveColor = Color(
    red: 1.0,
    green: 0.22,
    blue: 0.10
)

private let foldInactiveColor = Color.green

private let leftFoldBackground =
    Color.blue.opacity(0.055)

private let rightFoldBackground =
    Color.orange.opacity(0.055)


// MARK: - Content View

struct ContentView: View {

    var body: some View {

        GeometryReader { proxy in

            let regions = proxy.reservedRegions(
                kind: .division,
                options: .includeInactive
            )

            let region = regions.first

            let isFolded =
                region?.isActive == true

            let foldFrame =
                region?.frame ?? .zero

            // Closed Duo is much narrower than the
            // fully-open presentation.
            let isCompact =
                !isFolded &&
                proxy.size.width < 650


            ZStack {

                // MARK: Background

                AppBackground(
                    isFolded: isFolded,
                    isCompact: isCompact
                )


                // MARK: Main presentation

                if isFolded {

                    FoldedLayout(
                        regionsCount: regions.count,
                        foldFrame: foldFrame
                    )

                } else if isCompact {

                    CompactLayout(
                        regionsCount: regions.count,
                        foldFrame: foldFrame
                    )

                } else {

                    OpenLayout(
                        regionsCount: regions.count,
                        foldFrame: foldFrame
                    )
                }


                // MARK: Physical fold indicator

                if isFolded {

                    FoldIndicatorOverlay(
                        rootSize: proxy.size,
                        foldFrame: foldFrame
                    )
                    .allowsHitTesting(false)
                }
            }
            .animation(
                .smooth(duration: 0.35),
                value: isFolded
            )
            .animation(
                .smooth(duration: 0.35),
                value: isCompact
            )
        }
    }
}


// MARK: - Background

private struct AppBackground: View {

    let isFolded: Bool
    let isCompact: Bool

    var body: some View {

        if isFolded {

            LinearGradient(
                colors: [
                    Color.blue.opacity(0.12),
                    Color.purple.opacity(0.07),
                    Color.orange.opacity(0.09)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .ignoresSafeArea()

        } else if isCompact {

            LinearGradient(
                colors: [
                    Color.blue.opacity(0.09),
                    Color.purple.opacity(0.055),
                    Color.orange.opacity(0.045)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

        } else {

            LinearGradient(
                colors: [
                    Color.blue.opacity(0.10),
                    Color.purple.opacity(0.07),
                    Color.orange.opacity(0.06)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
}


// MARK: - Fold Indicator

private struct FoldIndicatorOverlay: View {

    let rootSize: CGSize
    let foldFrame: CGRect

    var body: some View {

        GeometryReader { overlay in

            let scaleX =
                overlay.size.width /
                max(rootSize.width, 1)

            let scaleY =
                overlay.size.height /
                max(rootSize.height, 1)

            let foldX =
                foldFrame.minX * scaleX

            let foldWidth =
                foldFrame.width * scaleX

            let foldCenterX =
                foldFrame.midX * scaleX

            let foldTop =
                foldFrame.minY * scaleY

            let foldHeight =
                foldFrame.height * scaleY


            ZStack(alignment: .topLeading) {

                Rectangle()
                    .fill(
                        foldActiveColor.opacity(0.018)
                    )
                    .frame(
                        width: max(foldWidth, 1),
                        height: foldHeight
                    )
                    .offset(
                        x: foldX,
                        y: foldTop
                    )


                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange,
                                foldActiveColor,
                                Color.red
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(
                        width: 4,
                        height: foldHeight
                    )
                    .offset(
                        x: foldCenterX - 2,
                        y: foldTop
                    )
                    .shadow(
                        color:
                            foldActiveColor.opacity(0.40),
                        radius: 5
                    )
            }
        }
    }
}


// MARK: - Folded Layout

private struct FoldedLayout: View {

    let regionsCount: Int
    let foldFrame: CGRect

    var body: some View {

        VStack(spacing: 14) {

            ArrangementView {

                FoldPrimaryPanel(
                    regionsCount: regionsCount,
                    foldFrame: foldFrame
                )

            } secondary: {

                FoldSecondaryPanel(
                    foldFrame: foldFrame
                )
            }
            .arrangementViewStyle(
                .split.axes(.horizontal)
            )


            FoldWebPanel(
                isFolded: true,
                regionsCount: regionsCount,
                foldFrame: foldFrame
            )
            .frame(height: 155)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
    }
}


// MARK: - Fold Primary Panel

private struct FoldPrimaryPanel: View {

    let regionsCount: Int
    let foldFrame: CGRect

    var body: some View {

        ZStack {

            leftFoldBackground
                .ignoresSafeArea()


            VStack(
                alignment: .leading,
                spacing: 18
            ) {

                VStack(
                    alignment: .leading,
                    spacing: 7
                ) {

                    BrandLabel()


                    Text("Fold\nInspector")
                        .font(
                            .system(
                                size: 38,
                                weight: .bold
                            )
                        )
                        .tracking(-1.2)
                }


                Spacer()


                VStack(
                    alignment: .leading,
                    spacing: 10
                ) {

                    Label(
                        "Dobra ativa",
                        systemImage:
                            "rectangle.split.2x1"
                    )
                    .font(.title3.bold())
                    .foregroundStyle(
                        foldActiveColor
                    )


                    Text(
                        "O sistema dividiu a interface entre as duas regiões físicas."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                }


                Divider()


                HStack(spacing: 12) {

                    CompactMetric(
                        title: "REGIÕES",
                        value:
                            "\(regionsCount)"
                    )


                    CompactMetric(
                        title: "ESTADO",
                        value: "ATIVA"
                    )


                    CompactMetric(
                        title: "LARGURA",
                        value:
                            number(foldFrame.width)
                    )
                }
            }
            .padding(24)
        }
        .glassEffect(
            .regular,
            in: .rect(
                cornerRadius: 30
            )
        )
    }
}


// MARK: - Fold Secondary Panel

private struct FoldSecondaryPanel: View {

    let foldFrame: CGRect

    var body: some View {

        ZStack {

            rightFoldBackground
                .ignoresSafeArea()


            VStack(
                alignment: .leading,
                spacing: 16
            ) {

                HStack(
                    alignment: .top
                ) {

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text("RESERVED REGION")
                            .font(.caption2.bold())
                            .foregroundStyle(.secondary)


                        Text("Divisão ativa")
                            .font(.title.bold())
                    }


                    Spacer()


                    Circle()
                        .fill(foldActiveColor)
                        .frame(
                            width: 12,
                            height: 12
                        )
                        .shadow(
                            color:
                                foldActiveColor.opacity(0.5),
                            radius: 7
                        )
                }


                Divider()


                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 10
                ) {

                    MetricCard(
                        title: "X",
                        value:
                            number(foldFrame.minX)
                    )


                    MetricCard(
                        title: "Y",
                        value:
                            number(foldFrame.minY)
                    )


                    MetricCard(
                        title: "LARGURA",
                        value:
                            "\(number(foldFrame.width)) pt"
                    )


                    MetricCard(
                        title: "ALTURA",
                        value:
                            "\(number(foldFrame.height)) pt"
                    )
                }


                Spacer()


                HStack(
                    alignment: .top,
                    spacing: 9
                ) {

                    Image(
                        systemName:
                            "info.circle.fill"
                    )
                    .foregroundStyle(
                        foldActiveColor
                    )


                    VStack(
                        alignment: .leading,
                        spacing: 3
                    ) {

                        Text("ArrangementView")
                            .font(.caption.bold())


                        Text(
                            "O sistema posiciona cada painel ao redor da divisão."
                        )
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(22)
        }
        .glassEffect(
            .regular,
            in: .rect(
                cornerRadius: 30
            )
        )
    }
}


// MARK: - Compact / Closed Layout

private struct CompactLayout: View {

    let regionsCount: Int
    let foldFrame: CGRect

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 16
            ) {

                // MARK: Compact Header

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {

                    BrandLabel()


                    Text("Fold Inspector")
                        .font(
                            .system(
                                size: 34,
                                weight: .bold
                            )
                        )
                        .tracking(-1.1)


                    Text(
                        "Inspeção da postura e da região reservada."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 4)


                // MARK: State Card

                VStack(
                    alignment: .leading,
                    spacing: 16
                ) {

                    HStack(spacing: 14) {

                        ZStack {

                            Circle()
                                .fill(
                                    foldInactiveColor.opacity(0.15)
                                )
                                .frame(
                                    width: 48,
                                    height: 48
                                )


                            Image(
                                systemName: "rectangle"
                            )
                            .font(
                                .system(
                                    size: 20,
                                    weight: .semibold
                                )
                            )
                            .foregroundStyle(
                                foldInactiveColor
                            )
                        }


                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text("DEVICE POSTURE")
                                .font(.caption2.bold())
                                .foregroundStyle(.secondary)


                            Text("Fechado")
                                .font(.title2.bold())
                        }


                        Spacer()


                        Circle()
                            .fill(
                                foldInactiveColor
                            )
                            .frame(
                                width: 11,
                                height: 11
                            )
                    }


                    Divider()


                    HStack(spacing: 12) {

                        CompactMetric(
                            title: "REGIÕES",
                            value:
                                "\(regionsCount)"
                        )


                        CompactMetric(
                            title: "DOBRA",
                            value: "INATIVA"
                        )


                        CompactMetric(
                            title: "LARGURA",
                            value:
                                "\(Int(foldFrame.width)) pt"
                        )
                    }
                }
                .padding(20)
                .glassEffect(
                    .regular,
                    in: .rect(
                        cornerRadius: 26
                    )
                )


                // MARK: Geometry Card

                VStack(
                    alignment: .leading,
                    spacing: 14
                ) {

                    HStack {

                        Text("Reserved Region")
                            .font(.headline)


                        Spacer()


                        Label(
                            "Inativa",
                            systemImage: "circle"
                        )
                        .font(.caption.bold())
                        .foregroundStyle(
                            foldInactiveColor
                        )
                    }


                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 10
                    ) {

                        MetricCard(
                            title: "X",
                            value:
                                number(foldFrame.minX)
                        )


                        MetricCard(
                            title: "Y",
                            value:
                                number(foldFrame.minY)
                        )


                        MetricCard(
                            title: "LARGURA",
                            value:
                                "\(number(foldFrame.width)) pt"
                        )


                        MetricCard(
                            title: "ALTURA",
                            value:
                                "\(number(foldFrame.height)) pt"
                        )
                    }


                    Text(
                        "A divisão continua registrada pelo sistema, mas não está ativa neste estado."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(20)
                .glassEffect(
                    .regular,
                    in: .rect(
                        cornerRadius: 26
                    )
                )


                // MARK: WebView

                FoldWebPanel(
                    isFolded: false,
                    regionsCount: regionsCount,
                    foldFrame: foldFrame
                )
                .frame(height: 210)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
    }
}


// MARK: - Fully Open Layout

private struct OpenLayout: View {

    let regionsCount: Int
    let foldFrame: CGRect

    var body: some View {

        VStack(spacing: 14) {

            HStack(spacing: 16) {

                VStack(
                    alignment: .leading,
                    spacing: 18
                ) {

                    VStack(
                        alignment: .leading,
                        spacing: 7
                    ) {

                        BrandLabel()


                        Text("Fold\nInspector")
                            .font(
                                .system(
                                    size: 36,
                                    weight: .bold
                                )
                            )
                            .tracking(-1.2)
                    }


                    Spacer()


                    VStack(
                        alignment: .leading,
                        spacing: 9
                    ) {

                        Label(
                            "Dobra inativa",
                            systemImage: "rectangle"
                        )
                        .font(.headline)
                        .foregroundStyle(
                            foldInactiveColor
                        )


                        Text(
                            "O aparelho está totalmente aberto."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(24)
                .frame(width: 260)
                .frame(maxHeight: .infinity)
                .glassEffect(
                    .regular,
                    in: .rect(
                        cornerRadius: 30
                    )
                )


                VStack(
                    alignment: .leading,
                    spacing: 18
                ) {

                    HStack {

                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {

                            Text("DEVICE POSTURE")
                                .font(.caption2.bold())
                                .foregroundStyle(.secondary)


                            Text("Totalmente aberto")
                                .font(.title.bold())
                        }


                        Spacer()


                        Circle()
                            .fill(
                                foldInactiveColor
                            )
                            .frame(
                                width: 12,
                                height: 12
                            )
                    }


                    Divider()


                    HStack(spacing: 10) {

                        MetricCard(
                            title: "REGIÕES",
                            value:
                                "\(regionsCount)"
                        )


                        MetricCard(
                            title: "ESTADO",
                            value: "INATIVA"
                        )


                        MetricCard(
                            title: "X",
                            value:
                                number(foldFrame.minX)
                        )


                        MetricCard(
                            title: "LARGURA",
                            value:
                                "\(number(foldFrame.width)) pt"
                        )
                    }


                    Spacer()


                    HStack(
                        alignment: .top,
                        spacing: 10
                    ) {

                        Image(
                            systemName:
                                "rectangle.split.2x1"
                        )
                        .font(.title2)
                        .foregroundStyle(.secondary)


                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {

                            Text("Reserved Region")
                                .font(.headline)


                            Text(
                                "A divisão existe, mas está inativa."
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(24)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .glassEffect(
                    .regular,
                    in: .rect(
                        cornerRadius: 30
                    )
                )
            }


            FoldWebPanel(
                isFolded: false,
                regionsCount: regionsCount,
                foldFrame: foldFrame
            )
            .frame(height: 155)
        }
        .padding(20)
    }
}


// MARK: - Brand Label

private struct BrandLabel: View {

    var body: some View {

        Text("VELHOBIT LABS")
            .font(.caption2)
            .fontWeight(.bold)
            .tracking(1.8)
            .foregroundStyle(.secondary)
    }
}


// MARK: - Compact Metric

private struct CompactMetric: View {

    let title: String
    let value: String

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 4
        ) {

            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)


            Text(value)
                .font(.headline)
                .monospacedDigit()
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }
}


// MARK: - Metric Card

private struct MetricCard: View {

    let title: String
    let value: String

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)


            Text(value)
                .font(
                    .system(
                        .headline,
                        design: .monospaced
                    )
                )
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(14)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .glassEffect(
            .clear,
            in: .rect(
                cornerRadius: 18
            )
        )
    }
}


// MARK: - Web Panel

private struct FoldWebPanel: View {

    let isFolded: Bool
    let regionsCount: Int
    let foldFrame: CGRect

    var body: some View {

        ZStack {

            FoldWebView(
                isFolded: isFolded,
                regionsCount: regionsCount,
                foldFrame: foldFrame
            )


            VStack {

                HStack {

                    Spacer()


                    HStack(spacing: 6) {

                        Circle()
                            .fill(
                                isFolded
                                    ? foldActiveColor
                                    : foldInactiveColor
                            )
                            .frame(
                                width: 7,
                                height: 7
                            )


                        Text("NATIVE → WEB")
                            .font(.caption2.bold())
                            .tracking(0.7)
                    }
                    .padding(
                        .horizontal,
                        10
                    )
                    .padding(
                        .vertical,
                        6
                    )
                    .glassEffect(
                        .regular,
                        in: .capsule
                    )
                }


                Spacer()
            }
            .padding(10)
            .allowsHitTesting(false)
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: 26,
                style: .continuous
            )
        )
        .glassEffect(
            .regular,
            in: .rect(
                cornerRadius: 26
            )
        )
    }
}


// MARK: - WKWebView

struct FoldWebView: UIViewRepresentable {

    let isFolded: Bool
    let regionsCount: Int
    let foldFrame: CGRect


    func makeCoordinator() -> Coordinator {

        Coordinator()
    }


    func makeUIView(
        context: Context
    ) -> WKWebView {

        let configuration =
            WKWebViewConfiguration()


        let webView =
            WKWebView(
                frame: .zero,
                configuration: configuration
            )


        webView.isOpaque = false

        webView.backgroundColor =
            .clear

        webView.scrollView.backgroundColor =
            .clear

        webView.navigationDelegate =
            context.coordinator


        context.coordinator.webView =
            webView


        context.coordinator.updateState(
            isFolded: isFolded,
            regionsCount: regionsCount,
            frame: foldFrame
        )


        let fileURL = URL(
            fileURLWithPath:
                "/Users/portillo/Downloads/test.html"
        )


        let directory =
            fileURL.deletingLastPathComponent()


        webView.loadFileURL(
            fileURL,
            allowingReadAccessTo:
                directory
        )


        return webView
    }


    func updateUIView(
        _ webView: WKWebView,
        context: Context
    ) {

        context.coordinator.updateState(
            isFolded: isFolded,
            regionsCount: regionsCount,
            frame: foldFrame
        )


        context.coordinator.sendState()
    }


    final class Coordinator:
        NSObject,
        WKNavigationDelegate
    {

        weak var webView: WKWebView?

        private var loaded = false

        private var isFolded = false

        private var regionsCount = 0

        private var foldFrame =
            CGRect.zero


        func updateState(
            isFolded: Bool,
            regionsCount: Int,
            frame: CGRect
        ) {

            self.isFolded =
                isFolded

            self.regionsCount =
                regionsCount

            self.foldFrame =
                frame
        }


        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {

            loaded = true

            sendState()
        }


        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {

            print(
                "WKWebView navigation error:",
                error.localizedDescription
            )
        }


        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {

            print(
                "WKWebView loading error:",
                error.localizedDescription
            )
        }


        // MARK: Native → Web

        func sendState() {

            guard
                loaded,
                let webView
            else {
                return
            }


            let division: [String: Any] = [

                "x":
                    Double(
                        foldFrame.origin.x
                    ),

                "y":
                    Double(
                        foldFrame.origin.y
                    ),

                "width":
                    Double(
                        foldFrame.width
                    ),

                "height":
                    Double(
                        foldFrame.height
                    ),

                "midX":
                    Double(
                        foldFrame.midX
                    ),

                "midY":
                    Double(
                        foldFrame.midY
                    )
            ]


            let payload: [String: Any] = [

                "folded":
                    isFolded,

                "active":
                    isFolded,

                "isActive":
                    isFolded,

                "posture":
                    isFolded
                        ? "folded"
                        : "continuous",

                "regionsCount":
                    regionsCount,

                "division":
                    division,

                "source":
                    "SwiftUI ReservedRegion",

                "timestamp":
                    Date().timeIntervalSince1970
            ]


            guard
                let data =
                    try? JSONSerialization.data(
                        withJSONObject: payload
                    ),

                let json =
                    String(
                        data: data,
                        encoding: .utf8
                    )
            else {
                return
            }


            let javascript = """

            (() => {

                const state = \(json);

                window.__foldState = state;

                window.dispatchEvent(
                    new CustomEvent(
                        "foldchange",
                        {
                            detail: state
                        }
                    )
                );

                console.log(
                    "[VelhoBit Native Bridge]",
                    state
                );

            })();

            """


            webView.evaluateJavaScript(
                javascript
            ) { _, error in

                if let error {

                    print(
                        "Fold bridge JS error:",
                        error.localizedDescription
                    )

                } else {

                    print(
                        "Fold state sent to WebView:",
                        json
                    )
                }
            }
        }
    }
}


// MARK: - Helpers

private func number(
    _ value: CGFloat
) -> String {

    String(
        format: "%.1f",
        Double(value)
    )
}


// MARK: - Preview

#Preview {
    ContentView()
}
