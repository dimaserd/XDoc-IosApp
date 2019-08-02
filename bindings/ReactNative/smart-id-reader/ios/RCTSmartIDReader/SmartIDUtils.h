//
//  SmartIDUtils.h
//  RCTSmartIDReader
//
//  Created by Никита Разумный on 02/04/2018.
//  Copyright © 2018 se. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SmartIDUtils : NSObject

+ (nonnull NSDictionary<NSString *, NSString *> *)convertImageFieldsFrom:(nonnull NSDictionary<NSString *, UIImage *> *)imageFields;

@end
