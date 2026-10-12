# Piano

A very simple, free iPhone and iPad piano app built for Swift Playgrounds on iPadOS.

## What it does

- Shows a one-octave piano keyboard.
- Plays locally synthesized notes using `AVAudioEngine`.
- Runs offline.
- Includes no ad SDKs, analytics SDKs, network code, or third-party dependencies.

## iPadOS Workflow

Open the `Piano.swiftpm` folder in Swift Playgrounds on iPad.

If you are using Working Copy or another Git client on iPad, clone this repository, then open or share `Piano.swiftpm` into Swift Playgrounds.

## Publishing

Swift Playgrounds can upload finished app builds to App Store Connect from iPadOS. You will still need:

- An Apple Developer Program account.
- An App Store Connect app record using the bundle ID `com.cdantonio.piano`.
- A real app icon before submission. The current package uses a temporary placeholder icon.
- Free pricing selected in App Store Connect.
- The Music app category selected in App Store Connect.

The source code has no ads and no in-app purchases. Pricing and App Store metadata are configured in App Store Connect, not in the app source code.

## Troubleshooting Swift Playgrounds

If Swift Playgrounds shows `SActionErrorDomain error 1` after pulling changes, close the project, fully quit Swift Playgrounds, and open `Piano.swiftpm` again. That error can be a stale run/build action after the package manifest changes.
