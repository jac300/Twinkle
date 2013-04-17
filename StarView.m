//
//
//  Created by Jennifer Clark on 3/12/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "StarView.h"
#import "DataController.h"

@interface StarView()

@property (strong, nonatomic) NSDictionary *transformXValuesForNegativeRotation;
@property (strong, nonatomic) NSDictionary *transformYValuesForNegativeRotation;
@property (strong, nonatomic) NSDictionary *transformXValuesForPositiveRotation;
@property (strong, nonatomic) NSDictionary *transformYValuesForPositiveRotation;
@property (nonatomic) float lastXCoordinateChosen;
@property (strong, nonatomic) NSArray *starImages;
@end

@implementation StarView

#pragma mark - property getters

#define STARSTRAIGHT @"starStraight"
#define STARTILTED @"starTilted"

- (NSArray *)prepareStarsImageArray
{
    self.starImages = [[NSArray alloc]initWithObjects: [UIImage imageNamed:STARSTRAIGHT], [UIImage imageNamed:STARTILTED], nil];
    return self.starImages;
}

- (NSMutableArray *)starsInAnimation
{
    if (!_starsInAnimation)  _starsInAnimation = [[NSMutableArray alloc]init];
    return _starsInAnimation;
}

#pragma mark - make star
#define HORIZONTAL_DISTANCE_BETWEEN_CREATED_STARS 200
- (float)generateRandomXCoordinateForSkateBoard: (float)viewHeight 
{
    int viewSize = [[NSNumber numberWithFloat:viewHeight] intValue];
    int randomIntWithinWidth = arc4random() % viewSize;
    float chosenValue = [[NSNumber numberWithInt: randomIntWithinWidth] floatValue];
    
    if ((chosenValue > self.lastXCoordinateChosen - HORIZONTAL_DISTANCE_BETWEEN_CREATED_STARS) && (chosenValue < self.lastXCoordinateChosen + HORIZONTAL_DISTANCE_BETWEEN_CREATED_STARS)) {
        chosenValue = [self generateRandomXCoordinateForSkateBoard:viewHeight];
    } else self.lastXCoordinateChosen = chosenValue;
    
    return chosenValue;
}

- (void)createStar:(float)viewHeight
{
    int imageIndexIdentifier = arc4random() % [self.starImages count];
    UIImage *starImage = [self.starImages objectAtIndex:imageIndexIdentifier];
   
    float starImageWidth = starImage.size.width;
    float rightLimit = viewHeight - starImageWidth;
    float leftLimit = starImageWidth;

    float x = [self generateRandomXCoordinateForSkateBoard:viewHeight];
    
    if (x > rightLimit)     x = rightLimit + (starImageWidth/2);
    else if   (x < leftLimit)   x = leftLimit + (starImageWidth/2);
   
    StarView *imageView = [[StarView alloc]init];
    imageView.image = starImage;
    imageView.frame = CGRectMake(x, 0, imageView.image.size.width, imageView.image.size.height);
    imageView.animationCounter = 0;
    imageView.imageIndexIdentifier = imageIndexIdentifier;
    
    [self.delegate starWasCreated:imageView];
    
}


#pragma mark - star image animation sequence
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
- (CGPoint)getLastKnownLocationForView:(StarView *)view
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
-(float)getXTransformValue:(BOOL)rotateValueIsNegative starAnimationCounter:(int)counter forImageView:(StarView *)view
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


-(float)getYTransformValue:(BOOL)rotateValueIsNegative starAnimationCounter:(int)counter forImageView:(StarView *)view
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

-(CGAffineTransform)animation:(StarView *)view rotationDegree:(float)degree xTransform:(float)x yTransform:(float)y
{
    if (view.numberOfTimesAnimated > 0 && view.numberOfTimesAnimated < 13)  view.numberOfTimesAnimated++;
    if (view.animationCounter < 4) view.animationCounter ++;
        else if (view.animationCounter == 4) view.animationCounter = 1;
        
    view.transform = CGAffineTransformTranslate(CGAffineTransformRotate(view.transform, DegreesToRadians(degree)), x, y);
    
    return view.transform;
}

- (void)starAnimation: (StarView *)view animationDuration:(float)duration
{
    //if (!view.imageAnimationBegan)  [self startSkateBoardImageAnimationTimer:view];
    if (view.animationCounter == 0) { //brand new views only
        [self.starsInAnimation addObject:view];
         view.animationCounter = 1;
         view.numberOfTimesAnimated = 1;
        if ([StarView getRotationDegreeForSkateboardAnimation] == -90) {
            view.rotationAngleIsNegative = YES;
        }   else view.rotationAngleIsNegative = NO;
    }
    
    if (view.wasPaused) {
      [self.starsInAnimation addObject:view];
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
        
        view.transform = [self animation:view rotationDegree:degree xTransform:[self getXTransformValue:view.rotationAngleIsNegative starAnimationCounter:view.animationCounter forImageView:view] yTransform:[self getYTransformValue:view.rotationAngleIsNegative starAnimationCounter:view.animationCounter forImageView:view]];
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            if (view.numberOfTimesAnimated < 12) {
                if ([self.delegate checkForCollision:view]) {
                    [self.starsInAnimation removeObject:view];
                }
                view.lastKnownLocation = [self getLastKnownLocationForView:view];
                [self starAnimation:view animationDuration:duration];
                
            }   else {
                //[view.timer invalidate];
                [self.starsInAnimation removeObject:view];
                [self.delegate animationBlockCompleted:view];
            }
        }
    }];
}

#pragma mark - get current views in animation
- (NSArray *)retrieveCurrentStarViews
{
    return [self.starsInAnimation copy];
}


@end
