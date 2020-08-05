//
//  UIDevice+KIAdditions.m
//  HuaxiajiaboApp
//
//  Created by HuamoMac on 15/4/20.
//  Copyright (c) 2015年 HuaMo. All rights reserved.
//

#import "UIDevice+KIAdditions.h"
#import <sys/sysctl.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#include <sys/types.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <net/if_dl.h>
#include <ifaddrs.h>
#import "sys/utsname.h"
#import <arpa/inet.h>
#import <mach/mach.h>
#include <objc/runtime.h>


static NSString *memoryUUID = nil;


@implementation UIDevice (KIAdditions)

+ (NSString *) deviceType
{
    NSString *deviceType = [[NSUserDefaults standardUserDefaults] stringForKey:@"devicetype"];
    if(nil != deviceType && [deviceType length]>0)
        return deviceType;
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    deviceType = [NSString stringWithUTF8String:machine];
    free(machine);
    /*
     if ([platform isEqualToString:@"iPhone1,1"])    deviceType = @"iPhone 1G";
     else if ([platform isEqualToString:@"iPhone1,2"])    deviceType = @"iPhone 3G";
     else if ([platform isEqualToString:@"iPhone2,1"])    deviceType = @"iPhone 3GS";
     else if ([platform isEqualToString:@"iPhone3,1"])    deviceType = @"iPhone 4";
     else if ([platform isEqualToString:@"iPhone3,3"])    deviceType = @"iPhone 4 Verizon";
     else if ([platform isEqualToString:@"iPhone4,1"])    deviceType = @"iPhone 4S";
     else if ([platform isEqualToString:@"iPhone5,2"])    deviceType = @"iPhone 5";
     
     else if ([platform isEqualToString:@"iPod1,1"])      deviceType = @"iPod Touch 1G";
     else if ([platform isEqualToString:@"iPod2,1"])      deviceType = @"iPod Touch 2G";
     else if ([platform isEqualToString:@"iPod3,1"])      deviceType = @"iPod Touch 3G";
     else if ([platform isEqualToString:@"iPod4,1"])      deviceType = @"iPod Touch 4G";
     
     else if ([platform isEqualToString:@"iPad1,1"])      deviceType = @"iPad";
     else if ([platform isEqualToString:@"iPad2,1"])      deviceType = @"iPad 2 (WiFi)";
     else if ([platform isEqualToString:@"iPad2,2"])      deviceType = @"iPad 2 (GSM)";
     else if ([platform isEqualToString:@"iPad2,3"])      deviceType = @"iPad 2 (CDMA)";
     
     else if ([platform isEqualToString:@"i386"])         deviceType = @"Simulator";
     
     
     if (nil == deviceType)  deviceType = platform;
     if (nil == deviceType)  deviceType = @"";
     if (nil != deviceType) */
    [[NSUserDefaults standardUserDefaults] setValue:deviceType forKey:@"devicetype"];
    
    return deviceType;
}




char*  getMacAddress(char* macAddress, char* ifName) {
    
    int  success;
    struct ifaddrs * addrs;
    struct ifaddrs * cursor;
    const struct sockaddr_dl * dlAddr;
    const unsigned char* base;
    int i;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != 0) {
            if ( (cursor->ifa_addr->sa_family == AF_LINK)
                && (((const struct sockaddr_dl *) cursor->ifa_addr)->sdl_type == 0x6) && strcmp(ifName,  cursor->ifa_name)==0 ) {
                dlAddr = (const struct sockaddr_dl *) cursor->ifa_addr;
                base = (const unsigned char*) &dlAddr->sdl_data[dlAddr->sdl_nlen];
                strcpy(macAddress, "");
                for (i = 0; i < dlAddr->sdl_alen; i++) {
                    if (i != 0) {
                        strcat(macAddress, ":");
                    }
                    char partialAddr[3];
                    sprintf(partialAddr, "%02X", base[i]);
                    strcat(macAddress, partialAddr);
                    
                }
            }
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    return macAddress;
}

+(NSString *)getMacAddress
{
    char* macAddressString= (char*)malloc(18);
    NSString* macAddress= [[NSString alloc] initWithCString:getMacAddress(macAddressString,"en0")
                                                   encoding:NSMacOSRomanStringEncoding];
    free(macAddressString);
    return macAddress;
}



#pragma mark - 获取设备信息

//获取电池电量(一般用百分数表示,大家自行处理就好)
-(CGFloat)getBatteryQuantity
{
    return [[UIDevice currentDevice] batteryLevel];
}

//获取电池状态(UIDeviceBatteryState为枚举类型)
-(UIDeviceBatteryState)getBatteryStauts
{
    return [UIDevice currentDevice].batteryState;
}

//获取总内存大小
+ (long long)getTotalMemorySize
{
    return [NSProcessInfo processInfo].physicalMemory /1024/1024;
}

//获取当前可用内存
+ (long long)getAvailableMemorySize
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if (kernReturn != KERN_SUCCESS)
    {
        return NSNotFound;
    }
    return ((vm_page_size * vmStats.free_count + vm_page_size * vmStats.inactive_count)) /1024/1024;
}


//获取已使用内存
+ (long long)getUsedMemorySize
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size /1024/1024;
}





@end
