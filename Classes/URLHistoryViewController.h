//
//  URLHistoryViewController.h
//  iSlideViewer
//
//  Created by Ed on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol URLHistoryViewControllerDelegate;

@interface URLHistoryViewController : UIViewController {
	<URLHistoryViewControllerDelegate>	delegate;
}

@property (nonatomic, assign) id <URLHistoryViewControllerDelegate> delegate;

@end

@protocol URLHistoryViewControllerDelegate

- (void)URLHistoryViewControllerDidFinish:(URLHistoryViewController*)controller;

@end