//
//  SmartIDUtils.m
//  RCTSmartIDReader
//
//  Created by Никита Разумный on 02/04/2018.
//  Copyright © 2018 se. All rights reserved.
//

#import "SmartIDUtils.h"

@implementation SmartIDUtils

+ (nonnull NSDictionary<NSString *, NSString *> *)convertImageFieldsFrom:(nonnull NSDictionary<NSString *, UIImage *> *)imageFields {
    NSMutableDictionary *converted = [NSMutableDictionary new];
    for (NSString * key in imageFields) {
        UIImage *current = [imageFields objectForKey:key];
        NSData *postData = UIImageJPEGRepresentation(current, 1.0);
        NSString *strEncoded  = [postData base64EncodedStringWithOptions:0];
        [converted setValue:strEncoded forKey:key];
    }
    return converted;
}

@end
