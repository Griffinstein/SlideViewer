//
//  Line.h
//  iSlideViewer
//
//  Created by Ed on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Line : UIView {
	
	int		red;
	
	CGPoint	startPoint;
	CGPoint finishPoint;
	
	BOOL	upLeft;
}

- (void)topLeft:(BOOL)TopLeft;

@property (readwrite) int red;

@property (readwrite) BOOL upLeft;				//Stores if the line goes to upright

@property (readwrite) CGPoint startPoint;		//Stores the start point of the line 
@property (readwrite) CGPoint finishPoint;		//Stores the end point of the line

@end