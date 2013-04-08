    //
//  Annotation.m
//  iSlideViewer
//
//  Created by Ed on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Annotation.h"
#import <QuartzCore/QuartzCore.h>

@implementation Annotation
@synthesize position, centre, height, width, zoom, description, frame, title;

//Deallocates memory for this annotation
-(void)dealloc{
	[description release];
	[title release];
	[frame release];
	[super dealloc];
}

//Called when the annotation needs to be removed
-(void)remove{
	position.x = 0;
	position.y = 0;
	centre.x = 0;
	centre.y = 0;
	height = 0;
	width = 0;
	zoom = 0;
	[frame.layer setBorderColor: 0];
	[title.layer setBorderColor: 0];
	[description.layer setBorderColor: 0];
	title.hidden = YES;
	description.hidden = YES;
	frame.hidden = YES;
	
	[self dealloc];
}

//Construction method for the annotation
-(void)create:(CGPoint)Position Height:(int)Height Width:(int)Width Zoom:(double)Zoom;{
	position = Position;				//Position on the slide
	height = Height;					//Height relative to the zoom level
	width = Width;						//Width relative to the zoom level
	centre.x = Position.x + (Width/2);	//Centre of the annotation
	centre.y = Position.y + (Height/2);
	zoom = Zoom;						//Zoom level during the annotation's created
	
	frame = [[UIImageView alloc] init];
	
	//Creates the annotation
	frame.frame = CGRectMake(position.x,
							 position.y,
							 width,
							 height);
	
	//Creates a border around the annotation
	[frame.layer setBorderColor: [[UIColor blackColor] CGColor]];
	[frame.layer setBorderWidth: 5.0];
}

//When the user has finished drawing the annotation
-(void)finishCreating{
	//Works out the centre of annotation
	centre.x = position.x + (width/2);
	centre.y = position.y + (height/2);
	
	//Creates the title
	title = [[UILabel alloc] init];
	
	//Creates the description
	description = [[UILabel alloc] init];
	
	//Unlimits the number of lines for the description
	description.numberOfLines = 0;
	
	//Creates a border around the title and centers the text
	[title.layer setBorderColor: [[UIColor blackColor] CGColor]];
    [title.layer setBorderWidth: 2.0];
	title.layer.cornerRadius = 8;
	title.textAlignment = UITextAlignmentCenter;
	
	//Creates a border around the description and centers the text
	[description.layer setBorderColor: [[UIColor blackColor] CGColor]];
	[description.layer setBorderWidth: 2.0];
	description.layer.cornerRadius = 8;
	description.textAlignment = UITextAlignmentCenter;
}

//Updates the annotation with each update
-(void)update:(CGPoint)slidePosition Zoom:(double)Zoom;{
	CGPoint newPosition;
	
	//Works out the new position, height and width for the update
	newPosition.x = (position.x * (zoom/Zoom)) - slidePosition.x;
	newPosition.y = (position.y * (zoom/Zoom)) - slidePosition.y;
	int newHeight = height * (zoom/Zoom);
	int newWidth = width * (zoom/Zoom);
	
	//If the annotation is too small, then it it shows an icon instead
	if ((newWidth < 25) && (newHeight < 25)) {
		//Removes the border around the icon
		[frame.layer setBorderWidth: 0.0];
		
		//Gets the icon for the annotation
		frame.image = [UIImage imageNamed:@"BPOIC.png"];
		frame.frame = CGRectMake(newPosition.x,
								 newPosition.y,
								 25,
								 25);
		
		//Updates the title description
		title.frame = CGRectMake(newPosition.x + (25 - title.frame.size.width)/2,
								 newPosition.y + 25 - 2,
								 title.frame.size.width,
								 title.frame.size.height);
	}
	else {
		//Adds the border to the annotation
		[frame.layer setBorderWidth: 5.0];
		
		//Removes the icon from the annotation
		frame.image = [UIImage imageWithData:nil];
		frame.frame = CGRectMake(newPosition.x,
								 newPosition.y,
								 newWidth,
								 newHeight);
		
		//Updates the title description
		title.frame = CGRectMake(newPosition.x + (newWidth - title.frame.size.width)/2,
								 newPosition.y + newHeight - 2,
								 title.frame.size.width,
								 title.frame.size.height);
	}
}

//Updates the description when the text is changed
-(void)updateDescription{
	//Updates the size of the description
	CGSize descriptionSize = [description.text sizeWithFont:description.font
										  constrainedToSize:CGSizeMake(250, 9999)
											  lineBreakMode:UILineBreakModeWordWrap];	
	
	//Redraws the frame of the rectangle
	description.frame = CGRectMake(20,
								   20,
								   descriptionSize.width + 4,
								   descriptionSize.height);
}

//Updates the title when the text is changed
-(void)updateTitle{
	//Updates the size of the title
	CGSize titleSize = [title.text sizeWithFont:title.font
							  constrainedToSize:CGSizeMake(500, 100)
								  lineBreakMode:UILineBreakModeWordWrap];

	//Redraws the frame of the rectangle
	title.frame = CGRectMake(position.x + (width - titleSize.width)/2,
							 position.y + height - 2,
							 titleSize.width + 8,
							 titleSize.height + 4);
}

//Returns true if the the click position is in the rectangle of the annotation
-(BOOL)onAnnotation:(CGPoint)slidePosition clickPosition:(CGPoint)clickPosition Zoom:(double)Zoom;{
	CGPoint newPosition;
	
	//Works out the annotation size at the relative zoom
	newPosition.x = (position.x * (zoom/Zoom)) - slidePosition.x;
	newPosition.y = (position.y * (zoom/Zoom)) - slidePosition.y;
	int newHeight = height * (zoom/Zoom);
	int newWidth = width * (zoom/Zoom);

	if ((newWidth < 25) && (newHeight < 25)) {//If the annotation is too small it checks against the icon
		if ((clickPosition.y > newPosition.y) &&
			(clickPosition.x > newPosition.x) &&
			(clickPosition.y < (25 + newPosition.y)) &&
			(clickPosition.x < (25 + newPosition.x)))
			return TRUE;
		else
			return FALSE;
	}
	else {//Else it checks against the actual annotation
		if ((clickPosition.y > newPosition.y) &&
			(clickPosition.x > newPosition.x) &&
			(clickPosition.y < (newHeight + newPosition.y)) &&
			(clickPosition.x < (newWidth + newPosition.x)))
			return TRUE;
		else
			return FALSE;
	}
}

@end
