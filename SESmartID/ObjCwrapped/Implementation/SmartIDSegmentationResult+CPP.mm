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

#import "SmartIDSegmentationResult+CPP.h"
#import "SmartIDQuadrangle+CPP.h"

@implementation SmartIDSegmentationResult {
    se::smartid::SegmentationResult result_;
}

- (instancetype)initWithCPPInstance:(const se::smartid::SegmentationResult &)segmentationResult {
    if (self = [super init]) {
        result_ = segmentationResult;
    }
    return self;
}

- (se::smartid::SegmentationResult &)getUnwrapped {
    return result_;
}

- (BOOL)hasRawFieldQuadrangleFor:(NSString *)rawFieldName {
    return result_.HasRawFieldQuadrangle([rawFieldName UTF8String]);
}

- (SmartIDQuadrangle *)rawFieldQuadrangleFor:(NSString *)rawFieldName {
    return [[SmartIDQuadrangle alloc] initWithCPPInstance:result_.GetRawFieldQuadrangle([rawFieldName UTF8String])];
}

- (SmartIDQuadrangle *)rawFieldQuadrangleForTemplate:(NSString *)rawFieldName {
    return [[SmartIDQuadrangle alloc] initWithCPPInstance:result_.GetRawFieldTemplateQuadrangle([rawFieldName UTF8String])];
}

- (NSArray<NSString *> *)rawFieldNames {
    NSMutableArray<NSString *> * arr = [@[] mutableCopy];
    for (const auto& name : result_.GetRawFieldsNames()) {
        [arr addObject:[NSString stringWithUTF8String:name.c_str()]];
    }
    return arr;
}

- (NSDictionary<NSString *,SmartIDQuadrangle *> *)rawFieldTemplateQuadrangles {
    NSDictionary<NSString *,SmartIDQuadrangle *> * dict = [@{} mutableCopy];
    for (const auto& kv : result_.GetRawFieldTemplateQuadrangles()) {
        SmartIDQuadrangle *val = [[SmartIDQuadrangle alloc] initWithCPPInstance:kv.second];
        NSString *key = [NSString stringWithUTF8String:kv.first.c_str()];
        [dict setValue:val forKey:key];
    }
    return dict;
}

- (NSDictionary<NSString *,SmartIDQuadrangle *> *)rawFieldQuadrangles {
    NSDictionary<NSString *,SmartIDQuadrangle *> * dict = [@{} mutableCopy];
    for (const auto& kv : result_.GetRawFieldQuadrangles()) {
        SmartIDQuadrangle *val = [[SmartIDQuadrangle alloc] initWithCPPInstance:kv.second];
        NSString *key = [NSString stringWithUTF8String:kv.first.c_str()];
        [dict setValue:val forKey:key];
    }
    return dict;
}

- (BOOL)accepted {
    return result_.GetAccepted();
}

@end
