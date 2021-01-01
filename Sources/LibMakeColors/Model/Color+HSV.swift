extension Color {
    init(hue: Int, saturation: UInt8, value: UInt8, alpha: UInt8 = 0xFF) {
        let degrees = abs(hue % 360)

        let s = Double(saturation) / 0xFF
        let v = Double(value) / 0xFF
        let C = s * v
        let X = C * (1 - abs((Double(degrees) / 60).truncatingRemainder(dividingBy: 2) - 1))
        let m = v - C

        let result: (r: Double, g: Double, b: Double)
        switch degrees {
        case 0..<60:
            result = (C, X, 0)
        case 60..<120:
            result = (X, C, 0)
        case 120..<180:
            result = (0, C, X)
        case 180..<240:
            result = (0, X, C)
        case 240..<300:
            result = (X, 0, C)
        case 300..<360:
            result = (C, 0, X)
        default:
            fatalError("Degrees out of range")
        }

        self.init(
            red: UInt8(((result.r + m) * 0xFF).rounded()),
            green: UInt8(((result.g + m) * 0xFF).rounded()),
            blue: UInt8(((result.b + m) * 0xFF).rounded()),
            alpha: alpha
        )
    }
}
