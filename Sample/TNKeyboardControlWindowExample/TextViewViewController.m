//
//  TextViewViewController.m
//  TNKeyboardControlWindowExample
//
//  Created by Tawa Nicolas on 27/5/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "TextViewViewController.h"
#import "TNKeyboardControlWindow.h"

@interface TextViewViewController () <TNKeyboardListenerProtocol>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation TextViewViewController

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
	self.bottomConstraint.constant = [UIScreen mainScreen].bounds.size.height - frame.origin.y + 8;
}

@end
