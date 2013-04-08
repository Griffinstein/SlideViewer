    //
//  AnnotationEditViewController.m
//  iSlideViewer
//
//  Created by Ed on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnnotationEditViewController.h"
#import "math.h"
#import <QuartzCore/QuartzCore.h>

@implementation AnnotationEditViewController

@synthesize delegate, titleLabel, descriptionLabel, thumbnail;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) addText:(NSString *)Title Description:(NSString *)Description {
		  titleLabel = (UILabel *) [self.view viewWithTag:1];
	descriptionLabel = (UILabel *) [self.view viewWithTag:2];
	   	  titleField = (UITextField *) [self.view viewWithTag:3];
	descriptionField = (UITextField *) [self.view viewWithTag:4];	
	
	      titleLabel.numberOfLines = 0;
	descriptionLabel.numberOfLines = 0;
	
		  titleLabel.text = Title;
	descriptionLabel.text = Description;
		  titleField.text = Title;
	descriptionField.text = Description;
}

//Updates the thumbnail
- (void)drawThumbnail:(NSString *)Slide SlideDirectory:(NSString *)SlideDirectory Height:(int)Height Width:(int)Width xCoord:(int)xCoord yCoord:(int)yCoord Zoom:(float)Zoom;{

	float ratio;
	float newXCoord;
	float newYCoord;
	float newHeight;
	float newWidth;
	float newZoom;
	
	if (Height > Width)
		ratio = (float)Height/300;
	else
		ratio = (float)Width/300;
	
	newWidth =  Width/ratio;
	newHeight = Height/ratio;
	newXCoord = xCoord/ratio;
	newYCoord = yCoord/ratio;
	newZoom = Zoom*ratio;
	
	thumbnail.frame = CGRectMake(thumbnail.frame.origin.x, 
								 thumbnail.frame.origin.y, 
								 newWidth, 
								 newHeight);
	
	[thumbnail.layer setBorderColor: [[UIColor blackColor] CGColor]];
	[thumbnail.layer setBorderWidth: 2.0];
	
	NSData *imageData;
	NSURL *imageURL;
	UIImage *image;
	NSString *URL;

	URL = [@"" stringByAppendingFormat:@"%@%@?GetImage?x=%i&y=%i&width=%i&height=%i&zoom=%.2f",SlideDirectory,Slide,(int)newXCoord,(int)newYCoord,(int)newWidth,(int)newHeight,newZoom];
	imageURL = [NSURL URLWithString:URL];
	imageData = [NSData dataWithContentsOfURL:imageURL];
	image = [[UIImage alloc] initWithData:imageData];
	thumbnail.image = image;
	[image release];
}

#pragma mark -
#pragma mark textField

//Adds the text field methods to obtain the wordsOfWisdom
//Starts the editing session
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
	[textField setReturnKeyType:UIReturnKeyNext];
	return YES;
}

//Occurs after the user has press the enter button
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;
}

//Sets the string what the user just typed out
- (void)textFieldDidEndEditing:(UITextField *)textField{
	titleLabel.text = titleField.text;
	descriptionLabel.text = descriptionField.text;	
}

#pragma mark -
#pragma mark Controls

- (IBAction) done{
	titleLabel.text = titleField.text;
	descriptionLabel.text = descriptionField.text;	
	
	[self.delegate AnnotationEditViewControllerDidFinish:self];
}

- (IBAction) deleteAnnotation{
	[self.delegate AnnotationEditDelete:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

@end
