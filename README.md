# Break Reminder 👀

A simple and elegant macOS menu bar application that reminds you to take regular breaks to reduce eye strain and improve productivity. Break Reminder follows the 20-20-20 rule and provides a beautiful full-screen overlay to encourage you to rest your eyes.

## Features

- 🕐 **Customizable Break Intervals**: Set break reminders from 5 to 60 minutes (default: 20 minutes)
- 🖥️ **Full-Screen Break Overlay**: Beautiful, immersive break screen that covers your entire display
- ⏰ **Automatic Countdown**: 60-second countdown timer with visual progress bar
- 🔄 **Snooze Functionality**: Snooze breaks for 5 minutes when you need more time
- 📱 **Menu Bar Integration**: Clean menu bar icon with easy access to all features
- ⚙️ **Preferences Panel**: Simple settings window to customize your break schedule
- 🎯 **20-20-20 Rule Support**: Recommended 20-minute intervals for optimal eye health
- 🔕 **Non-Intrusive**: Runs silently in the background without cluttering your dock

## Screenshots

### Main Menu Bar Interface
![Menu Bar Interface](Screenshots/1.png)
*Clean menu bar integration with easy access to all features*

### Preferences Window
![Preferences](Screenshots/2.png)
*Customize your break intervals and settings*

### Break Overlay Screen
![Break Overlay](Screenshots/3.png)
*Beautiful full-screen break reminder with countdown timer*

### About Window
![About Window](Screenshots/4.png)
*App information and version details*

## Installation

### Requirements
- macOS 13.0 (Ventura) or newer
- Xcode 14.0 or newer (for building from source)

### Download
1. Download the latest release from the [Releases](https://github.com/yourusername/BreakReminder/releases) page
2. Open the downloaded `.dmg` file
3. Drag Break Reminder to your Applications folder
4. Launch the app from Applications or Spotlight

### Building from Source
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/BreakReminder.git
   cd BreakReminder
   ```

2. Open the project in Xcode:
   ```bash
   open BreakReminder.xcodeproj
   ```

3. Build and run the project (⌘+R) or create an archive for distribution

## Usage

### Getting Started
1. Launch Break Reminder from your Applications folder
2. The app will appear in your menu bar with an eye icon
3. Break reminders will start automatically with the default 20-minute interval

### Menu Bar Options
- **Take a Break Now** (⌘+B): Immediately trigger a break overlay
- **Preferences...** (⌘+,): Open settings to customize break intervals
- **About Break Reminder**: View app information and version
- **Quit** (⌘+Q): Exit the application

### During a Break
- The app displays a full-screen overlay with a 60-second countdown
- **Snooze 5 min**: Postpone the break for 5 minutes
- **Skip**: End the current break immediately
- The break will automatically end after 60 seconds

### Customizing Settings
1. Click the menu bar icon and select "Preferences..."
2. Adjust the break interval using the stepper (5-60 minutes)
3. Click "Save" to apply your changes
4. The app will restart the timer with your new settings

## The 20-20-20 Rule

Break Reminder is designed around the 20-20-20 rule, a widely recommended practice for reducing digital eye strain:

- **Every 20 minutes**, look away from your screen
- **Look at something 20 feet away** (or as far as possible)
- **For at least 20 seconds**

This simple practice helps prevent:
- Digital eye strain
- Dry eyes
- Headaches
- Neck and shoulder pain
- Reduced productivity

## Technical Details

### Architecture
- **SwiftUI**: Modern, declarative UI framework
- **AppKit**: Native macOS integration for menu bar and window management
- **UserDefaults**: Persistent storage for user preferences
- **Timer**: Background scheduling for break reminders

### Key Components
- `BreakReminderApp.swift`: Main app entry point with MenuBarExtra
- `BreakReminder.swift`: Core timer logic and state management
- `BreakOverlayView.swift`: Full-screen break interface
- `BreakOverlayWindow.swift`: Custom window management for overlay
- `PreferencesView.swift`: Settings interface
- `AppDelegate.swift`: Menu bar integration and window management

### Permissions
Break Reminder requests notification permissions to ensure break reminders work properly. You can manage these permissions in System Preferences > Notifications.

## Contributing

We welcome contributions! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the 20-20-20 rule for digital eye health
- Built with SwiftUI and native macOS technologies
- Icons and assets designed for optimal menu bar integration

## Support

If you encounter any issues or have suggestions for improvements, please:
1. Check the [Issues](https://github.com/yourusername/BreakReminder/issues) page
2. Create a new issue with detailed information about your problem
3. Include your macOS version and any relevant error messages

---

**Take care of your eyes! 👀** Regular breaks are essential for maintaining healthy vision and productivity in our digital world.
