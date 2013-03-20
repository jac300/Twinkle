//
//  CMMotionManager+SharedInstance.h
//  knockONwood
//
//  Created by Jennifer Clark on 3/13/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

@interface CMMotionManager (SharedInstance)

+ (CMMotionManager *)sharedMotionManager;

@end
