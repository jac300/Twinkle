//
//  SkateBoardView.h
//
//  Created by Jennifer Clark on 3/12/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StarView;
@protocol StarAnimation <NSObject>

@required
- (BOOL)checkForCollision: (StarView *)starView;
- (void)animationBlockCompleted: (StarView *)starView;
- (void)starWasCreated:(StarView *)imageView;

@end

@interface StarView : UIImageView

@property (nonatomic) CGPoint lastKnownLocation;

@property (nonatomic) int animationCounter; //counts current animation step in 4 part sequence
@property (nonatomic) int numberOfTimesAnimated; //counts total number of times animated
@property (nonatomic) int imageIndexIdentifier; //identifies which skateboard image the view presents

@property (nonatomic) BOOL wasPaused;
@property (nonatomic) BOOL rotationAngleIsNegative;

@property (weak, nonatomic) id <StarAnimation> delegate;
@property (strong, nonatomic) NSMutableArray *starsInAnimation;

- (NSArray *)retrieveCurrentStarViews;
- (NSArray *)prepareStarsImageArray;
- (void)starAnimation: (StarView *)view animationDuration:(float)duration;
- (float)makeTransformDictionaries:(float)viewControllerViewHeight;
- (void)createStar:(float)viewHeight;


//for image animation sequence
//@property (nonatomic) NSTimer *timer;
//@property (nonatomic) int skateboardImageRotationCounter;
//@property (nonatomic) BOOL imageAnimationBegan;

@end
