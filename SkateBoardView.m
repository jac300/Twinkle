//
//  SkateBoardView.m
//  knockONwood
//
//  Created by Jennifer Clark on 3/12/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "SkateBoardView.h"
#import "DataController.h"

@interface SkateBoardView()

@property (strong, nonatomic) NSDictionary *transformXValuesForNegativeRotation;
@property (strong, nonatomic) NSDictionary *transformYValuesForNegativeRotation;
@property (strong, nonatomic) NSDictionary *transformXValuesForPositiveRotation;
@property (strong, nonatomic) NSDictionary *transformYValuesForPositiveRotation;
@property (strong, nonatomic) NSArray *skateboardImages;
@end

@implementation SkateBoardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

#pragma mark - property getters
//skate board Images
#define SKATEBOARD_L2R @"skateBoardLeftToRight"
#define SKATEBOARD_R2LU @"skateBoardUpsideDownRtoL"
#define SKATEBOARD_R2L @"rightToLeftSkateBoard"
#define SKATEBOARD_L2RU @"skateBoardUpsideDownLtoR"

- (NSArray *)prepareSkateBoardImageArray
{
    self.skateboardImages = [[NSArray alloc]initWithObjects: [UIImage imageNamed:SKATEBOARD_L2R], [UIImage imageNamed:SKATEBOARD_R2LU], [UIImage imageNamed:SKATEBOARD_R2L], [UIImage imageNamed: SKATEBOARD_L2RU], nil];
    return self.skateboardImages;
}

- (NSMutableArray *)skateBoardsInAnimation
{
    if (!_skateBoardsInAnimation)  _skateBoardsInAnimation = [[NSMutableArray alloc]init];
    return _skateBoardsInAnimation;
}

#pragma mark - skateBoard image animation sequence
//- (void)startAnimatingBoardImages:(NSTimer*)timer 
//{
//    SkateBoardView *view = [timer userInfo];
//    if (view.skateboardImageRotationCounter > [self.skateboardImages count] - 1)  view.skateboardImageRotationCounter = 0;
//    UIImage *image = [self.skateboardImages objectAtIndex:view.skateboardImageRotationCounter];
//    view.image = image;
//    view.skateboardImageRotationCounter++;
//}
//
//- (void)startSkateBoardImageAnimationTimer:(SkateBoardView *)view
//{
//    if (!view.animationCounter)  view.animationCounter = 0;
//    view.imageAnimationBegan = YES;
//    view.timer = [NSTimer scheduledTimerWithTimeInterval:0.2
//                                                     target:self
//                                                   selector:@selector(startAnimatingBoardImages:)
//                                                   userInfo:view
//                                                    repeats:YES];
//}

#pragma mark - get last location of view
- (CGPoint)getLastKnownLocationForView:(SkateBoardView *)view
{
    float centerX = view.transform.tx + view.center.x;
    float centerY = view.transform.ty + view.center.y;
    
    return CGPointMake(centerX, centerY);
}

#pragma mark - make transform dictionaries
- (float)makeTransformDictionaries:(float)viewControllerViewHeight
{
    float availableViewHeight = viewControllerViewHeight - 0.10696187*viewControllerViewHeight;
    NSString *distanceToMove = [NSString stringWithFormat:@"%f", availableViewHeight/15];
    NSString *negativeDistanceToMove = [NSString stringWithFormat:@"%f", -1*availableViewHeight/15];
    float zeroFloat = 0;
    NSString *zero = [NSString stringWithFormat:@"%f", zeroFloat];
 
    NSArray *counterValues = [[NSArray alloc]initWithObjects:@"1", @"2", @"3", @"4", nil];
    NSArray *xPositive = [[NSArray alloc]initWithObjects:distanceToMove, zero, negativeDistanceToMove, zero, nil];
    NSArray *yPositive = [[NSArray alloc]initWithObjects:zero, negativeDistanceToMove, zero, distanceToMove, nil];
    NSArray *xNegative = [[NSArray alloc]initWithObjects:negativeDistanceToMove, zero, distanceToMove, zero, nil];
    NSArray *yNegative = [[NSArray alloc]initWithObjects:zero, negativeDistanceToMove, zero, distanceToMove, nil];
    
    self.transformXValuesForNegativeRotation = [[NSDictionary alloc]initWithObjects:xNegative forKeys:counterValues];
    self.transformXValuesForPositiveRotation = [[NSDictionary alloc]initWithObjects:xPositive forKeys:counterValues];
    self.transformYValuesForNegativeRotation = [[NSDictionary alloc]initWithObjects:yNegative forKeys:counterValues];
    self.transformYValuesForPositiveRotation = [[NSDictionary alloc]initWithObjects:yPositive forKeys:counterValues];
    
    return [distanceToMove floatValue];
}

#pragma mark - get values for animation sequence
-(float)getXTransformValue:(BOOL)rotateValueIsNegative skateBoardAnimationCounter:(int)counter forImageView:(SkateBoardView *)view
{
    float xTransformValue = 0;
    NSString *counterString = [NSString stringWithFormat:@"%i",counter];
    
    if (rotateValueIsNegative) {
        NSString *floatStringNegative = [self.transformXValuesForNegativeRotation objectForKey:counterString];
        xTransformValue = [floatStringNegative floatValue];
    }  else {
        NSString *floatStringPositive = [self.transformXValuesForPositiveRotation objectForKey:counterString];
        xTransformValue = [floatStringPositive floatValue];
    }

    return xTransformValue;
}


-(float)getYTransformValue:(BOOL)rotateValueIsNegative skateBoardAnimationCounter:(int)counter forImageView:(SkateBoardView *)view
{
    float yTransformValue = 0;
    NSString *counterString = [NSString stringWithFormat:@"%i", counter];
    
    if (rotateValueIsNegative) {
        NSString *floatStringNegative = [self.transformYValuesForNegativeRotation objectForKey:counterString];
        yTransformValue = [floatStringNegative floatValue];
    }  else {
        NSString *floatStringPositive = [self.transformYValuesForPositiveRotation objectForKey:counterString];
        yTransformValue = [floatStringPositive floatValue];
    }
    
    return yTransformValue;
}

+ (float)getRotationDegreeForSkateboardAnimation
{
    NSArray *array = [[NSArray alloc]initWithObjects:[NSNumber numberWithFloat:90], [NSNumber numberWithFloat:-90], nil];
    
    return [[array objectAtIndex:arc4random() % [array count]]floatValue];
}

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
}

-(CGAffineTransform)animation:(SkateBoardView *)view rotationDegree:(float)degree xTransform:(float)x yTransform:(float)y
{
    if (view.numberOfTimesAnimated > 0 && view.numberOfTimesAnimated < 13)  view.numberOfTimesAnimated++;
    if (view.animationCounter < 4) view.animationCounter ++;
        else if (view.animationCounter == 4) view.animationCounter = 1;
        
    view.transform = CGAffineTransformTranslate(CGAffineTransformRotate(view.transform, DegreesToRadians(degree)), x, y);
    
    return view.transform;
}

- (void)skateBoardAnimation: (SkateBoardView *)view animationDuration:(float)duration
{
    //if (!view.imageAnimationBegan)  [self startSkateBoardImageAnimationTimer:view];
    if (view.animationCounter == 0) { //brand new views only
        [self.skateBoardsInAnimation addObject:view];
         view.animationCounter = 1;
         view.numberOfTimesAnimated = 1;
        if ([SkateBoardView getRotationDegreeForSkateboardAnimation] == -90) {
            view.rotationAngleIsNegative = YES;
        }   else view.rotationAngleIsNegative = NO;
    }
    
    if (view.wasPaused) {
      [self.skateBoardsInAnimation addObject:view];
        view.wasPaused = NO;
        view.animationCounter = 1;
        view.numberOfTimesAnimated --;
    }
    
    UIViewAnimationOptions options = UIViewAnimationOptionCurveLinear;
    [UIView animateWithDuration:duration delay:0 options:options animations:^ {
        
        view.lastKnownLocation = [self getLastKnownLocationForView:view];
        float degree;
        if (view.rotationAngleIsNegative) degree = -90;
        else degree = 90;
        
        view.transform = [self animation:view rotationDegree:degree xTransform:[self getXTransformValue:view.rotationAngleIsNegative skateBoardAnimationCounter:view.animationCounter forImageView:view] yTransform:[self getYTransformValue:view.rotationAngleIsNegative skateBoardAnimationCounter:view.animationCounter forImageView:view]];
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            if (view.numberOfTimesAnimated < 12) {
                if ([self.delegate checkForCollision:view]) {
                    [self.skateBoardsInAnimation removeObject:view];
                }
                view.lastKnownLocation = [self getLastKnownLocationForView:view];
                [self skateBoardAnimation:view animationDuration:duration];
                
            }   else {
                //[view.timer invalidate];
                [self.skateBoardsInAnimation removeObject:view];
                [self.delegate animationBlockCompleted:view];
            }
        }
    }];
}

#pragma mark - get current views in animation
- (NSArray *)retrieveCurrentSkateBoardViews
{
    return [self.skateBoardsInAnimation copy];
}


@end
