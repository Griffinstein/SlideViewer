    //
//  AppScrollView.m
//  iSlideViewer
//
//  Created by Ed on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppScrollView.h"


@implementation AppScrollView

- (id)initWithFrame:(CGRect)frame 
{
	return [super initWithFrame:frame];
}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{	
	// If not dragging, send event to next responder
	if (!self.dragging) 
		[self.nextResponder touchesEnded: touches withEvent:event]; 
	else
		[super touchesEnded: touches withEvent: event];
}

@end