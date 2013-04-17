//
//  GameData.h
//  knockONwood
//
//  Created by Jennifer Clark on 3/10/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject

#define MAX_LEVEL 10

-(BOOL)checkIfLevelWon:(int)boardsCollected forLevel:(int)level;

-(int)determineNextGameLevel:(BOOL)levelPassed currentGameLevel:(int)level;
- (float)getBoardRequirementForCurrentLevel:(int)level;

+(NSDictionary *)getDictionaryForRateOfSkateBoardFall;
+(NSDictionary *)getDictionaryForRateOfSkateBoardCreation;


@end
