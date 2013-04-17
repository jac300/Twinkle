//
//  StartGameViewController.m
//
//  Created by Jennifer Clark on 3/10/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "StartGameViewController.h"

@implementation StartGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)startButton {
    [self performSegueWithIdentifier:@"playGame" sender:self];
}

@end
