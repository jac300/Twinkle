//
//  GamePlayViewController.m
//
//  Created by Jennifer Clark on 2/11/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "GamePlayViewController.h"
#import "GameData.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>
#import "StarView.h"
#import "CMMotionManager+SharedInstance.h"

@interface GamePlayViewController () <StarAnimation>

@property (strong, nonatomic) NSTimer *starDropTimer;
@property (strong, nonatomic) NSTimer *runTimer;

@property (nonatomic) BOOL gameOver;
@property (nonatomic) BOOL startAllOver;
@property (nonatomic) BOOL stopAccelerometerUpdatesWasCalled;
@property (nonatomic) BOOL stopRunTimerWasCalled;
@property (nonatomic) BOOL accelerometerIsNotAvailable;
@property (nonatomic) BOOL difficultyLevelWasIncremented;
@property (nonatomic) BOOL levelPassed;

@property (strong, nonatomic) GameData *gameData;
@property (strong, nonatomic) StarView *starView;

@property (strong, nonatomic) NSArray *starImages;
@property (strong, nonatomic) NSMutableArray *runSequenceLeftToRight;
@property (strong, nonatomic) NSMutableArray *starsInPlayerArms;
@property (strong, nonatomic) NSMutableArray *viewsToBeReAnimated;

@property (strong, nonatomic) NSDictionary *rateOfStarDropPerLevel;
@property (strong, nonatomic) NSDictionary *rateOfStarCreationPerLevel;

@property (weak, nonatomic) IBOutlet UIImageView *playerBody;
@property (weak, nonatomic) IBOutlet UIImageView *playerArm;
@property (weak, nonatomic) IBOutlet UIImageView *scoreBoard;

@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIView *mainBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *scoreSignView;
@property (weak, nonatomic) IBOutlet UIView *pauseView;

@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *resumeButton;
@property (strong, nonatomic) UIButton *tryAgainButton;
@property (strong, nonatomic) UIButton *continueButton;
@property (strong, nonatomic) UIButton *playAgainFromBeginningButton;

@property (strong, nonatomic) UIImageView *centerView;
@property (strong, nonatomic) UIImageView *leftView;
@property (strong, nonatomic) UIImageView *rightView;

@property (strong, nonatomic) UIImageView *leftViewForMissedStar;
@property (strong, nonatomic) UIImageView *centerViewForMissedStar;
@property (strong, nonatomic) UIImageView *rightViewForMissedStar;
@property (strong, nonatomic) UIImageView *levelImageViewForMainView;
@property (strong, nonatomic) UIImageView *leftLevelDigitImageViewForMainView;
@property (strong, nonatomic) UIImageView *rightLevelDigitImageViewForMainView;
@property (strong, nonatomic) UIImageView *singleDigitImageViewForMainView;

@property (strong, nonatomic) UIView *youLostView;
@property (strong, nonatomic) UIView *nextLevelView;
@property (strong, nonatomic) UIView *wonEntireGameView;

@property (nonatomic) int runSequenceCounter;
@property (nonatomic) int collectedStars;
@property (nonatomic) int missedStars;
@property (nonatomic) int currentLevel;
@property (nonatomic) float animationDistance;
@property (nonatomic) float starCreationRate;
@property (nonatomic) int nextLevel;

@end

@implementation GamePlayViewController

#pragma mark - property getters
-(int)runSequenceCounter
{
    if (!_runSequenceCounter)  _runSequenceCounter = 0;
    return _runSequenceCounter;
}

-(int)missedBoards
{
    if (!_missedStars) _missedStars = 0;
    return _missedStars;
}

-(int)collectedStars
{
    if (!_collectedStars)  _collectedStars = 0;
    return _collectedStars;
}

- (NSMutableArray *)starsInPlayerArms
{
    if (!_starsInPlayerArms)  _starsInPlayerArms = [[NSMutableArray alloc]init];
    return _starsInPlayerArms;
}

-(int)currentLevel
{
    if (!_currentLevel)  _currentLevel = 1;
    return _currentLevel;
}

-(NSMutableArray *)viewsToBeReAnimated
{
    if (!_viewsToBeReAnimated)  _viewsToBeReAnimated = [[NSMutableArray alloc]init];
    return _viewsToBeReAnimated;
}

- (float)getRateOfSkateBoardCreationForCurrentLevel:(int)currentLevel
{
    return [[self.rateOfStarCreationPerLevel objectForKey:[NSString stringWithFormat:@"%i", currentLevel]] floatValue];
}

- (float)getRateOfSkateBoardFallForCurrentLevel:(int)currentLevel
{
    return [[self.rateOfStarDropPerLevel objectForKey:[NSString stringWithFormat:@"%i", currentLevel]] floatValue];
}

#pragma mark - create views

-(void)createLevelLabelForMainView:(int)gameLevel
{
    UIImage *levelImage = [UIImage imageNamed:@"level_text"];
    CGFloat levelWidth = levelImage.size.width/2;
    CGFloat levelHeight = levelImage.size.height/2;
    CGFloat levelx = 50;
    CGFloat levely = 170;
    UIImageView *levelImageView = [[UIImageView alloc]initWithFrame:CGRectMake(levelx, levely, levelWidth, levelHeight)];
    levelImageView.image = levelImage;
    self.levelImageViewForMainView = levelImageView;
    [self.scoreSignView addSubview:self.levelImageViewForMainView];
    
    if (gameLevel < 10) {
    UIImage *digitImage = [UIImage imageNamed:[NSString stringWithFormat:@"digit%i",gameLevel]];
    CGFloat digitWidth = digitImage.size.width/2;
    CGFloat digitHeight = digitImage.size.height/2;
    CGFloat digitx = levelx + levelWidth/2 + 15;
    CGFloat digity = 160;
    UIImageView *digitImageView = [[UIImageView alloc]initWithFrame:CGRectMake(digitx, digity, digitWidth, digitHeight)];
    digitImageView.image = digitImage;
    self.singleDigitImageViewForMainView = digitImageView;
    [self.scoreSignView addSubview:self.singleDigitImageViewForMainView];
    } else {
        UIImage *digitLeftImage = [UIImage imageNamed:@"digit1"];
        CGFloat digitLeftWidth = digitLeftImage.size.width/2;
        CGFloat digitLeftHeight = digitLeftImage.size.height/2;
        CGFloat digitLeftx = levelx + levelWidth/2 + 15;
        CGFloat digitLefty = 160;
        UIImageView *digitLeftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(digitLeftx, digitLefty, digitLeftWidth, digitLeftHeight)];
        digitLeftImageView.image = digitLeftImage;
        self.leftLevelDigitImageViewForMainView = digitLeftImageView;
        [self.scoreSignView addSubview:self.leftLevelDigitImageViewForMainView];
        
        UIImage *digitRightImage = [UIImage imageNamed:@"digit0"];
        CGFloat digitRightWidth = digitRightImage.size.width/2;
        CGFloat digitRightHeight = digitRightImage.size.height/2;
        CGFloat digitRightx = digitLeftx + digitLeftWidth/2 - 3;
        CGFloat digitRighty = 155;
        UIImageView *digitRightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(digitRightx, digitRighty, digitRightWidth, digitRightHeight)];
        digitRightImageView.image = digitRightImage;
        self.rightLevelDigitImageViewForMainView = digitRightImageView;
        [self.scoreSignView addSubview:self.rightLevelDigitImageViewForMainView];
    }
}

-(void)createMissedStarsViews
{
    CGFloat y = 682;
    CGFloat x = 390;
    
    UIImage *image = [UIImage imageNamed:@"missedStar"];
    CGRect leftFrame = CGRectMake(x, y, image.size.width, image.size.height);
    CGRect centerFrame = CGRectMake(x + 10 + image.size.width, y, image.size.width, image.size.height);
    CGRect rightFrame = CGRectMake(x + 20 + 2*image.size.width, y, image.size.width, image.size.height);

    self.leftViewForMissedStar = [[UIImageView alloc]initWithFrame:leftFrame];
    self.centerViewForMissedStar = [[UIImageView alloc]initWithFrame:centerFrame];
    self.rightViewForMissedStar = [[UIImageView alloc]initWithFrame:rightFrame];

    [self.view addSubview:self.leftViewForMissedStar];
    [self.view addSubview:self.centerViewForMissedStar];
    [self.view addSubview:self.rightViewForMissedStar];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (!self.pauseButton.isHidden) {
    [self pauseButton:self.pauseButton];
    }
}

- (void)getGameInfo {
    [self performSegueWithIdentifier:@"getInfoFromGameScreen" sender:self];
}

-(void)addInfoButton
{
    UIImage *image = [UIImage imageNamed:@"getGameInfoButton"];
    CGFloat width = image.size.width/2;
    CGFloat height = image.size.height/2;
    CGFloat x = 42;
    CGFloat y = 675;
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(x, y, width, height)];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(getGameInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}


-(UIButton *)createTryAgainButton
{
    UIImage *buttonImage = [UIImage imageNamed:@"tryAgainButton"];
    CGFloat x = self.view.frame.size.width/2 - buttonImage.size.width/2;
    CGFloat y = self.view.frame.size.height *2/3;
    CGRect buttonFrame = CGRectMake(x, y, buttonImage.size.width, buttonImage.size.height);
    UIButton *tryAgainButton = [[UIButton alloc]initWithFrame:buttonFrame];
    [tryAgainButton setImage:buttonImage forState:UIControlStateNormal];
    [tryAgainButton addTarget:self action:@selector(playAgainButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return tryAgainButton;
}

-(UIButton *)createContinueButton
{
    UIImage *buttonImage = [UIImage imageNamed:@"continueButton"];
    CGFloat x = self.view.frame.size.width/2 - buttonImage.size.width/2;
    CGFloat y = self.view.frame.size.height *2/3;
    CGRect buttonFrame = CGRectMake(x, y, buttonImage.size.width, buttonImage.size.height);
    UIButton *continueButton = [[UIButton alloc]initWithFrame:buttonFrame];
    [continueButton setImage:buttonImage forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(playAgainButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return continueButton;
}

-(UIButton *)createPlayAgainButton
{
    UIImage *buttonImage = [UIImage imageNamed:@"playAgainButton"];
    CGFloat x = self.view.frame.size.width/2 - buttonImage.size.width/2;
    CGFloat y = self.view.frame.size.height *2/3;
    CGRect buttonFrame = CGRectMake(x, y, buttonImage.size.width, buttonImage.size.height);
    UIButton *playAgainButton = [[UIButton alloc]initWithFrame:buttonFrame];
    [playAgainButton setImage:buttonImage forState:UIControlStateNormal];
    [playAgainButton addTarget:self action:@selector(playAgainButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return playAgainButton;
}


-(UIView *)createYouLostView
{
    UIView *youLostView = [[UIView alloc]initWithFrame:self.view.frame];
    UIImage *lostImage = [UIImage imageNamed:@"lose"];
    CGFloat width = lostImage.size.width/2;
    CGFloat height = lostImage.size.height/2;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    imageView.image = lostImage;
    imageView.center = self.view.center;
    [youLostView addSubview:imageView];    
    return youLostView;
}

-(UIView *)createNextLevelView:(int)gameLevel
{
    UIView *nextLevelView = [[UIView alloc]initWithFrame:self.view.frame];
    UIImage *nextLevelImage = [UIImage imageNamed:@"nextLevelView"];
    UIImageView *mainImageView = [[UIImageView alloc]initWithImage:nextLevelImage];
    mainImageView.center = self.view.center;
    
    [nextLevelView addSubview:mainImageView];
    
    UIImage *singleDigit = [UIImage imageNamed:[NSString stringWithFormat:@"sdigit%i", gameLevel]];
    UIImage *firstDigit = [UIImage imageNamed:@"sdigit1"];
    UIImage *secondDigit = [UIImage imageNamed:@"sdigit0"];
    
    CGFloat x = self.view.frame.size.width * 2/3 - 43;
    CGFloat y = self.view.frame.size.height/3 + 85;
  
    if (gameLevel < 10) {
        CGFloat width = singleDigit.size.width/2;
        CGFloat height = singleDigit.size.height/2;
        CGPoint imageCenter = CGPointMake(x, y);
        CGRect frame = CGRectMake(x, y, width, height);
        UIImageView *singleDigitLevel = [[UIImageView alloc]initWithFrame:frame];
        singleDigitLevel.image = singleDigit;
        singleDigitLevel.center = imageCenter;
        [nextLevelView addSubview:singleDigitLevel];
    
    }  else {
        CGFloat width = firstDigit.size.width/2;
        CGFloat height = firstDigit.size.height/2;
        CGFloat xForLeftView = self.view.frame.size.width * 2/3 - 90;
        CGFloat xForRightView = xForLeftView + firstDigit.size.width/4;
        CGRect frameLeftView = CGRectMake(xForLeftView, y-33, width, height);
        CGRect rightLeftView = CGRectMake(xForRightView, y-33, width, height);
        UIImageView *leftView = [[UIImageView alloc]initWithFrame:frameLeftView];
        UIImageView *rightView = [[UIImageView alloc]initWithFrame:rightLeftView];
        leftView.image = firstDigit;
        rightView.image = secondDigit;
        [nextLevelView addSubview:leftView];
        [nextLevelView addSubview:rightView];
    }
    
    return nextLevelView;
}


-(UIView *)createWonEntireGameView
{
    UIView *wonEntireGameView = [[UIView alloc]initWithFrame:self.view.frame];
    UIImage *wonEntireGameImage = [UIImage imageNamed:@"wonEntireGame"];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:wonEntireGameImage];
    imageView.center = self.view.center;
    
    [wonEntireGameView addSubview:imageView];
        
    return wonEntireGameView;
}


#pragma mark - run sequence
- (void)prepareRunSequenceArrays
{
    self.runSequenceLeftToRight = [[NSMutableArray alloc]init];
    NSString *imageTitle = @"walk";
    int i;
    for (i = 1; i < 10; i++) { //there are 9 run sequence images
        NSString *newTitle = [NSString stringWithFormat:@"%@%i", imageTitle, i];
        UIImage *runSequenceImage = [UIImage imageNamed:newTitle];
        [self.runSequenceLeftToRight addObject:runSequenceImage];
    }
}
- (void)startRunSequence:(NSTimer*)timer 
{
    if (self.runSequenceCounter > [self.runSequenceLeftToRight count] - 1)  self.runSequenceCounter = 0;
    UIImage *image = [self.runSequenceLeftToRight objectAtIndex:self.runSequenceCounter];
    self.playerBody.image = image;
    self.runSequenceCounter++;
}


- (void)startRunTimer
{
    self.runTimer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                         target:self
                                                       selector:@selector(startRunSequence:)
                                                       userInfo:nil
                                                        repeats:YES];
}

#pragma mark - update game state changes

- (void)checkTimersAndAccelerometerState
{
    if (self.stopAccelerometerUpdatesWasCalled) {
        [self startPlayerMotionUsingAccelerometer];
        self.stopAccelerometerUpdatesWasCalled = NO;
    }
    
    if (self.stopRunTimerWasCalled) {
        [self startRunTimer];
        self.stopRunTimerWasCalled = NO;
    }
}

- (NSArray *)retrieveViewsFromPausedState:(NSArray *)viewArray
{
    NSMutableArray *newViews = [[NSMutableArray alloc]init];
    for (StarView *view in viewArray) {
        float newXPosition = view.lastKnownLocation.x;
        float newYPosition = view.lastKnownLocation.y;
        CGPoint newCenter = CGPointMake(newXPosition, newYPosition);
        StarView *newView = [[StarView alloc]initWithImage:[self.starImages objectAtIndex:view.imageIndexIdentifier]];
        newView.center = newCenter;
        newView.rotationAngleIsNegative = view.rotationAngleIsNegative;
        newView.imageIndexIdentifier = view.imageIndexIdentifier;
        newView.wasPaused = view.wasPaused;
        newView.animationCounter = view.animationCounter;
        newView.numberOfTimesAnimated = view.numberOfTimesAnimated;
        [self.mainBackgroundView addSubview:newView];
        [newViews addObject:newView];
        }
    
    [self.viewsToBeReAnimated removeAllObjects];
    return newViews; 
}

- (void)updateMissedStarsView
{
    UIImage *image = [UIImage imageNamed:@"missedStar"];
    
   if (self.missedBoards == 1) {
        self.leftViewForMissedStar.image = image;
    }   else if (self.missedBoards == 2) {
            self.centerViewForMissedStar.image = image;
        }   else if (self.missedBoards == 3) {
                self.rightViewForMissedStar.image = image;
                self.gameOver = YES;
                self.levelPassed = NO;
                [self gameEnded];
            }   
}

- (void)prepareSceneWhenGameEnds {
    if (!self.levelPassed) {
        self.youLostView = [self createYouLostView];
        [self.view addSubview:self.youLostView];
        self.tryAgainButton = [self createTryAgainButton];
        [self.view addSubview:self.tryAgainButton];
    } else if (self.levelPassed && !self.startAllOver) {
        self.nextLevel = [self.gameData determineNextGameLevel:[self.gameData checkIfLevelWon:self.collectedStars forLevel:self.currentLevel] currentGameLevel:self.currentLevel];
        self.nextLevelView = [self createNextLevelView:self.nextLevel];
        [self.view addSubview:self.nextLevelView];
        self.continueButton = [self createContinueButton];
        [self.view addSubview:self.continueButton];
    }  else if (self.startAllOver) {
        self.wonEntireGameView = [self createWonEntireGameView];
        [self.view addSubview:self.self.wonEntireGameView];
        self.playAgainFromBeginningButton = [self createPlayAgainButton];
        [self.view addSubview:self.playAgainFromBeginningButton];
    }
}

- (void)gameEnded
{
    [self.starDropTimer invalidate];
    NSArray *currentAnimations = [self.starView retrieveCurrentStarViews];
    for (UIImageView *view in currentAnimations) { 
        [view removeFromSuperview];
    }
     self.pauseButton.hidden = YES;
     self.resumeButton.hidden = YES;
    
     self.missedStars = 0;
    [self performSelector:@selector(prepareSceneWhenGameEnds) withObject:nil afterDelay:0.3];
}

- (UIImageView *)createScoreDigitView:(NSString *)scoreString characterIndex:(int)index xOffset:(float)x yOffSet:(float)y
{
    NSString *stringDigit = [NSString stringWithFormat:@"%c",[scoreString characterAtIndex:index]];
    NSString *digitImageName = [NSString stringWithFormat:@"digit%@",stringDigit];
    UIImage *imageForDigit = [UIImage imageNamed:digitImageName];
    CGRect imageViewFrame = CGRectMake(self.scoreBoard.frame.size.width - x, self.scoreBoard.frame.size.height - y, imageForDigit.size.width, imageForDigit.size.height);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageViewFrame];
    imageView.image = imageForDigit;
    return imageView;
}

- (void)postCurrentScore:(int)currentScore
{
    NSString *scoreString = [NSString stringWithFormat:@"%i", currentScore];
    NSInteger scoreStringLength = [scoreString length];
    [self.leftView removeFromSuperview];
    [self.centerView removeFromSuperview];
    [self.rightView removeFromSuperview];

    if (scoreStringLength == 1) {
        self.centerView = [self createScoreDigitView:scoreString characterIndex:0 xOffset:192 yOffSet:92];
        [self.scoreSignView addSubview:self.centerView];
    }   else if (scoreStringLength == 2) {
        //first digit
         self.leftView = [self createScoreDigitView:scoreString characterIndex:0 xOffset:205 yOffSet:90];
         [self.scoreSignView addSubview:self.leftView];
        //second digit
        self.rightView = [self createScoreDigitView:scoreString characterIndex:1 xOffset:185 yOffSet:102];
        [self.scoreSignView addSubview:self.rightView];
        }   else if (scoreStringLength == 3) {
            //first digit
            self.leftView = [self createScoreDigitView:scoreString characterIndex:0 xOffset:218 yOffSet:80];
            [self.scoreSignView addSubview:self.leftView];
            //second digit
            self.centerView = [self createScoreDigitView:scoreString characterIndex:1 xOffset:203 yOffSet:90];
            [self.scoreSignView addSubview:self.centerView];
            //third digit
            self.rightView = [self createScoreDigitView:scoreString characterIndex:2 xOffset:183 yOffSet:105];
            [self.scoreSignView addSubview:self.rightView];
            }
}

- (void)stopTrackingPlayerMotionUsingAccelerometer
{
    [[CMMotionManager sharedMotionManager] stopAccelerometerUpdates];
}

#pragma mark - catch star
- (void)catchStar //creates illusion that stars are piling up in player's arms
{
    NSArray *stars = [self.starImages copy];
    int randomIndex = arc4random() % [stars count];
    
    UIImage *star = [stars objectAtIndex:randomIndex];
    UIImageView *view = [[UIImageView alloc]initWithImage:star];
   
    float originOffset = star.size.height;
    if (self.collectedStars > 5 && self.collectedStars < 10) originOffset -= 10;
    if (self.collectedStars > 10 && self.collectedStars < 15) originOffset -= 20;
    if (self.collectedStars > 15 && self.collectedStars < 20) originOffset -= 30;
    if (self.collectedStars > 20 && self.collectedStars < 25) originOffset -= 40;
    if (self.collectedStars > 25 && self.collectedStars < 30) originOffset -= 50;
    if (self.collectedStars > 30 && self.collectedStars < 35) originOffset -= 60;
    if (self.collectedStars > 35 && self.collectedStars < 40) originOffset -= 70;
    if (self.collectedStars > 40 && self.collectedStars < 45) originOffset -= 80;
    if (self.collectedStars > 45 && self.collectedStars < 50) originOffset -= 90;
    if (self.collectedStars > 50) originOffset -= 100;

    float xPointForStar = self.playerArm.frame.origin.x + star.size.width*2;
    float yPointForStar = self.playerArm.frame.origin.y + 10 + originOffset;
    CGPoint newCenterForView = CGPointMake(xPointForStar, yPointForStar);
    view.center = newCenterForView;

    [self.playerView addSubview:view];
    [self.playerView sendSubviewToBack:view];
    [self.playerView sendSubviewToBack:self.playerArm];
    
    self.collectedStars++;
    [self postCurrentScore:self.collectedStars];
    
    if([self.gameData checkIfLevelWon:self.collectedStars forLevel:self.currentLevel]) {
        if (self.currentLevel == MAX_LEVEL) { ////RESART WHOLE GAME
            self.startAllOver = YES;
        } else  { //GO TO NEXT LEVEL
            self.levelPassed = YES;
        }
        
        [self gameEnded];
    } 
    
    [self.starsInPlayerArms addObject:view];
}

#pragma mark - player motion gesture recognizer
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer { 
    
    if (!self.accelerometerIsNotAvailable) recognizer.enabled = NO; //gesture only available if there is no acceleromter
    
    CGPoint translation = [recognizer translationInView:self.view];
    
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self startRunTimer];
    }   else if(recognizer.state == UIGestureRecognizerStateEnded && self.runTimer) {
        [self.runTimer invalidate];
    }
    
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    if(velocity.x > 0) { 
            self.playerView.transform = CGAffineTransformMakeScale(1, 1),0,0;
    }   else {
            self.playerView.transform = CGAffineTransformMakeScale(-1, 1),0,0;
    }
}

#pragma mark - player motion accelerometer
#define DRIFT_HZ 50.0
#define DRIFT_RATE 20

- (void)startPlayerMotionUsingAccelerometer
{
    CMMotionManager *manager = [CMMotionManager sharedMotionManager];
    if ([manager isAccelerometerAvailable]) {
        [manager setAccelerometerUpdateInterval:1/DRIFT_RATE];
        [manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *data, NSError *error) {
            
            if (!self.runTimer) [self startRunTimer];
            CGFloat rightLimit = self.view.bounds.size.width;
            CGFloat leftLimit = self.view.bounds.origin.x;
            CGPoint center = self.playerView.center;
            
           if(data.acceleration.y > 0) {
                if (self.playerView.frame.origin.x > rightLimit) {
                    CGFloat newPosition = leftLimit - self.playerView.frame.size.width;
                    center.x = newPosition;
                }
                
                if(data.acceleration.y > 0.05) self.playerView.transform = CGAffineTransformMakeScale(1, 1),0,0;
            
            }  else if(data.acceleration.y < 0) {
                    if (self.playerView.frame.origin.x + self.playerView.frame.size.width < leftLimit) {
                    CGFloat newPosition = rightLimit + self.playerView.frame.size.width;
                    center.x = newPosition;
                    }
                
                    if(data.acceleration.y < 0.05) self.playerView.transform = CGAffineTransformMakeScale(-1, 1),0,0;
                }
            
            center.x += data.acceleration.y * DRIFT_HZ;
            self.playerView.center = center;
        }];
    
    }   else self.accelerometerIsNotAvailable = YES;
}


#pragma mark - delegate methods

- (void)incrementBoardDropRateAtEndOfLevel
{
    float starCreationIncrementor = 0.1;
    
    if (self.collectedStars < [self.gameData getBoardRequirementForCurrentLevel:self.currentLevel]/2) {
        self.starCreationRate = [self getRateOfSkateBoardCreationForCurrentLevel:self.currentLevel];
    }
    
    if ((self.collectedStars > [self.gameData getBoardRequirementForCurrentLevel:self.currentLevel]/2) && !self.difficultyLevelWasIncremented) {
        self.starCreationRate = self.starCreationRate - starCreationIncrementor;
        self.difficultyLevelWasIncremented = YES;
    }
}

- (BOOL)checkForCollision: (StarView *)starView //check if player "caught" a star
{
    CGRect view1 = starView.frame;
    CGRect view2 = self.playerView.frame;
    CGRect intersection = CGRectIntersection(view1, view2);
    if(!CGRectIsNull(intersection)) {
        [starView removeFromSuperview];
        [self incrementBoardDropRateAtEndOfLevel];
        [self catchStar];
        return YES;
    }
    
    return NO;
}

- (void)animationBlockCompleted: (StarView *)starView //a given star view is done animating
{
    [starView removeFromSuperview];
    self.missedStars ++;
    [self updateMissedStarsView];
}


- (void)starWasCreated:(StarView *)imageView
{
    [self.mainBackgroundView addSubview:imageView];
    [self.starView starAnimation:imageView animationDuration:[self getRateOfSkateBoardFallForCurrentLevel:self.currentLevel]];
}
    

-(void)dropStar:(NSTimer *)timer
{
    if (!self.gameOver) {
        [self.starView createStar:self.view.bounds.size.height];
    }
}

- (void)dropTimer
{
    self.starCreationRate = [self getRateOfSkateBoardCreationForCurrentLevel:self.currentLevel];
    self.starDropTimer = [NSTimer scheduledTimerWithTimeInterval:self.starCreationRate
                                                         target:self
                                                       selector:@selector(dropStar:)
                                                       userInfo:nil
                                                        repeats:YES];
}

- (void)prepareToDropStar
{
    if ([self view]) [self performSelector:@selector(dropTimer) withObject:nil afterDelay:0];
}

#pragma mark - buttons
- (IBAction)resumeButton:(id)sender {
    
    self.pauseView.hidden = YES; 
    self.pauseButton.hidden = NO;
    [self prepareToDropStar];
    [self checkTimersAndAccelerometerState];
    NSArray *newViews = [self retrieveViewsFromPausedState:self.viewsToBeReAnimated];
    for (StarView *view in newViews) {
        [self.starView starAnimation:view animationDuration:[self getRateOfSkateBoardFallForCurrentLevel:self.currentLevel]];
    [self.viewsToBeReAnimated removeAllObjects];
    }
}

- (IBAction)pauseButton:(UIButton *)sender {
    self.pauseButton.hidden = YES;
    self.pauseView.hidden = NO;
    [self.starDropTimer invalidate];
    self.viewsToBeReAnimated = [[self.starView retrieveCurrentStarViews]mutableCopy];
    [self.starView.starsInAnimation removeAllObjects];
        for (StarView *view in self.viewsToBeReAnimated) {
        view.wasPaused = YES;
        [view removeFromSuperview];
    }
}

- (void)playAgainButton:(UIButton *)sender {
    if (!self.pauseView.isHidden)  self.pauseView.hidden = YES;     
    [self checkTimersAndAccelerometerState];
    [self.starView.starsInAnimation removeAllObjects];
    self.difficultyLevelWasIncremented = NO;
    
    if (self.startAllOver) {
    self.nextLevel = 1;
    self.startAllOver = NO;
        [self.wonEntireGameView removeFromSuperview];
        [self.playAgainFromBeginningButton removeFromSuperview];
    
    }   else {
        self.nextLevel = [self.gameData determineNextGameLevel:[self.gameData checkIfLevelWon:self.collectedStars forLevel:self.currentLevel] currentGameLevel:self.currentLevel];
        }
    
    [self.leftLevelDigitImageViewForMainView removeFromSuperview];
    [self.rightLevelDigitImageViewForMainView removeFromSuperview];
    [self.levelImageViewForMainView removeFromSuperview];
    [self.singleDigitImageViewForMainView removeFromSuperview];
    [self.leftViewForMissedStar removeFromSuperview];
    [self.centerViewForMissedStar removeFromSuperview];
    [self.rightViewForMissedStar removeFromSuperview];
    
    self.leftView.image = nil;
    self.centerView.image = nil;
    self.rightView.image = nil;
    
    for (StarView *view in self.starsInPlayerArms) {
        [view removeFromSuperview];
    }
  
    [self createMissedStarsViews];
        
    self.currentLevel = self.nextLevel;
    [self createLevelLabelForMainView:self.currentLevel];
    self.gameOver = NO;
    self.collectedStars = 0;
    [self prepareToDropStar];
    self.pauseButton.hidden = NO;
    self.resumeButton.hidden = NO;
    
    if ([self.view.subviews containsObject:self.youLostView]) {
        [self.youLostView removeFromSuperview];
        [self.tryAgainButton removeFromSuperview];
    }
    
    if ([self.view.subviews containsObject:self.nextLevelView]) {
        [self.nextLevelView removeFromSuperview];
        [self.continueButton removeFromSuperview];
    }
    
}

#pragma mark - view controller life cycle
- (void)appEnteredBackground
{
    [[CMMotionManager sharedMotionManager] stopAccelerometerUpdates];
    self.stopAccelerometerUpdatesWasCalled = YES;
    [self.runTimer invalidate];
    self.stopRunTimerWasCalled = YES;
    [self.starDropTimer invalidate];
    
    if (!self.pauseButton.isHidden) {
        self.pauseView.hidden = NO;
        self.pauseButton.hidden = YES;
        self.resumeButton.hidden = NO;
        self.viewsToBeReAnimated = [[self.starView retrieveCurrentStarViews]mutableCopy];
        [self.starView.starsInAnimation removeAllObjects];
        for (StarView *view in self.viewsToBeReAnimated) {
            view.wasPaused = YES;
            [view removeFromSuperview];
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //prepare view
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.pauseView.hidden = YES;
    //class instances
    self.gameData = [[GameData alloc]init];
    self.starView = [[StarView alloc]init];
    self.starView.delegate = self;
    //prepare arrays
    [self prepareRunSequenceArrays];
    self.starImages = [self.starView prepareStarsImageArray];
    self.animationDistance = [self.starView makeTransformDictionaries:self.view.bounds.size.height];
    self.rateOfStarCreationPerLevel = [GameData getDictionaryForRateOfSkateBoardCreation];
    self.rateOfStarDropPerLevel = [GameData getDictionaryForRateOfSkateBoardFall];
    //update labels & views
    [self createLevelLabelForMainView:self.currentLevel];
    [self createMissedStarsViews];
    [self addInfoButton];
    //begin star animation
    [self prepareToDropStar];
    [self startPlayerMotionUsingAccelerometer];
    //add listener for application enters background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredBackground) name:@"AppDidCloseNotification" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self appEnteredBackground];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.playerBody = nil;
    self.playerArm = nil;
    self.playerView = nil;
    self.pauseButton = nil;
    self.scoreSignView = nil;
    self.scoreBoard = nil;
    self.pauseView = nil;
    self.mainBackgroundView = nil;
}

@end
