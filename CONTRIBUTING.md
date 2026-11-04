# Contributing

Thanks for helping out! For a larger change, please open an issue first so the direction is clear.

1. Fork the repository and create a branch.
2. Open `BreakReminder.xcodeproj` in Xcode 16 or newer (macOS 13+ is the deployment target).
3. Make your change. Keep the app a quiet menu bar utility.
4. Run the unit tests:

   ```bash
   xcodebuild test -project BreakReminder.xcodeproj -scheme BreakReminder \
     -destination 'platform=macOS' -only-testing:BreakReminderTests
   ```

5. Open a pull request against `main`. CI runs the same tests.

Before you push, check that a break overlay still opens, closes (countdown, **Skip**, **Esc**) and restores the Dock and menu bar afterwards.
