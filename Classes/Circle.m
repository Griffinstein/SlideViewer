//
//  Circle.m
//  iSlideViewer
//
//  Created by Ed on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Circle.h"


@implementation Circle


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //Make a simple rectangle and fill background BLUE with half Opeque
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	[[UIColor blackColor] set];
	
	// Draw a circle (border only)
	CGContextStrokeEllipseInRect(context, CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height));
	
	CGContextStrokePath(context);
}


- (void)dealloc {
    [super dealloc];
}


@end
