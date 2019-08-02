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

#import "SmartIDQuadrangleView.h"

static NSString * const kAnimation = @"path";

@interface SmartIDQuadrangleView()

@property (nonatomic, strong) CAShapeLayer *animLayer;
@property (nonatomic, assign) QuadrangleAnimationMode mode;

@end

@implementation SmartIDQuadrangleView

- (id) init {
    if (self = [super init]) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void) configureWithMode:(QuadrangleAnimationMode)mode {
    if (mode == QuadrangleAnimationModeSmoothOneQuadrangle) {
        [self setAnimLayer:[CAShapeLayer new]];
        [[self layer] addSublayer:[self animLayer]];
        [[self animLayer] setStrokeColor:[UIColor yellowColor].CGColor];
        [[self animLayer] setFillColor:[UIColor clearColor].CGColor];
        [[self animLayer] setPath:[UIBezierPath new].CGPath];
        [[self animLayer] setLineWidth:1.5];
    }
    _mode = mode;
}

- (void) hideQuad {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self animLayer] removeAllAnimations];
        [[self animLayer] setPath:[UIBezierPath new].CGPath];
    });
}

- (void) animateQuadrangle:(SmartIDQuadrangle *)quadrangle
                     color:(UIColor *)color
                     width:(CGFloat)width
                     alpha:(CGFloat)alpha
                   offsetX:(CGFloat)offsetX
                   offsetY:(CGFloat)offsetY
         deviceOrientation:(UIDeviceOrientation)dOrientation
                sourceSize:(CGSize)size {
    
    [quadrangle preprocesssWithFrameSize:[self frame].size
                              sourceSize:size
                       deviceOrientation:dOrientation
                                 offsets:CGPointMake(offsetX, offsetY)];
    
    if ([self mode] == QuadrangleAnimationModeDefault && quadrangle != nil) {

        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = [quadrangle bezierPath].CGPath;
        layer.backgroundColor = UIColor.redColor.CGColor;
        layer.strokeColor = color.CGColor;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.lineWidth = width;
        layer.opacity = 0.0f;
        
        [self.layer addSublayer:layer];
        
        __weak CAShapeLayer *weakLayer = layer;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakLayer removeFromSuperlayer];
                });
            }];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation.fromValue = @(alpha);
            animation.toValue = @(0.0f);
            animation.duration = 0.7f;
            
            [weakLayer addAnimation:animation forKey:animation.keyPath];
            
            [CATransaction commit];
            [self setNeedsDisplay];
        });
    } else {
        if ([[self animLayer] isHidden]) {
            return;
        }
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:kAnimation];
        [anim setFromValue:[[[self animLayer] presentationLayer] valueForKeyPath:kAnimation]];
        [[self animLayer] removeAnimationForKey:kAnimation];
        if (quadrangle != nil) {
            [anim setToValue:[quadrangle bezierPath].CGPath];
        } else {
            [anim setToValue:nil];
        }
        [anim setDuration:0.1];
        [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        [[self animLayer] removeAnimationForKey:kAnimation];
        [anim setFillMode:kCAFillModeBoth];
        [anim setRemovedOnCompletion:NO];
        [[self animLayer] addAnimation:anim forKey:kAnimation];
        
        CABasicAnimation *strokeAnim = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
        [strokeAnim setFromValue:[[[self animLayer] presentationLayer] valueForKeyPath:@"strokeColor"]];
        [[self animLayer] removeAnimationForKey:@"strokeColor"];
        strokeAnim.toValue = (id) color.CGColor;
        strokeAnim.duration = 0.1;
        strokeAnim.repeatCount = 10;
        [strokeAnim setRemovedOnCompletion:NO];
        [[self animLayer] addAnimation:strokeAnim forKey:@"strokeColor"];
    }
}


@end

