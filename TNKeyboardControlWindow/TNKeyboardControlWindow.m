//
//  TNKeyboardControlWindow.m
//
//  Created by Tawa Nicolas on 26/5/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "TNKeyboardControlWindow.h"

NSString *const TNKeyboardFrameChangeNotification	= @"TNKeyboardFrameChangeNotification";
NSString *const TNKeyboardFrameUserInfoKey			= @"TNKeyboardFrameUserInfoKey";

@interface TNKeyboardControlWindow ()
{
	NSMutableArray *listeners;
	CGRect keyboardFrame;
	CGSize screenSize;
	CGSize keyboardSize;
	
	NSTimeInterval lastTouchTimestamp;
	CGFloat lastTouchY;
	
	CADisplayLink *displayLink;
	
	BOOL keyboardIsHiding;
}

@property (weak, nonatomic) UIView *keyboardView;
@property (weak, nonatomic) UIWindow *keyboardWindow;
@property (weak, nonatomic) UITouch *currentTouch;

@end

@implementation TNKeyboardControlWindow

-(instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self) {
		[self becomeFirstResponder];
		
		listeners = [NSMutableArray array];
		screenSize = [[UIScreen mainScreen] bounds].size;
		keyboardFrame = CGRectZero;
		displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(checkKeyboard)];
		[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	}
	
	return self;
}

-(void)addKeyboardFrameListener:(id<TNKeyboardListenerProtocol>)listener
{
	if (![listeners containsObject:listener]) {
		[listeners addObject:listener];
	}
}

-(void)removeKeyboardFrameListener:(id<TNKeyboardListenerProtocol>)listener
{
	if ([listeners containsObject:listener]) {
		[listeners removeObject:listeners];
	}
}

-(void)keyboardWillShow:(NSNotification *)notification
{
	if (self.keyboardWindow == nil) {
		keyboardIsHiding = NO;
		for (UIWindow *window in [UIApplication sharedApplication].windows) {
			if ([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]) {
				self.keyboardWindow = window;
				self.keyboardView = window.rootViewController.view.subviews.firstObject;
				keyboardFrame = self.keyboardView.frame;
				keyboardSize = keyboardFrame.size;
			}
		}
		[self checkKeyboard];
	}
}

-(void)keyboardWillHide:(NSNotification *)notification
{
	keyboardIsHiding = YES;
}
-(void)keyboardDidHide:(NSNotification *)notification
{
	self.keyboardWindow = nil;
	self.keyboardView = nil;
}

+(TNKeyboardControlWindow *)window
{
	static TNKeyboardControlWindow *w = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		w = [[TNKeyboardControlWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	});
	
	return w;
}

-(void)checkKeyboard
{
	if (self.keyboardView) {
		if (!CGRectEqualToRect(self.keyboardView.layer.presentationLayer.frame, keyboardFrame)) {
			keyboardFrame = self.keyboardView.layer.presentationLayer.frame;
			
			if (keyboardFrame.origin.y > screenSize.height) {
				keyboardFrame.origin.y = screenSize.height;
			}
			
			for (id<TNKeyboardListenerProtocol>listener in listeners) {
				[listener keyboardDidChangeFrame:keyboardFrame];
			}
			
			[self postKeyboardFrameChangeNotification:keyboardFrame];
		}
	}
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (self.currentTouch == nil) {
		self.currentTouch = touch;
		lastTouchY = [touch locationInView:self].y;
		lastTouchTimestamp = [touch timestamp];
	}
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ([touch isEqual:self.currentTouch]) {
		CGPoint point = [touch locationInView:self];
		CGFloat y = point.y;
		CGRect frame = self.keyboardView.frame;
		CGFloat minY = screenSize.height-keyboardSize.height;
		frame.origin.y = MAX(minY,y);
		
		[self updateKeyboardFrame:frame];
		lastTouchY = point.y;
		lastTouchTimestamp = [touch timestamp];
	}
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ([touch isEqual:self.currentTouch]) {
		self.currentTouch = nil;
		CGPoint point = [touch locationInView:self];
		CGFloat y = point.y;
		
		CGFloat deltaTime = touch.timestamp - lastTouchTimestamp;
		CGFloat deltaY = y - lastTouchY;
		CGFloat velocityY = 0.2 * deltaY/deltaTime;

		CGFloat duration = (ABS(velocityY)*.0002)+.2;
		CGFloat finalY = y + velocityY;

		if (finalY >= screenSize.height-keyboardSize.height*0.5) {
			CGRect frame = CGRectMake(0, screenSize.height, keyboardSize.width, keyboardSize.height);
			keyboardIsHiding = YES;
			[UIView animateWithDuration:duration animations:^{
				[self updateKeyboardFrame:frame];
			} completion:^(BOOL finished) {
				[self.keyboardWindow setHidden:YES];
				[self keyboardDidHide:nil];
				[self endEditing:YES];
			}];
		} else {
			CGRect frame = CGRectMake(0, screenSize.height-keyboardSize.height, keyboardSize.width, keyboardSize.height);
			[UIView animateWithDuration:duration animations:^{
				[self updateKeyboardFrame:frame];
			}];
		}
	}
}

-(void)sendEvent:(UIEvent *)event
{
	[super sendEvent:event];
	
	if (self.keyboardView && !keyboardIsHiding) {
		if (event.type == UIEventTypeTouches) {
			for (UITouch *touch in [event allTouches]) {
				if (touch.phase == UITouchPhaseMoved) {
					[self touchMoved:touch withEvent:event];
				} else if (touch.phase == UITouchPhaseBegan) {
					[self touchBegan:touch withEvent:event];
				} else if (touch.phase == UITouchPhaseEnded) {
					[self touchEnded:touch withEvent:event];
				} else if (touch.phase == UITouchPhaseCancelled) {
					[self touchEnded:touch withEvent:event];
				}
			}
		}
	}
}

-(void)updateKeyboardFrame:(CGRect)frame
{
	if (self.keyboardView) {
		self.keyboardView.frame = frame;
	}
}

-(void)postKeyboardFrameChangeNotification:(CGRect)frame
{
	[[NSNotificationCenter defaultCenter] postNotificationName:TNKeyboardFrameChangeNotification object:nil userInfo:@{TNKeyboardFrameUserInfoKey:[NSValue valueWithCGRect:frame]}];
}


-(BOOL)canBecomeFirstResponder
{
	return YES;
}

@end
