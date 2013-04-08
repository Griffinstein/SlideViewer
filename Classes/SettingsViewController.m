    //
//  SettingsViewController.m
//  iSlideViewer
//
//  Created by Ed on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HJMOFileCache.h"
#import "AppScrollView.h"

@implementation SettingsViewController

@synthesize delegate, selectedAnno, listOfAnnos, highlight,currentSlide, red, green, blue, brightness, contrast, numOfAnnos, sharpen, redSlider, greenSlider, blueSlider, brightnessSlider, contrastSlider, thumbnail, minimap, annotation, descript, sharpenSwitch, minimapSwitch, annotationSwitch, descriptionSwitch, minimapBool, annotationBool, descriptionBool, labelScroll, xCoord, yCoord, zoom, slideDirectory, imgMan;

#pragma mark -
#pragma mark Setup

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];	
	[self setup];
	
	//Update the imagescroll to allow movement in the x direction to the last slide
	labelScroll.clipsToBounds = YES;
	labelScroll.delegate = self;
	labelScroll.contentSize = CGSizeMake(250, 35*numOfAnnos);
	
	if (![listOfAnnos isEqualToString:@""]) {
		[self drawLabels];
	}
}

//Setup the variables and for the slider and text
- (void)setup{
	[self updateThumbnail];
	
	selectedAnno = 0;
	
	//Connects the variables to the textfields on the IB
	       redField = (UITextField *) [self.view viewWithTag:1];
	     greenField = (UITextField *) [self.view viewWithTag:2];
	      blueField = (UITextField *) [self.view viewWithTag:3];	
	brightnessField = (UITextField *) [self.view viewWithTag:4];
	  contrastField = (UITextField *) [self.view viewWithTag:5];
	
	//Updates the text on the textfield with the game variable
	       redField.text = [@"" stringByAppendingFormat:@"%i",red];
	     greenField.text = [@"" stringByAppendingFormat:@"%i",green];
		  blueField.text = [@"" stringByAppendingFormat:@"%i",blue];
	brightnessField.text = [@"" stringByAppendingFormat:@"%i",brightness];
	  contrastField.text = [@"" stringByAppendingFormat:@"%i",contrast];
	
	//Updates the switch for the sharpen switch
	if (sharpen == 0)
		sharpenSwitch.on = NO;
	else
		sharpenSwitch.on = YES;

	//Updates the minimap for the sharpen switch
	if (minimapBool){
		minimapSwitch.on = YES;
		minimap.hidden = NO;
	}
	else{
		minimapSwitch.on = NO;
		minimap.hidden = YES;
	}
	
	//Updates the annotation for the sharpen switch
	if (annotationBool){
		annotationSwitch.on = YES;
		annotation.hidden = NO;
	}
	else{
		annotationSwitch.on = NO;
		annotation.hidden = YES;
	}
	
	//Updates the description for the sharpen switch
	if (descriptionBool){
		descriptionSwitch.on = YES;
		descript.hidden = NO;
	}
	else{
		descriptionSwitch.on = NO;
		descript.hidden = YES;
	}	
	
	//Updates the value on the sliders
	redSlider.value = red + 255;
	greenSlider.value = green + 255;
	blueSlider.value = blue + 255;
	contrastSlider.value = contrast + 100;
	brightnessSlider.value = brightness + 100;
	
	//Draws the thumbnail on the minimap
	NSData *imageData;
	NSURL *imageURL;
	UIImage *image;
	NSString *URL;
	
	URL = [@"" stringByAppendingFormat:@"%@%@?GetThumbnail?x=0&y=0&width=60&height=60",slideDirectory,currentSlide];
	imageURL = [NSURL URLWithString:URL];
	imageData = [NSData dataWithContentsOfURL:imageURL];
	image = [[UIImage alloc] initWithData:imageData];
	minimap.image = image;
	[image release];
	
	//Draws the border for the minimap
	[minimap.layer setBorderColor: [[UIColor blackColor] CGColor]];
	[minimap.layer setBorderWidth: 2.0];
	
	//Draws the border for the annotation
	[annotation.layer setBorderColor: [[UIColor blackColor] CGColor]];
	[annotation.layer setBorderWidth: 3.0];
	
	//Draws the border for the description
	[descript.layer setBorderColor: [[UIColor blackColor] CGColor]];
	[descript.layer setBorderWidth: 1.0];
	
	[thumbnail.layer setBorderColor: [[UIColor blackColor] CGColor]];
	[thumbnail.layer setBorderWidth: 1.0];
}

-(void) drawLabels{
	NSArray *components = [listOfAnnos componentsSeparatedByString:@"|"];
	
	for (int i = 0; i < ([components count] - 1); i++) {
		UILabel * tempLabel= [[UILabel alloc] init];
		
		[tempLabel.layer setBorderColor: [[UIColor blackColor] CGColor]];
		[tempLabel.layer setBorderWidth: 2.0];
		[tempLabel.layer setCornerRadius: 10.0];
		
		tempLabel.frame = CGRectMake(10, 
									 5 + (i * 35), 
									 230, 
									 30);
		
		NSArray	*innerComponents = [[components objectAtIndex:i] componentsSeparatedByString:@"title="];
		tempLabel.text = [innerComponents objectAtIndex:1];
		
		tempLabel.textAlignment = UITextAlignmentCenter;
		
		[labelScroll addSubview:tempLabel];

		[tempLabel release];
	}
}

-(void) allocLabels{
	listOfAnnos = [[NSString alloc] init];
	[listOfAnnos retain];
}

//Draws the scrollview with all of the labels
-(void) createLabels:(int)annoCount Title:(NSString *)Title{
	//Creates a temp ImageView to hold the image and store it in the ScrollView
	//UILabel * tempLabel= [[UILabel alloc] init];
	NSString *tempString = [[NSString alloc] initWithString:@""];
	
	//Creates a black border around the image 2 pixels thick
	//[tempLabel.layer setBorderColor: [[UIColor blackColor] CGColor]];
	//[tempLabel.layer setBorderWidth: 2.0];

	if ([Title isEqualToString:@""])
		tempString = @"No title";
	else //Gets the image of the slide as well as returning the height and width of the slide
		tempString = Title;
	
	/*
	if ([Title isEqualToString:@""])
		tempLabel.text = [@"Anno: " stringByAppendingFormat:@"%i",annoCount];
	else //Gets the image of the slide as well as returning the height and width of the slide
		tempLabel.text = Title;
	*/
	 
	listOfAnnos = [listOfAnnos stringByAppendingFormat:@"title=%@|",tempString];
	
	//NSLog(@"%@",listOfAnnos);
	
	//Using widthDist decides how far along the Scrollview the image is
	//tempLabel.frame = CGRectMake(10, 
	//							 10 + ((annoCount-1) * 35), 
	//							 230, 
	//							 30);
	
	//Centres the text
	//tempLabel.textAlignment = UITextAlignmentCenter;
	
	//Creates a black border around the lavel 2 pixels thick
	//[tempLabel.layer setBorderColor: [[UIColor whiteColor] CGColor]];
	//[tempLabel.layer setBorderWidth: 2.0];
	//tempLabel.layer.cornerRadius = 10;
	
	//Adds the label and imageview to the scrollview
	//[labelScroll addSubview:tempLabel];

	//Release the used imageview and label
	//[tempLabel release];
	[tempString release];
}

#pragma mark -
#pragma mark Controls

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	//Gets the position of the last touch on the screen
	NSSet *allTouches = [event allTouches];	
	UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
	CGPoint touchLoc = [touch locationInView:[self view]];
	
	//Number of touches that were on the screen
	switch ([allTouches count]){			
		case 1: {//There was 1 touch on the screen
			switch([touch tapCount])
			{
				case 1: {//Single tap
					if ((touchLoc.y > labelScroll.frame.origin.y) &&
						 (touchLoc.x > labelScroll.frame.origin.x) &&
						 (touchLoc.y < (labelScroll.frame.size.height + labelScroll.frame.origin.y)) &&
						 (touchLoc.x < (labelScroll.frame.size.width + labelScroll.frame.origin.x))) {
						
						selectedAnno = (int)(floor(((touchLoc.y - labelScroll.frame.origin.y) + (int)labelScroll.contentOffset.y)/35));
					
						NSLog(@"%i",selectedAnno);
						
						highlight.frame = CGRectMake(0, 
													 (35 * selectedAnno) + 2, 
													 250, 
													 36);
						
						
						[labelScroll addSubview:highlight];
						[labelScroll sendSubviewToBack:highlight];
						
						[labelScroll setContentOffset:CGPointMake(0, ((35 * selectedAnno) - 50)) animated:YES];		
					}
					//Determines the position of the ScrollView using the touch location and how big it's offset is
					//From that, determine which image has been selected
					//selectedSlideNum = (int)(floor((touchLoc.x - 10 + (int)imageScroll.contentOffset.x)/35));
					
					//highlight.frame = CGRectMake((320 * selectedSlideNum) - 10, 
					//							 0, 
					//							 highlight.frame.size.width, 
					//							 highlight.frame.size.height);
					
					
					//[imageScroll addSubview:highlight];
					//[imageScroll sendSubviewToBack:highlight];
					
					//Scroll the image to the centre of the screen
					//[labelScroll setContentOffset:CGPointMake(0, 10) animated:YES];
				} break;
				case 2: {//Double tap
					if ((touchLoc.y > labelScroll.frame.origin.y) &&
						(touchLoc.x > labelScroll.frame.origin.x) &&
						(touchLoc.y < (labelScroll.frame.size.height + labelScroll.frame.origin.y)) &&
						(touchLoc.x < (labelScroll.frame.size.width + labelScroll.frame.origin.x))) {
						if (numOfAnnos > 0 && (selectedAnno + 1) > 0) {
							selectedAnno = selectedAnno + 1;
							[self done];
						}
					}
				} break;
			}
		} break;
	}
}


//Adds the values from the slide view to the settings view
- (void)addValues:(int)Red Green:(int)Green Blue:(int)Blue Brightness:(int)Brightness Contrast:(int)Contrast Slide:(NSString *)Slide Directory:(NSString *)Directory Sharpen:(int)Sharpen Anno:(bool)Anno Minimap:(bool)Minimap Description:(bool)Description coordX:(int)coordX coordY:(int)coordY Zoom:(float)Zoom;{
	currentSlide = Slide;
	slideDirectory = Directory;
	
		xCoord = coordX;
		yCoord = coordY;
		  zoom = Zoom;
	       red = Red;
         green = Green;
	      blue = Blue;
	brightness = Brightness;
	  contrast = Contrast;
	   sharpen = Sharpen;
	
	    minimapBool = Minimap;
	 annotationBool = Anno;
	descriptionBool = Description;
	
	//Sets the label to the scrollview
	//labelScroll = (UIScrollView *) [self.view viewWithTag:90];
	labelScroll.clipsToBounds = YES;
	labelScroll.delegate = self;
	//Update the imagescroll to allow movement in the x direction to the last slide
	labelScroll.contentSize = CGSizeMake(250, 600);
	//[labelScroll setDelegate:(id<UIScrollViewDelegate>)self];
}

//Updates the sharpen value when the switch is touched
- (IBAction) minimapSwitcher: (UISlider *) sender{
	if (!minimapSwitch.on){	//Switch is on, measuring tool is visible
		minimapBool = FALSE;
		minimap.hidden = YES;
	}
	else{					//Switch is off, measuring tool not is visible
		minimapBool = TRUE;
		minimap.hidden = NO;
	}
}

//Updates the sharpen value when the switch is touched
- (IBAction) annotationSwitcher: (UISlider *) sender{
	if (!annotationSwitch.on){	
		//Switch is on, measuring tool is visible
		annotationBool = FALSE;
		annotation.hidden = YES;
	}
	else{						//Switch is off, measuring tool not is visible
		annotationBool = TRUE;
		annotation.hidden = NO;
	}
}

//Updates the sharpen value when the switch is touched
- (IBAction) descriptionSwitcher: (UISlider *) sender{
	if (!descriptionSwitch.on){	//Switch is on, measuring tool is visible
		descriptionBool = FALSE;
		descript.hidden = YES;
	}
	else{						//Switch is off, measuring tool not is visible
		descriptionBool = TRUE;
		descript.hidden = NO;
	}
}

//Updates the sharpen value when the switch is touched
- (IBAction) sharpSwitch: (UISlider *) sender{
	if (sharpenSwitch.on) //Switch is on, sharpen is applyed
		sharpen = 1;
	else
		sharpen = 0;	  //Switch is off, sharpen is not applyed
	
	[self updateThumbnail];
}

//Updates the red value when the redSlider is moved
- (IBAction) redSlider: (UISlider *) sender{
	red = redSlider.value - 255;
	redField.text = [@"" stringByAppendingFormat:@"%i",red];
	[self updateThumbnail];
}

//Updates the green value when the redSlider is moved
- (IBAction) greenSlider: (UISlider *) sender{
	green = greenSlider.value - 255;
	greenField.text = [@"" stringByAppendingFormat:@"%i",green];
	[self updateThumbnail];
}

//Updates the blue value when the redSlider is moved
- (IBAction) blueSlider: (UISlider *) sender{
	blue = blueSlider.value - 255;
	blueField.text = [@"" stringByAppendingFormat:@"%i",blue];
	[self updateThumbnail];
}

//Updates the brightness value when the redSlider is moved
- (IBAction) brightnessSlider: (UISlider *) sender{
	brightness = brightnessSlider.value - 100;
	brightnessField.text = [@"" stringByAppendingFormat:@"%i",brightness];
	[self updateThumbnail];
}

//Updates the contrast value when the redSlider is moved
- (IBAction) contrastSlider: (UISlider *) sender{
	contrast = contrastSlider.value - 100;
	contrastField.text = [@"" stringByAppendingFormat:@"%i",contrast];
	[self updateThumbnail];
}

//Returns to the Slide View and creates a rect anno
- (IBAction)createRect{	
	[self.delegate CreateRectAnno:self];
}

//Returns to the Slide View and saves the annotations
- (IBAction)saveAnnos{
	[self.delegate SaveAnnos:self];
}

//Returns to the Slide View and loads the annotations
- (IBAction)loadAnnos{
	[self.delegate LoadAnnos:self];
}

//Return to the Slide View
- (IBAction)done{
	//[listOfAnnos release];
	[self.delegate SettingsViewControllerDidFinish:self];
}

//Returns to the main menu from the options menu
- (IBAction)returnToMainMenu{
	[self.delegate SlideReturnToMenu:self];
}

//Restore the attributes to the default
- (IBAction)restoreToDefault{
	red = 0;
	green = 0;
	blue = 0;
	contrast = 0;
	brightness = 0;
	sharpen = 0;
	sharpenSwitch.on = NO;
	
	redField.text = @"0";
	greenField.text = @"0";
	blueField.text = @"0";
	brightnessField.text = @"0";
	contrastField.text = @"0";
	
	redSlider.value = 255;
	greenSlider.value = 255;
	blueSlider.value = 255;
	contrastSlider.value = 100;
	brightnessSlider.value = 100;
	
	descriptionBool = FALSE;
	descript.hidden = YES;
	descriptionSwitch.on = NO;
	minimapBool = TRUE;
	minimap.hidden = NO;
	minimapSwitch.on = YES;
	annotationBool = TRUE;
	annotation.hidden = NO;
	annotationSwitch.on = YES;
	
	[self updateThumbnail];
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
	//Gets the value from the text boxes and convert it to int
	       red = [redField.text intValue];
	     green = [greenField.text intValue];
	      blue = [blueField.text intValue];
	  contrast = [contrastField.text intValue];
	brightness = [brightnessField.text intValue];

	//Prevents the red value going over or under the limits
	if (red > 255)
		red = 255;
	else if (red < -255)
		red = -255;

	//Prevents the blue value going over or under the limits
	if (blue > 255)
		blue = 255;
	else if (blue < -255)
		blue = -255;
	
	//Prevents the green value going over or under the limits
	if (green > 255)
		green = 255;
	else if (green < -255)
		green = -255;
	
	//Prevents the brightness value going over or under the limits
	if (brightness > 100)
		brightness = 100;
	else if (brightness < -100)
		brightness = -100;
	
	//Prevents the contrast value going over or under the limits
	if (contrast > 100)
		contrast = 100;
	else if (contrast < -100)
		contrast = -100;
	
	//Updates the thumbnail
	[self updateThumbnail];
}

#pragma mark -
#pragma mark Updates

//Updates the thumbnail
- (void)updateThumbnail{	
	float ratio;
	float newXCoord;
	float newYCoord;
	float newHeight;
	float newWidth;
	float newZoom;

	ratio = (float)768/305;
	
	newWidth =  768/ratio;
	newHeight = 1024/ratio;
	newXCoord = xCoord/ratio;
	newYCoord = yCoord/ratio;
	newZoom = zoom*ratio;
	
	NSData *imageData;
	NSURL *imageURL;
	UIImage *image;
	NSString *URL;
	
	URL = [@"" stringByAppendingFormat:@"%@%@?GetImage?x=%i&y=%i&width=%i&height=%i&zoom=%.2f&brightness=%i&contrast=%i&r=%i&g=%i&b=%i&sharpen=%i",slideDirectory,currentSlide,(int)newXCoord,(int)newYCoord,(int)newWidth,(int)newHeight,newZoom,brightness,contrast,red,green,blue,sharpen];
	imageURL = [NSURL URLWithString:URL];
	imageData = [NSData dataWithContentsOfURL:imageURL];
	image = [[UIImage alloc] initWithData:imageData];
	thumbnail.image = image;
	[image release];
	
	//thumbnail.url = [NSURL URLWithString:URL];
	
	//Starts downloading the image using the manager, the image will be automatically updated when it has fully downloaded
	//[self.imgMan manage:thumbnail];
}

#pragma mark -
#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
	//[listOfAnnos release];
    [super dealloc];
}

@end
