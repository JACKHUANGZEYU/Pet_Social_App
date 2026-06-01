import SwiftUI

struct AppTheme {
    let palette = AppPalette()
}

struct AppPalette {
    let appBackground = Color(red: 0.98, green: 0.95, blue: 0.90)
    let surface = Color.white
    let accent = Color(red: 0.90, green: 0.40, blue: 0.17)
    let accentSoft = Color(red: 0.98, green: 0.88, blue: 0.80)
    let ink = Color(red: 0.16, green: 0.12, blue: 0.10)
    let muted = Color(red: 0.45, green: 0.39, blue: 0.35)
    let stroke = Color(red: 0.90, green: 0.82, blue: 0.74)
}
