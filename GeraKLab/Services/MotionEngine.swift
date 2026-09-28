import Foundation
import CoreMotion

@Observable
public final class MotionEngine {
    public static let shared = MotionEngine()

    public var currentGForce: Double = 1.0
    public var peakGForce: Double = 1.0
    public var isTracking: Bool = false

    private let motionManager = CMMotionManager()
    private var updateTimer: Timer?

    private init() {}

    public func startTracking(onPeakReached: ((Double) -> Void)? = nil) {
        guard motionManager.isAccelerometerAvailable else {
            startSimulatedMotion(onPeakReached: onPeakReached)
            return
        }

        isTracking = true
        currentGForce = 1.0
        peakGForce = 1.0
        motionManager.accelerometerUpdateInterval = 0.05
        motionManager.startAccelerometerUpdates()

        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, let data = self.motionManager.accelerometerData else { return }

            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            let totalG = sqrt(x * x + y * y + z * z)

            DispatchQueue.main.async {
                self.currentGForce = totalG
                if totalG > self.peakGForce {
                    self.peakGForce = totalG
                    onPeakReached?(totalG)
                }
            }
        }
    }

    private func startSimulatedMotion(onPeakReached: ((Double) -> Void)?) {
        isTracking = true
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let simulated = Double.random(in: 1.0...4.5)
            DispatchQueue.main.async {
                self.currentGForce = simulated
                if simulated > self.peakGForce {
                    self.peakGForce = simulated
                    onPeakReached?(simulated)
                }
            }
        }
    }

    public func stopTracking() {
        updateTimer?.invalidate()
        updateTimer = nil
        if motionManager.isAccelerometerAvailable {
            motionManager.stopAccelerometerUpdates()
        }
        isTracking = false
        currentGForce = 1.0
    }
}
