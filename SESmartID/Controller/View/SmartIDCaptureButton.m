/**
 Copyright (c) 2012-2018, Smart Engines Ltd
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 * Neither the name of the Smart Engines Ltd nor the names of its
 contributors may be used to endorse or promote products derived from this
 software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SmartIDCaptureButton.h"

@interface SmartIDCaptureButton() <UIGestureRecognizerDelegate>

@property (nonatomic, strong, nonnull) UITapGestureRecognizer *panGesture;
@property (nonatomic, assign) SECameraButtonState recordingState;
@property (nonatomic, assign) SECameraButtonMode mode;

@end

@implementation SmartIDCaptureButton

- (void) configure {
    [self setPanGesture:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateTap)]];
    [[self panGesture] setDelegate:self];
    [self addGestureRecognizer:[self panGesture]];
    [[self layer] setCornerRadius:[self frame].size.width / 2.0];
    [[self layer] setBorderWidth:2.0];
    [[self layer] setBorderColor:[[self defaultColor] CGColor]];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setMode:SECameraButtonModeVideo];
    [self setRecordingState:SECameraButtonStateWaiting];
}

- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, 60, 60)]) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configure];
    }
    return self;
}
     
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andMode:(SECameraButtonMode)mode {
    if (self = [super initWithFrame:frame]) {
        [self configure];
        [self setMode:mode];
    }
    return self;
}

- (void) animateTakePhotoWithCompletion:(void(^)(void)) completion duration:(CFTimeInterval)duration {
    [UIView animateWithDuration:duration / 2.0
                     animations:^{
                         [self setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:duration / 2.0
                                          animations:^{
                                              [self setTransform:CGAffineTransformIdentity];
                                          }
                                          completion:^(BOOL finished) {
                                              if (completion) {
                                                  completion();
                                              }
                                          }];
                     }];
}

- (void) animateStartRecordingWithCompletion:(void(^)(void)) completion duration:(CFTimeInterval)duration {
    [UIView animateWithDuration:duration
                     animations:^{
                         [self setTransform:CGAffineTransformRotate(CGAffineTransformMakeScale(0.6, 0.6), M_PI_2)];
                         [[self layer] setBorderColor:[[self videoProcColor] CGColor]];
                         [[self layer] setCornerRadius:5.0];
                         [self setBackgroundColor:[self videoProcColor]];
                     } completion:^(BOOL finished) {
                         if (completion) {
                             completion();
                         }
                     }];
}

- (void) animateEndRecordingWithCompletion:(void(^)(void)) completion duration:(CFTimeInterval)duration {
    [UIView animateWithDuration:duration
                     animations:^{
                         [self setTransform:CGAffineTransformIdentity];
                         [[self layer] setCornerRadius:[self frame].size.width / 2.0];
                         [[self layer] setBorderWidth:2.0];
                         [[self layer] setBorderColor:[[self defaultColor] CGColor]];
                         [self setBackgroundColor:[UIColor clearColor]];
                     } completion:^(BOOL finished) {
                         if (completion) {
                             completion();
                         }
                     }];
}

- (void) restoreState {
    if ([self mode] == SECameraButtonModeVideo) {
        [self setRecordingState:SECameraButtonStateWaiting];
        [self animateEndRecordingWithCompletion:nil duration:.0];
    }
}

- (void) animateTap {
    CFTimeInterval duration = [self animationDuration];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setUserInteractionEnabled:NO];
        switch ([self mode]) {
            case SECameraButtonModePhoto: {
                [self animateTakePhotoWithCompletion:^{
                    [[self delegate] SmartIDCameraButtonTapped:self];
                    [self setUserInteractionEnabled:YES];
                } duration:duration];
                break;
            }
            case SECameraButtonModeVideo: {
                switch ([self recordingState]) {
                    case SECameraButtonStateWaiting: {
                        [self animateStartRecordingWithCompletion:^{
                            [self setRecordingState:SECameraButtonStateRecording];
                            [[self delegate] SmartIDCameraButtonTapped:self];
                            [self setUserInteractionEnabled:YES];
                        } duration:duration];
                        break;
                    }
                    case SECameraButtonStateRecording: {
                        [self setRecordingState:SECameraButtonStateWaiting];
                        [[self delegate] SmartIDCameraButtonTapped:self];
                        [self animateEndRecordingWithCompletion:^{
                            [self setUserInteractionEnabled:YES];
                        } duration:duration];
                        break;
                    }
                }
                break;
            }
        }
    });
 }

- (UIColor *)defaultColor {
    if (!_defaultColor) {
        _defaultColor = [UIColor whiteColor];
    }
    return _defaultColor;
}

- (UIColor *)videoProcColor {
    if (!_videoProcColor) {
        _videoProcColor = [UIColor redColor];
    }
    return _videoProcColor;
}

- (SECameraButtonMode)mode {
    return _mode;
}

- (SECameraButtonState)recordingState {
    return _recordingState;
}

@end
