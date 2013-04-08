    //
//  MainMenuViewController.m
//  iSlideViewer
//
//  Created by Ed on 2/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//http://cluster.ipathimager.co.uk/E:/images/Inview/Slide%20Repository/CervixHisto_1/
//http://143.117.148.59/C:/Virtual%20Slides/Cervix%20Tissue/SVS_Trancate_JPEG/

#import "MainMenuViewController.h"
#import "iSlideViewerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "math.h"
#import "AppScrollView.h"
#import "HJMOFileCache.h"

@implementation MainMenuViewController

@synthesize delegate, imageScroll, historyButton, numOfSlides, drawnSlides, selectedSlideNum, highlight, slideDirectory, dir, slideArray, loadingLight, loadingStatus, imgMan, drawingBool, imageArray;

#pragma mark -
#pragma mark View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	drawnSlides = 0;
	numOfSlides = 0;
	
	drawingBool = FALSE;
	historyButton.enabled = NO;
	
	[self createImageScroll];
	
	self.imgMan = [[[HJObjManager alloc] init] autorelease];
	
	slideArray = [[NSMutableArray alloc] init];
	imageArray = [[NSMutableArray alloc] init];
	
	//dir.text = @"http://143.117.148.59/C:/Virtual%20Slides/Cervix%20Tissue/SVS_Trancate_JPEG/";
	//dir.text = @"http://172.16.1.20/C:/images/";
	dir.text = @"http://cluster.ipathimager.co.uk/E:/images/Inview/Slide%20Repository/CervixHisto_1/";
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"0"])
		historyButton.enabled = YES;
	
	/*
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"0"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"1"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"2"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"3"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"4"];
	 [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"9"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"10"];
	
	
	NSError *error;
	NSString* iPadID = [UIDevice currentDevice].uniqueIdentifier;
	NSString* test = @"1234tellmethatyoulovememore";
	NSString* directory = [ NSString stringWithFormat: @"/Users/ed/Desktop/slideinfo/test.txt"];
	//NSString* directory = [ NSString stringWithFormat: @"//143.117.148.61/C$/ipadslide/%@.txt",iPadID];
	
	//NSString* derp = [[NSString alloc] initWithContentsOfFile:directory];
	BOOL ok = [test writeToFile:directory atomically:YES encoding:NSUnicodeStringEncoding error:&error];
	
	NSLog(@"%@",derp);
	
	[derp release];
	
	if (ok) 
		NSLog(@"TRUE");
	else
		NSLog(@"FALSE");

	*/
	//Calls drawSlides every .1 seconds
	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self
								   selector:@selector(drawSlides) userInfo:Nil
									repeats:YES];
}

//Method used to draw each of the thumbnails
- (void)drawSlides {
	if (drawingBool) {	//If there are thumbnails to draw
		if (drawnSlides < numOfSlides) {	//If there are less slides drawn than slides
			[self createSlides];
			drawnSlides++;
		}
		else {	//Else there are no more slides to draw
			loadingLight.hidden = TRUE;
			loadingStatus.hidden = TRUE;
			drawingBool = FALSE;
		}
	}
}

#pragma mark -
#pragma mark Controls

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	//Gets the position of the last touch on the screen
	NSSet *allTouches = [event allTouches];	
	UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
	CGPoint touchLoc = [touch locationInView:[self view]];
	
	if (numOfSlides > 0) {	//Can only click if there are slides to select
		//Number of touches that were on the screen
		switch ([allTouches count]){			
			case 1: {//There was 1 touch on the screen
				switch([touch tapCount])
				{
					case 1: {//Single tap
						//Determines the position of the ScrollView using the touch location and how big it's offset is
						//From that, determine which image has been selected
						selectedSlideNum = (int)(floor((touchLoc.x - 20 + (int)imageScroll.contentOffset.x)/320));
						
						highlight.frame = CGRectMake((320 * selectedSlideNum) - 10, 
													 0, 
													 highlight.frame.size.width, 
													 highlight.frame.size.height);
						
						
						[imageScroll addSubview:highlight];
						[imageScroll sendSubviewToBack:highlight];
						
						//Scroll the image to the centre of the screen
						[imageScroll setContentOffset:CGPointMake(((320 * selectedSlideNum) - 234), 0) animated:YES];
					} break;
					case 2: {//Double tap
						if ([slideArray count] > 0) {
							[self openSlide];
						}
					} break;
				}
			} break;
		}
	}
}

//Button to open up a list of previous directorys
- (IBAction)openHistory{
	HistoryViewController *controller = [[HistoryViewController alloc] initWithNibName:@"HistoryViewController"bundle:nil];
	
	//Creates Model View
	controller.modalPresentationStyle = UIModalPresentationFullScreen;	
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	controller.delegate = self;
	
	NSMutableArray *tempArray = [[[NSMutableArray alloc] init] autorelease];
	
	//Gets the history saved on this iPad
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	NSString *tagString;
	NSString *URLString;
	int savedPosition = 0;
	
	//Loops through the saved links and adds them to the list
	while (TRUE) {
		//Gets the string that is saved at that saved position
		tagString = [@"" stringByAppendingFormat: @"%d",savedPosition];
		URLString = [prefs stringForKey:tagString];
		
		if (URLString == NULL){	//If the position is empty then all the history has been added
			[prefs setObject:URLString forKey:tagString];
			break;
		}
		else{	//Else add this link to the list and loops around to check the next position
			[tempArray addObject:URLString];
			savedPosition++;
		}
	}
	
	//Sets up the list of previous links
	[controller testSetup:tempArray];
	
	//Brings up the list of previous links
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

//Button to get slides from the typed in directory
- (IBAction)getSlide{
	
	//Removes everything from the scroll view
	while([imageScroll.subviews count] > 0) {
		[[[imageScroll subviews] objectAtIndex:0] removeFromSuperview];
	}
	
	//Removes all the images from the imagearray
	while ([imageArray count] > 0) {
		[imageArray removeLastObject];
	}
	
	//Removes all the details from the slidearray
	while ([slideArray count] > 0) {
		[slideArray removeLastObject];
	}
	
	//Returns the number of slides and number of drawn slides to nill
	numOfSlides = 0;
	drawnSlides = 0;
	
	//The slide directory is now null
	slideDirectory = NULL;
	
	//Accesses the saved data on the URL
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	NSString *URLChecker;
	NSString *URL;
	NSURL *stringURL;
	NSData *stringData;
	NSString *string;
	
	loadingLight.hidden = NO;
	loadingStatus.hidden = NO;
	loadingStatus.text = @"Checking directory for images...";
	
	NSArray *components = [dir.text componentsSeparatedByString:@" "];
	URLChecker = [components objectAtIndex:0];
	
	//Converts spaces to %20's so that the link will work
	for (int i = 1; i < [components count]; i++) {
		URLChecker = [URLChecker stringByAppendingString:@"%20"];
		URLChecker = [URLChecker stringByAppendingFormat:@"%@",[components objectAtIndex:i]];
	}
	
	//Updates the directory text field with the updated directory
	dir.text = URLChecker;
	
	NSString *tagString;
	NSString *URLString;
	int savedPosition = 0;
	BOOL addUrl = FALSE;
	
	//Adds the directory to history
	while (TRUE) {	
		//Checks the current position
		tagString = [@"" stringByAppendingFormat: @"%d",savedPosition];
		URLString = [prefs stringForKey:tagString];
	
		if (URLString == NULL){	//If the position is empty, add the directory at this position
			addUrl = TRUE;
			break;
		}
		else if ([URLChecker isEqualToString:URLString])	//Else if the directory is already in the history, break
			break;
		else	//Else check the next position
			savedPosition++;
	}
	
	slideDirectory = dir.text;
	
	//Using the slide, gets the info for the slide and allocates it to a string
	URL = [@"" stringByAppendingFormat:@"%@?DIR",slideDirectory];
	
	stringURL = [NSURL URLWithString:URL];
	stringData = [NSData dataWithContentsOfURL:stringURL];
	string = [[NSString alloc] initWithBytes:[stringData bytes] length:[stringData length] encoding:NSUTF8StringEncoding];
	
	//Parses the string in an array of components
	components = [string componentsSeparatedByString:@"|dir|"];
	[string release];
	
	//Ignores the empty space at the end of the count
	int count = [components count] - 1;
	
	//Gets all the different files in the directory and parses it
	components = [[components objectAtIndex:count] componentsSeparatedByString:@"\n"];
	count = [components count] - 1;
	
	loadingStatus.text = @"Downloading images...";
	
	//Loops through all the files and searchs for .svs and .ndpi files
	for (int i = 1; i < count; i++) {
		//BOOL used to check if the slide has already been added to the list
		BOOL alreadyExists = FALSE;
		
		//Checks the extension of the file and check if it is either svs or a ndpi file type
		string = [components objectAtIndex:i];
		NSArray *innerComponents = [string componentsSeparatedByString:@"."];
		if ([[innerComponents objectAtIndex:1] isEqualToString:@"svs|file|"]) {
			for (int i = 1; i < numOfSlides; i++) {	//Loops through the files that are already in the list
				NSArray *slideComponents = [[slideArray objectAtIndex:i] componentsSeparatedByString:@"|SLIDENAME|"];
				//Gets the name of the slide and the slide extension
				NSString *tempDir = [slideComponents objectAtIndex:0];
				NSString *tempSlideName = [slideComponents objectAtIndex:1];
				
				//If there is a usable image in this directory, and it hasn't been already added, add it to the list of directorys
				if (addUrl) {
					[prefs setObject:URLChecker forKey:tagString];
					addUrl = FALSE;
				}
				
				//Checks to see if the slide has already been added to the slide list
				if ([tempDir isEqualToString:slideDirectory] && 
					[tempSlideName isEqualToString:[innerComponents objectAtIndex:0]]) {
					
					alreadyExists = TRUE;
					break;
				}
			}
			
			//If the slide doesn't already exist in the slide list, add it to the scroll view
			if (!alreadyExists) {
				NSString *tempString = [slideDirectory stringByAppendingString:@"|SLIDENAME|"];
				tempString = [tempString stringByAppendingString:[innerComponents objectAtIndex:0]];
				tempString = [tempString stringByAppendingString:@"|SLIDENAME|.svs"];
			
				//Add the directory of the slide, name and extension to the array
				[slideArray addObject:tempString];
			
				numOfSlides++;
			}
		}
		else if ([[innerComponents objectAtIndex:1] isEqualToString:@"ndpi|file|"]) { // Same as above but for NDPI files instead of SVS
			for (int i = 1; i < numOfSlides; i++) {
				NSArray *slideComponents = [[slideArray objectAtIndex:i] componentsSeparatedByString:@"|SLIDENAME|"];
				NSString *tempDir = [slideComponents objectAtIndex:0];
				NSString *tempSlideName = [slideComponents objectAtIndex:1];
				
				if (addUrl) {
					[prefs setObject:URLChecker forKey:tagString];
					addUrl = FALSE;
				}
				
				if ([tempDir isEqualToString:slideDirectory] && 
					[tempSlideName isEqualToString:[innerComponents objectAtIndex:0]]) {
					alreadyExists = TRUE;
					
					break;
				}
			}
			
			if (!alreadyExists) {
				NSString *tempString = [slideDirectory stringByAppendingString:@"|SLIDENAME|"];
				tempString = [tempString stringByAppendingString:[innerComponents objectAtIndex:0]];
				
				tempString = [tempString stringByAppendingString:@"|SLIDENAME|.ndpi"];
				
				[slideArray addObject:tempString];
				numOfSlides++;
			}
		}
	}
	//Start drawing the slides on the scroll view
	drawingBool = TRUE;
	
	//Create the size of the scroll view
	imageScroll.contentSize = CGSizeMake(numOfSlides * 320, 300);
	
	[slideDirectory retain];
}

//Creates the MainMenu view
- (void)openSlide {
	NSArray *slideComponents = [[slideArray objectAtIndex:(selectedSlideNum)] componentsSeparatedByString:@"|SLIDENAME|"];
	NSString *tempSlideName = [slideComponents objectAtIndex:1];
	NSString *tempSlideEx = [slideComponents objectAtIndex:2];
	
	SlideViewController *controller = [[SlideViewController alloc] initWithNibName:@"SlideViewController"bundle:nil];
	
	//Creates Model View
	controller.modalPresentationStyle = UIModalPresentationFullScreen;	
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	controller.delegate = self;
	
	[controller slideSetup:tempSlideName
				 extension:tempSlideEx
				 directory:slideDirectory];
	
	//Presents the animated Modal View
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

//Called when returned to main menu from the viewer
- (void)SlideViewControllerDidFinish:(SlideViewController *)controller{
	//Deallocates everything that was used in the viewer
	//[controller dealloc];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)HistoryViewControllerCancel:(HistoryViewController*)controller
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)HistoryViewControllerLoadHistory:(HistoryViewController*)controller directory:(NSString *)directory
{
	slideDirectory = directory;
	[slideDirectory retain];
	dir.text = directory;
	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

#pragma mark -
#pragma mark Memory management

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

//Creates the image scroller
-(void) createImageScroll{
	imageScroll = (UIScrollView *) [self.view viewWithTag:1];
	imageScroll.clipsToBounds = YES;
	imageScroll.delegate = self;
	//Gives the paged effect. Find out if prefer it on or offS
	//imageScroll.pagingEnabled = YES;
	
	//Update the imagescroll to allow movement in the x direction to the last slide
	imageScroll.contentSize = CGSizeMake(numOfSlides * 320, 300);
}

//Draws an image and label for each slide in the array
-(void) createSlides{
	//Gets the directory, slide name and extension
	NSArray *slideComponents = [[slideArray objectAtIndex:(drawnSlides)] componentsSeparatedByString:@"|SLIDENAME|"];
	NSString *tempSlideDirectory = [slideComponents objectAtIndex:0];
	NSString *tempSlideName = [slideComponents objectAtIndex:1];
	NSString *tempSlideExtension = [slideComponents objectAtIndex:2];
	
	//Creates a temp ImageView to hold the image and store it in the ScrollView
	HJManagedImageV * tempImageView = [[HJManagedImageV alloc] init];
	
	//Creates a black border around the image 2 pixels thick
	[tempImageView.layer setBorderColor: [[UIColor blackColor] CGColor]];
	[tempImageView.layer setBorderWidth: 2.0];
	
	//Gets the image of the slide as well as returning the height and width of the slide
	[self getThumbnail:tempImageView slide:tempSlideName directory:tempSlideDirectory extension:tempSlideExtension];
	
	
	//Using widthDist decides how far along the Scrollview the image is
	tempImageView.frame = CGRectMake((320 * (drawnSlides)) + (300 - tempImageView.frame.size.width)/2, 
									 ((300 - tempImageView.frame.size.height)/2) + 20, 
									 tempImageView.frame.size.width, 
									 tempImageView.frame.size.height);
	
	//Creates a temp Label to hold the title of the slide
	UILabel * tempLabel = [[UILabel alloc] init];
	//Sets the text to the slide name
	tempLabel.text = tempSlideName;
	//Centres the text
	tempLabel.textAlignment = UITextAlignmentCenter;
	
	//Determines the size of the label required with the given text
	CGSize labelSize = [tempLabel.text sizeWithFont:tempLabel.font
								  constrainedToSize:CGSizeMake(250, 50)
									  lineBreakMode:UILineBreakModeWordWrap];	
	
	//Creates the label and positions it bottom centre of the imageview
	tempLabel.frame = CGRectMake(tempImageView.frame.origin.x + tempImageView.frame.size.width/2 - labelSize.width/2, 
								 tempImageView.frame.origin.y + tempImageView.frame.size.height, 
								 labelSize.width + 10, 
								 labelSize.height + 4);
	
	//Creates a black border around the lavel 2 pixels thick
	[tempLabel.layer setBorderColor: [[UIColor blackColor] CGColor]];
	[tempLabel.layer setBorderWidth: 2.0];
	tempLabel.layer.cornerRadius = 6;
	
	//Adds the label and imageview to the scrollview
	[imageScroll addSubview:tempImageView];
	[imageScroll addSubview:tempLabel];
	
	[imageArray addObject:tempImageView];
	
	//Release the used imageview and label
	[tempImageView release];
	[tempLabel release];
}

//Gets the image for the thumbnail for each slide
-(void)getThumbnail:(HJManagedImageV *)imageViewer slide:(NSString *)slide directory:(NSString *)directory extension:(NSString *)extension;{
	
	NSString *URL;
	NSURL *stringURL;
	NSData *stringData;
	NSString *string;
	CGPoint slideSize;
	float thumbNailZoom;
	
	//Using the slide, gets the info for the slide and allocates it to a string
	URL = [@"" stringByAppendingFormat:@"%@%@%@?GetInfo?",directory,slide,extension];
	//URL = [@"http://cluster.ipathimager.co.uk/E:/images/Inview/Slide%20Repository/CervixHisto_1/" stringByAppendingFormat:@"%@.svs?GetInfo?",slide];
	
	//NSLog(@"%@",URL);
	
	stringURL = [NSURL URLWithString:URL];
	stringData = [NSData dataWithContentsOfURL:stringURL];
	string = [[NSString alloc] initWithBytes:[stringData bytes] length:[stringData length] encoding:NSUTF8StringEncoding];
	
	//Parses the string in an array of components
	NSArray *components = [string componentsSeparatedByString:@","];
	[string release];
	
	//Gets the values that correspond to the items that is being searched for, namely Width, Height and Mag
	for (int i = 0; i < [components count]; i++) {
		string = [components objectAtIndex:i];
		NSArray *innerComponents = [string componentsSeparatedByString:@"="];
		if ([[innerComponents objectAtIndex:0] isEqualToString:@"width"]) {
			slideSize.x = [[innerComponents objectAtIndex:1] doubleValue];
		}
		else if ([[innerComponents objectAtIndex:0] isEqualToString:@"height"]) {
			slideSize.y = [[innerComponents objectAtIndex:1] doubleValue];
		}
	}
	
	//If the size of the slide is 0, then the connect to the server has failed and return the following error message
	if (slideSize.x == 0){
		UIAlertView *error = [[UIAlertView alloc] initWithTitle: @"Network error" message: @"Error receiving data from the server" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		[error show];
		[error release];
	} 
	else {
		
		//Finds which dimension is the biggest, and scales it down to 300
		if (slideSize.x > slideSize.y)
			thumbNailZoom = (slideSize.x/300);
		else 
			thumbNailZoom = (slideSize.y/300);		
		
		
		//Applys the scaling factor to both the height and width so to avoid stretching
		float thumbNailHeight = slideSize.y / thumbNailZoom;
		float thumbNailWidth = slideSize.x / thumbNailZoom;
		
		//Gets the URL and adds it to the imageview
		URL = [@"" stringByAppendingFormat:@"%@%@%@?GetThumbnail?x=0&y=0&width=%i&height=%i",directory,slide,extension,(int)thumbNailWidth,(int)thumbNailHeight];
		imageViewer.url = [NSURL URLWithString:URL];
		
		//Starts downloading the image using the manager, the image will be automatically updated when it has fully downloaded
		[self.imgMan manage:imageViewer];
		
		//Draws the frame of the image
		imageViewer.frame = CGRectMake(0, 
									   0, 
									   thumbNailWidth, 
									   thumbNailHeight);
	}
}

@end