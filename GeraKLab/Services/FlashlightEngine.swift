import AVFoundation

@Observable
public final class FlashlightEngine {
    public static let shared = FlashlightEngine()

    public var isStrobeActive: Bool = false
    private var strobeTimer: Timer?
    private var flashState: Bool = false

    private init() {}

    public func startStrobe(frequency: Double = 0.07) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
            isStrobeActive = true
            return
        }

        isStrobeActive = true
        strobeTimer?.invalidate()
        strobeTimer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.flashState.toggle()
            self.setTorch(on: self.flashState, device: device)
        }
    }

    private func setTorch(on: Bool, device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            if on {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            // Игнорируем ошибки блокировки устройства
        }
    }

    public func stopStrobe() {
        strobeTimer?.invalidate()
        strobeTimer = nil
        isStrobeActive = false

        if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
            try? device.lockForConfiguration()
            device.torchMode = .off
            device.unlockForConfiguration()
        }
    }
}
