//
//  CMMotionManager+SharedInstance.m
//
//  Created by Jennifer Clark on 3/13/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "CMMotionManager+SharedInstance.h"

@implementation CMMotionManager (SharedInstance)

+ (CMMotionManager *)sharedMotionManager
{
    static CMMotionManager *shared = nil;
    if (!shared) shared = [[CMMotionManager alloc] init];
    return shared;
}


@end
