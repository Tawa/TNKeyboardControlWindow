//
//  TextFieldViewController.m
//  TNKeyboardControlWindowExample
//
//  Created by Tawa Nicolas on 27/5/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "TextFieldViewController.h"

@interface TextFieldViewController ()

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@end

@implementation TextFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.logoutButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
}

-(void)dismiss
{
	[self.tabBarController dismissViewControllerAnimated:YES completion:nil];
}

@end
