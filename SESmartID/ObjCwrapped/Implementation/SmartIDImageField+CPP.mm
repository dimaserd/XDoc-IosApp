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

#import "SmartIDImageField+CPP.h"
#import "SmartIDImage+CPP.h"

@implementation SmartIDImageField {
    se::smartid::ImageField image_field_;
}

- (instancetype)initWithCPPInstance:(const se::smartid::ImageField &)field {
    if (self = [super init]) {
        image_field_ = field;
    }
    return self;
}

- (instancetype)initWithImage:(SmartIDImage *)img name:(NSString *)name acceptance:(BOOL)acc confidence:(float)conf {
    if (self = [super init]) {
        image_field_ = se::smartid::ImageField([name UTF8String], [img getUnwrapped], acc, conf);
    }
    return self;
}

- (NSString *)name {
    return [NSString stringWithUTF8String:image_field_.GetName().c_str()];
}

- (SmartIDImage *)value {
    return [[SmartIDImage alloc] initWithCPPInstance:image_field_.GetValue()];
}

- (float)getConfidence {
    return image_field_.GetConfidence();
}

- (se::smartid::ImageField &)getUnwrapped {
    return image_field_;
}

- (BOOL)isAccepted {
    return image_field_.IsAccepted();
}


@end
