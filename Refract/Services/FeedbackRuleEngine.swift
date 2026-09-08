//
//  FeedbackRuleEngine.swift
//  Refract
//
//  Created by Davin P on 08/09/26.
//

// MARK: FeedbackRuleEngine adalah threshold-based feedback message kepada user
enum FeedbackRuleEngine {
    static let highlightClippingThreshold: Double = 0.10
    static let shadowClippingThreshold: Double = 0.10
    static let saturationDeviationThreshold: Double = 0.35
    
    static func evaluate(_ stats: HistogramStats) -> [FeedbackMessage] {
        var feedbackMessages: [FeedbackMessage] = []
        
        if stats.highlightClippingPercentage > highlightClippingThreshold {
            let percent = Int((stats.highlightClippingPercentage * 100).rounded())
            feedbackMessages.append(FeedbackMessage(
                severity: .warning, message: "\(percent)% area terang di foto kamu udah pure white, detailnya ilang. Coba turunin Brightness atau Contrast sedikit."
            ))
        }

        if stats.shadowClippingPercentage > shadowClippingThreshold {
            let percent = Int((stats.shadowClippingPercentage * 100).rounded())
            feedbackMessages.append(FeedbackMessage(
                severity: .warning, message: "\(percent)% area gelap di foto kamu udah pure black, detailnya ilang. Coba naikin Brightness sedikit atau turunin Contrast."
            ))
        }
        
        if abs(stats.saturationDeviation) > saturationDeviationThreshold {
            if stats.saturationDeviation > 0 {
                feedbackMessages.append(FeedbackMessage(
                    severity: .warning,
                    message: "Warna foto kamu kelihatan terlalu jenuh/norak. Coba pakai Vibrance daripada Saturation biar lebih natural."
                ))
            } else {
                feedbackMessages.append(FeedbackMessage(
                    severity: .warning,
                    message: "Warna foto kamu kelihatan pucat/kurang hidup. Coba naikin Vibrance dikit biar lebih punchy tapi tetap natural."
                ))
            }
        }
        
        if feedbackMessages.isEmpty {
            feedbackMessages.append(FeedbackMessage(
                severity: .ok, message: "Exposure dan warna udah balanced, hasil grading kamu solid! 🎉"
            ))
        }
        
        return feedbackMessages
    }
}
