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

#import "SmartIDProcessingFeedback+CPP.h"
#import "SmartIDQuadrangle+CPP.h"

@implementation SmartIDProcessingFeedback {
    se::smartid::ProcessingFeedback processing_feedback_;
}

- (instancetype)initWithCPPInstance:(const se::smartid::ProcessingFeedback &)processingFeedback {
    if (self = [super init]) {
        processing_feedback_ = processingFeedback;
    }
    return self;
}

- (se::smartid::ProcessingFeedback &)getUnwrapped {
    return processing_feedback_;
}

- (NSDictionary<NSString *,SmartIDQuadrangle *> *) quadrangles {
    NSDictionary<NSString *,SmartIDQuadrangle *> * dict = [@{} mutableCopy];
    for (const auto& kv : processing_feedback_.GetQuadrangles()) {
        SmartIDQuadrangle *val = [[SmartIDQuadrangle alloc] initWithCPPInstance:kv.second];
        NSString *key = [NSString stringWithUTF8String:kv.first.c_str()];
        [dict setValue:val forKey:key];
    }
    return dict;
}


@end
