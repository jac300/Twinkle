//
//  GameData.m
//  knockONwood
//
//  Created by Jennifer Clark on 3/10/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "GameData.h"
#import "DataController.h"

@interface GameData()

@property (strong, nonatomic) NSDictionary *boardsForEachLevel;

@end

@implementation GameData

-(BOOL)checkIfLevelFailed:(int)missedBoards
{
    return (missedBoards >= 3) ? YES : NO;
}

-(int)determineNextGameLevel:(BOOL)levelPassed currentGameLevel:(int)level
{
    return (levelPassed) ? level +1 : level;
}

-(BOOL)checkIfLevelWon:(int)boardsCollected forLevel:(int)level
{
    NSString *numberOfBoardsNeededForCurrentLevel = [[GameData getBoardRequirementsForEachLevel] objectForKey:[NSString stringWithFormat:@"%i",level]];
        
    return ([numberOfBoardsNeededForCurrentLevel intValue] <= boardsCollected) ? YES : NO;
}

+ (NSDictionary *)getBoardRequirementsForEachLevel
{
    NSArray *levels = [[NSArray alloc]initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", nil];
    NSArray *boardAmounts = [[NSArray alloc]initWithObjects:@"10",@"15",@"20",@"25",@"30",@"35",@"40",@"45",@"50",@"55",nil];
    NSDictionary *boardsForEachLevel = [[NSDictionary alloc]initWithObjects:boardAmounts forKeys:levels];
    return boardsForEachLevel;
}

+ (NSDictionary *)getDictionaryForRateOfSkateBoardCreation
{
    NSArray *levels = [[NSArray alloc]initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10" ,nil];
    NSArray *rateOfSkateBoardCreationArray = [[NSArray alloc] initWithObjects:@"1", @".9", @".8", @".8", @".7", @".7", @".7", @".7", @".6", @".6", nil];
    NSDictionary *dictionary = [[NSDictionary alloc]initWithObjects:rateOfSkateBoardCreationArray forKeys:levels];
    return dictionary;
}

+ (NSDictionary *)getDictionaryForRateOfSkateBoardFall
{
    NSArray *levels = [[NSArray alloc]initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10" ,nil];
    NSArray *rateOfSkateBoardFallArray = [[NSArray alloc]initWithObjects:@"0.25", @"0.22", @"0.20", @"0.19", @"0.19", @"0.17", @"0.15", @"0.15", @"0.12", @"0.11",  nil];
    NSDictionary *dictionary = [[NSDictionary alloc]initWithObjects:rateOfSkateBoardFallArray forKeys:levels];
    return dictionary;
}

- (float)getBoardRequirementForCurrentLevel:(int)level
{
    NSString *numberOfBoardsNeededForCurrentLevel = [[GameData getBoardRequirementsForEachLevel] objectForKey:[NSString stringWithFormat:@"%i",level]];
    return [numberOfBoardsNeededForCurrentLevel floatValue];
}

@end
