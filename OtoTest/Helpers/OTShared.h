//
//  OTShared.h
//  OtoTest
//
//  Created by alden on 1/2/13.
//  Copyright (c) 2013 alden. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSArray-Blocks.h"
#import "../Models/Models.h"

@interface OTShared : NSObject

+ (NSArray *)toneFiles;
+ (void)logTestResult:(OTResult *)result;
+ (UIImage *)imageWithColor:(UIColor *)color;

@end
