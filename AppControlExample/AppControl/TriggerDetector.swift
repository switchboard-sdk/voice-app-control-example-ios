import Foundation

class TriggerDetector {
    
    // Keywords organized by trigger type
    private static var triggerKeywords: [TriggerType: [String]] = [
        .down: ["down", "next", "forward"],
        .up: ["up", "last", "previous", "back"],
        .like: ["like", "favourite", "heart"],
        .dislike: ["dislike", "dont like", "do not like"],
        .expand: ["expand", "details", "open"],
        .runtimeTriggers: []
    ]
    
    // Trim function to remove leading/trailing whitespace
    static func trim(_ str: String) -> String {
        return str.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Clean function to remove regex patterns, trim, lowercase and remove punctuation
    static func clean(_ phrase: String) -> String {
        var input = phrase
        
        // Remove patterns like [text], (text), *text*
        let pattern = "\\[[^\\]]*\\]|\\([^\\)]*\\)|\\*[^*]*\\*"
        input = input.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        
        // Trim whitespace
        input = trim(input)
        
        // Convert to lowercase
        input = input.lowercased()
        
        // Remove punctuation
        input = input.components(separatedBy: CharacterSet.punctuationCharacters).joined()
        
        return input
    }
    
    static func findLongestMatch(_ phrase: String, keywords: [String]) -> String {
        var bestLength = 0
        var bestMatch = ""
        
        for keyword in keywords {
            if phrase.contains(keyword) && keyword.count > bestLength {
                bestMatch = keyword
                bestLength = keyword.count
            }
        }
        
        return bestMatch
    }
    
    // Trigger detection function
    static func detectTrigger(_ phrase: String) -> TriggerResult {
        let cleanedPhrase = clean(phrase)
        var bestLength = 0
        var bestTriggerType: TriggerType = .unknown
        var bestKeyword = ""
        
        for (triggerType, keywords) in triggerKeywords {
            let match = findLongestMatch(cleanedPhrase, keywords: keywords)
            if !match.isEmpty && match.count > bestLength {
                bestTriggerType = triggerType
                bestLength = match.count
                bestKeyword = match
            }
        }
        
        let detected = bestLength > 0
        return TriggerResult(triggerType: bestTriggerType, keyword: bestKeyword, detected: detected)
    }
    
    // Add runtime triggers
    static func setRuntimeTriggers(_ triggers: [String]) {
        triggerKeywords[.runtimeTriggers] = triggers.map { clean($0) }
    }
}
