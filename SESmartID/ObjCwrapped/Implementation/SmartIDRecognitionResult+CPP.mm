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

#import "SmartIDRecognitionResult+CPP.h"

#import "SmartIDImageField+CPP.h"
#import "SmartIDStringField+CPP.h"
#import "SmartIDMatchResult+CPP.h"
#import "SmartIDSegmentationResult+CPP.h"

@implementation SmartIDRecognitionResult {
    se::smartid::RecognitionResult result_;
}

- (void)eraseMatchResultAtIndex:(NSUInteger)index {
    auto matchResults = result_.GetMatchResults();
    matchResults.erase(matchResults.begin() + index);
    result_.SetMatchResults(matchResults);
}

- (void)eraseSegmentationResultAtIndex:(NSUInteger)index {
    auto segmResults = result_.GetSegmentationResults();
    segmResults.erase(segmResults.begin() + index);
    result_.SetSegmentationResults(segmResults);
}

- (NSArray<SmartIDMatchResult *> *)getMatchResults {
    NSMutableArray<SmartIDMatchResult *> * arr = [@[] mutableCopy];
    for (const auto& result : result_.GetMatchResults()) {
        [arr addObject:[[SmartIDMatchResult alloc] initWithCPPInstance:result]];
    }
    return arr;
}

- (NSArray<SmartIDSegmentationResult *> *)getSegmentationResults {
    NSMutableArray<SmartIDSegmentationResult *> * arr = [@[] mutableCopy];
    for (const auto& result : result_.GetSegmentationResults()) {
        [arr addObject:[[SmartIDSegmentationResult alloc] initWithCPPInstance:result]];
    }
    return arr;
}

- (void)insertMatchResultAtIndex:(SmartIDMatchResult *)result atIndex:(NSUInteger)index {
    auto matchResults = result_.GetMatchResults();
    matchResults.insert(matchResults.begin() + index, [result getUnwrapped]);
    result_.SetMatchResults(matchResults);
}

- (void)insertSegmentationResult:(SmartIDSegmentationResult *)result atIndex:(NSUInteger)index {
    auto segmResults = result_.GetSegmentationResults();
    segmResults.insert(segmResults.begin() + index, [result getUnwrapped]);
    result_.SetSegmentationResults(segmResults);
}

- (void)setImageField:(SmartIDImageField *)field forFieldName:(NSString *)name {
    result_.GetImageFields()[[name UTF8String]] = [field getUnwrapped];
}

- (void)setStringField:(SmartIDStringField *)field forFieldName:(NSString *)fieldName {
    result_.GetStringFields()[[fieldName UTF8String]] = [field getUnwrapped];
}


#pragma mark - C++

- (instancetype)init {
    if (self = [super init]) {
        result_ = se::smartid::RecognitionResult();
    }
    return self;
}

- (instancetype)initWithCPPInstance:(const se::smartid::RecognitionResult &)result {
    if (self = [super init]) {
        result_ = result;
    }
    return self;
}

- (se::smartid::RecognitionResult &)getUnwrapped {
    return result_;
}


#pragma mark - wrap

- (nonnull NSString *)getDocumentType {
    return [NSString stringWithUTF8String:result_.GetDocumentType().c_str()];
}

- (NSArray<NSString *> *)getStringFieldNames {
    auto namesCPP = result_.GetStringFieldNames();
    NSMutableArray *namesObjC = [@[] mutableCopy];
    for (const auto& name : namesCPP) {
        [namesObjC addObject:[NSString stringWithUTF8String:name.c_str()]];
    }
    return namesObjC;
}

- (BOOL)hasStringFieldWithName:(NSString *)name {
    return result_.HasStringField([name UTF8String]);
}

- (SmartIDStringField *)getStringFieldWithName:(NSString *)name {
    return [[SmartIDStringField alloc] initWithCPPInstance:result_.GetStringField([name UTF8String])];
}

- (NSDictionary<NSString *, SmartIDStringField *> *)getStringFields {
    auto stringFieldsCPP = result_.GetStringFields();
    NSMutableDictionary *stringFieldsObjC = [@{} mutableCopy];
    for (const auto& field : stringFieldsCPP) {
        NSString *fieldName = [NSString stringWithUTF8String: field.first.c_str()];
        SmartIDStringField *fieldValue = [[SmartIDStringField alloc] initWithCPPInstance:field.second];
        [stringFieldsObjC setObject:fieldValue forKey:fieldName];
    }
    return stringFieldsObjC;
}

- (NSArray<NSString *> *)getImageFieldNames {
    auto namesCPP = result_.GetImageFieldNames();
    NSMutableArray *namesObjC = [@[] mutableCopy];
    for (const auto& name : namesCPP) {
        [namesObjC addObject:[NSString stringWithUTF8String:name.c_str()]];
    }
    return namesObjC;
}

- (BOOL)hasImageFieldWithName:(NSString *)name {
    return result_.HasImageField([name UTF8String]);
}

- (SmartIDImageField *)getImageFieldWithName:(NSString *)name {
    return [[SmartIDImageField alloc] initWithCPPInstance:result_.GetImageField([name UTF8String])];
}

- (NSDictionary<NSString *, SmartIDImageField *> *)getImageFields {
    auto imageFieldsCPP = result_.GetImageFields();
    NSMutableDictionary *imageFieldsObjC = [@{} mutableCopy];
    for (const auto& field : imageFieldsCPP) {
        NSString *fieldName = [NSString stringWithUTF8String: field.first.c_str()];
        SmartIDImageField *fieldValue = [[SmartIDImageField alloc] initWithCPPInstance:field.second];
        [imageFieldsObjC setObject:fieldValue forKey:fieldName];
    }
    return imageFieldsObjC;
}

- (BOOL) isTerminal {
    return result_.IsTerminal();
}

- (void)setIsTerminal:(BOOL)value {
    result_.SetIsTerminal(value);
}



@end
