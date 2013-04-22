//
//  GameInfoViewController.m
//  twinkle
//
//  Created by Jennifer Clark on 4/21/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "GameInfoViewController.h"

@interface GameInfoViewController ()

@end

@implementation GameInfoViewController

-(void)addMainView
{
    UIImage *image = [UIImage imageNamed:@"gameInfo"];
    CGFloat width = image.size.width/2;
    CGFloat height = image.size.height/2;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    imageView.image = image;
    [self.view addSubview:imageView];
}

- (void)dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addDismissButton
{
    UIImage *image = [UIImage imageNamed:@"exitInfoButton"];
    CGFloat width = image.size.width/2;
    CGFloat height = image.size.height/2;
    CGFloat x = 55;
    CGFloat y = 675;
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(x, y, width, height)];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addMainView];
    [self addDismissButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
