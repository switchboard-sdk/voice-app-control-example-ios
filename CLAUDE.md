# CLAUDE.md - Voice Control App Example (iOS)

## Project Overview

This is an iOS SwiftUI application demonstrating offline voice control using the Switchboard SDK. Users can navigate a movie list and perform actions using voice commands processed entirely on-device through Whisper speech-to-text and Silero VAD.

## Architecture

### Core Components

- **AppControlExampleApp.swift** (`AppControlExample/AppControlExampleApp.swift`): App entry point, initializes Switchboard SDK
- **AppControlEngine.swift** (`AppControlExample/AppControl/AppControlExample.swift`): Manages audio engine lifecycle and event listeners
- **TriggerDetector.swift** (`AppControlExample/AppControl/TriggerDetector.swift`): Keyword matching and trigger detection logic
- **AppControlView.swift** (`AppControlExample/AppControl/AppControlView.swift`): Main UI and voice control coordination
- **DataModels.swift** (`AppControlExample/AppControl/DataModels.swift`): Data structures and movie list
- **ListView.swift** (`AppControlExample/AppControl/ListView.swift`): List UI component

### Audio Processing Pipeline

The voice pipeline is configured in `AppControlExample/AppControl/AudioGraph.json`:

```
Microphone → MultiChannelToMono → BusSplitter → SileroVAD → WhisperSTT → Trigger Detection → UI Actions
```

Configuration details:
- Sample rate: 16000 Hz
- Buffer size: 512
- VAD threshold: 0.5
- GPU acceleration enabled for Whisper

For detailed audio pipeline customization, see [Switchboard Audio Documentation](https://docs.switchboard.audio).

## Dependencies

### Switchboard SDK Frameworks (downloaded via setup script)

- **SwitchboardSDK**: Core audio processing engine
- **SwitchboardOnnx**: ONNX runtime support
- **SwitchboardSileroVAD**: Voice activity detection
- **SwitchboardWhisper**: Whisper speech-to-text model

Frameworks are downloaded from S3 and placed in `Frameworks/` directory by `scripts/setup.sh`.

## Setup Requirements

### Prerequisites

- Xcode 16.2
- macOS development environment
- Switchboard SDK credentials (App ID and App Secret)

### Initial Setup

1. **Download SDK frameworks:**
   ```bash
   bash scripts/setup.sh
   ```

2. **Configure credentials:**
   - Open `AppControlExample/AppControlExampleApp.swift:18`
   - Replace placeholders with your credentials:
     ```swift
     SBSwitchboardSDK.initialize(withAppID: "YOUR_APP_ID", appSecret: "YOUR_APP_SECRET")
     ```
   - Get credentials at: https://console.switchboard.audio/register

3. **Open project:**
   ```bash
   open AppControlExample.xcodeproj
   ```

**IMPORTANT:** Never commit real credentials. Keep `YOUR_APP_ID` and `YOUR_APP_SECRET` placeholders in version control. Consider using environment variables or a local config file (added to `.gitignore`) for actual credentials.

## Voice Commands

### Built-in Commands

**Navigation:**
- Next: "down", "next", "forward"
- Previous: "up", "last", "previous", "back"

**Actions:**
- Like: "like", "favourite", "heart"
- Dislike: "dislike", "dont like", "do not like"
- Expand: "expand", "details", "open"

**Runtime Triggers (Movie Titles):**
- "Dune", "Jaws", "Matrix", "Tron", "Soul", "Frozen", "Avatar", "Inception", "Interstellar"

### Adding New Voice Commands

1. **Add trigger type** in `DataModels.swift`:
   ```swift
   enum TriggerType {
       case myNewCommand
       // ... existing cases
   }
   ```

2. **Add keywords** in `TriggerDetector.swift:6`:
   ```swift
   private static var triggerKeywords: [TriggerType: [String]] = [
       .myNewCommand: ["keyword1", "keyword2", "keyword3"],
       // ... existing mappings
   ]
   ```

3. **Handle trigger** in `AppControlView.swift` in `AppControlDelegate.triggerDetected()`:
   ```swift
   case .myNewCommand:
       // Implement action
   ```

### Adding Runtime Triggers (Dynamic Keywords)

Runtime triggers are set dynamically at startup. Currently used for movie titles:

```swift
// In AppControlView.swift:72-73
let movieTitles = DataSource.shared.movieData.map { $0.title }
engine?.setRuntimeTriggers(movieTitles)
```

To add custom runtime triggers, call `setRuntimeTriggers()` with an array of strings.

## Modifying Movie Data

Edit the `movieData` array in `DataModels.swift:34`. Each item requires:
- `title`: String (also becomes voice trigger if added to runtime triggers)
- `description`: String
- `likeState`: LikeState enum (.neutral, .liked, .disliked)

## Testing

### Test Structure

- **Unit Tests**: `AppControlExampleTests/AppControlExampleTests.swift`
- **UI Tests**: `AppControlExampleUITests/AppControlExampleUITests.swift`
- **Launch Tests**: `AppControlExampleUITests/AppControlExampleUITestsLaunchTests.swift`

### Running Tests

Run tests in Xcode (Cmd+U) or via xcodebuild:
```bash
xcodebuild test -project AppControlExample.xcodeproj -scheme AppControlExample -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Testing Voice Commands

Since voice recognition requires actual audio input:
1. Run on physical device or simulator
2. Grant microphone permissions
3. Test commands by speaking clearly
4. Monitor `detectedKeyword` display in UI for feedback

## Common Development Tasks

### Debugging Voice Recognition

- Check transcription output in `AppControlEngine.swift:31-42` event listener
- Add print statements in `TriggerDetector.detectTrigger()` to see cleaned phrases
- Verify keyword matching logic in `TriggerDetector.findLongestMatch()`

### Adjusting Voice Sensitivity

While detailed audio configuration is covered in [Switchboard docs](https://docs.switchboard.audio), key settings in `AudioGraph.json`:
- `vadNode.config.threshold`: Voice detection sensitivity (0.0-1.0)
- `vadNode.config.minSilenceDurationMs`: Silence duration before speech end
- `graph.config.sampleRate`: Audio sample rate
- `sttNode.config.useGPU`: GPU acceleration toggle

### Modifying UI

- List appearance: `ListView.swift`
- Main layout: `AppControlView.swift:47-82`
- Item cards: `ListView.swift` item rendering

## Project Structure

```
AppControlExample/
├── AppControlExampleApp.swift          # App entry point
├── AppControl/
│   ├── AppControlExample.swift         # Audio engine manager
│   ├── AppControlView.swift            # Main view and delegate
│   ├── TriggerDetector.swift           # Keyword detection
│   ├── DataModels.swift                # Data structures
│   ├── ListView.swift                  # List UI component
│   └── AudioGraph.json                 # Audio pipeline config
├── Assets.xcassets/                    # App assets
└── Preview Content/                    # SwiftUI previews

AppControlExampleTests/                 # Unit tests
AppControlExampleUITests/               # UI tests
scripts/
└── setup.sh                            # SDK download script
Frameworks/                             # Downloaded SDK frameworks (gitignored)
```

## Important Notes

- **Credentials Security**: Never commit real App ID/Secret values
- **SDK Version**: Currently using custom release `tayyabjaved/v3-example-release-build`
- **Minimum iOS Version**: Check project settings in Xcode
- **Offline Processing**: All voice recognition runs on-device
- **Microphone Permissions**: Required for voice control to function
- **Framework Dependencies**: Must run `scripts/setup.sh` before building

## Resources

- [Switchboard SDK Documentation](https://docs.switchboard.audio)
- [Switchboard Console](https://console.switchboard.audio/register)
- Project README: `README.md`
