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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SmartIDStringField.h"
#import "SmartIDImageField.h"
#import "SmartIDSegmentationResult.h"
#import "SmartIDMatchResult.h"

@interface SmartIDRecognitionResult : NSObject

- (nonnull NSString *)getDocumentType;

// string fields
- (nonnull NSArray< NSString *  > *)getStringFieldNames;
- (BOOL) hasStringFieldWithName:(nonnull NSString *)name;
- (SmartIDStringField *_Nonnull) getStringFieldWithName:(nonnull NSString *)name;
- (nonnull NSDictionary<NSString *, SmartIDStringField *> *)getStringFields;
- (void) setStringField:(nonnull SmartIDStringField *)field forFieldName:(nonnull NSString *)fieldName;

// image fields
- (nonnull NSArray<NSString *> *)getImageFieldNames;
- (BOOL) hasImageFieldWithName:(nonnull NSString *)name;
- (nonnull SmartIDImageField *) getImageFieldWithName:(nonnull NSString *)name;
- (nonnull NSDictionary<NSString *, SmartIDImageField *> *)getImageFields;
- (void) setImageField:(nonnull SmartIDImageField *)field forFieldName:(nonnull NSString *) name;

// segmentation results
- (nonnull NSArray<SmartIDSegmentationResult *> *) getSegmentationResults;
- (void) insertSegmentationResult:(nonnull SmartIDSegmentationResult *)result atIndex:(NSUInteger)index;
- (void) eraseSegmentationResultAtIndex:(NSUInteger)index;

// match results
- (nonnull NSArray<SmartIDMatchResult *> *) getMatchResults;
- (void) insertMatchResultAtIndex:(nonnull SmartIDMatchResult *)result atIndex:(NSUInteger)index;
- (void) eraseMatchResultAtIndex:(NSUInteger)index;

// terminality
- (BOOL) isTerminal;
- (void) setIsTerminal:(BOOL)value;

@end


