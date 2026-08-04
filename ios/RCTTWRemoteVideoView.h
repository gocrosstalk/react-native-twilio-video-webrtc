//
//  RCTTWRemoteVideoView.h
//  RNTwilioVideoWebRTC
//
//  Custom container view for remote participant video that implements
//  TVIVideoViewDelegate to receive frame dimension change callbacks.
//

#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>
#import <TwilioVideo/TwilioVideo.h>

@class RCTTWVideoModule;

@interface RCTTWRemoteVideoView : UIView <TVIVideoViewDelegate>

/**
 * The inner TVIVideoView that renders the video.
 */
@property (nonatomic, strong, readonly) TVIVideoView *videoView;

/**
 * The module holding the room, set when a trackIdentifier is assigned.
 *
 * Weak on purpose: the module owns the room and outlives this view, and the
 * view must not keep a bridge module alive. It is only read on teardown, to
 * detach `videoView` from whatever track it is still rendering.
 */
@property (nonatomic, weak) RCTTWVideoModule *videoModule;

/**
 * Callback when video frame dimensions change.
 */
@property (nonatomic, copy) RCTDirectEventBlock onFrameDimensionsChanged;

/**
 * Current video orientation (used for rotation calculation).
 */
@property (nonatomic, assign) TVIVideoOrientation currentOrientation;

@end

