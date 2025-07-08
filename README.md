# Voice App Control Example - iOS

Example iOS app that showcases a voice-controlled navigation using the SwitchboardSDK. This example app allows users to navigate through a movie list and interact with items using voice commands.

## How to build

1. **Download and setup SwitchboardSDK frameworks**

```bash
bash scripts/setup.sh
```

2. **Open the project in Xcode**

```bash
open AppControlExample.xcodeproj
```

4. **Configure SwitchboardSDK credentials**

- Open `AppControlExampleApp.swift`
- Add your SwitchboardSDK App ID and App Secret in the initialization:

```swift
SBSwitchboardSDK.initialize(withAppID: "YOUR_APP_ID", appSecret: "YOUR_APP_SECRET")
```

3. **Build and run the project**
   - Select your target device/simulator
   - Run

## Project Structure

```
AppControlExample/
├── AppControl/
│   ├── AppControlExample.h          # Objective-C header for voice control
│   ├── AppControlExample.mm         # C++ implementation with SwitchboardSDK integration
│   ├── AppControlView.swift         # Main SwiftUI view
│   ├── ListView.swift               # Movie list UI components
│   ├── DataModels.swift             # Data models and sample movie data
│   └── AudioGraph.json              # Audio processing pipeline configuration
├── AppControlExampleApp.swift       # App entry point with SDK initialization
├── AppControlExample-Bridging-Header.h # Swift-Objective-C bridging header

scripts/
└── setup.sh                        # Framework download and setup script
```

## How SwitchboardSDK Integration Works

### 1. SDK Initialization

The app initializes three SwitchboardSDK extensions in `AppControlExampleApp.swift`:

```swift
SBSwitchboardSDK.initialize(withAppID: "YOUR_APP_ID", appSecret: "YOUR_APP_SECRET")
SBWhisperExtension.initialize(withConfig: [:])
SBSileroVADExtension.initialize(withConfig: [:])
```

### 2. Audio Processing Pipeline

The audio processing is configured via `AudioGraph.json`:

- **Input**: Microphone audio capture
- **MultiChannelToMono**: Converts stereo to mono audio
- **BusSplitter**: Splits audio stream for parallel processing
- **SileroVAD**: Detects voice activity to trigger speech recognition
- **WhisperSTT**: Converts speech to text when voice activity is detected

### 3. Engine Management

The C++ implementation (`AppControlExample.mm`) handles:

- **Engine Creation**: Loads the audio graph configuration
- **Event Handling**: Listens for transcription events from the STT node
- **Trigger Processing**: Analyzes transcribed text for voice commands
- **Delegate Communication**: Sends recognized commands to the SwiftUI interface

### 4. Voice Command Processing

The example implements a system that processes text output from Whisper Speech-To-Text engine and matches keywords defined by the app:

#### Navigation Commands

- **"next"**, **"forward"**, **"skip"**, **"down"** - Navigate to next item
- **"back"**, **"last"**, **"previous"**, **"up"** - Navigate to previous item

#### Action Commands

- **"like"**, **"favourite"**, **"heart"** - Like current item
- **"dislike"**, **"don't like"**, **"do not like"** - Dislike current item
- **"expand"**, **"details"**, **"open"** - Expand item description

#### Runtime Commands (demonstrates how to setup trigger keywords at runtime)

- **Movie titles** - Say any movie title to jump directly to that item
  - "Dune", "Matrix", "Avatar", "Inception", etc.

### How Voice Recognition Works

1. **Continuous Listening**: The app continuously monitors audio through the microphone
2. **Voice Activity Detection**: Silero VAD detects when speech begins and ends
3. **Speech Recognition**: Whisper STT converts detected speech to text
4. **Command Processing**: The system analyzes the text for known commands
5. **UI Updates**: Recognized commands trigger corresponding UI actions

### Voice Processing Flow

```
Microphone → Voice Activity Detection → Speech Recognition → Command Processing → UI Action
```

## Customization

### Adding New Voice Commands

1. Update the `triggerKeywords` map in `AppControlExample.mm`
2. Add corresponding trigger type to `TriggerType` enum
3. Handle the new trigger in `AppControlDelegate.triggerDetected`

### Modifying Sample Data

- Edit the `movieData` array in `DataModels.swift`
- Update runtime triggers in `AppControlView.swift`

### Audio Processing Tuning

- Modify `AudioGraph.json` to adjust VAD sensitivity
- Update buffer sizes and sample rates as needed
