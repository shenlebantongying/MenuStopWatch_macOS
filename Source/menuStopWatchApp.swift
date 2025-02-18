import SwiftUI

final class MyTimer: ObservableObject {
    @Published var timerText = ""

    var startTime = Date()

    init(){
        update()
    }
    
    func reset() {
        startTime = Date()
    }
    
    func update() {
        timerText =
            Duration
            .seconds(Date().timeIntervalSince(startTime))
            .formatted(
                .units(
                    allowed: [.hours, .minutes, .seconds],
                    width: .wide
                ))
    }
}

struct MyContentView: View {
    @EnvironmentObject var t: MyTimer
    var body: some View {
        VStack {
            Text("\(t.timerText)")
            Button(
                "Reset",
                action: {
                    t.reset()
                })
            Button(
                "Quit",
                action: {
                    exit(0)
                }
            )

        }
        .padding()
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        let bundleIdentifier = Bundle.main.bundleIdentifier

        if NSWorkspace.shared.runningApplications.filter({ $0.bundleIdentifier == bundleIdentifier }).count > 1 {
            debugPrint("App already running.")
            exit(0)
        }
    }
}

@main
struct menuStopWatchApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {

        MenuBarExtra("MenuStopWatch", systemImage: "timer") {
            let t = MyTimer()
            MyContentView()
                .environmentObject(t)
                .onAppear {
                    NotificationCenter.default.addObserver(
                        forName: NSWindow.didChangeOcclusionStateNotification, object: nil, queue: nil
                    ) { notification in
                            debugPrint((notification.object as! NSWindow).occlusionState.contains(.visible))
                        t.update()
                    }
                }
        }
    }
}

#Preview {
    let t = MyTimer()
    MyContentView()
        .environmentObject(t)
}
