#import "AppControlExample.h"

#include <switchboard/SwitchboardV3.hpp>
#include <algorithm>
#include <regex>

using namespace switchboard;

@implementation AppControlExample {
    std::string engineID;
}

enum TriggerType {
   NEXT,
   BACK,
   LIKE,
   DISLIKE,
   EXPAND,
   RUNTIME_TRIGGERS,
   UNKNOWN
};

// Keywords organized by trigger type
static std::map<TriggerType, std::vector<std::string>> triggerKeywords = {
    {TriggerType::NEXT, {
        "next",
        "forward",
        "skip",
        "down"
    }},
    {TriggerType::BACK, {
        "back",
        "last",
        "previous",
        "up"
    }},
    {TriggerType::LIKE, {
        "like",
        "favourite",
        "heart"
    }},
    {TriggerType::DISLIKE, {
        "dislike",
        "dont like",
        "do not like"
    }},
    {TriggerType::EXPAND, {
        "expand",
        "details",
        "open"
    }},
    {TriggerType::RUNTIME_TRIGGERS, {
        // we add items at runtime
    }}
};

// Trim function to remove leading/trailing whitespace
static std::string trim(const std::string& str) {
    auto begin = std::find_if_not(str.begin(), str.end(), ::isspace);
    auto end = std::find_if_not(str.rbegin(), str.rend(), ::isspace).base();

    if (begin >= end) return "";
    return std::string(begin, end);
}

// Clean function to remove regex patterns, trim, lowercase and remove punctuation  
static std::string clean(const std::string& phrase) {
    std::regex pattern(R"(\[[^\]]*\]|\([^\)]*\)|\*[^*]*\*)");
    std::string input = std::regex_replace(phrase, pattern, "");
    input = trim(input);
    std::transform(input.begin(), input.end(), input.begin(), ::tolower);
    input.erase(std::remove_if(input.begin(), input.end(), ::ispunct), input.end());
    return input;
}


// Keyword detection function
static std::string findLongestMatch(const std::string& phrase, const std::vector<std::string>& keywords) {
    size_t bestLength = 0;
    std::string bestMatch;

    for (const auto& keyword : keywords) {
        if (phrase.find(keyword) != std::string::npos && keyword.length() > bestLength) {
            bestMatch = keyword;
            bestLength = keyword.length();
        }
    }
    
    return bestMatch;
}

// Trigger detection function
bool detectTrigger(const std::string& phrase, TriggerType& outMode, std::string& outKeyword) {
    size_t bestLength = 0;
    TriggerType bestTriggerType = TriggerType::UNKNOWN;
    std::string bestKeyword;

    for (const auto& [triggerType, keywords] : triggerKeywords) {
        std::string match = findLongestMatch(phrase, keywords);
        if (!match.empty() && match.length() > bestLength) {
            bestTriggerType = triggerType;
            bestLength = match.length();
            bestKeyword = match;
        }
    }
    
    if (bestLength > 0) {
        outMode = bestTriggerType;
        outKeyword = bestKeyword;
        return true;
    }

    outMode = TriggerType::UNKNOWN;
    outKeyword = "";
    return false;
}


- (void)createEngine {
    NSError *error;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"AudioGraph" ofType:@"json"];
    NSString *jsonString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error reading JSON file: %@", error.localizedDescription);
    }

    const char* config = [jsonString UTF8String];
    Result<SwitchboardV3::ObjectID> result = SwitchboardV3::createEngine(std::string(config));
    if (result.isError()) {
        return;
    }
    engineID = result.value().value();

    AppControlExample* __weak weakSelf = self;
    SwitchboardV3::addEventListener("sttNode", "transcription", [weakSelf](const std::any& data) {
        const auto text = Config::toString(data);
        std::string cleaned = clean(text);
        
        AppControlExample* strongSelf = weakSelf;
        if (!strongSelf) return;
        
        TriggerType triggerType;
        std::string detectedKeyword;
        
        if (detectTrigger(cleaned, triggerType, detectedKeyword)) {
            NSString* keyword = [NSString stringWithUTF8String:detectedKeyword.c_str()];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.delegate triggerDetected:(NSInteger)triggerType withKeyword:keyword];
            });
        }
    });
}

- (void)startEngine {
    auto startEngineResult = SwitchboardV3::callAction(engineID, "start");
    if (startEngineResult.isError()) {
        NSLog(@"Failed to start audio engine");
    }
}

- (void)stopEngine {
    auto stopEngineResult = SwitchboardV3::callAction(engineID, "stop");
    if (stopEngineResult.isError()) {
        NSLog(@"Failed to stop audio engine");
    }
}

- (void)setRuntimeTriggers:(NSArray<NSString*>*)triggers {
    for (NSString* trigger in triggers) {
        std::string triggerString = [trigger UTF8String];
        triggerKeywords[TriggerType::RUNTIME_TRIGGERS].push_back(clean(triggerString));
    }
}

@end
