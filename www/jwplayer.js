var exec    = require('cordova/exec'),
    channel = require('cordova/channel'),
    events  = ['ready', 'play', 'pause', 'levels', 'seek', 'complete', 'time', 'error', 'setupError', 'playlistItem',
        'firstFrame'];

events.forEach(function (type) {
    channel.create('jwplayerSdk.' + type);
});

var jwplayerSdk = {

    init: function (config, successCallback, errorCallback) {
        exec(successCallback, errorCallback, "jwplayerSdk", "init", [config]);
    },

    move: function (x, y) {
        exec(null, null, "jwplayerSdk", "move", [x, y]);
    },

    resize: function (width, height) {
        exec(null, null, "jwplayerSdk", "resize", [width, height]);
    },

    load: function (file) {
        exec(null, null, "jwplayerSdk", "load", [file]);
    },

    play: function (force) {
        exec(null, null, "jwplayerSdk", "play", [force]);
    },

    pause: function (force) {
        exec(null, null, "jwplayerSdk", "pause", [force]);
    },

    seek: function (position) {
        exec(null, null, "jwplayerSdk", "seek", [position]);
    },

    stop: function () {
        exec(null, null, "jwplayerSdk", "stop", []);
    },

    playlistItem: function (index) {
        exec(null, null, "jwplayerSdk", "playlistItem", [index]);
    },

    setForceFullScreenOnLandscape: function (state) {
        exec(null, null, "jwplayerSdk", "setForceFullScreenOnLandscape", [state]);
    },

    setForceLandscapeOnFullScreen: function (state) {
        exec(null, null, "jwplayerSdk", "setForceLandscapeOnFullScreen", [state]);
    },

    setCurrentQuality: function (index) {
        exec(null, null, "jwplayerSdk", "setCurrentQuality", [index]);
    },

    bringToFront: function () {
        exec(null, null, "jwplayerSdk", "bringToFront", []);
    },

    sendToBack: function () {
        exec(null, null, "jwplayerSdk", "sendToBack", []);
    },

    remove: function () {

        var eventChannel;

        exec(null, null, "jwplayerSdk", "remove", []);

        // unsubscribe all event handlers
        events.forEach(function (type) {
            eventChannel = channel['jwplayerSdk.' + type];

            if (eventChannel) {
                Object
                    .keys(eventChannel.handlers)
                    .forEach(function (key) {
                        eventChannel.unsubscribe(eventChannel.handlers[key])
                    });
            }
        });
    },

    on: function (type, callback) {

        var eventChannel = channel['jwplayerSdk.' + type];

        if (eventChannel) {
            eventChannel.subscribe(callback);
        }
    },

    off: function (type, callback) {

        var eventChannel = channel['jwplayerSdk.' + type];

        if (eventChannel) {
            eventChannel.unsubscribe(callback);
        }
    },

    fire: function (type, event) {

        var eventChannel = channel['jwplayerSdk.' + type];

        if (eventChannel) {
            eventChannel.fire(event);
        }
    }
};

module.exports = jwplayerSdk;
