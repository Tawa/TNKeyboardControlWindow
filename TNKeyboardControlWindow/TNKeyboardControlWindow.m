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
	NSMutableArray *listeners;				// Array of listeners that are gonna be waiting for keyboard events
	CGRect keyboardFrame;					// Keyboard Frame on screen
	CGSize screenSize;						// Screen size
	
	NSTimeInterval lastTouchTimestamp;		// Previous touch timestamp. Used to calculate touch drag speed
	CGFloat lastTouchY;						// Previous touch y position on the screen. Used to calculate touch drag speed
	
	CADisplayLink *displayLink;				// Display link used to watch keyboard movements
	BOOL displayLinkAdded;					// Flag used to monitor displayLink status
	
	BOOL keyboardIsHiding;					// Flag in order to stop drag events in case the keyboard is hiding
}

@property (weak, nonatomic) UIView *keyboardView;		// Weak reference to the keyboard view
@property (weak, nonatomic) UIWindow *keyboardWindow;	// Weak reference to the keyboard window
@property (weak, nonatomic) UITouch *currentTouch;		// Weak reference to the touch event that first started handling the keyboard, this is to avoid multitouch panning issues

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
		displayLinkAdded = NO;
		
		// Observers that will notify listeners about keyboard events
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	}
	
	return self;
}


/**
 Add new listener to the keyboard events

 @param listener - New listener
 */
-(void)addKeyboardFrameListener:(id<TNKeyboardListenerProtocol>)listener
{
	if (![listeners containsObject:listener]) {
		[listeners addObject:listener];
	}
}

/**
 Remove listener from the keyboard events

 @param listener - Listener to be removed
 */
-(void)removeKeyboardFrameListener:(id<TNKeyboardListenerProtocol>)listener
{
	if ([listeners containsObject:listener]) {
		[listeners removeObject:listeners];
	}
}

/**
 Keyboard will show on the screen

 @param notification - NSNotification sent by the OS.
 */
-(void)keyboardWillShow:(NSNotification *)notification
{
	for (id<TNKeyboardListenerProtocol>listener in listeners) {
		if ([listener respondsToSelector:@selector(keyboardWillStartShowing)]) {
			[listener keyboardWillStartShowing];
		}
	}
	
	// In case the keyboardWindow is nil, find it in the display hierarchy, and find the keyboard view, and get the initial frame
	if (self.keyboardWindow == nil) {
		keyboardIsHiding = NO;
		for (UIWindow *window in [UIApplication sharedApplication].windows) {
			if ([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]) {
				self.keyboardWindow = window;
				self.keyboardView = window.rootViewController.view.subviews.firstObject;
				keyboardFrame = self.keyboardView.frame;
			}
		}
	}
}

/**
 Keyboard did finish showing on the screen

 @param notification - NSNotification sent by the OS.
 */
-(void)keyboardDidShow:(NSNotification *)notification
{
	for (id<TNKeyboardListenerProtocol>listener in listeners) {
		if ([listener respondsToSelector:@selector(keyboardDidFinishShowing)]) {
			[listener keyboardDidFinishShowing];
		}
	}
}

/**
 Keyboard will start hiding from the screen

 @param notification - NSNotification sent by the OS.
 */
-(void)keyboardWillHide:(NSNotification *)notification
{
	keyboardIsHiding = YES;
	
	for (id<TNKeyboardListenerProtocol>listener in listeners) {
		if ([listener respondsToSelector:@selector(keyboardWillStartHiding)]) {
			[listener keyboardWillStartHiding];
		}
	}
}

/**
 Keyboard did finish hiding from the screen

 @param notification - NSNotification sent by the OS.
 */
-(void)keyboardDidHide:(NSNotification *)notification
{
	self.keyboardWindow = nil;
	self.keyboardView = nil;

	for (id<TNKeyboardListenerProtocol>listener in listeners) {
		if ([listener respondsToSelector:@selector(keyboardDidFinishHiding)]) {
			[listener keyboardDidFinishHiding];
		}
	}
}

// Shared instance
+(TNKeyboardControlWindow *)window
{
	static TNKeyboardControlWindow *w = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		w = [[TNKeyboardControlWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	});
	
	return w;
}

/**
 This method watches the keyboard in case it exists
 */
-(void)checkKeyboard
{
	// If the keyboard view is available. Check if the presentationLayer frame has changed
	if (self.keyboardView) {
		if (!CGRectEqualToRect(self.keyboardView.layer.presentationLayer.frame, keyboardFrame)) {
			keyboardFrame = self.keyboardView.layer.presentationLayer.frame;
			
			if (!CGRectEqualToRect(keyboardFrame, CGRectZero)) { // Check if not zero, which means the layer is available.
				if (keyboardFrame.origin.y > screenSize.height) {
					keyboardFrame.origin.y = screenSize.height;
				}
				
				// Notify listener
				for (id<TNKeyboardListenerProtocol>listener in listeners) {
					[listener keyboardDidChangeFrame:keyboardFrame];
				}
				
				// Send notification with the new frame
				[self postKeyboardFrameChangeNotification:keyboardFrame];
			}
		}
	} else {
		// If the view does not exist, we don't need to monitor it anymore.
		[self removeDisplayLink];
	}

}


/**
 Setter used to watch the value of tke property. If a non-nil value is set, start monitoring the keyboard frame
 */
-(void)setKeyboardView:(UIView *)keyboardView
{
	_keyboardView = keyboardView;
	
	if (keyboardView != nil) {
		[self addDisplayLink];
	}
}

/**
 Safely add displayLink to runloop.
 */
-(void)addDisplayLink
{
	if (!displayLinkAdded) {
		[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		displayLinkAdded = YES;
	}
}


/**
 Safely remove displayLink from runloop.
 */
-(void)removeDisplayLink
{
	if (displayLinkAdded) {
		[displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		displayLinkAdded = NO;
	}
}


/**
 When a new touch starts, this method checks if we're not watching a touch event, and start watching it

 @param touch - target touch event
 */
-(void)touchBegan:(UITouch *)touch
{
	if (self.currentTouch == nil) {
		self.currentTouch = touch;
		lastTouchY = [touch locationInView:self].y;
		lastTouchTimestamp = [touch timestamp];
	}
}


/**
 When the touch moves, update the keyboard relatively to the position of the touch.

 @param touch - touch event being watched
 */
-(void)touchMoved:(UITouch *)touch
{
	if ([touch isEqual:self.currentTouch]) {
		CGPoint point = [touch locationInView:self];
		CGFloat y = point.y;
		CGRect frame = self.keyboardView.frame;
		
		CGFloat minY = screenSize.height-keyboardFrame.size.height;	// Can't let the keyboard view go higher than its height. The keyboard's minimum Y position should be (Screen Height - Keyboard Height)
		frame.origin.y = MAX(minY,y);
		
		[self updateKeyboardFrame:frame];
		lastTouchY = point.y;
		lastTouchTimestamp = [touch timestamp];
	}
}


/**
 When the touch ends, check if the keyboard should be dismiss or displalyed back properly on the screen.

 @param touch - touch event being watched.
 */
-(void)touchEnded:(UITouch *)touch
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

		if (finalY >= screenSize.height-keyboardFrame.size.height*0.5) {
			CGRect frame = CGRectMake(0, screenSize.height, keyboardFrame.size.width, keyboardFrame.size.height);
			keyboardIsHiding = YES;
			[UIView animateWithDuration:duration animations:^{
				[self updateKeyboardFrame:frame];
			} completion:^(BOOL finished) {
				[self.keyboardWindow setHidden:YES];
				[self keyboardDidHide:nil];
				[self endEditing:YES];
			}];
		} else {
			CGRect frame = CGRectMake(0, screenSize.height-keyboardFrame.size.height, keyboardFrame.size.width, keyboardFrame.size.height);
			[UIView animateWithDuration:duration animations:^{
				[self updateKeyboardFrame:frame];
			}];
		}
	}
}


/**
 This method catches touch events and handles them
 */
-(void)sendEvent:(UIEvent *)event
{
	[super sendEvent:event];
	
	if (self.keyboardView && !keyboardIsHiding) {
		if (event.type == UIEventTypeTouches) {
			for (UITouch *touch in [event allTouches]) {
				if (touch.phase == UITouchPhaseMoved) {
					[self touchMoved:touch];
				} else if (touch.phase == UITouchPhaseBegan) {
					[self touchBegan:touch];
				} else if (touch.phase == UITouchPhaseEnded) {
					[self touchEnded:touch];
				} else if (touch.phase == UITouchPhaseCancelled) {
					[self touchEnded:touch];
				}
			}
		}
	}
}


/**
 This method updates the keyboard frame on the screen

 @param frame - target frame
 */
-(void)updateKeyboardFrame:(CGRect)frame
{
	if (self.keyboardView) {
		self.keyboardView.frame = frame;
	}
}

/**
 Notification used in case you want to listen to keyboard change events without using listeners.

 @param frame - new frame of the keyboard
 */
-(void)postKeyboardFrameChangeNotification:(CGRect)frame
{
	[[NSNotificationCenter defaultCenter] postNotificationName:TNKeyboardFrameChangeNotification object:nil userInfo:@{TNKeyboardFrameUserInfoKey:[NSValue valueWithCGRect:frame]}];
}

@end
