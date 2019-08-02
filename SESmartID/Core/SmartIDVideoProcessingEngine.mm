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

#import "SmartIDVideoProcessingEngine.h"
#import "SmartIDRecognitionCore.h"

#import "SmartIDSessionSettings+CPP.h"
#import "SmartIDQuadrangle+CPP.h"
#import "SmartIDRecognitionResult+CPP.h"
#import "SmartIDMatchResult+CPP.h"
#import "SmartIDSegmentationResult+CPP.h"
#import "SmartIDProcessingFeedback+CPP.h"

#import <AVFoundation/AVFoundation.h>

#include <smartIdEngine/smartid_engine.h>

#include <cmath>

struct smartIDResultReporter : public se::smartid::ResultReporterInterface {
    __weak smartIDVideoProcessingEngine *smartIDEngine; // to pass data back to view controller
    
    int processedFramesCount;
    
    virtual void SnapshotRejected() override;
    virtual void FeedbackReceived(const se::smartid::ProcessingFeedback &processing_feedback) override;
    virtual void DocumentMatched(const std::vector<se::smartid::MatchResult>& match_results) override;
    virtual void DocumentSegmented(const std::vector<se::smartid::SegmentationResult>& segmentation_results) override;
    virtual void SnapshotProcessed(const se::smartid::RecognitionResult& recog_result) override;
    virtual void SessionEnded() override;
    virtual ~smartIDResultReporter();
};

@interface smartIDVideoProcessingEngine() {
    smartIDResultReporter resultReporter_;
}

@property (nonatomic, strong) SmartIDRecognitionCore *recognitionCore;
@property (nonatomic, assign) UIDeviceOrientation actualOrientation;
@property (nonatomic, assign) CGSize actualImageSize;

@end

@implementation smartIDVideoProcessingEngine

+ (NSString *)version {
    return [NSString stringWithUTF8String:se::smartid::RecognitionEngine::GetVersion().c_str()];
}

- (instancetype)init {
    if (self = [super init]) {
        _recognitionCore = [[SmartIDRecognitionCore alloc] init];
        
        __weak typeof(self) weakSelf = self;
        resultReporter_.smartIDEngine = weakSelf;
    }
    return self;
}

- (void)startSession:(CGSize)cameraPreset {
    [self.recognitionCore initializeSessionWithReporter:&resultReporter_];
    self.actualImageSize = cameraPreset;
}

- (BOOL) isSessionRunning {
    return [self.recognitionCore canProcessFrames];
}

- (void)endSession {
    [self.recognitionCore setCanProcessFrames:NO];
}

#pragma mark - image processing

- (void) processSampleBuffer:(CMSampleBufferRef)sampleBuffer withOrientation:(UIDeviceOrientation)deviceOrientation {
    if ([self.recognitionCore canProcessFrames]) {
        self.actualOrientation = deviceOrientation;
        
        se::smartid::ImageOrientation orientation = [smartIDVideoProcessingEngine getOrientationFrom:deviceOrientation];
        
        se::smartid::RecognitionResult resultCPP = [self.recognitionCore processSampleBuffer:sampleBuffer orientation:orientation];
        
        SmartIDRecognitionResult *result = [[SmartIDRecognitionResult alloc] initWithCPPInstance:resultCPP];
        
        // processing is performed on video queue so forcing main queue
        if ([NSThread isMainThread]) {
            [self.delegate smartIDVideoProcessingEngineDidRecognizeResult:result];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate smartIDVideoProcessingEngineDidRecognizeResult:result];
            });
        }
    }
}

- (void) processSampleBuffer:(CMSampleBufferRef)sampleBuffer withOrientation:(UIDeviceOrientation)deviceOrientation andRoi:(CGRect)roi {
    if ([self.recognitionCore canProcessFrames]) {
        self.actualOrientation = deviceOrientation;
        
        se::smartid::ImageOrientation orientation = [smartIDVideoProcessingEngine getOrientationFrom:deviceOrientation];
        se::smartid::Rectangle roiCPP{
            static_cast<int>(roi.origin.x),
            static_cast<int>(roi.origin.y),
            static_cast<int>(roi.size.width),
            static_cast<int>(roi.size.height)
        };
        
        se::smartid::RecognitionResult resultCPP = [self.recognitionCore
                                                          processSampleBuffer:sampleBuffer
                                                          orientation:orientation
                                                          roi:roiCPP];
        
        
        SmartIDRecognitionResult *result = [[SmartIDRecognitionResult alloc] initWithCPPInstance:resultCPP];
        
        // processing is performed on video queue so forcing main queue
        if ([NSThread isMainThread]) {
            [self.delegate smartIDVideoProcessingEngineDidRecognizeResult:result];
            if ([self.delegate respondsToSelector:@selector(smartIDVideoProcessingEngineDidRecognizeResult:fromBuffer:)]) {
                [self.delegate smartIDVideoProcessingEngineDidRecognizeResult:result fromBuffer:sampleBuffer];
            }
            
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate smartIDVideoProcessingEngineDidRecognizeResult:result];
                if ([self.delegate respondsToSelector:@selector(smartIDVideoProcessingEngineDidRecognizeResult:fromBuffer:)]) {
                    [self.delegate smartIDVideoProcessingEngineDidRecognizeResult:result fromBuffer:sampleBuffer];
                }
            });
        }
    }
}

+ (se::smartid::ImageOrientation) getOrientationFrom:(UIDeviceOrientation)orientation {
    if (orientation == UIDeviceOrientationPortrait) {
        return se::smartid::Portrait;
    } else if (orientation == UIDeviceOrientationLandscapeRight) {
        return se::smartid::InvertedLandscape;
    } else if (orientation == UIDeviceOrientationLandscapeLeft) {
        return se::smartid::Landscape;
    } else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
        return se::smartid::InvertedPortrait;
    } else {
        return se::smartid::Portrait;
    }
}

#pragma mark SmartIDResultReporter implementation
void smartIDResultReporter::SnapshotRejected() {
    [smartIDEngine.delegate smartIDVideoProcessingEngineDidRejectSnapshot];
}

void smartIDResultReporter::FeedbackReceived(const se::smartid::ProcessingFeedback &processing_feedback) {
    SmartIDProcessingFeedback *feedback = [[SmartIDProcessingFeedback alloc] initWithCPPInstance:processing_feedback];
    dispatch_async(dispatch_get_main_queue(), ^{
        [smartIDEngine.delegate smartIDVideoProcessingEngineDidReceiveFeedback:feedback];
    });
}

void smartIDResultReporter::DocumentMatched(const std::vector<se::smartid::MatchResult>& match_results) {
    NSMutableArray<SmartIDMatchResult *> *results = [@[] mutableCopy];
    for (const auto& result : match_results) {
        SmartIDMatchResult *matchResult = [[SmartIDMatchResult alloc] initWithCPPInstance:result];
        [results addObject:matchResult];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [smartIDEngine.delegate smartIDVideoProcessingEngineDidMatchResult:results];
    });
}

void smartIDResultReporter::DocumentSegmented(const std::vector<se::smartid::SegmentationResult>& segmentation_results) {
    NSMutableArray<SmartIDSegmentationResult *> *results = [@[] mutableCopy];
    for (const auto& result : segmentation_results) {
        SmartIDSegmentationResult *segmResult = [[SmartIDSegmentationResult alloc] initWithCPPInstance:result];
        [results addObject:segmResult];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [smartIDEngine.delegate smartIDVideoProcessingEngineDidSegmentResult:results];
    });
}

void smartIDResultReporter::SnapshotProcessed(const se::smartid::RecognitionResult &result) {
    [smartIDEngine.delegate smartIDVideoProcessingEngineDidProcessSnapshot];
}

void smartIDResultReporter::SessionEnded() {
    //  NSLog(@"%s", __FUNCTION__);
}

smartIDResultReporter::~smartIDResultReporter() {
    smartIDEngine = nil;
}

#pragma mark - session

- (SmartIDSessionSettings *) settings {
    return [self.recognitionCore settings];
}

@end

