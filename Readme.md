# Historian

Historian is an app state viewer and manipulator for apps written in [Pointfree.co's Composable Architecture](https://www.pointfree.co/collections/composable-architecture).

<img width="1453" alt="Screenshot 2020-03-22 at 18 24 03" src="https://user-images.githubusercontent.com/65520/77255797-5fee3000-6c6a-11ea-898c-472dda92a862.png">

For more information see this [introductory blog post](https://finestructure.co/blog/2020/3/30/state-of-the-app-state-surfing).

## OS variants

The iOS and macOS apps are only minimally different and can probably be merged soon.

The main reason it's not the case yet is that using a single app target seems to make the whole app a catalyst app, even when using SwiftUI.

It would probably be possible to integrate both into single app even without doing so but since most of the code really sits in the dependency `HistoryView` and the apps are simple viewer shell it's likely more hassle that it's worth.
