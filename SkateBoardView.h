//
//  SkateBoardView.h
//  knockONwood
//
//  Created by Jennifer Clark on 3/12/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SkateBoardView;
@protocol SkateBoardAnimation <NSObject>

@required
- (BOOL)checkForCollision: (SkateBoardView *)skateBoardView;
- (void)animationBlockCompleted: (SkateBoardView *)skateBoardView;

@end

@interface SkateBoardView : UIImageView

@property (nonatomic) CGPoint lastKnownLocation;

@property (nonatomic) int animationCounter; //counts current animation step in 4 part sequence
@property (nonatomic) int numberOfTimesAnimated; //counts total number of times animated
@property (nonatomic) int imageIndexIdentifier; //identifies which skateboard image the view presents

@property (nonatomic) BOOL wasPaused;
@property (nonatomic) BOOL rotationAngleIsNegative;

@property (weak, nonatomic) id <SkateBoardAnimation> delegate;
@property (strong, nonatomic) NSMutableArray *skateBoardsInAnimation;

- (NSArray *)retrieveCurrentSkateBoardViews;
- (NSArray *)prepareSkateBoardImageArray;
- (void)skateBoardAnimation: (SkateBoardView *)view animationDuration:(float)duration;
- (float)makeTransformDictionaries:(float)viewControllerViewHeight;

//for image animation sequence
//@property (nonatomic) NSTimer *timer;
//@property (nonatomic) int skateboardImageRotationCounter;
//@property (nonatomic) BOOL imageAnimationBegan;

@end
