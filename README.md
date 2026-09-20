# iPhone Duo Tests

A small experimental project exploring how apps can adapt to the
**iPhone Duo** using SwiftUI, reserved regions, `ArrangementView`, and a
native-to-web bridge with `WKWebView`.

The goal is not to build a production app. This repository is a
playground for understanding what changes when the display is no longer
just a rectangle with a fixed shape, and how native and web-based
interfaces can react to the fold.

## 🎥 Video

[![Testei o iPhone Duo no Xcode: é assim que os apps vão
funcionar](https://img.youtube.com/vi/KkvM5rGZzX4/maxresdefault.jpg)](https://youtu.be/KkvM5rGZzX4)

**[Testei o iPhone Duo no Xcode: é assim que os apps vão
funcionar](https://youtu.be/KkvM5rGZzX4)**

The video is in Portuguese and shows the simulator, adaptive layouts,
Safari behavior, non-adapted apps, and the experiments in this
repository.

## What this project explores

-   How an app can know when the iPhone Duo division is active.
-   How a layout can react to the physical division of the display.
-   What happens when the division exists but is inactive.
-   How primary and secondary content can adapt with `ArrangementView`.
-   How native fold state and geometry can be passed to a `WKWebView`.
-   What fold-related information was exposed to JavaScript in the
    Safari/WebKit environment I tested.

## Reserved regions and fold state

On iPhone Duo, SwiftUI can query **reserved regions** associated with
the display.

This experiment queries the division region and includes inactive
regions, allowing the app to inspect it even when it isn't currently
acting as an active fold.

The important distinction in the environment I tested is the region's
state:

-   **Inactive:** the division is known, but isn't currently acting as
    an active fold.
-   **Active:** the division is active and can affect how the interface
    should be arranged.

The app also displays the geometry reported for the region, making it
easier to visualize what the system is telling the layout.

Instead of trying to infer the fold from screen dimensions, the native
interface can react to information supplied by the system.

## Adaptive layouts with ArrangementView

The experiment uses SwiftUI's `ArrangementView` to organize **primary**
and **secondary** content.

With a split arrangement, those views can be distributed according to
the current environment and active division regions.

That matters because adapting to a foldable isn't necessarily just:

> screen width / 2

The physical configuration of the device can participate in the layout
decision.

The project also uses a compact presentation for narrow configurations
so the experiment remains usable when the simulated device is closed.

## Native → Web fold bridge

One of the main experiments is communication between SwiftUI and a web
interface running inside `WKWebView`.

The native side can obtain information such as:

-   whether the division is active;
-   detected region count;
-   division frame;
-   X and Y position;
-   width and height;
-   center coordinates.

That information can then be delivered to JavaScript inside the WebView.

``` text
iPhone Duo
    ↓
SwiftUI / Reserved Region
    ↓
Fold state + geometry
    ↓
WKWebView
    ↓
JavaScript
    ↓
Web interface adapts
```

The included web experiment reacts to those updates, allowing web
content hosted by the app to change when the native layer detects a
change in fold state.

## Safari / WebKit experiment

I also tested whether a page running directly in Safari could
independently obtain an equivalent fold state.

In the **Safari/WebKit environment tested with the iPhone Duo
simulator**, I did not find a JavaScript API exposing the same
fold-state information available to the native experiment.

The tests included viewport and geometry changes, along with
foldable-related concepts such as posture and viewport segments.

This should **not** be interpreted as "the web does not support
foldables." Foldable-related web APIs and proposals exist.

The narrower observation from this experiment is:

> In the WebKit environment I tested, the page did not receive an
> equivalent JavaScript signal telling it that the Duo's division region
> had become active.

For web content hosted inside a `WKWebView`, a native-to-web bridge is
one possible way to provide that device context.

## Project structure

``` text
iPhoneDuo-Testes/
├── DuoFoldTest.xcodeproj
├── DuoFoldTest/
│   └── ...
└── test.html
```

-   **`DuoFoldTest/`** contains the SwiftUI experiment and native fold
    handling.
-   **`test.html`** contains the web-side experiment used to visualize
    information delivered by the native layer.

## Requirements

You will need:

-   macOS;
-   a compatible Xcode version with iPhone Duo support;
-   iOS 27.1 SDK or newer for the APIs used by this experiment;
-   the iPhone Duo Simulator runtime.

The Apple APIs explored here are new and some are currently documented
as beta, so behavior and API details may change.

## Running the experiment

1.  Clone this repository.
2.  Open `DuoFoldTest.xcodeproj` in Xcode.
3.  Select **iPhone Duo** as the run destination.
4.  Build and run.
5.  Change the simulated device posture and observe the native layout.
6.  Watch the web section to see fold state and geometry propagated from
    the native layer.

If you move or rename the HTML file, check the local WebView loading
configuration in the project as well.

## What I learned

The most interesting part of this experiment is that adapting to a
foldable isn't simply a matter of adding another responsive breakpoint.

The same device can move between very different physical configurations
while an app is already running.

An interface may therefore need to consider:

-   available width and height;
-   active physical divisions;
-   primary and secondary content;
-   controls that make more sense on the side than at the bottom;
-   whether the interface is native, web-based, or hybrid.

Hybrid applications are particularly interesting here: native code can
understand device-specific characteristics and pass useful context to a
web interface.

## Notes

This is an **experimental project** created for learning, testing, and
documenting behavior in the iPhone Duo simulator.

It is not an official Apple sample and is not affiliated with or
endorsed by Apple.

Behavior may change as Xcode, iOS, WebKit, and the iPhone Duo SDK
evolve.

## References

-   [Apple Developer --- Strike a pose with adaptive layouts on iPhone
    Duo](https://developer.apple.com/videos/play/tech-talks/111463/)
-   [Apple Developer --- SwiftUI
    updates](https://developer.apple.com/documentation/Updates/SwiftUI)

## License

This project is licensed under the **Mozilla Public License 2.0
(MPL-2.0)**.

See `LICENSE` for details.
