# Voice Controlled App Example - iOS

Example iOS app that showcases a voice-controlled navigation using the Switchboard SDK. This example app allows users to navigate through a movie list and interact with items using voice commands.

## How to build

### Xcode

We used the following versions of respective IDEs:

- Xcode: 16.2

### Download Switchboard SDK frameworks

Run the following command in root of the project.

```bash
bash scripts/setup.sh
```

### Open the project in Xcode

Open AppControlExample.xcodeproj in Xcode

```bash
open AppControlExample.xcodeproj
```

### Configure Switchboard SDK credentials

- Open `AppControlExampleApp.swift`
- Add your Switchboard SDK App ID and App Secret in the initialization ([sign up here](https://console.switchboard.audio/register) to receive your appID and appSecret values):

```swift
SBSwitchboardSDK.initialize(withAppID: "YOUR_APP_ID", appSecret: "YOUR_APP_SECRET")
```

### Build and run the project

- Select your target device/simulator
- Run

## How It Works

### Voice Commands

You can say following commands to executed attached actions:

**Navigation:**

- **Next**: "down", "forward", "skip", "next"
- **Previous**: "up", "last", "previous", "back"

**Actions:**

- **Like**: "like", "favourite", "heart"
- **Dislike**: "dislike", "dont like", "do not like"
- **Expand**: "expand", "details", "open"

### Voice Processing Pipeline

```
Microphone → Voice Activity Detection → Speech Recognition → String Processing → UI Action
```

The example implements an audio pipline that captures audio from microphone, processes voice via Whisper Speech-To-Text, processes text output from Speech-To-Text engine and matches keywords defined by the app.

The voice pipeline is configured in `AudioGraph.json`:

### Processing Flow

1. **Microphone input** captured and converted to mono
2. **Voice Activity Detection** triggers when speech is detected
3. **Speech Recognition** converts speech to text
4. **String Processing** matches keywords and triggers UI actions

### SDK Components

- `SBSwitchboardSDK`: Core audio processing engine
- `SBWhisperExtension`: Speech-to-text conversion
- `SBSileroVADExtension`: Voice activity detection

**Movie Navigation:**

- Say any movie title to jump directly to that item:
- "Dune", "Jaws", "Matrix", "Tron", "Soul", "Frozen", "Avatar", "Inception", "Interstellar"

## Customization

### Adding New Voice Commands

1. Update the `triggerKeywords` map in `TriggerDetector.swift`
2. Add corresponding trigger type to `TriggerType` enum
3. Handle the new trigger in `AppControlDelegate.triggerDetected`

### Modifying Sample Data

- Edit the `movieData` array in `DataModels.swift`
- Update runtime triggers in `AppControlView.swift`

### Audio Processing Tuning

- Modify `AudioGraph.json` to adjust VAD sensitivity
- Update buffer sizes and sample rates as needed
