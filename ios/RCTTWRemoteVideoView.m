//
//  RCTTWRemoteVideoView.m
//  RNTwilioVideoWebRTC
//
//  Custom container view for remote participant video that implements
//  TVIVideoViewDelegate to receive frame dimension change callbacks.
//

#import "RCTTWRemoteVideoView.h"
#import "RCTTWVideoModule.h"

@interface RCTTWRemoteVideoView ()

@property (nonatomic, strong, readwrite) TVIVideoView *videoView;

@end

@implementation RCTTWRemoteVideoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupVideoView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupVideoView];
    }
    return self;
}

- (void)dealloc {
    // TVIVideoTrack retains its renderers strongly, so `_videoView` outlives
    // this container and keeps consuming decoded frames unless it is detached
    // here. Reached on unmount under the RN Fabric legacy-interop path:
    // RCTLegacyViewManagerInteropComponentView.prepareForRecycle drops BOTH
    // strong references to the paper view — it nils its adapter (whose dealloc
    // removes the view from its superview) and then nils its own `contentView`,
    // a strong property, which is the release that actually deallocs us.
    [_videoModule detachParticipantView:_videoView];
}

- (void)setupVideoView {
    _currentOrientation = TVIVideoOrientationUp;
    _videoView = [[TVIVideoView alloc] initWithFrame:self.bounds delegate:self];
    _videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_videoView];
}

#pragma mark - TVIVideoViewDelegate

- (void)videoViewDidReceiveData:(TVIVideoView *)view {
    // Fire the callback with initial dimensions when first frame is received
    // This is needed because videoDimensionsDidChange only fires when dimensions CHANGE,
    // not when they are first set
    if (self.onFrameDimensionsChanged) {
        CMVideoDimensions dimensions = view.videoDimensions;
        NSInteger rotation = [self rotationDegreesFromOrientation:self.currentOrientation];
        self.onFrameDimensionsChanged(@{
            @"width": @(dimensions.width),
            @"height": @(dimensions.height),
            @"rotation": @(rotation)
        });
    }
}

- (void)videoView:(TVIVideoView *)view videoDimensionsDidChange:(CMVideoDimensions)dimensions {
    if (self.onFrameDimensionsChanged) {
        NSInteger rotation = [self rotationDegreesFromOrientation:self.currentOrientation];
        self.onFrameDimensionsChanged(@{
            @"width": @(dimensions.width),
            @"height": @(dimensions.height),
            @"rotation": @(rotation)
        });
    }
}

- (void)videoView:(TVIVideoView *)view videoOrientationDidChange:(TVIVideoOrientation)orientation {
    self.currentOrientation = orientation;
    
    // Also fire the callback when orientation changes with current dimensions
    if (self.onFrameDimensionsChanged) {
        CMVideoDimensions dimensions = view.videoDimensions;
        NSInteger rotation = [self rotationDegreesFromOrientation:orientation];
        self.onFrameDimensionsChanged(@{
            @"width": @(dimensions.width),
            @"height": @(dimensions.height),
            @"rotation": @(rotation)
        });
    }
}

#pragma mark - Rotation Mapping

- (NSInteger)rotationDegreesFromOrientation:(TVIVideoOrientation)orientation {
    switch (orientation) {
        case TVIVideoOrientationUp:
            return 0;
        case TVIVideoOrientationLeft:
            return 90;
        case TVIVideoOrientationDown:
            return 180;
        case TVIVideoOrientationRight:
            return 270;
        default:
            return 0;
    }
}

@end

