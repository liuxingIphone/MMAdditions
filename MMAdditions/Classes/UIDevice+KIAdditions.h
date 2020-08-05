//
//  UIDevice+KIAdditions.h
//  HuaxiajiaboApp
//
//  Created by HuamoMac on 15/4/20.
//  Copyright (c) 2015年 HuaMo. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface UIDevice (KIAdditions)

+ (NSString *) deviceType;


char*  getMacAddress(char* macAddress, char* ifName);
+(NSString *)getMacAddress;





+ (long long)getTotalMemorySize;
+ (long long)getAvailableMemorySize;
+ (long long)getUsedMemorySize;


@end
