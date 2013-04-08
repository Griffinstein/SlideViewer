//
//  Line.m
//  iSlideViewer
//
//  Created by Ed on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Line.h"


@implementation Line

@synthesize startPoint, finishPoint, upLeft, red;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

//Used to change the direction of the line
- (void)topLeft:(BOOL)TopLeft {
	upLeft = TopLeft;
}

- (void)drawRect:(CGRect)rect {
	
    //Make a simple rectangle and fill background BLUE with half Opeque
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    [[UIColor blackColor] set];
	
	if (upLeft) {
		CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
		CGContextAddLineToPoint( context, rect.size.width, rect.size.height);
	}
	else if (!upLeft) {
		CGContextMoveToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
		CGContextAddLineToPoint( context, -rect.size.width, rect.size.height * 2);
	}
	
    CGContextStrokePath(context);
}

- (void)dealloc {
    [super dealloc];
}


@end
