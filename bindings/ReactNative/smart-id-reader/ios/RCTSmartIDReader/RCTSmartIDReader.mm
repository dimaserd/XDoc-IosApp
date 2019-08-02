//
//  RCTSmartIDReader.m
//  RCTSmartIDReader
//
//  Created by Никита Разумный on 23/03/2018.
//  Copyright © 2018 se. All rights reserved.
//

#import "RCTSmartIDReader.h"
#import "SmartIDUtils.h"
#import "SmartIDViewControllerSwift.h"

#import <React/RCTConvert.h>


@interface RCTSmartIDReader() <SmartIDViewControllerDelegate>

@property (nonatomic, strong) SmartIDViewControllerSwift *vc;


@end

@implementation RCTSmartIDReader

RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(initEngine,
                 initEngineWithResolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject) {
    @try {
        _vc = [[SmartIDViewControllerSwift alloc] init];
        [_vc setSmartIDDelegate:self];
        resolve(@YES);
    } @catch (NSException *ex) {
        NSError *err = [NSError errorWithDomain:@"RTCSmartIDReader" code:-1 userInfo:nil];
        reject(@"initEngine", @"cannot load bundle", err);
    }
}


RCT_EXPORT_METHOD(setParams: (NSDictionary *)params) {
    if ([params objectForKey:@"sessionTimeout"]) {
        [_vc setSessionTimeout:[[params objectForKey:@"sessionTimeout"] floatValue]];
    }
    if ([params objectForKey:@"displayZonesQuadrangles"]) {
        [_vc setDisplayZonesQuadrangles:[[params objectForKey:@"displayZonesQuadrangles"] boolValue]];
    }
    if ([params objectForKey:@"displayDocumentQuadrangle"]) {
        [_vc setDisplayZonesQuadrangles:[[params objectForKey:@"displayDocumentQuadrangle"] boolValue]];
    }
    if ([params objectForKey:@"documentMask"]) {
        [_vc removeEnabledDocTypesMask:@"*"];
        [_vc addEnabledDocTypesMask:[params objectForKey:@"documentMask"]];
    }
}

RCT_REMAP_METHOD(startRecognition,
                 startRecognitionWithResolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject) {
    @try {
        UINavigationController* contactNavigator = [[UINavigationController alloc] initWithRootViewController:_vc];
        [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:contactNavigator animated:NO completion:^{
           resolve(@YES);
        }];
    } @catch (NSException *ex) {
        NSError *err = [NSError errorWithDomain:@"RTCSmartIDReader" code:-1 userInfo:nil];
        reject(@"startRecognition", @"cannot present smartID view controller", err);
    }
}

RCT_REMAP_METHOD(cancelRecognition,
                 cancelRecognitionWithResolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject) {
    @try {
        [_vc dismissViewControllerAnimated:YES completion:^{
            resolve(@YES);
        }];
    } @catch (NSException *ex) {
        NSError *err = [NSError errorWithDomain:@"RTCSmartIDReader" code:-1 userInfo:nil];
        reject(@"cancelRecognition", @"cannot cancel smartID view controller", err);
    }
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"DidRecognize", @"DidCancel"];
}

- (void)smartIDViewControllerDidRecognize:(nonnull SmartIDRecognitionResult *)result {
    
    [self sendEventWithName:@"DidRecognize" body:@{
                                                   @"terminal": [NSNumber numberWithBool:[result isTerminal]],
                                                   @"imageFields": [SmartIDUtils convertImageFieldsFrom:[result getImageFields]],
                                                   @"stringFields": [result getStringFields]
                                                   }];
}

- (void)smartIDviewControllerDidCancel {
    [self sendEventWithName:@"DidCancel" body:@{
                                                @"name": @"smartIDviewControllerDidCancel"
                                                }];
}

@end
