//
//  StartGameViewController.m
//
//  Created by Jennifer Clark on 3/10/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "StartGameViewController.h"

@implementation StartGameViewController



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)startButton {
    [self performSegueWithIdentifier:@"playGame" sender:self];
}

-(void)segueToInfoView
{
    [self performSegueWithIdentifier:@"getInfoFromStartScreen" sender:self];
}

- (void)addGetInfoButtonToView
{
    UIImage *image = [UIImage imageNamed:@"getGameInfoButton"];
    CGFloat width = image.size.width/2;
    CGFloat height = image.size.height/2;
    CGFloat x = 55;
    CGFloat y = 675;
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(x, y, width, height)];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(segueToInfoView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self addGetInfoButtonToView];
}

@end
