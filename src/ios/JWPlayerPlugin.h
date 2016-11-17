#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <JWPlayer-iOS-SDK/JWPlayerController.h>

@interface JWPlayerPlugin : CDVPlugin <JWPlayerDelegate> {

}

- (void)init:(CDVInvokedUrlCommand*)command;
- (void)move:(CDVInvokedUrlCommand*)command;
- (void)load:(CDVInvokedUrlCommand*)command;
- (void)loadPlaylist:(CDVInvokedUrlCommand*)command;
- (void)resize:(CDVInvokedUrlCommand*)command;
- (void)remove:(CDVInvokedUrlCommand*)command;
- (void)play:(CDVInvokedUrlCommand*)command;
- (void)pause:(CDVInvokedUrlCommand*)command;
- (void)stop:(CDVInvokedUrlCommand*)command;
- (void)seek:(CDVInvokedUrlCommand*)command;
- (void)playlistItem:(CDVInvokedUrlCommand*)command;
- (void)setForceFullScreenOnLandscape:(CDVInvokedUrlCommand*)command;
- (void)setForceLandscapeOnFullScreen:(CDVInvokedUrlCommand*)command;
- (void)setCurrentQuality:(CDVInvokedUrlCommand*)command;
- (void)bringToFront:(CDVInvokedUrlCommand*)command;
- (void)sendToBack:(CDVInvokedUrlCommand*)command;

@end

