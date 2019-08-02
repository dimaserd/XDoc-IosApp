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

#import "SmartIDStringField+CPP.h"

@implementation SmartIDStringField {
    se::smartid::StringField string_field_;
}

- (instancetype)initWithCPPInstance:(const se::smartid::StringField &)field {
    if (self = [super init]) {
        string_field_ = field;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
                       value:(NSString *)value
                  acceptance:(BOOL)acc
                  confidence:(float)conf
                  attributes:(NSDictionary<NSString *,NSString *> *)attrs {
    if (self = [super init]) {
        std::map<std::string, std::string> attrs_cpp;
        for (NSString *key in attrs) {
            attrs_cpp[[key UTF8String]] = [[attrs valueForKey:key] UTF8String];
        }
        string_field_ = se::smartid::StringField([name UTF8String], [value UTF8String], acc, conf, attrs_cpp);
    }
    return self;
}

- (se::smartid::StringField &)getUnwrapped {
    return string_field_;
}

- (float)getConfidence {
    return string_field_.GetConfidence();
}

- (BOOL)isAccepted {
    return string_field_.IsAccepted();
}

- (NSString *)getValue {
    return [NSString stringWithUTF8String:string_field_.GetValue().GetUtf8String().c_str()];
}

- (NSString *)getName {
    return [NSString stringWithUTF8String:string_field_.GetName().c_str()];
}

- (NSString *)getAttributeFor:(NSString *)name {
    auto str = string_field_.GetAttribute([name UTF8String]);
    return [NSString stringWithUTF8String:str.c_str()];
}

- (NSDictionary<NSString *,NSString *> *)getAttributes {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    auto attrs = string_field_.GetAttributes();
    for (const auto& i: attrs) {
        NSString *key = [NSString stringWithUTF8String:i.first.c_str()];
        NSString *value = [NSString stringWithUTF8String:i.second.c_str()];
        [dict setObject:value forKey:key];
    }
    return dict;
}

@end
