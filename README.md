**NOTE:** This project is not maintained. The easiest way to implement JW Player into your Cordova project is to use the web player. Alternatively, take a look at the [iOS](https://developer.jwplayer.com/ios-sdk/) and [Android](https://developer.jwplayer.com/android-sdk/) SDKs.

Cordova JW Player Plugin
======

## Initialisation

### methods

**init(config)**

Initializes player with given configuration. Use same [configuration options](https://developer.jwplayer.com/jw-player/docs/developer-guide/customization/configuration-reference/) as the JW Player javascript player.

```js
jwplayerSdk.init({
    file:        'http://streamserver/prog_index.m3u8',
    width:       '100%',
    aspectratio: '16:9'
});
```

### events

**ready**

Fired when player is ready to start playback

```js
jwplayerSdk.on('ready', readyEventHandler);
```

---

**setupError**

Fired when the player provider could not be set up.

```js
jwplayerSdk.on('setupError', setupErrorEventHandler);
```

## Player view

### methods

**move(x, y)**

Moves player view to given coordinates.

```js
jwplayerSdk.move(0, 90);
```

---

**resize(width, height)**

Resizes player view to given size.

```js
jwplayerSdk.resize(100, 100);
jwplayerSdk.resize('100%');
```

---

**bringToFront()**

Brings the player view on top of the Cordova webview.

```js
jwplayerSdk.bringToFront();
```

---

**sendToBack()**

Sends the player view below the Cordova webview. Useful when using overlays (modals, menu's, etc) in your webview. 

Note: users can't interact with the player while being sent to back.

```js
jwplayerSdk.sendToBack();
```

---

**setForceFullScreenOnLandscape(state)**

A Boolean value that determines whether the video should go to full screen mode when the device rotates to landscape.

```js
jwplayerSdk.setForceFullScreenOnLandscape(true);
```

---

**setForceLandscapeOnFullScreen(state)**

A Boolean value that determines whether the video should rotate to landscape when the fullscreen button is pressed.

```js
jwplayerSdk.setForceLandscapeOnFullScreen(true);
```

## Playlists

**load(playlist)**

Loads a new playlist in the player.

```js
jwplayerSdk.load([{
    title: 'Video title',
    description: 'Video description',
    file: 'http://streamserver/prog_index.m3u8'
}]);
```

---

**playlistItem(index)**

Start playback of the playlist item at the specified index.

```js
jwplayerSdk.playlistItem(0);
```

### events

**playlistItem**

Fired when a new playlist item is loaded by the player.

```js
jwplayerSdk.on('playlistItem', playlistItemEventHandler);
```

## Playback

### methods

**play()**

Starts to play video from current position.

```js
jwplayerSdk.play();
```

---

**pause()**

Pauses video.

```js
jwplayerSdk.pause();
```

---

**stop()**

Stops the player (returning it to the idle state) and unloads the currently playing media file.

```js
jwplayerSdk.stop();
```

---

**jwplayerSdk.seek(position)**

Seek to given position.

```js
jwplayerSdk.seek(72);
```

---

**jwplayerSdk.setCurrentQuality(index)**

Set quality level index.

```js
jwplayerSdk.setCurrentQuality(2);
```

### events

**play**

Fired when the player enters the playing state.

**pause**

Fired when the player enters the paused state.

**firstFrame**

Use this to determine the period of time between a user pressing play and the same user viewing their content. Triggered by a video's first frame event (Or the instant an audio file begins playback). This event pinpoints when content playback begins.

**time**

While the player is playing, this event is fired as the playback position gets updated. This may occur as frequently as 10 times per second.

**seek**

Fired after a seek has been requested either by scrubbing the controlbar or through the API.

**levels**

Fired when the list of available quality levels is updated. Happens e.g. shortly after a playlist item starts playing.

**complete**

Fired when an item completes playback.

## Remove

### methods

**remove()**

Remove player from view and cleanup events.

```js
jwplayerSdk.remove();
```

## Event handlers

**on(type, callback)**

Add event handler.

**off(type, callback)**

Unlisten event handler.

