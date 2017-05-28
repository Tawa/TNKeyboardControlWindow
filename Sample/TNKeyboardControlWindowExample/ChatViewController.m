//
//  ChatViewController.m
//  TNKeyboardControlWindowExample
//
//  Created by Tawa Nicolas on 27/5/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "ChatViewController.h"
#import "TNKeyboardControlWindow.h"
#import "TabBarController.h"

@interface ChatViewController () <TNKeyboardListenerProtocol, UITableViewDelegate, UITableViewDataSource>
{
	CGPoint initialContentOffset;
	BOOL initialContentOffsetValid;
	
	NSMutableArray <NSString *> *messages;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	initialContentOffset = CGPointZero;
	initialContentOffsetValid = NO;
	
	messages = [NSMutableArray array];
	for (int i = 1; i < 100; i++) {
		[messages addObject:[NSString stringWithFormat:@"Message %d", i]];
	}
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

- (IBAction)dismissKeyboard:(id)sender {
	[self.view endEditing:YES];
}

- (IBAction)sendAction:(id)sender {
	if ([self.textField.text length] > 0) {
		[messages addObject:self.textField.text];
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messages count]-1 inSection:0];
		
		[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
		
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
		
		self.textField.text = @"";
	}
}

#pragma mark - TNKeyboardListenerProtocol method

-(void)keyboardWillStartShowing
{
	initialContentOffset = self.tableView.contentOffset;
	initialContentOffsetValid = YES;
}

-(void)keyboardDidFinishShowing
{
	initialContentOffsetValid = NO;
}

-(void)keyboardDidChangeFrame:(CGRect)frame
{
	CGFloat y = frame.origin.y;
	CGFloat tabBarY = ((TabBarController *)self.tabBarController).tabBarY;
	
	if (y < tabBarY) {
		self.bottomConstraint.constant = tabBarY-y;
	} else {
		self.bottomConstraint.constant = 0;
	}
	
	if (initialContentOffsetValid) {
		if (y < tabBarY) {
			CGFloat offsetY = (tabBarY - y);
			CGPoint offset = CGPointMake(initialContentOffset.x, initialContentOffset.y + offsetY);
			self.tableView.contentOffset = offset;
		} else {
		}
	}
}

#pragma mark - UITableView methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [messages count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	
	cell.textLabel.text = [messages objectAtIndex:indexPath.row];
	
	return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (UITableViewCellEditingStyleDelete) {
		[messages removeObjectAtIndex:indexPath.row];
		[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	}
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 0;
}


@end
