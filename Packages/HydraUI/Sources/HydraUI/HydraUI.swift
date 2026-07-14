// HydraUI — design system tokens + dumb components. See docs/02 §7, docs/04.
//
// SKELETON. Depends on SwiftUI (iOS SDK), does not build on CLT-only host.
// Token values are defined in Assets.xcassets; components take values, return actions.
//
// Contract (docs/02 §7):
//   enum HydraColor   { water, waterFill, soil, leaf, bloom, heat, caution, surface, ... }
//   enum HydraFont    { display(_:), title, body, caption, numeral (tabular figures) }
//   enum HydraSpacing { xs=4, sm=8, md=16, lg=24, xl=40 }   // no in-between values
//
//   struct ProgressRing: View       // progress 0...1.5; >1.0 bloom, >1.5 caution tone
//   struct PlantView: View          // animated:false for widget + Reduce Motion
//   struct QuickLogRow: View
//   struct HydraButton: View        // primary/secondary/destructive/plain
//   struct InfoCard: View           // neutral/caution/celebration
//                                   // .celebration FORBIDDEN when progress > 1.5 (SG-02)
//   struct WeatherAttributionView: View  // required on every screen showing weather
//
// Implement with SwiftUI in Xcode. Every View ships a #Preview using Stub* services.

import Foundation

/// Spacing scale is pure data, so it can live here without SwiftUI and be unit-tested.
public enum HydraSpacing {
    public static let xs: Double = 4
    public static let sm: Double = 8
    public static let md: Double = 16
    public static let lg: Double = 24
    public static let xl: Double = 40
}
