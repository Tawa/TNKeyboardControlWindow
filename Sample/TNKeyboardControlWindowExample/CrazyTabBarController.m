//
//  CrazyTabBarController.m
//  TNKeyboardControlWindowExample
//
//  Created by Tawa Nicolas on 27/5/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "CrazyTabBarController.h"
#import "TNKeyboardControlWindow.h"

@interface CrazyTabBarController () <TNKeyboardListenerProtocol>

@end

@implementation CrazyTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[[TNKeyboardControlWindow window] addKeyboardFrameListener:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[TNKeyboardControlWindow window] removeKeyboardFrameListener:self];
}

#pragma mark - TNKeyboardListenerProtocol method

-(void)keyboardDidChangeFrame:(CGRect)frame
{
	CGRect f = self.tabBar.frame;
	
	f.origin.y = frame.origin.y - f.size.height;
	
	self.tabBar.frame = f;
}

@end
