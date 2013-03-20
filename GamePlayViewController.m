//
//  GamePlayViewController.m
//  knockONwood
//
//  Created by Jennifer Clark on 2/11/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "GamePlayViewController.h"
#import "GameData.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>
#import "SkateBoardView.h"
#import "CMMotionManager+SharedInstance.h"
#import "DataController.h"

@interface GamePlayViewController () <SkateBoardAnimation>

@property (strong, nonatomic) NSTimer *skateBoardDropTimer;
@property (strong, nonatomic) NSTimer *runTimer;

@property (nonatomic) BOOL gameOver;
@property (nonatomic) BOOL startAllOver;
@property (nonatomic) BOOL stopAccelerometerUpdatesWasCalled;
@property (nonatomic) BOOL stopRunTimerWasCalled;
@property (nonatomic) BOOL accelerometerIsNotAvailable;
@property (nonatomic) BOOL difficultyLevelWasIncremented;

@property (strong, nonatomic) GameData *gameData;
@property (strong, nonatomic) SkateBoardView *skateboardView;

@property (strong, nonatomic) NSArray *skateBoardImages;
@property (strong, nonatomic) NSArray *skateBoardsToPause;
@property (strong, nonatomic) NSMutableArray *runSequenceLeftToRight;
@property (strong, nonatomic) NSMutableArray *skateBoardsInPlayerArms;
@property (strong, nonatomic) NSMutableArray *viewsToBeReAnimated;

@property (strong, nonatomic) NSDictionary *rateOfSkateBoardDropPerLevel;
@property (strong, nonatomic) NSDictionary *rateOfSkateBoardCreationPerLevel;

@property (weak, nonatomic) IBOutlet UIImageView *treeTopView;
@property (weak, nonatomic) IBOutlet UIImageView *playerBody;
@property (weak, nonatomic) IBOutlet UIImageView *playerArm;
@property (weak, nonatomic) IBOutlet UIImageView *scoreBoard;

@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIView *mainBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *scoreSignView;
@property (weak, nonatomic) IBOutlet UIView *pauseView;

@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *playAgainButton;

@property (strong, nonatomic) UIImageView *centerView;
@property (strong, nonatomic) UIImageView *leftView;
@property (strong, nonatomic) UIImageView *rightView;
@property (strong, nonatomic) UIImageView *currentSkateboardView;

@property (weak, nonatomic) UILabel *missedBoardsLabel;
@property (weak, nonatomic) UILabel *gameLevelLabel;

@property (nonatomic) int runSequenceCounter;
@property (nonatomic) int collectedBoards;
@property (nonatomic) int missedBoards;
@property (nonatomic) int currentLevel;
@property (nonatomic) float lastXCoordinateChosen;
@property (nonatomic) float animationDistance;
@property (nonatomic) float skateboardCreationRate;

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
    if (!_missedBoards) _missedBoards = 0;
    return _missedBoards;
}

-(int)collectedBoards
{
    if (!_collectedBoards)  _collectedBoards = 0;
    return _collectedBoards;
}

- (NSMutableArray *)skateBoardsInPlayerArms
{
    if (!_skateBoardsInPlayerArms)  _skateBoardsInPlayerArms = [[NSMutableArray alloc]init];
    return _skateBoardsInPlayerArms;
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
    return [[self.rateOfSkateBoardCreationPerLevel objectForKey:[NSString stringWithFormat:@"%i", currentLevel]] floatValue];
}

- (float)getRateOfSkateBoardFallForCurrentLevel:(int)currentLevel
{
    return [[self.rateOfSkateBoardDropPerLevel objectForKey:[NSString stringWithFormat:@"%i", currentLevel]] floatValue];
}

#pragma mark - create labels

#define GameLevelLabel_x 30
#define GameLevelLabel_y 275
#define GameLevelLabel_width 350
#define GameLevelLabel_Height 64

-(UILabel *)createGameLevelLabel:(NSString*)gameLevel
{
    CGRect frame = CGRectMake(GameLevelLabel_x, GameLevelLabel_y, GameLevelLabel_width, GameLevelLabel_Height); 
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    [label setBackgroundColor:[UIColor clearColor]];
    label.text = gameLevel;
    return label;
}

#define MissedBoardLabel_x 30
#define MissedBoardLabel_y 300
#define MissedBoardLabel_width 350
#define MissedBoardLabel_Height 64

-(UILabel *)createMissedBoardsLabel
{
    CGRect frame = CGRectMake(MissedBoardLabel_x, MissedBoardLabel_y, MissedBoardLabel_width, MissedBoardLabel_Height);
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}

#pragma mark - run sequence
- (void)prepareRunSequenceArrays
{
    self.runSequenceLeftToRight = [[NSMutableArray alloc]init];
    NSString *imageTitle = @"runSequence";
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
    self.runTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
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
    
    for (SkateBoardView *view in viewArray) {
        float newXPosition = view.lastKnownLocation.x;
        float newYPosition = view.lastKnownLocation.y;
        CGPoint newCenter = CGPointMake(newXPosition, newYPosition);
        SkateBoardView *newView = [[SkateBoardView alloc]initWithImage:[self.skateBoardImages objectAtIndex:view.imageIndexIdentifier]];
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

- (void)updateMissedBoardsLabel
{
    NSString *strike = @"X";
    NSString *doubleStrike = [strike stringByAppendingString:@"X"];
    NSString *tripleStrike = [doubleStrike stringByAppendingString:@"X"];
    self.gameOver = [self.gameData checkIfLevelFailed:self.missedBoards];
    
    if (self.gameOver) {
         self.missedBoardsLabel.text = @"GAME OVER!";
         [self gameEnded];
    }   else if (self.missedBoards == 1) {
        self.missedBoardsLabel.text = strike;
        }   else if (self.missedBoards == 2) {
            self.missedBoardsLabel.text = doubleStrike;
            }   else if (self.missedBoards == 3) {
                self.missedBoardsLabel.text = tripleStrike;
                }

}

- (void)gameEnded
{
    [self.skateBoardDropTimer invalidate];
    NSArray *currentAnimations = [self.skateboardView retrieveCurrentSkateBoardViews];
    for (UIImageView *view in currentAnimations) { 
        [view removeFromSuperview];
    }
     self.pauseButton.hidden = YES;
     self.missedBoards = 0;
    
    if (self.startAllOver) {
        [self.playAgainButton setTitle:@"Start Over?" forState:UIControlStateNormal];
    }
    
    self.playAgainButton.hidden = NO;
}

- (UIImageView *)createScoreDigitView:(NSString *)scoreString characterIndex:(int)index xOffset:(float)x
{
    NSString *stringDigit = [NSString stringWithFormat:@"%c",[scoreString characterAtIndex:index]];
    UIImage *imageForDigit = [UIImage imageNamed:stringDigit];
    CGRect imageViewFrame = CGRectMake(self.scoreBoard.frame.size.width - x, self.scoreBoard.frame.size.height - 174, imageForDigit.size.width, imageForDigit.size.height); 
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageViewFrame];
    imageView.image = imageForDigit;
    return imageView;
}

- (void)postCurrentScore:(int)currentScore
{
    NSString *scoreString = [NSString stringWithFormat:@"%i", currentScore];
    int scoreStringLength = [scoreString length];
    [self.leftView removeFromSuperview];
    [self.centerView removeFromSuperview];
    [self.rightView removeFromSuperview];

    if (scoreStringLength == 1) {
        self.centerView = [self createScoreDigitView:scoreString characterIndex:0 xOffset:70];
        [self.scoreSignView addSubview:self.centerView];
    }   else if (scoreStringLength == 2) {
        //first digit
         self.leftView = [self createScoreDigitView:scoreString characterIndex:0 xOffset:86];
         [self.scoreSignView addSubview:self.leftView];
        //second digit
        self.rightView = [self createScoreDigitView:scoreString characterIndex:1 xOffset:57];
        [self.scoreSignView addSubview:self.rightView];
        }   else if (scoreStringLength == 3) {
            //first digit
            self.leftView = [self createScoreDigitView:scoreString characterIndex:0 xOffset:100];
            [self.scoreSignView addSubview:self.leftView];
            //second digit
            self.centerView = [self createScoreDigitView:scoreString characterIndex:1 xOffset:72];
            [self.scoreSignView addSubview:self.centerView];
            //third digit
            self.rightView = [self createScoreDigitView:scoreString characterIndex:2 xOffset:44];
            [self.scoreSignView addSubview:self.rightView];
            }
}

- (void)stopTrackingPlayerMotionUsingAccelerometer
{
    [[CMMotionManager sharedMotionManager] stopAccelerometerUpdates];
}

#pragma mark - catch board
- (void)catchBoard //creates illusion that boards are piling up in player's arms
{
    NSArray *skateBoards = [self.skateBoardImages copy];
    int randomIndex = arc4random() % [skateBoards count];
    
    UIImage *skateBoard = [skateBoards objectAtIndex:randomIndex];
    UIImageView *view = [[UIImageView alloc]initWithImage:skateBoard];
   
    float originOffset = skateBoard.size.height;
    if (self.collectedBoards > 5 && self.collectedBoards < 10) originOffset -= 10;
    if (self.collectedBoards > 10 && self.collectedBoards < 15) originOffset -= 20;
    if (self.collectedBoards > 15 && self.collectedBoards < 20) originOffset -= 30;
    if (self.collectedBoards > 20 && self.collectedBoards < 25) originOffset -= 40;
    if (self.collectedBoards > 25 && self.collectedBoards < 30) originOffset -= 50;
    if (self.collectedBoards > 30 && self.collectedBoards < 35) originOffset -= 60;
    if (self.collectedBoards > 35 && self.collectedBoards < 40) originOffset -= 70;
    if (self.collectedBoards > 40 && self.collectedBoards < 45) originOffset -= 80;
    if (self.collectedBoards > 45 && self.collectedBoards < 50) originOffset -= 90;
    if (self.collectedBoards > 50) originOffset -= 100;

    float xPointForSkateBoard = self.playerArm.frame.origin.x + skateBoard.size.height;
    float yPointForSkateBoard = self.playerArm.frame.origin.y + originOffset;
    CGPoint newCenterForView = CGPointMake(xPointForSkateBoard, yPointForSkateBoard);
    view.center = newCenterForView;

    [self.playerView addSubview:view];
    [self.playerView sendSubviewToBack:view];
    [self.playerView sendSubviewToBack:self.playerArm];
    
    self.collectedBoards++;
    [self postCurrentScore:self.collectedBoards];
    
    if([self.gameData checkIfLevelWon:self.collectedBoards forLevel:self.currentLevel]) {
        if (self.currentLevel == MAX_LEVEL) {
            self.missedBoardsLabel.text = @"YOU WON THE WHOLE GAME!!!!!!!!!";
            self.startAllOver = YES;
        } else  self.missedBoardsLabel.text = @"YOU WON!";
        
        [self gameEnded];
    }
    
    [self.skateBoardsInPlayerArms addObject:view];
}

#pragma mark - player motion gesture recognizer
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer { 
    
    if (!self.accelerometerIsNotAvailable) recognizer.enabled = NO; //only available if there is no acceleromter
    
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
    float skateboardCreationIncrementor = 0.1;
    
    if (self.collectedBoards < [self.gameData getBoardRequirementForCurrentLevel:self.currentLevel]/2) {
        self.skateboardCreationRate = [self getRateOfSkateBoardCreationForCurrentLevel:self.currentLevel];
    }
    
    if ((self.collectedBoards > [self.gameData getBoardRequirementForCurrentLevel:self.currentLevel]/2) && !self.difficultyLevelWasIncremented) {
        self.skateboardCreationRate = self.skateboardCreationRate - skateboardCreationIncrementor;
        self.difficultyLevelWasIncremented = YES;
    }
}

- (BOOL)checkForCollision: (SkateBoardView *)skateBoardView //check if player "caught" a skateboard
{
    CGRect view1 = skateBoardView.frame;
    CGRect view2 = self.playerView.frame;
    CGRect intersection = CGRectIntersection(view1, view2);
    if(!CGRectIsNull(intersection)) {
        [skateBoardView removeFromSuperview];
        [self incrementBoardDropRateAtEndOfLevel];
        [self catchBoard];
        return YES;
    }
    
    return NO;
}

- (void)animationBlockCompleted: (SkateBoardView *)skateboardView //a given skateboard view is done animating
{
    [skateboardView removeFromSuperview];
    self.missedBoards ++;
    [self updateMissedBoardsLabel];
}

#define HORIZONTAL_DISTANCE_BETWEEN_CREATED_BOARDS 200
- (float)generateRandomXCoordinateForSkateBoard //create random drop location for skateboard
{
    int viewSize = [[NSNumber numberWithFloat:self.view.bounds.size.height] intValue];
    int randomIntWithinWidth = arc4random() % viewSize;
    float chosenValue = [[NSNumber numberWithInt: randomIntWithinWidth] floatValue];
    
    if ((chosenValue > self.lastXCoordinateChosen - HORIZONTAL_DISTANCE_BETWEEN_CREATED_BOARDS) && (chosenValue < self.lastXCoordinateChosen + HORIZONTAL_DISTANCE_BETWEEN_CREATED_BOARDS)) {
        chosenValue = [self generateRandomXCoordinateForSkateBoard];
    } else self.lastXCoordinateChosen = chosenValue;
    
    return chosenValue;
}

- (void)createSkateBoard
{
    int imageIndexIdentifier = arc4random() % [self.skateBoardImages count];
    UIImage *skateBoardImage = [self.skateBoardImages objectAtIndex:imageIndexIdentifier];
    
    float skateBoardImageWidth = skateBoardImage.size.width;
    float rightLimit = self.view.bounds.size.height - skateBoardImageWidth;
    float leftLimit = skateBoardImageWidth;
    float x = [self generateRandomXCoordinateForSkateBoard];
    
    if (x > rightLimit)     x = rightLimit + (skateBoardImageWidth/2);
        else if   (x < leftLimit)   x = leftLimit + (skateBoardImageWidth/2);
    
    SkateBoardView *imageView = [[SkateBoardView alloc]init];
    imageView.image = skateBoardImage;
    imageView.frame = CGRectMake(x, 0, imageView.image.size.width, imageView.image.size.height);
    imageView.animationCounter = 0;
    imageView.imageIndexIdentifier = imageIndexIdentifier;
    
    [self.mainBackgroundView addSubview:imageView];
    
    [self.skateboardView skateBoardAnimation:imageView animationDuration:[self getRateOfSkateBoardFallForCurrentLevel:self.currentLevel]];
 
     
}

-(void)dropBoard:(NSTimer *)timer
{
    if (!self.gameOver) {
    [self createSkateBoard]; 
    }
}

- (void)dropTimer
{
    self.skateboardCreationRate = [self getRateOfSkateBoardCreationForCurrentLevel:self.currentLevel];
    self.skateBoardDropTimer = [NSTimer scheduledTimerWithTimeInterval:self.skateboardCreationRate
                                                         target:self
                                                       selector:@selector(dropBoard:)
                                                       userInfo:nil
                                                        repeats:YES];
}

- (void)prepareToDropSkateBoard
{
    if ([self view]) [self performSelector:@selector(dropTimer) withObject:nil afterDelay:0];
}

#pragma mark - buttons
- (IBAction)resumeButton:(id)sender {
    
    self.pauseView.hidden = YES; //always remove the pause view from the screen
    
    if (self.playAgainButton.isHidden) { //if the play again button is not visible, do regular resume activities
    [self prepareToDropSkateBoard];
    [self checkTimersAndAccelerometerState];
    NSArray *newViews = [self retrieveViewsFromPausedState:self.viewsToBeReAnimated];
    for (SkateBoardView *view in newViews) {
        [self.skateboardView skateBoardAnimation:view animationDuration:[self getRateOfSkateBoardFallForCurrentLevel:self.currentLevel]];
    }
    [self.viewsToBeReAnimated removeAllObjects];
    }

}

- (IBAction)pauseButton:(UIButton *)sender {
    if (self.playAgainButton.isHidden) { //if the play again button is hidden, do pause action, otherwise do nothing
    self.pauseView.hidden = NO;
    [self.skateBoardDropTimer invalidate];
    self.viewsToBeReAnimated = [[self.skateboardView retrieveCurrentSkateBoardViews]mutableCopy];
    [self.skateboardView.skateBoardsInAnimation removeAllObjects]; 
        for (SkateBoardView *view in self.viewsToBeReAnimated) {
        view.wasPaused = YES;
        [view removeFromSuperview];
    }
    }
}

- (IBAction)playAgainButton:(UIButton *)sender {
    if (!self.pauseView.isHidden)  self.pauseView.hidden = YES; //if the pause view is visible, dismiss it when we press play again
    
    [self checkTimersAndAccelerometerState];
    [self.skateboardView.skateBoardsInAnimation removeAllObjects];
    self.difficultyLevelWasIncremented = NO;
    
    int nextLevel;
    if (self.startAllOver) {
    nextLevel = 1;
    [self.playAgainButton setTitle:@"Play Again?" forState:UIControlStateNormal];
    self.startAllOver = NO;
    }   else {
        nextLevel = [self.gameData determineNextGameLevel:[self.gameData checkIfLevelWon:self.collectedBoards forLevel:self.currentLevel] currentGameLevel:self.currentLevel];
        }

    self.playAgainButton.hidden = YES;
    [self.gameLevelLabel removeFromSuperview];
    [self.missedBoardsLabel removeFromSuperview];
    [self.leftView removeFromSuperview];
    [self.centerView removeFromSuperview];
    [self.rightView removeFromSuperview];
    for (SkateBoardView *view in self.skateBoardsInPlayerArms) {
        [view removeFromSuperview];
    }
    self.gameLevelLabel = [self createGameLevelLabel:[NSString stringWithFormat:@"Level %i", nextLevel]];
    [self.view addSubview:self.gameLevelLabel];
    self.missedBoardsLabel = [self createMissedBoardsLabel];
    [self.view addSubview:self.missedBoardsLabel];
    self.currentLevel = nextLevel;
    self.gameOver = NO;
    self.collectedBoards = 0;
    [self prepareToDropSkateBoard];
    self.pauseButton.hidden = NO;
}

#pragma mark - view controller life cycle
- (void)appEnteredBackground
{
    [[CMMotionManager sharedMotionManager] stopAccelerometerUpdates];
    self.stopAccelerometerUpdatesWasCalled = YES;
    [self.runTimer invalidate];
    self.stopRunTimerWasCalled = YES;
    [self.skateBoardDropTimer invalidate];
    
    if (!self.pauseButton.isHidden) {
        self.viewsToBeReAnimated = [[self.skateboardView retrieveCurrentSkateBoardViews]mutableCopy];
        [self.skateboardView.skateBoardsInAnimation removeAllObjects];
        for (SkateBoardView *view in self.viewsToBeReAnimated) {
            view.wasPaused = YES;
            [view removeFromSuperview];
        }
    }
    
    if (self.playAgainButton.isHidden)  self.pauseView.hidden = NO;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //prepare view
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.pauseView.hidden = YES;
    [self.playAgainButton setTitle:@"Play Again?" forState:UIControlStateNormal];
    self.playAgainButton.hidden = YES;
    //class instances
    self.gameData = [[GameData alloc]init];
    self.skateboardView = [[SkateBoardView alloc]init];
    self.skateboardView.delegate = self;
    //prepare arrays
    [self prepareRunSequenceArrays];
    self.skateBoardImages = [self.skateboardView prepareSkateBoardImageArray];
    self.animationDistance = [self.skateboardView makeTransformDictionaries:self.view.bounds.size.height];
    self.rateOfSkateBoardCreationPerLevel = [GameData getDictionaryForRateOfSkateBoardCreation];
    self.rateOfSkateBoardDropPerLevel = [GameData getDictionaryForRateOfSkateBoardFall];
    //labels
    self.gameLevelLabel = [self createGameLevelLabel:[NSString stringWithFormat:@"Level %i", self.currentLevel]];
    [self.view addSubview:self.gameLevelLabel];
    self.missedBoardsLabel = [self createMissedBoardsLabel];
    [self.view addSubview:self.missedBoardsLabel];
    //begin skateboard animation
    [self prepareToDropSkateBoard];
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
    self.treeTopView = nil;
    self.playerArm = nil;
    self.playerView = nil;
    self.pauseButton = nil;
    self.scoreSignView = nil;
    self.scoreBoard = nil;
    self.missedBoardsLabel = nil;
    self.gameLevelLabel = nil;
    self.playAgainButton = nil;
    self.pauseView = nil;
    self.mainBackgroundView = nil;
}

@end
