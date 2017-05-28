//
//  TNKeyboardControlWindow.h
//
//  Created by Tawa Nicolas on 26/5/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TNKeyboardListenerProtocol <NSObject>

@optional
-(void)keyboardWillStartShowing;
-(void)keyboardDidFinishShowing;

-(void)keyboardWillStartHiding;
-(void)keyboardDidFinishHiding;

@required
-(void)keyboardDidChangeFrame:(CGRect)frame;

@end

extern NSString *const TNKeyboardFrameChangeNotification;
extern NSString *const TNKeyboardFrameUserInfoKey;

@interface TNKeyboardControlWindow : UIWindow

@property (class, readonly, strong) TNKeyboardControlWindow *window;

-(void)addKeyboardFrameListener:(id<TNKeyboardListenerProtocol>)listener;
-(void)removeKeyboardFrameListener:(id<TNKeyboardListenerProtocol>)listener;

@end
