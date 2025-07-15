# Voice App Control Example - iOS

Example iOS app that showcases a voice-controlled navigation using the SwitchboardSDK. This example app allows users to navigate through a movie list and interact with items using voice commands.

## How to build

We use the following verions of respective IDEs:
Xcode: 16.2

1. **Download and setup SwitchboardSDK frameworks**

```bash
bash scripts/setup.sh
```

2. **Open the project in Xcode**

```bash
open AppControlExample.xcodeproj
```

3. **Configure SwitchboardSDK credentials**

- Open `AppControlExampleApp.swift`
- Add your SwitchboardSDK App ID and App Secret in the initialization:

```swift
SBSwitchboardSDK.initialize(withAppID: "YOUR_APP_ID", appSecret: "YOUR_APP_SECRET")
```

4. **Build and run the project**
   - Select your target device/simulator
   - Run

## How It Works

### Voice Commands

You can say following commands to executed attached actions:

**Navigation:**

- **Next**: "next", "forward", "skip", "down"
- **Previous**: "back", "last", "previous", "up"

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

- **SBSwitchboardSDK**: Core audio processing engine
- **SBWhisperExtension**: Speech-to-text conversion
- **SBSileroVADExtension**: Voice activity detection

**Movie Navigation:**

- Say any movie title to jump directly to that item:
- "Dune", "Jaws", "Matrix", "Tron", "Soul", "Frozen", "Avatar", "Inception", "Interstellar"

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
