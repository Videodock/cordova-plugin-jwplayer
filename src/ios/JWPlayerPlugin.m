#import "JWPlayerPlugin.h"
#import <Cordova/CDVAvailability.h>
#import <MediaPlayer/MediaPlayer.h>
#import <GoogleCast/GoogleCast.h>

@interface JWPlayerPlugin ()

@property (nonatomic) MPVolumeView *airPlayView;
@property (nonatomic) JWPlayerController *player;
@property (nonatomic) NSDictionary *options;

@end

@implementation JWPlayerPlugin (hidden)

/**
 Fire event with type

 @param type Event type
 */
- (void)fireEventWithType:(NSString*)type
{
    [self fireEventWithType:type andEventObject:[[NSMutableArray alloc] init]];
}

/**
 Fire event with type and event object

 @param type        Event type
 @param eventObject Event object which will be sent to event listeners
 */
- (void)fireEventWithType:(NSString*)type andEventObject:(NSArray*)eventObject
{
    // always set event type
    [eventObject setValue:@"type" forKey:type];

    // parse eventObject to JSON string
    NSError* error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:eventObject options:NSJSONWritingPrettyPrinted error:&error];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    // create JS string
    NSString *js = [NSString stringWithFormat:@"window.jwplayerSdk.fire('%@', %@)", type, json];

    // evaluate JS string
    [self.webViewEngine evaluateJavaScript:js completionHandler:^(id object, NSError *error) {
        if (error != NULL) {
            NSLog(@"could not execute JS");
        }
    }];
}

/**
 Create CGSize from given width, height and aspectratio.

 @param width       Width of player
 @param height      Height of player
 @param aspectratio Aspectratio

 @return GCSize
 */
- (CGSize)getPlayerSizeFromWidth:(NSString*)width height:(NSString*)height aspectratio:(NSString*)aspectratio
{

    double dWidth = [width doubleValue];
    double dHeight = [height doubleValue];

    if ([width isEqual:@"100%"] && aspectratio != NULL) {

        dWidth = self.viewController.view.bounds.size.width;

        if ([aspectratio isEqual:@"16:9"]) {
            dHeight = dWidth * 0.5625;
        }
        else if ([aspectratio isEqual:@"4:3"]) {
            dHeight = dWidth * 0.75;
        }
    }

    return CGSizeMake(dWidth, dHeight);
}

/**
 Parse NSArray playlist to a NSArray with JWPlaylistItem instances.

 @param playlist Playlist

 @return NSArray with JWPlaylistItem's
 */
-(NSMutableArray*)parsePlaylistItemsWithArray:(NSArray*)playlist
{
    NSMutableArray *playlistItems = [[NSMutableArray alloc] init];
    int i, d, e;

    for (i = 0; i < playlist.count; i++) {

        JWPlaylistItem *item = [[JWPlaylistItem alloc] init];

        item.title = [playlist[i] valueForKey:@"title"];
        item.desc  = [playlist[i] valueForKey:@"description"];

        NSArray *sources = [playlist[i] valueForKey:@"sources"];
        NSMutableArray *playlistSources = [[NSMutableArray alloc] init];

        for (d = 0; d < sources.count; d++) {

            JWSource *source = [[JWSource alloc] init];

            source.file  = [sources[d] valueForKey:@"file"];
            source.label = [sources[d] valueForKey:@"label"];

            [playlistSources addObject:source];
        }

        NSArray *tracks = [playlist[i] valueForKey:@"tracks"];
        NSMutableArray *playlistTracks = [[NSMutableArray alloc] init];

        for (e = 0; e < tracks.count; e++) {

            JWTrack *track = [[JWTrack alloc] init];
            track.file = [tracks[e] valueForKey:@"file"];
            track.label = [tracks[e] valueForKey:@"label"];
            track.kind = [tracks[e] valueForKey:@"kind"];

            [playlistTracks addObject:track];
        }

        item.tracks = playlistTracks;
        item.sources = playlistSources;

        [playlistItems addObject:item];
    }

    return playlistItems;
}

/**
 Initialises AirPlay
 */
-(void)initAirPlay
{
    float buttonWidth = 44;
    float buttonCoordinateX = self.player.view.frame.size.width - buttonWidth - 5;

    self.airPlayView = [[MPVolumeView alloc] initWithFrame:CGRectMake(buttonCoordinateX, 5, buttonWidth, 44)];

    [self.airPlayView setShowsVolumeSlider:NO];
    self.airPlayView.backgroundColor = [UIColor clearColor];
    self.airPlayView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

    [self.player.view addSubview:self.airPlayView];
}

@end

@implementation JWPlayerPlugin

#pragma mark - CDVPlugin

- (void)pluginInitialize {

}

#pragma mark - JWPlayerPlugin

- (void)init:(CDVInvokedUrlCommand *)command
{
    //
    if (self.player) {
        [self remove:nil];
    }

    // keep options
    self.options = [command argumentAtIndex:0];
    JWConfig *config = [[JWConfig alloc] init];

    NSArray *playlist = [self.options valueForKey:@"playlist"];
    NSMutableArray *playlistItems = [self parsePlaylistItemsWithArray:playlist];

    NSString *width = [self.options valueForKey:@"width"];
    NSString *height = [self.options valueForKey:@"height"];
    NSString *aspectratio = [self.options valueForKey:@"aspectratio"];

    config.size = [self getPlayerSizeFromWidth:width height:height aspectratio:aspectratio];
    config.playlist = playlistItems;

    // initialize player
    self.player = [[JWPlayerController alloc] initWithConfig:config];
    self.player.delegate = self;

    self.player.forceFullScreenOnLandscape = TRUE;
    self.player.forceLandscapeOnFullScreen = TRUE;

    // add player view to cordova view
    [self.viewController.view addSubview:self.player.view];

    // make webview transparent
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];

    [self initAirPlay];
}

- (void)loadPlaylist:(CDVInvokedUrlCommand *)command
{
    if (self.player != NULL) {
        NSArray *playlist = [command argumentAtIndex:0];
        NSMutableArray *playlistItems = [self parsePlaylistItemsWithArray:playlist];
        [self.player loadPlaylist:playlistItems];
    }
}

- (void)load:(CDVInvokedUrlCommand *)command
{
    if (self.player) {
        [self.player load:[command argumentAtIndex:0]];
    }
}

- (void)resize:(CDVInvokedUrlCommand *)command
{
    if (self.player) {

        NSString *width = [command argumentAtIndex:0];
        NSString *height = [command argumentAtIndex:1];
        NSString *aspectratio = [self.options valueForKey:@"aspectratio"];

        // update options
        [self.options setValue:width forKey:@"width"];
        [self.options setValue:height forKey:@"height"];

        // calculate new size
        CGSize size = [self getPlayerSizeFromWidth:width height:height aspectratio:aspectratio];

        // re-use existing position
        CGPoint origin = self.player.view.frame.origin;

        self.player.view.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
    }
}

- (void)move:(CDVInvokedUrlCommand *)command
{
    if (self.player) {

        int x = [[command argumentAtIndex:0] intValue];
        int y = [[command argumentAtIndex:1] intValue];

        // add the offset of the webview
        y += self.webView.frame.origin.y;

        // update player view origin
        self.player.view.frame = CGRectMake(x, y, self.player.view.frame.size.width, self.player.view.frame.size.height);
    }
}

- (void)playlistItem:(CDVInvokedUrlCommand *)command
{
    if (self.player) {
        int index = [[command argumentAtIndex:0] intValue];
        self.player.playlistIndex = index;
    }
}

- (void)seek:(CDVInvokedUrlCommand *)command
{
    if (self.player) {
        int position = [[command argumentAtIndex:0] intValue];
        [self.player seek:position];
    }
}

- (void)play:(CDVInvokedUrlCommand *)command
{
    if (self.player) {
        [self.player play];
    }
}

- (void)pause:(CDVInvokedUrlCommand *)command
{
    if (self.player) {
        [self.player pause];
    }
}

- (void)stop:(CDVInvokedUrlCommand *)command
{
    if (self.player) {
        [self.player stop];
    }
}

- (void)setForceFullScreenOnLandscape:(CDVInvokedUrlCommand *)command
{
    if (self.player) {
        self.player.forceFullScreenOnLandscape = [[command argumentAtIndex:0] boolValue];
    }
}

- (void)setForceLandscapeOnFullScreen:(CDVInvokedUrlCommand *)command
{
    if (self.player) {
        self.player.forceLandscapeOnFullScreen = [[command argumentAtIndex:0] boolValue];
    }
}

-(void)setCurrentQuality:(CDVInvokedUrlCommand *)command
{
    if (self.player) {
        [self.player setCurrentQualityLevel:[[command argumentAtIndex:0] intValue]];
    }
}

- (void)bringToFront:(CDVInvokedUrlCommand *)command
{
    if (self.player) {
        [self.viewController.view bringSubviewToFront:self.player.view];
    }
}

- (void)sendToBack:(CDVInvokedUrlCommand *)command
{
    if (self.player) {
        [self.viewController.view sendSubviewToBack:self.player.view];
    }
}

- (void)remove:(CDVInvokedUrlCommand *)command
{
    if (self.player != nil) {

        [self.airPlayView removeFromSuperview];

        [self.player stop];
        [self.player.view removeFromSuperview];

        self.player = nil;
    }
}

#pragma mark - JWPlayerDelegate

-(void)onReady:(NSInteger)setupTime
{
    NSMutableArray *eventObject = [[NSMutableArray alloc] init];
    [eventObject setValue:[NSNumber numberWithInteger:setupTime] forKey:@"setupTime"];

    [self fireEventWithType:@"ready" andEventObject:eventObject];}

-(void)onPlaylistItem:(NSInteger)index
{
    NSMutableArray *eventObject = [[NSMutableArray alloc] init];
    [eventObject setValue:[NSNumber numberWithInteger:index] forKey:@"index"];

    [self fireEventWithType:@"playlistItem" andEventObject:eventObject];
}

-(void)onPlay:(NSString *)oldState
{
    NSMutableArray *eventObject = [[NSMutableArray alloc] init];
    [eventObject setValue:oldState forKey:@"oldState"];

    [self fireEventWithType:@"play" andEventObject:eventObject];
}

-(void)onPause:(NSString *)oldState
{
    NSMutableArray *eventObject = [[NSMutableArray alloc] init];
    [eventObject setValue:oldState forKey:@"oldState"];

    [self fireEventWithType:@"pause" andEventObject:eventObject];
}

-(void)onTime:(double)position ofDuration:(double)duration
{
    NSMutableArray *eventObject = [[NSMutableArray alloc] init];
    [eventObject setValue:[NSNumber numberWithDouble:position] forKey:@"position"];
    [eventObject setValue:[NSNumber numberWithDouble:duration] forKey:@"duration"];

    [self fireEventWithType:@"error" andEventObject:eventObject];
}

-(void)onError:(NSError *)error
{
    NSMutableArray *eventObject = [[NSMutableArray alloc] init];
    [eventObject setValue:error.description forKey:@"error"];

    [self fireEventWithType:@"error" andEventObject:eventObject];
}

-(void)onSetupError:(NSError *)error
{
    NSMutableArray *eventObject = [[NSMutableArray alloc] init];
    [eventObject setValue:error.description forKey:@"error"];

    [self fireEventWithType:@"setupError" andEventObject:eventObject];
}

-(void)onSeek:(double)offset fromPosition:(double)position
{
    NSMutableArray *eventObject = [[NSMutableArray alloc] init];
    [eventObject setValue:[NSNumber numberWithDouble:offset] forKey:@"offset"];
    [eventObject setValue:[NSNumber numberWithDouble:position] forKey:@"position"];

    [self fireEventWithType:@"seek" andEventObject:eventObject];
}

-(void)onLevels:(NSArray *)levels
{
    NSMutableArray *eventObject = [[NSMutableArray alloc] init];
    [eventObject setValue:levels forKey:@"levels"];

    [self fireEventWithType:@"levels" andEventObject:eventObject];
}

-(void)onComplete
{
    [self fireEventWithType:@"complete"];
}

-(void)onFirstFrame:(NSInteger)loadTime
{
    NSMutableArray *eventObject = [[NSMutableArray alloc] init];
    [eventObject setValue:[NSNumber numberWithInteger:loadTime] forKey:@"loadTime"];

    [self fireEventWithType:@"firstFrame" andEventObject:eventObject];
}

@end
