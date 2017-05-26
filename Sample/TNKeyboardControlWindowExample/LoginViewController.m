//
//  LoginViewController.m
//  TNKeyboardControlWindowExample
//
//  Created by Tawa Nicolas on 27/5/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "LoginViewController.h"
#import "TabBarController.h"
#import "TNKeyboardControlWindow.h"

@interface LoginViewController () <TNKeyboardListenerProtocol>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.scrollView.contentSize = self.scrollView.bounds.size;
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
	CGFloat y = frame.origin.y;
	CGFloat tabBarY = ((TabBarController *)self.tabBarController).tabBarY;
	
	if (y < tabBarY) {
		self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, tabBarY-y, 0);
	} else {
		self.scrollView.contentInset = UIEdgeInsetsZero;
	}
}

@end
