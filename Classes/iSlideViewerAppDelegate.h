//
//  iSlideViewerAppDelegate.h
//  iSlideViewer
//
//  Created by Ed on 2/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iSlideViewerViewController;

@interface iSlideViewerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    iSlideViewerViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet iSlideViewerViewController *viewController;

@end

