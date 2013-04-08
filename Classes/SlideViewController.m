    //
//  SlideViewController.m
//  iSlideViewer
//
//  Created by Ed on 2/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SlideViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Annotation.h"
#import "math.h"
#import "HJMOFileCache.h"

HJManagedImageV *imageArray[13][9];
Annotation *annoArray[20];	//Max Annotations is 20
int rankArray[9][12];
int rankGridPixelCacheArray[5];
int rankGridPixelCacheTimesArray[5];
BOOL sharpFlagArray[9][12];

@implementation SlideViewController

@synthesize delegate, showDescript, buttonBG, descriptionVis, slideDescription, tileSize, screenWidth, screenHeight, miniMap, miniMapView, currentSlideCoord, description, miniMapZoom, maxSlideCoord, maxMag, currentSlide, slideCoord, arrayPosition, currentRank, currentZoom, previousZoom, previousTouch, centrePoint, selectedTile, touchDistance, tileDisplacement, zoomBool, annoCreation, annoCount, red, green, blue, brightness, contrast, sharpen, transition, selectedAnno, edit, annoHidden, measureButton, measureBool, measureLine, measureDistance, startPoint, MPP, MPPDistance, background, X1BarButton, X5BarButton, X10BarButton, X20BarButton, X40BarButton, HUDBarButton, brightnessField, brightnessSlider, barTitle, movedBool, totalDisplacement, zoomTo, tempRatio, targetPoint, tempZoom, zoomAnimCount, redrawGrid, updateGrid, drawnLine, toolBar, slideDirectory, imgMan;

#pragma mark -
#pragma mark Setup

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.imgMan = [[[HJObjManager alloc] init] autorelease];
	
	[NSTimer scheduledTimerWithTimeInterval:0 target:self
								   selector:@selector(update) userInfo:Nil
									repeats:YES];
}

//Sets the currentslide to the selected slide from the main menu
-(void) slideSetup:(NSString *)slide extension:(NSString *)extension directory:(NSString *)directory;{
	red = 0;
	green = 0;
	blue = 0;
	contrast = 0;
	brightness = 0;
	MPP = 0.2508;
	annoCount = 0;
	selectedAnno = 0;
	zoomAnimCount = 0;
	
	screenWidth = 768;
	screenHeight = 1024;
	tileSize = 256;
	
	transition = FALSE;
	measureBool = FALSE;
	movedBool = TRUE;
	redrawGrid = TRUE;
	updateGrid = FALSE;
	drawnLine = FALSE;
	descriptionVis = FALSE;
	
	self.currentSlide  = [slide stringByAppendingString:extension];
	self.slideDirectory = directory;
	
	NSLog(@"start");
	
	[currentSlide retain];
	
	arrayPosition.x = 1;
	arrayPosition.y = 1;
	annoCount = 1;
	slideCoord.x = 0;
	slideCoord.y = 0;
	
	//measureLine = [[Line alloc] init];
	//measureLine.frame = CGRectMake(0, 0, 0, 0);
	//measureLine.opaque = NO;
	//[self.view addSubview:measureLine];
	//[measureLine release];
	
	[self buildArray];
	[self getInfo];
	[self drawBorders];	
	
	NSArray *components = [currentSlide componentsSeparatedByString:@"."];
	
	//NSString* infoDirectory = [ NSString stringWithFormat: @"%@.txt",[components objectAtIndex:0]];
	//NSString* fileContents = [[NSString alloc] initWithContentsOfFile:infoDirectory];
	//NSString* fileContents = [[NSString alloc] initWithContentsOfFile:@"CHCCase04.txt"];
	
	NSString* path = [[NSBundle mainBundle] pathForResource:[components objectAtIndex:0]
													 ofType:@"txt"];
	
	NSString* fileContents = [NSString stringWithContentsOfFile:path
													   encoding:NSUnicodeStringEncoding
														  error:NULL];
	
	components = [fileContents componentsSeparatedByString:@"|"];
	
	NSString* tissue = [components objectAtIndex:0];
	NSString* gender = [components objectAtIndex:1];
	NSString* age = [components objectAtIndex:2];
	NSString* clinicalinfo = [components objectAtIndex:3];
	NSString* descript = [components objectAtIndex:4];
	NSString* diagnosis = [components objectAtIndex:5];
	
	components = [tissue componentsSeparatedByString:@"="];
	tissue = [components objectAtIndex:1];
	components = [gender componentsSeparatedByString:@"="];
	gender = [components objectAtIndex:1];
	components = [age componentsSeparatedByString:@"="];
	age = [components objectAtIndex:1];
	components = [clinicalinfo componentsSeparatedByString:@"="];
	clinicalinfo = [components objectAtIndex:1];
	components = [descript componentsSeparatedByString:@"="];
	descript = [components objectAtIndex:1];
	components = [diagnosis componentsSeparatedByString:@"="];
	diagnosis = [components objectAtIndex:1];
	
	NSString* fullDescription = [ NSString stringWithFormat:@"Tissue:\t\t\t\t\tGender:\t\t\t\t\tAge:\n%@\t\t\t\t\t%@\t\t\t\t\t\%@\n\nClinical Information:\n%@\n\nDescription:\n%@\n\nDiagnosis:\n%@", tissue, gender, age, clinicalinfo, descript, diagnosis];
	//slideDescription.text = @"Tissue:\ntissuetext\n\nGender:\nGendertext\n\nAge:\nagetext\n\nClinical Information:\nclininfotext\n\nDescription:\ntescriptiontext\n\nDiagnosis:\nDiagnosistext";
	slideDescription.text = fullDescription;
	//barTitle.title = @"J_13b.svs";
	
	//barTitle.title = currentSlide;
}

//Creates a 2D array for holding the grid of slides, attaching each element to the corrosponding imageview in the UIBuilder
-(void) buildArray{
	
	//NSString *tagString;
	//int tagNum;
	
	//For loop cycles trhough the whole array, getting each element
	for (int i = 1; i < 13; i++) {
		for (int j = 1; j < 10; j++) {
			//Gets the current tag using i and j and converts it to an int
			//tagString = [@"" stringByAppendingFormat: @"%d%d",i,j];
			//tagNum = [tagString intValue];
			//Attachs the current element in the array to the correct Imageview in the UIBuilder
			//imageArray[i][j] = (UIImageView *) [self.view viewWithTag:tagNum];
			imageArray[i][j] = [[[HJManagedImageV alloc] init] autorelease];
			[self.view addSubview:imageArray[i][j]];
			[self.view sendSubviewToBack:imageArray[i][j]];
		}
	}
}

//Creates the minimap and gets the info regarding the current slide
-(void) getInfo{
	NSString *URL;
	NSURL *stringURL;
	NSData *stringData;
	NSString *string;
	
	//Using the slide, gets the info for the slide and allocates it to a string
	URL = [@"" stringByAppendingFormat:@"%@%@?GetInfo?",slideDirectory,currentSlide];
	
	NSLog(@"Slide Directory: %@",slideDirectory);
	NSLog(@"Slide Name: %@",currentSlide);
	
	stringURL = [NSURL URLWithString:URL];
	stringData = [NSData dataWithContentsOfURL:stringURL];
	string = [[NSString alloc] initWithBytes:[stringData bytes] length:[stringData length] encoding:NSUTF8StringEncoding];
	
	NSArray *components = [string componentsSeparatedByString:@","];
	[string release];
	
	//Get the height, width and zoom from the string
	for (int i = 0; i < [components count]; i++) {
		string = [components objectAtIndex:i];
		NSArray *innerComponents = [string componentsSeparatedByString:@"="];
		if ([[innerComponents objectAtIndex:0] isEqualToString:@"width"]) {
			maxSlideCoord.x = [[innerComponents objectAtIndex:1] doubleValue];
		}
		else if ([[innerComponents objectAtIndex:0] isEqualToString:@"height"]) {
			maxSlideCoord.y = [[innerComponents objectAtIndex:1] doubleValue];
		}
		else if ([[innerComponents objectAtIndex:0] isEqualToString:@"mag"]) {
			maxMag = [[innerComponents objectAtIndex:1] doubleValue];
		}
	}
	
	//If the maxMag is 0 that means there was a failure to get any info, so it returns this error message
	if (maxMag == 0){
		UIAlertView *error = [[UIAlertView alloc] initWithTitle: @"Network error" message: @"Error receiving data from the server" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		[error show];
		[error release];
	}
	else {
		//Sets the current zoom to the max zoom
		currentZoom = maxMag;
		
		//Works out the larger axis and scales the whole image accordingly
		if (maxSlideCoord.x > maxSlideCoord.y)
			miniMapZoom = (maxSlideCoord.x/200);
		else
			miniMapZoom = (maxSlideCoord.y/200);		
		
		//Works out the dimensions for the minimap
		float miniMapHeight = maxSlideCoord.y / miniMapZoom;
		float miniMapWidth = maxSlideCoord.x / miniMapZoom;
		float miniMapx = miniMap.frame.origin.x + 200 - miniMapWidth;
		float miniMapy = miniMap.frame.origin.y;
		
		//Draws the minimap
		miniMap.frame = CGRectMake(miniMapx,
								   miniMapy,
								   miniMapWidth,
								   miniMapHeight);
		
		NSData *imageData;
		NSURL *imageURL;
		UIImage *image;
		
		//Then gets the image itself and applys it to the minimap
		URL = [@"" stringByAppendingFormat:@"%@%@?GetThumbnail?x=0&y=0&width=%i&height=%i",slideDirectory,currentSlide,(int)miniMapWidth,(int)miniMapHeight];
		imageURL = [NSURL URLWithString:URL];
		imageData = [NSData dataWithContentsOfURL:imageURL];
		image = [[UIImage alloc] initWithData:imageData];
		miniMap.image = image;
		[image release];
		
		background.frame = CGRectMake(0,
									  0,
									  maxSlideCoord.x / maxMag,
									  maxSlideCoord.y / maxMag);
		
		URL = [@"" stringByAppendingFormat:@"%@%@?GetThumbnail?x=0&y=0&width=%i&height=%i",slideDirectory,currentSlide,(int)((maxSlideCoord.x / maxMag)/5),(int)((maxSlideCoord.y / maxMag)/5)];
		imageURL = [NSURL URLWithString:URL];
		imageData = [NSData dataWithContentsOfURL:imageURL];
		image = [[UIImage alloc] initWithData:imageData];
		background.image = image;
		[image release];
		
		[self.view addSubview:background];
		[self.view sendSubviewToBack:background];
	}
}

//Draws the borders around the minimap, viewer and mag label
-(void) drawBorders{
	//Adds a black border 2 pixels thick around the minimap
	[miniMap.layer setBorderColor: [[UIColor blackColor] CGColor]];
	[miniMap.layer setBorderWidth: 2.0];
	
	//Adds a black border 1 pixel thick around the view that shows the current location on the minimap
	[miniMapView.layer setBorderColor: [[UIColor blackColor] CGColor]];
	[miniMapView.layer setBorderWidth: 1.0];		
	miniMapView.layer.cornerRadius = 2;
	
	//Adds a black border 2 pixels thick around the description label
	[description.layer setBorderColor: [[UIColor blackColor] CGColor]];
	[description.layer setBorderWidth: 2.0];
	description.layer.cornerRadius = 10;
	
	//Adds a black border 2 pixels thick around the MPPDistance label
	[MPPDistance.layer setBorderColor: [[UIColor blackColor] CGColor]];
	[MPPDistance.layer setBorderWidth: 2.0];
	MPPDistance.layer.cornerRadius = 10;
}

#pragma mark -
#pragma mark Update

//Update cycle for this slide viewer
-(void) update{
	//background.frame = CGRectMake(-slideCoord.x,
	//							  -slideCoord.y,
	//							  maxSlideCoord.x / currentZoom,
	//							  maxSlideCoord.y / currentZoom);
	
	//NSLog(@"Slide Directory: %@",slideDirectory);
	//NSLog(@"Slide Name: %@",currentSlide);
	
	
	//for (int i = 1; i < 13; i++) {
	//	for (int j = 1; j < 10; j++) {
	//		if (imageArray[i][j].image == NULL) {
	//			[self.imgMan manage:imageArray[i][j]];
	//		}
	//	}
	//}
	
	if (!transition) {//Prevents the slideviewer updating while the viewer is updating
		
		if (descriptionVis){
			if (slideDescription.frame.origin.x < 0){
				slideDescription.frame = CGRectMake(slideDescription.frame.origin.x+2, 
													slideDescription.frame.origin.y, 
													slideDescription.frame.size.width, 
													slideDescription.frame.size.height);
			}
		}
		else{
			if (slideDescription.frame.origin.x > -728){
				slideDescription.frame = CGRectMake(slideDescription.frame.origin.x-2, 
													slideDescription.frame.origin.y, 
													slideDescription.frame.size.width, 
													slideDescription.frame.size.height);
			}
		}

		buttonBG.frame = CGRectMake(slideDescription.frame.origin.x+slideDescription.frame.size.width, 
									buttonBG.frame.origin.y, 
									buttonBG.frame.size.width, 
									buttonBG.frame.size.height);
		
		showDescript.frame = CGRectMake(slideDescription.frame.origin.x+slideDescription.frame.size.width, 
										showDescript.frame.origin.y, 
										showDescript.frame.size.width, 
										showDescript.frame.size.height);

		
		if (zoomTo){
			[self zoomToPoint];
		}
		else{
			
			for (int i = 1; i < 13; i++) {
				for (int j = 1; j < 10; j++) {
					if (!sharpFlagArray[j-1][i-1]) {
						//imageArray[i][j].hidden = YES;
						//NSLog(@"Changing Alpha");
						imageArray[i][j].alpha = 0;
						//imageArray[i][j].image = NULL;
					}
					else {
						//imageArray[i][j].hidden = NO;
						if (imageArray[i][j].alpha < 1) {
							imageArray[i][j].alpha = imageArray[i][j].alpha + 0.25;
						}
					}
				}
			}
			
			//Make sure the negative is priority if the image is too small
			if (slideCoord.x < 0)
				slideCoord.x = 0;
			if (slideCoord.y < 0)
				slideCoord.y = 0;
			
			//NSLog(@"%i %i", (int)slideCoord.x, (int)slideCoord.y);
			
			//Updates the annotations
			for (int i = 1; i < annoCount; i++) {
				[annoArray[i] update:slideCoord Zoom:currentZoom];
			}
			
			if (maxMag != 0){ //Prevents crash if the server failed to get the image		
				//Updates the position of the slide
				float currentpositionX = (slideCoord.x + (screenWidth/2)) * currentZoom;
				float currentpositionY = (slideCoord.y + (screenHeight/2)) * currentZoom;
				
				//Updates the description for this slide
				description.text = [NSString stringWithFormat:@" MPP: %.4f\n Slide Size X: %i\n Slide Size Y: %i\n Current Position X: %i\n Current Position Y: %i", (float)(MPP * currentZoom), (int)maxSlideCoord.x, (int)maxSlideCoord.y, (int)currentpositionX, (int)currentpositionY];
				
				//Used to convert the slideCoord to the maxslide size
				float minZoom = (currentZoom/maxMag);
				//Holds the ratio between the minimap's zoom and the slide's max zoom
				float zoomRatio = (miniMapZoom/maxMag);
				
				//Works out the X Y Height and Width for the view on the minimap
				float miniMapx = miniMap.frame.origin.x + ((slideCoord.x * minZoom)/zoomRatio);
				float miniMapy = miniMap.frame.origin.y + ((slideCoord.y * minZoom)/zoomRatio);
				float miniMapWidth = (screenWidth * minZoom)/zoomRatio;
				float miniMapHeight = (screenHeight * minZoom)/zoomRatio;
				
				//Prevents the view's width on the minimap going outisde of the frame on the minimap itself
				if ( (miniMapWidth + miniMapx) > (miniMap.frame.origin.x + miniMap.frame.size.width) )
					miniMapWidth = ((miniMap.frame.origin.x + miniMap.frame.size.width) - miniMapx);
				
				//Prevents the view's height on the minimap going outisde of the frame on the minimap itself
				if ( (miniMapHeight + miniMapy) > (miniMap.frame.origin.y + miniMap.frame.size.height) )
					miniMapHeight = ((miniMap.frame.origin.y + miniMap.frame.size.height) - miniMapy);
				
				//Arbitraryly sets the min size of the view on the minimap 
				if (miniMapWidth < 5 || miniMapHeight < 4){
					miniMapWidth = 4;
					miniMapHeight = 5;
				}
				
				//Creates the view on the minimap
				miniMapView.frame = CGRectMake(miniMapx, 
											   miniMapy, 
											   miniMapWidth, 
											   miniMapHeight);
			}
			
			if (redrawGrid)
				[self redrawTheGrid];
			if (updateGrid)
				[self updateTheGrid];
			
			//for (int i = 0; i < 12; i++) {
			//	for (int j = 0; j < 9; j++) {
			//		if (imageArray[i+1][j+1].image == NULL) {
			//			imageArray[i+1][j+1].frame = CGRectMake(0, 
			//												0, 
			//												0, 
			//												0);
			//		}
			//	}
			//}

		}
	}
}

//Called when completely redrawing the grid
-(void)redrawTheGrid{
	
	redrawGrid = FALSE;
	
	currentRank = 0;
	arrayPosition.x = 1;
	arrayPosition.y = 1;
	
	NSLog(@"Reset Grid");
	for (int i = 0; i < 12; i++) {
		for (int j = 0; j < 9; j++) {
			//Resets the default position of the grid			
			sharpFlagArray[j][i] = FALSE;
			imageArray[i+1][j+1].frame = CGRectMake(imageArray[5][4].frame.origin.x + ((j-3) * tileSize), 
													imageArray[5][4].frame.origin.x + ((i-4) * tileSize), 
													0, 
													0);
			imageArray[i+1][j+1].image = NULL;
		}
	}
	
	updateGrid = TRUE;
}

//Called when updating the grid but not redrawing it
//Called when updating the grid but not redrawing it
-(void)updateTheGrid{
	BOOL Drawn = FALSE;
	
	//NSLog(@"Images for centre tiles");	
	for (int i = 4; i < 8 && currentRank == 0 && !Drawn; i++) {
		for (int j = 3; j < 6; j++) {
			if (!sharpFlagArray[j][i]) {
				if (i == 4 && j ==3) {
					[self getImage:imageArray[i+1][j+1] 
							 xcord:(int)slideCoord.x
							 ycord:(int)slideCoord.y
							height:tileSize
							 width:tileSize
							  zoom:currentZoom];
					
					imageArray[i+1][j+1].frame = CGRectMake(0, 
															0, 
															tileSize, 
															tileSize);
					
					currentSlideCoord = slideCoord;
				}
				else{
					[self getImage:imageArray[i+1][j+1] 
							 xcord:(int)currentSlideCoord.x + ((j-3) * tileSize) //((slideCoord.x + imageArray[5][4].frame.origin.x) + ((j-3) * tileSize))
							 ycord:(int)currentSlideCoord.y + ((i-4) * tileSize) //((slideCoord.y + imageArray[5][4].frame.origin.y) + ((i-4) * tileSize))
							height:tileSize
							 width:tileSize
							  zoom:currentZoom];
					
					imageArray[i+1][j+1].frame = CGRectMake(imageArray[5][4].frame.origin.x + ((j-3) * tileSize), 
															imageArray[5][4].frame.origin.y + ((i-4) * tileSize), 
															tileSize, 
															tileSize);
				}
				
				
				//NSLog(@"Drawing Screen X% i Y% i",(int)j,(int)i);
				
				sharpFlagArray[j][i] = TRUE;
				Drawn = TRUE;
				
				break;
			}
		}
	}
	
	//NSLog(@"Images for outside tiles");
	//For loop cycles through the whole array, getting each element
	for (int i = 0; i < 12 && !Drawn; i++) {
		for (int j = 0; j < 9; j++) {
			if (!sharpFlagArray[j][i]) {
				
				if (imageArray[i+1][j+1].frame.size.height == tileSize && imageArray[i+1][j+1].frame.size.width == tileSize) {
					//NSLog(@"If Statement");
					//NSLog(@"Number j:%i i:%i Origin X:%i Y:%i", j,i,(int)imageArray[i+1][j+1].frame.origin.x, (int)imageArray[i+1][j+1].frame.origin.y);
					if (!((imageArray[i+1][j+1].frame.origin.x + imageArray[i+1][j+1].frame.size.width) <= 0) && 
						!(imageArray[i+1][j+1].frame.origin.x >= screenWidth) &&
						!((imageArray[i+1][j+1].frame.origin.y + imageArray[i+1][j+1].frame.size.height) <= 0) &&
						!(imageArray[i+1][j+1].frame.origin.y >= screenHeight)) {
						
						
						//NSLog(@"Drawing X:%i Y:%i", (int)currentSlideCoord.x, (int)currentSlideCoord.y);
						
						[self getImage:imageArray[i+1][j+1] 
								 xcord:(int)currentSlideCoord.x +((j-3) * tileSize)
								 ycord:(int)currentSlideCoord.y +((i-4) * tileSize)
								height:tileSize
								 width:tileSize
								  zoom:currentZoom];
						
						sharpFlagArray[j][i] = TRUE;
						Drawn = TRUE;
						
						break;
						
						//[self.view sendSubviewToBack:imageArray[i+1][j+1]];
						//[self.view sendSubviewToBack:background];
						
						//NSLog(@"Drawing New Screen X% i Y% i",(int)j,(int)i);
						//NSLog(@"Current Slide %@",currentSlide);
						
						//NSLog(@"Updating %i %i", i, j);
					}
				}
				
			}
		}
		if (i == 11) {
			//NSLog(@"Finished Updating Screen");
		}
	}
	
	//NSLog(@"Finished getting images");
	
	
	
	//Always keeps the grid centered and moves the images around the grid
	if (!zoomBool){
		if (imageArray[5][4].frame.origin.x > tileSize && !Drawn) {
			//NSLog(@"Grid moved Right");
			
			//NSLog(@"res: %.f", floor(imageArray[5][4].frame.origin.x/tileSize));
			if (floor(imageArray[5][4].frame.origin.x/tileSize) > 0) {
				currentSlideCoord.x = currentSlideCoord.x - tileSize;
				for (int i = 0; i < 12; i++) {
					for (int j = 8; j > -1; j--) {
						if (j == 0){
							imageArray[i+1][j+1].image = NULL;
							sharpFlagArray[j][i] = FALSE;
						}
						else{
							if (sharpFlagArray[j-1][i] != FALSE) {
								imageArray[i+1][j+1].image = imageArray[i+1][j].image;
								sharpFlagArray[j][i] = TRUE;
							}
							else{
								imageArray[i+1][j+1].image = NULL;
								sharpFlagArray[j][i] = FALSE;
							}
							
							
							//imageArray[i+1][j+1].image = imageArray[i+1][j].image;
							//sharpFlagArray[j][i] = sharpFlagArray[j-1][i];
							//	[self.imgMan manage:imageArray[i+1][j+1]];
							//	[self.imgMan manage:imageArray[i+1][j]];
						}
						
						imageArray[i+1][j+1].frame = CGRectMake(imageArray[i+1][j+1].frame.origin.x - tileSize, 
																imageArray[i+1][j+1].frame.origin.y, 
																imageArray[i+1][j+1].frame.size.width, 
																imageArray[i+1][j+1].frame.size.height);
					}
				}
			}
		}
		else if (imageArray[5][4].frame.origin.x < -tileSize && !Drawn) {
			//NSLog(@"Grid moved left");
			
			//NSLog(@"res: %.f", floor(imageArray[5][4].frame.origin.x/-tileSize));
			if (floor(imageArray[5][4].frame.origin.x/-tileSize) > 0) {
				currentSlideCoord.x = currentSlideCoord.x + tileSize;
				for (int i = 0; i < 12; i++) {
					for (int j = 0; j < 9; j++) {
						if (j == 8){
							imageArray[i+1][j+1].image = NULL;
							sharpFlagArray[j][i] = FALSE;
						}
						else{
							if (sharpFlagArray[j+1][i] != FALSE) {
								imageArray[i+1][j+1].image = imageArray[i+1][j+2].image;
								sharpFlagArray[j][i] = TRUE;
							}
							else{
								imageArray[i+1][j+1].image = NULL;
								sharpFlagArray[j][i] = FALSE;
							}
							
							
							//imageArray[i+1][j+1].image = imageArray[i+1][j+2].image;
							//sharpFlagArray[j][i] = sharpFlagArray[j+1][i];
							//[self.imgMan manage:imageArray[i+1][j+1]];
							//[self.imgMan manage:imageArray[i+1][j+2]];
						}
						 
						imageArray[i][j].frame = CGRectMake(imageArray[i][j].frame.origin.x + tileSize, 
															imageArray[i][j].frame.origin.y, 
															imageArray[i][j].frame.size.width, 
															imageArray[i][j].frame.size.height);
						 
					}
				}
			}
		}
		
		if (imageArray[5][4].frame.origin.y > tileSize && !Drawn) {
			//NSLog(@"Grid moved down");
			
			//NSLog(@"res: %.f", floor(imageArray[5][4].frame.origin.y/tileSize));
			if (floor(imageArray[5][4].frame.origin.y/tileSize) > 0) {
				currentSlideCoord.y = currentSlideCoord.y - tileSize;
				for (int i = 11; i > -1; i--) {
					for (int j = 0; j < 9; j++) {
						if (i == 0){
							imageArray[i+1][j+1].image = NULL;
							sharpFlagArray[j][i] = FALSE;
						}
						else{
							if (sharpFlagArray[j][i-1] != FALSE) {
								imageArray[i+1][j+1].image = imageArray[i][j+1].image;
								sharpFlagArray[j][i] = TRUE;
							}
							else{
								imageArray[i+1][j+1].image = NULL;
								sharpFlagArray[j][i] = FALSE;
							}
							
	//						imageArray[i+1][j+1].image = imageArray[i][j+1].image;
	//						sharpFlagArray[j][i] = sharpFlagArray[j][i-1];
	//						//[self.imgMan manage:imageArray[i+1][j+1]];
	//					//[self.imgMan manage:imageArray[i][j+1]];
						}
	
						imageArray[i+1][j+1].frame = CGRectMake(imageArray[i+1][j+1].frame.origin.x, 
																imageArray[i+1][j+1].frame.origin.y - tileSize, 
																imageArray[i+1][j+1].frame.size.width, 
																imageArray[i+1][j+1].frame.size.height);
						
					}
				}
			}
		}
		else if (imageArray[5][4].frame.origin.y < -tileSize && !Drawn) {
			//NSLog(@"Grid moved up");
			
			//NSLog(@"res: %.f", floor(imageArray[5][4].frame.origin.y/-tileSize));
			if (floor(imageArray[5][4].frame.origin.y/-tileSize) > 0) {
				currentSlideCoord.y = currentSlideCoord.y + tileSize;
				for (int i = 0; i < 12; i++) {
					for (int j = 0; j < 9; j++) {
						if (i == 11){
							imageArray[i+1][j+1].image = NULL;
							sharpFlagArray[j][i] = FALSE;
						}
						else{
							if (sharpFlagArray[j][i+1] != FALSE) {
								imageArray[i+1][j+1].image = imageArray[i+2][j+1].image;
								sharpFlagArray[j][i] = TRUE;
							}
							else{
								imageArray[i+1][j+1].image = NULL;
								sharpFlagArray[j][i] = FALSE;
							}
							
							//imageArray[i+1][j+1].image = imageArray[i+2][j+1].image;
							//sharpFlagArray[j][i] = sharpFlagArray[j][i+1];
							//	[self.imgMan manage:imageArray[i+1][j+1]];
							//	[self.imgMan manage:imageArray[i+2][j+1]];
						}
						
						
						imageArray[i][j].frame = CGRectMake(imageArray[i][j].frame.origin.x, 
															imageArray[i][j].frame.origin.y + tileSize, 
															imageArray[i][j].frame.size.width, 
															imageArray[i][j].frame.size.height);
						 
					}
				}
			}
		}
	}
	
	/*
	  
	  
	if (currentRank == 0 && !Drawn) {
		NSLog(@"Starting last loop");
		for (int i = 0; i < 12; i++) {
			for (int j = 0; j < 9; j++) {
				if (!sharpFlagArray[j][i]) {
					//Resets the default position of the grid
					imageArray[i+1][j+1].frame = CGRectMake((j-3) * tileSize, 
															(i-4) * tileSize, 
															tileSize, 
															tileSize);
					
					//NSLog(@"%i %i",i,j);
					
					imageArray[i+1][j+1].image = NULL;
					
					sharpFlagArray[j][i] = FALSE;
				}
			}
		}
		
		currentRank = 1;
	}
	 
	*/
	
	//if (!Drawn) {
	//	updateGrid = FALSE;
	//}
}


//Gets the requested image from the server using the given specfications
-(void)getImage:(HJManagedImageV *)imageViewer xcord:(int)xcord ycord:(int)ycord height:(int)height width:(int)width zoom:(float)zoom;{
	
	/*
	int x, y, tempHeight, tempWidth;
	
	x = imageViewer.frame.origin.x;
	y = imageViewer.frame.origin.y;
	tempHeight = imageViewer.frame.size.height;
	tempWidth = imageViewer.frame.size.width;
	
	//[imageViewer removeFromSuperview];
	//[imageViewer release];
	
	//imageViewer = [[[HJManagedImageV alloc] init] autorelease];
	//[self.view addSubview:imageViewer];
	
	NSString *URL;
	URL = [@"" stringByAppendingFormat:@"%@%@?GetImage?x=%i&y=%i&width=%i&height=%i&zoom=%.2f&brightness=%i&contrast=%i&r=%i&g=%i&b=%i&sharpen=%i",slideDirectory,currentSlide,xcord,ycord,width,height,zoom,brightness,contrast,red,green,blue,sharpen];
	
	imageViewer.url = [NSURL URLWithString:URL];
	
	[self.imgMan manage:imageViewer];
	
	/*/
	NSData *imageData;
	NSURL *imageURL;
	UIImage *image;
	NSString *URL;
	
	//Calls the image using X and Y coord, height, width and zoom
	URL = [@"" stringByAppendingFormat:@"%@%@?GetImage?x=%i&y=%i&width=%i&height=%i&zoom=%.2f&brightness=%i&contrast=%i&r=%i&g=%i&b=%i&sharpen=%i",slideDirectory,currentSlide,xcord,ycord,width,height,zoom,brightness,contrast,red,green,blue,sharpen];
	//URL = [@"" stringByAppendingFormat:@"%@%@?GetImage?x=%i&y=%i&width=%i&height=%i&zoom=%.2f",slideDirectory,currentSlide,xcord,ycord,width,height,zoom];

	imageURL = [NSURL URLWithString:URL];
	imageData = [NSData dataWithContentsOfURL:imageURL];
	//If there is no length of the data, that means the program failed to get the image from the server
	if ([imageData length] == 0){
		UIAlertView *error = [[UIAlertView alloc] initWithTitle: @"Network error" message: @"Error receiving data from the server" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		[error show];
		[error release];
		currentRank = 5;
	}
	else {
		//Apply the image to the imageViewer
		image = [[UIImage alloc] initWithData:imageData];
		imageViewer.image = image;
		[image release];
	}

}

//Creates the annotation
-(void) createAnnotation:(CGPoint)Position{
	annoArray[annoCount] = [[Annotation alloc] init];
	
	[annoArray[annoCount] create:Position Height:10 Width:10 Zoom:currentZoom];
	[self.view addSubview:annoArray[annoCount].frame];
	[self.view bringSubviewToFront:annoArray[annoCount].frame];	
	[self.view bringSubviewToFront:miniMap];
	[self.view bringSubviewToFront:miniMapView];
	[self.view bringSubviewToFront:toolBar];
	[self.view bringSubviewToFront:buttonBG];
	[self.view bringSubviewToFront:slideDescription];
	[self.view bringSubviewToFront:showDescript];
	
	//[self.view bringSubviewToFront:edit];
	//edit.hidden = NO;
	annoCount++;
}

//Zooms to the annotations
-(void)zoomToAnnotation:(int)annoNum{
	//Gets the annotation's zoom
	currentZoom = annoArray[annoNum].zoom;
	//Zooms to the centre of the annotation
	slideCoord.x = annoArray[annoNum].centre.x - (screenWidth/2);
	slideCoord.y = annoArray[annoNum].centre.y - (screenHeight/2);
	
	//float ratio;
	//float height = annoArray[annoNum].height;
	//float width = annoArray[annoNum].width;

	//if ((height/(screenHeight - 64)) > (width/screenWidth))
	//	ratio = (float)height/(screenHeight - 64);
	//else
	//	ratio = (float)width/screenWidth;
	//
	//currentZoom = annoArray[annoNum].zoom * ratio;
	
	slideCoord.x = (annoArray[annoNum].centre.x ) - (screenWidth  /2);
	slideCoord.y = (annoArray[annoNum].centre.y) - (screenHeight /2);
	
	//Makes sure the viewer isn't outside of the slide
	if (slideCoord.y < 0)
		slideCoord.y = 0;
	if (slideCoord.x < 0)
		slideCoord.x = 0;
	
	redrawGrid = TRUE;
	
	background.frame = CGRectMake(-slideCoord.x,
								  -slideCoord.y,
								  maxSlideCoord.x / currentZoom,
								  maxSlideCoord.y / currentZoom);
	
	[self updateSlide];
	
	annoArray[annoNum].title.hidden = NO;
	annoArray[annoNum].description.hidden = NO;
}

//Deletes the selected annotation
-(void)deleteAnnotation{
	//Runs the remove method on the annotation
	[annoArray[selectedAnno] remove];
	
	//Defrags the anno Array so there isn't an empty space in the array
	while (selectedAnno < annoCount) {
		annoArray[selectedAnno] = annoArray[selectedAnno + 1];
		selectedAnno++;
	}
	
	//Drops the count by 1 due to the lose of an annotation in the array
	annoCount--;
	//Unselectes the annotation
	selectedAnno = 0;
	//Releases the deleted annotation
	[annoArray[annoCount] release];
}

//Updates the distance of the line while it's getting drawn
-(void)updateMeasure{
	float height = (measureLine.frame.size.height * currentZoom);
	float width = (measureLine.frame.size.width * currentZoom);
	float total = sqrt(pow(height, 2) + pow(width, 2));
	measureDistance = total * MPP; //(MPP is 0.2508)
	MPPDistance.text = [NSString stringWithFormat:@"Length: %i microns", (int)measureDistance];
	MPPDistance.hidden = NO;
}

//Called to simulate the zooming into a target point on the slide
- (void)zoomToPoint{
	float targetZoom;
	
	if (currentZoom > 8)//If the user is over 1 mag go to 5
		targetZoom = 8;
	else if (currentZoom > 4)//If the user is over 5 mag go to 10
		targetZoom = 4;
	else if (currentZoom > 2)//If the user is over 10 mag go to 20
		targetZoom = 2;
	else if (currentZoom > 1)//If the user is over 20 mag go to 40
		targetZoom = 1;
	
	//This covers the zooming in animation
	if(tempZoom > targetZoom){
		if (zoomAnimCount != 50) {
	
			zoomAnimCount++;
			
			float yMovement = (targetPoint.y - (screenHeight/2)) / 50;
			float xMovement = (targetPoint.x - (screenWidth/2)) / 50;
			
			for (int i=1; i<13; i++) {
				for (int j=1; j<10; j++) {
					imageArray[i][j].frame = CGRectMake(imageArray[i][j].frame.origin.x - xMovement,
														imageArray[i][j].frame.origin.y - yMovement,
														imageArray[i][j].frame.size.width,
														imageArray[i][j].frame.size.height);
				}
			}
			
			background.frame = CGRectMake(background.frame.origin.x - xMovement,
										  background.frame.origin.y - yMovement,
										  background.frame.size.width,
										  background.frame.size.height);
			
			
			//NSLog(@"%i %i", (int)targetPoint.x, (int)targetPoint.y);
		}
		else {
			//Simulates the fingers moving across the screen
			tempRatio -= 0.02;
			
			//Works out the new size of the tile
			float newSize = (tileSize / tempRatio);
			
			//Works out the origin of the from where to stretch from
			float newOriginx = ((screenWidth/2) - (newSize * tileDisplacement.x)) - (newSize * (selectedTile.y));
			float newOriginy = ((screenHeight/2) - (newSize * tileDisplacement.y)) - (newSize * (selectedTile.x));
			
			//Updates the position of the stretching tiles
			for (int i=1; i<13; i++) {
				for (int j=1; j<10; j++) {
					imageArray[i][j].frame = CGRectMake((newOriginx + (j * newSize)),
														(newOriginy + (i * newSize)),
														newSize,
														newSize);
				}
			}
			
			//Works out how much bigger or smaller the tiles are to the orginial size
			float sizeDifference = imageArray[4][4].frame.size.height / tileSize;
			
			//Using the size difference, I work out the current zoom			
			tempZoom = 40/((40/currentZoom) * sizeDifference);
			
			float dWidth = background.frame.size.width - (maxSlideCoord.x / tempZoom);
			float dHeight = background.frame.size.height - (maxSlideCoord.y / tempZoom);
			
			float rx = (targetPoint.x + slideCoord.x) / (maxSlideCoord.x / currentZoom);
			float ry = (targetPoint.y + slideCoord.y) / (maxSlideCoord.y / currentZoom); 
			
			background.frame = CGRectMake(background.frame.origin.x + (dWidth*rx),
										  background.frame.origin.y + (dHeight*ry),
										  maxSlideCoord.x / tempZoom,
										  maxSlideCoord.y / tempZoom);
		}
		
		for (int i = 1; i < annoCount; i++) {
			annoArray[i].frame.hidden = YES;
		}
		
	}
	else {
		//Zooms into the centre of the screen
		slideCoord.y = (int)((slideCoord.y + targetPoint.y)*(currentZoom/targetZoom))-(screenHeight/2);
		slideCoord.x = (int)((slideCoord.x + targetPoint.x)*(currentZoom/targetZoom))-(screenWidth/2);
		
		//Sets the current zoom to the new zoom
		currentZoom = targetZoom;
		
		zoomTo = FALSE;
		
		[self barButtonEnable];
		
		if (currentZoom == 8)
			X5BarButton.style = UIBarButtonItemStyleDone;
		else if (currentZoom == 4)
			X10BarButton.style = UIBarButtonItemStyleDone;
		else if (currentZoom == 2)
			X20BarButton.style = UIBarButtonItemStyleDone;
		else if (currentZoom == 1)
			X40BarButton.style = UIBarButtonItemStyleDone;
		
		zoomAnimCount = 0;
	}	
}



#pragma mark -
#pragma mark Touch Control

//Called when a new touch is detected on the screen
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {	
	//Get all the touches events
	NSSet *allTouches = [event allTouches];
	MPPDistance.hidden = YES;
	measureLine.hidden = YES;
	totalDisplacement.x = 0;
	totalDisplacement.y = 0;
	
	background.hidden = NO;
	
	if (drawnLine ) {
		[[[self.view subviews] lastObject] removeFromSuperview];
		drawnLine = FALSE;
	}
	
	//Detects how many touches are on the screen
	switch ([allTouches count]) {
		case 1: { //Single touch
			
			//Gets the position of the touch
			UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
		
			//Stores the starting touch position
			previousTouch = [touch locationInView:[self view]];
			
			switch ([touch tapCount])
			{
				case 1: {//Single Tap
					if (annoCreation == 1) {//Called to create a Rect Annotation
						
						CGPoint annoPosition;
						annoPosition.x = slideCoord.x + previousTouch.x;
						annoPosition.y = slideCoord.y + previousTouch.y;
						
						[self createAnnotation:annoPosition];
					}
					else if (!movedBool) {//Called to start drawing a line used for measuring
						startPoint = previousTouch;
						movedBool = TRUE;						
						
						measureBool = TRUE;
						drawnLine = TRUE;
						measureButton.style = UIBarButtonItemStyleDone;
						measureLine = [[Line alloc] init];
						measureLine.frame = CGRectMake(0, 0, 0, 0);
						measureLine.opaque = NO;
						[self.view addSubview:measureLine];
						[measureLine release];
					}
					//else {//Removes the line from the screen
					//	[[[self.view subviews] lastObject] removeFromSuperview];
					//	measureLine = [[Line alloc] init];
					//	measureLine.frame = CGRectMake(0, 0, 0, 0);
					//	measureLine.opaque = NO;
					//	[self.view addSubview:measureLine];
					//	[measureLine release];
					//}
					
					//Hides all the labels and edit button for each annotation
					for (int i = 1; i < annoCount; i++){
						if (annoArray[i].description.hidden == NO)//Hides the descriptions
							annoArray[i].description.hidden = YES;
						if (annoArray[i].title.hidden == NO)//Hides the titles
							annoArray[i].title.hidden = YES;
					}
					
					if (!annoArray[1].frame.hidden) {
						//Cycles through all the annotations
						for (int i = 1; i < annoCount; i++) {
							//Checks to see if the user is clicking on any of the annotations
							if ([annoArray[i] onAnnotation:slideCoord clickPosition:previousTouch Zoom:currentZoom]){
								annoArray[i].title.hidden = NO;
								break;
							}		
						}
					}
					
					
					//Hides the edit button
					edit.enabled = NO;
					
					//Unselects any annotations that are selected
					selectedAnno = 0;
					
					//movedBool = FALSE;
				} break;
				case 2: {//Double tap
					movedBool = TRUE;
					//Converts the current zoom to the miniMap zoom
					float zoomRatio = (miniMapZoom/maxMag);
					BOOL anything = FALSE;
					
					if ((previousTouch.y > miniMap.frame.origin.y) &&
						(previousTouch.x > miniMap.frame.origin.x) &&
						(previousTouch.y < (miniMap.frame.size.height + miniMap.frame.origin.y)) &&
						(previousTouch.x < (miniMap.frame.size.width + miniMap.frame.origin.x)) &&
						(!miniMap.hidden)){
						anything = TRUE;
						redrawGrid = TRUE;
						
						//Works out where the mouse clicks on the minimap in relation to the slide
						slideCoord.x = (((previousTouch.x - miniMap.frame.origin.x)*zoomRatio) * (maxMag/currentZoom)) - (screenWidth/2);
						slideCoord.y = (((previousTouch.y - miniMap.frame.origin.y)*zoomRatio) * (maxMag/currentZoom)) - (screenHeight/2);
						
						//Prevents the slide's x coord from going past the max or min of the slide that doesn't exist
						if (slideCoord.x < 0)
							slideCoord.x = 0;
						else if (slideCoord.x > ((maxSlideCoord.x/currentZoom) - screenWidth))
							slideCoord.x = (maxSlideCoord.x/currentZoom) - screenWidth;
						
						//Prevents the slide's y coord from going past the max or min of the slide that doesn't exist			
						if (slideCoord.y < 0)
							slideCoord.y = 0;
						else if (slideCoord.y > ((maxSlideCoord.y/currentZoom) - screenHeight))
							slideCoord.y = (maxSlideCoord.y/currentZoom)- screenHeight;
						
						background.frame = CGRectMake(-slideCoord.x,
													  -slideCoord.y,
													  maxSlideCoord.x / currentZoom,
													  maxSlideCoord.y / currentZoom);
						
						[self updateSlide];
					}
					else if ((previousTouch.y > slideDescription.frame.origin.y) &&
							 (previousTouch.x > slideDescription.frame.origin.x) &&
							 (previousTouch.y < (slideDescription.frame.size.height + slideDescription.frame.origin.y)) &&
							 (previousTouch.x < (slideDescription.frame.size.width + slideDescription.frame.origin.x))){
						
					}
					else if (!annoArray[1].frame.hidden){
						//Cycles through all the annotations
						for (int i = 1; i < annoCount; i++) {
							//Checks to see if the user is clicking on any of the annotations
							if ([annoArray[i] onAnnotation:slideCoord clickPosition:previousTouch Zoom:currentZoom]){
								[self zoomToAnnotation:i];
								annoArray[i].description.hidden = NO;
								edit.enabled = YES;
								selectedAnno = i;
								anything = TRUE;
								redrawGrid = TRUE;
								break;
							}		
						}
					}
					if(!anything) {//If the user hasn't double tabbed anything then zoom in
						redrawGrid = TRUE;
						
						if (currentZoom > 8){//If the user is over 1 mag go to 5
							[self barButtonEnable];
							tempRatio = 1;
							targetPoint = previousTouch;
							zoomTo = TRUE;
							tempZoom = currentZoom;
							
							//Works out the tile that is being focused on between the 2 touches
							selectedTile.x = (ceil(targetPoint.x / tileSize)) + 4;
							selectedTile.y = (ceil(targetPoint.y / tileSize)) + 3;
							
							//Stores the distance between the targetPoint and the origin of the tile
							tileDisplacement.x = (targetPoint.x - (imageArray[(int)selectedTile.x][(int)selectedTile.y].frame.origin.x))/tileSize;
							tileDisplacement.y = (targetPoint.y - (imageArray[(int)selectedTile.x][(int)selectedTile.y].frame.origin.y))/tileSize;
						}
						else if (currentZoom > 4){//If the user is over 5 mag go to 10
							[self barButtonEnable];
							tempRatio = 1;
							targetPoint = previousTouch;
							zoomTo = TRUE;
							tempZoom = currentZoom;
							
							//Works out the tile that is being focused on between the 2 touches
							selectedTile.x = (ceil(targetPoint.x / tileSize)) + 4;
							selectedTile.y = (ceil(targetPoint.y / tileSize)) + 3;
							
							//Stores the distance between the targetPoint and the origin of the tile
							tileDisplacement.x = (targetPoint.x - (imageArray[(int)selectedTile.x][(int)selectedTile.y].frame.origin.x))/tileSize;
							tileDisplacement.y = (targetPoint.y - (imageArray[(int)selectedTile.x][(int)selectedTile.y].frame.origin.y))/tileSize;	
						}
						else if (currentZoom > 2){//If the user is over 10 mag go to 20
							[self barButtonEnable];
							tempRatio = 1;
							targetPoint = previousTouch;
							zoomTo = TRUE;
							tempZoom = currentZoom;
							
							//Works out the tile that is being focused on between the 2 touches
							selectedTile.x = (ceil(targetPoint.x / tileSize)) + 4;
							selectedTile.y = (ceil(targetPoint.y / tileSize)) + 3;
							
							//Stores the distance between the targetPoint and the origin of the tile
							tileDisplacement.x = (targetPoint.x - (imageArray[(int)selectedTile.x][(int)selectedTile.y].frame.origin.x))/tileSize;
							tileDisplacement.y = (targetPoint.y - (imageArray[(int)selectedTile.x][(int)selectedTile.y].frame.origin.y))/tileSize;
						}
						else if (currentZoom > 1){//If the user is over 20 mag go to 40
							[self barButtonEnable];
							tempRatio = 1;
							targetPoint = previousTouch;
							zoomTo = TRUE;
							tempZoom = currentZoom;
							
							//Works out the tile that is being focused on between the 2 touches
							selectedTile.x = (ceil(targetPoint.x / tileSize)) + 4;
							selectedTile.y = (ceil(targetPoint.y / tileSize)) + 3;
							
							//Stores the distance between the targetPoint and the origin of the tile
							tileDisplacement.x = (targetPoint.x - (imageArray[(int)selectedTile.x][(int)selectedTile.y].frame.origin.x))/tileSize;
							tileDisplacement.y = (targetPoint.y - (imageArray[(int)selectedTile.x][(int)selectedTile.y].frame.origin.y))/tileSize;
						}
						
						//Makes sure that the view isn't out of bounds of the slide
						if (slideCoord.y > ((maxSlideCoord.y/currentZoom) - screenHeight))
							slideCoord.y = (maxSlideCoord.y/currentZoom)- screenHeight;
						if (slideCoord.x > ((maxSlideCoord.x/currentZoom) - screenWidth))
							slideCoord.x = (maxSlideCoord.x/currentZoom) - screenWidth;
						
						//Gives the top left priority to be in view
						if (slideCoord.x < 0)
							slideCoord.x = 0;
						if (slideCoord.y < 0)
							slideCoord.y = 0;
					}
				} break;
			}
		} break;
		case 2: { //Double Touch
			//Zoom begins
			zoomBool = TRUE;
			[self barButtonEnable];
			
			//Used to hide annotations when zooming
			if (!annoHidden) {
				for (int i = 1; i < annoCount; i++) {
					annoArray[i].frame.hidden = YES;
				}
			}
			
			//Gets the position of the touches
			UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
			UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
						
			previousZoom = currentZoom;
			
			//Works out the point in between the two points
			centrePoint.x = ([touch2 locationInView:[self view]].x + [touch1 locationInView:[self view]].x)/2;
			centrePoint.y = ([touch2 locationInView:[self view]].y + [touch1 locationInView:[self view]].y)/2;
			
			//Works out the tile that is being focused on between the 2 touches
			selectedTile.x = (ceil(centrePoint.x / tileSize)) + 4;
			selectedTile.y = (ceil(centrePoint.y / tileSize)) + 3;
			
			//Stores the distance between the centre point and the origin of the tile
			tileDisplacement.x = (centrePoint.x - (imageArray[(int)selectedTile.x][(int)selectedTile.y].frame.origin.x))/tileSize;
			tileDisplacement.y = (centrePoint.y - (imageArray[(int)selectedTile.x][(int)selectedTile.y].frame.origin.y))/tileSize;
			
			//Works out the difference between the two touches
			float dx = [touch1 locationInView:[self view]].x - [touch2 locationInView:[self view]].x;
			float dy = [touch1 locationInView:[self view]].y - [touch2 locationInView:[self view]].y;
			
			//Returns the distance between the two points
			touchDistance = sqrt(dx*dx + dy*dy);
			
			previousTouch.x = (([touch2 locationInView:[self view]].x + [touch1 locationInView:[self view]].x)/2);
			previousTouch.y = (([touch2 locationInView:[self view]].y + [touch1 locationInView:[self view]].y)/2);
			
		} break;
	}
}

//Called when a touch changes position from it's orginial position
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	movedBool = TRUE;
	//Get all the touches events
	NSSet *allTouches = [event allTouches];

	
	//Detects how many touches are on the screen
	switch ([allTouches count]){
		case 1: {
			//Returns the current touch position
			UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			
			//Gets the difference between the previous touch position and the current
			float dx = [touch locationInView:[self view]].x - previousTouch.x;
			float dy = [touch locationInView:[self view]].y - previousTouch.y;
			
			if (annoCreation == 1) {//Called when creating a rect anno
				if (dx < 0 && dy > 0) {
					annoArray[annoCount-1].height = dy;
					annoArray[annoCount-1].width = -dx;
					CGPoint temp;
					temp.x = slideCoord.x + [touch locationInView:[self view]].x;
					temp.y = annoArray[annoCount-1].position.y;
					annoArray[annoCount-1].position = temp;
				}
				else if (dx > 0 && dy < 0) {
					annoArray[annoCount-1].height = -dy;
					annoArray[annoCount-1].width = dx;
					CGPoint temp;
					temp.x = annoArray[annoCount-1].position.x;
					temp.y = slideCoord.y + [touch locationInView:[self view]].y;
					annoArray[annoCount-1].position = temp;
				}
				else if (dx < 0 && dy < 0) {
					annoArray[annoCount-1].height = -dy;
					annoArray[annoCount-1].width = -dx;
					CGPoint temp;
					temp.x = slideCoord.x + [touch locationInView:[self view]].x;
					temp.y = slideCoord.y + [touch locationInView:[self view]].y;
					annoArray[annoCount-1].position = temp;
				}
				else {
					annoArray[annoCount-1].height = dy;
					annoArray[annoCount-1].width = dx;
				}
			}
			else if (measureBool){
				if (dx < 0 && dy > 0) {
					[[[self.view subviews] lastObject] removeFromSuperview];
					CGPoint temp;
					temp.x = [touch locationInView:[self view]].x;
					temp.y = startPoint.y;
					
					measureLine = [[Line alloc] init];
					[measureLine topLeft:FALSE];
					measureLine.frame = CGRectMake(temp.x, temp.y, -dx, dy);
					measureLine.opaque = NO;
					[self.view addSubview:measureLine];
					[measureLine release];
					[self updateMeasure];
				}
				else if (dx > 0 && dy < 0) {
					[[[self.view subviews] lastObject] removeFromSuperview];
					CGPoint temp;
					temp.x = startPoint.x;
					temp.y = [touch locationInView:[self view]].y;
					
					measureLine = [[Line alloc] init];
					[measureLine topLeft:FALSE];
					measureLine.frame = CGRectMake(temp.x, temp.y, dx, -dy);
					measureLine.opaque = NO;
					[self.view addSubview:measureLine];
					[measureLine release];
					[self updateMeasure];
				}
				else if (dx < 0 && dy < 0) {
					[[[self.view subviews] lastObject] removeFromSuperview];
					CGPoint temp;
					temp.x = [touch locationInView:[self view]].x;
					temp.y = [touch locationInView:[self view]].y;
					
					measureLine = [[Line alloc] init];
					[measureLine topLeft:TRUE];
					measureLine.frame = CGRectMake(temp.x, temp.y, -dx, -dy);
					measureLine.opaque = NO;
					[self.view addSubview:measureLine];
					[measureLine release];
					[self updateMeasure];
				}
				else {
					[[[self.view subviews] lastObject] removeFromSuperview];
					CGPoint temp;
					temp.x = startPoint.x;
					temp.y = startPoint.y;
					
					measureLine = [[Line alloc] init];
					[measureLine topLeft:TRUE];
					measureLine.frame = CGRectMake(temp.x, temp.y, dx, dy);
					measureLine.opaque = NO;
					[self.view addSubview:measureLine];
					[measureLine release];
					[self updateMeasure];
				}
			}
			else {//Called normally unless you're creating an anno
				//Returns the position of the inner top left grid position
				float _viewX = imageArray[5][4].frame.origin.x;
				float _viewY = imageArray[5][4].frame.origin.y;
				
				//Updates the slide's coordinates
				slideCoord.x -= dx;
				slideCoord.y -= dy;
				
				//Prevents the slide's x coord from going past the max or min of the slide that doesn't exist
				if (slideCoord.x < 0){
					_viewX += (slideCoord.x + dx);
					slideCoord.x = 0;
					redrawGrid = TRUE;
				}
				else if (slideCoord.x > ((maxSlideCoord.x/currentZoom) - screenWidth)){
					slideCoord.x = (maxSlideCoord.x/currentZoom) - screenWidth;
					redrawGrid = TRUE;
				}
				else
					_viewX += dx;
				
				//Prevents the slide's y coord from going past the max or min of the slide that doesn't exist			
				if (slideCoord.y < 0){
					_viewY += (slideCoord.y + dy);
					slideCoord.y = 0;
					redrawGrid = TRUE;
				}
				else if (slideCoord.y > ((maxSlideCoord.y/currentZoom) - screenHeight)){
					slideCoord.y = (maxSlideCoord.y/currentZoom)- screenHeight;
					redrawGrid = TRUE;
				}
				else
					_viewY += dy;
				
				background.frame = CGRectMake(-slideCoord.x,
											  -slideCoord.y,
											  background.frame.size.width,
											  background.frame.size.height);
				
				//NSLog(@"DX: %i DY: %i", (int)dx, (int)dy);
				//NSLog(@"SlideX: %i SlideY: %i", (int)slideCoord.x, (int)slideCoord.y);
				//NSLog(@"ViewX: %i ViewY: %i", (int)_viewX, (int)_viewY);
				
				//Updates the screen position for each tile in the grid
				for (int i=1; i<13; i++) {
					for (int j=1; j<10; j++) {
						imageArray[i][j].frame = CGRectMake(_viewX + ((j-4)*tileSize), 
															_viewY + ((i-5)*tileSize), 
															tileSize, 
															tileSize);
					}
				}
				
				previousTouch = [touch locationInView:[self view]];
			}
		} break;
		case 2: {
			if (centrePoint.x != 0 && centrePoint.y != 0) {
				
				//Gets the position of the touches
				UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
				UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
				
				//Works out the difference between the 2 touches
				float dx = [touch1 locationInView:[self view]].x - [touch2 locationInView:[self view]].x;
				float dy = [touch1 locationInView:[self view]].y - [touch2 locationInView:[self view]].y;
				
				//How far apart the touches are
				float thisTouchDistance = sqrt(dx*dx + dy*dy);
				
				//The ratio of how far apart the touches are now to how far apart they were to start with
				float ratio = touchDistance / thisTouchDistance; // greater than one for pinching out to zoom in
				
				//Works out the new size using the last ratio
				float newSize = (tileSize / ratio);
				
				//Works out the origin of the from where to stretch from
				float newOriginx = (centrePoint.x - (newSize * tileDisplacement.x)) - (newSize * (selectedTile.y));
				float newOriginy = (centrePoint.y - (newSize * tileDisplacement.y)) - (newSize * (selectedTile.x));

				//Gets the difference between the previous touch position and the current
				dx = (([touch2 locationInView:[self view]].x + [touch1 locationInView:[self view]].x)/2) - previousTouch.x;
				dy = (([touch2 locationInView:[self view]].y + [touch1 locationInView:[self view]].y)/2) - previousTouch.y;
				
				//Returns the position of the inner top left grid position
				float _viewX = imageArray[5][4].frame.origin.x;
				float _viewY = imageArray[5][4].frame.origin.y;
				
				//NSLog(@"%i %i",(int)tileDisplacement.x, (int)tileDisplacement.y);
				
				//Prevents the slide's x coord from going past the max or min of the slide that doesn't exist
				if (slideCoord.x < 0)
					slideCoord.x = 0;
				else if (slideCoord.x > ((maxSlideCoord.x/currentZoom) - screenWidth))
					slideCoord.x = (maxSlideCoord.x/currentZoom) - screenWidth;
				else 
					_viewX += dx;
				
				//Prevents the slide's y coord from going past the max or min of the slide that doesn't exist			
				if (slideCoord.y < 0)
					slideCoord.y = 0;
				else if (slideCoord.y > ((maxSlideCoord.y/currentZoom) - screenHeight))
					slideCoord.y = (maxSlideCoord.y/currentZoom)- screenHeight;
				else
					_viewY += dy;
				
				totalDisplacement.y += dy;
				totalDisplacement.x += dx;
				
				//Using the size difference, I work out the current zoom
				float sizeDifference = imageArray[4][4].frame.size.height / tileSize;
				float tempCurrentZoom = 40/((40/currentZoom) * sizeDifference);
				
				//background.frame = CGRectMake(background.frame.origin.x + ,
				//							  background.frame.origin.y + ,
				//							  maxSlideCoord.x / tempCurrentZoom,
				//							  maxSlideCoord.y / tempCurrentZoom);
				
				float dWidth = background.frame.size.width - (maxSlideCoord.x / tempCurrentZoom);
				float dHeight = background.frame.size.height - (maxSlideCoord.y / tempCurrentZoom);
				
				float rx = (centrePoint.x + slideCoord.x) / (maxSlideCoord.x / currentZoom);
				float ry = (centrePoint.y + slideCoord.y) / (maxSlideCoord.y / currentZoom); 
				
				background.frame = CGRectMake(background.frame.origin.x + (dWidth*rx),
											  background.frame.origin.y + (dHeight*ry),
											  maxSlideCoord.x / tempCurrentZoom,
											  maxSlideCoord.y / tempCurrentZoom);
				
				
				//Updates the position of the stretching tiles
				for (int i=1; i<13; i++) {
					for (int j=1; j<10; j++) {
						imageArray[i][j].frame = CGRectMake((newOriginx + (j * newSize)) + totalDisplacement.x, 
															(newOriginy + (i * newSize)) + totalDisplacement.y, 
															newSize, 
															newSize);
					}
				}
				
				previousTouch.x = (([touch2 locationInView:[self view]].x + [touch1 locationInView:[self view]].x)/2);
				previousTouch.y = (([touch2 locationInView:[self view]].y + [touch1 locationInView:[self view]].y)/2);
				 
			}
			
			//float backgroundSizeX = (maxSlideCoord.x/currentZoom)/ratio;
			//float backgroundSizeY = (maxSlideCoord.y/currentZoom)/ratio;
			
			//background.frame = CGRectMake(newOriginx, 
			//							  newOriginy, 
			//							  backgroundSizeX, 
			//							  backgroundSizeY);
		} break;
	}	
}

//Called when a touch is removed from the screen
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	//Get all the touches events
	NSSet *allTouches = [event allTouches];
	
	[self barButtonEnable];
	
	if (currentZoom == 40)
		X1BarButton.style = UIBarButtonItemStyleDone;
	else if (currentZoom == 8)
		X5BarButton.style = UIBarButtonItemStyleDone;
	else if (currentZoom == 4)
		X10BarButton.style = UIBarButtonItemStyleDone;
	else if (currentZoom == 2)
		X20BarButton.style = UIBarButtonItemStyleDone;
	else if (currentZoom == 1)
		X40BarButton.style = UIBarButtonItemStyleDone;
	else if (currentZoom > 8){
		X1BarButton.style = UIBarButtonItemStyleDone;
		X5BarButton.style = UIBarButtonItemStyleDone;
	}
	else if (currentZoom > 4){
		X5BarButton.style = UIBarButtonItemStyleDone;
		X10BarButton.style = UIBarButtonItemStyleDone;
	}
	else if (currentZoom > 2){
		X10BarButton.style = UIBarButtonItemStyleDone;
		X20BarButton.style = UIBarButtonItemStyleDone;
	}
	else if (currentZoom > 1){
		X20BarButton.style = UIBarButtonItemStyleDone;
		X40BarButton.style = UIBarButtonItemStyleDone;
	}
	
	//NSLog(@"X: %i   Y: %i",(int)(imageArray[5][4].frame.origin.x),(int)(imageArray[5][4].frame.origin.y));
	
	if ((imageArray[5][4].frame.origin.x) < (-screenWidth) ||
		(imageArray[5][4].frame.origin.x) > (screenWidth) ||
		(imageArray[5][4].frame.origin.y) < (-screenHeight) ||
		(imageArray[5][4].frame.origin.y) > (screenHeight)){
		redrawGrid = TRUE;
	}
	
	//Reveals the annotations after the zoom
	if (!annoHidden) {
		for (int i = 1; i < annoCount; i++) {
			annoArray[i].frame.hidden = NO;
		}
	}
	
	//Works out the distance of the line microns Per Person (MPP)
	if (measureBool) {
		measureBool = FALSE;
		measureButton.style = UIBarButtonItemStyleBordered;
		[self updateMeasure];
	}
	
	//Number of touches that were on the screen
	switch ([allTouches count]){			
		case 1: {//There was 1 touch on the screen
			updateGrid = TRUE;
			if (annoCreation == 1) {
				[annoArray[annoCount-1] finishCreating];
				[self.view addSubview:annoArray[annoCount-1].title];
				[self.view bringSubviewToFront:annoArray[annoCount-1].title];	
				[self.view addSubview:annoArray[annoCount-1].description];
				[self.view bringSubviewToFront:annoArray[annoCount-1].description];	
				[self.view bringSubviewToFront:miniMap];
				[self.view bringSubviewToFront:miniMapView];
				[self.view bringSubviewToFront:toolBar];
				[self.view bringSubviewToFront:buttonBG];
				[self.view bringSubviewToFront:slideDescription];
				[self.view bringSubviewToFront:showDescript];
				annoArray[annoCount-1].title.text = @"";
				annoArray[annoCount-1].description.text = @"";
				annoCreation = 0;
			}
			
			//Get the last position of the touch
			UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			
			switch([touch tapCount])
			{
				case 1: {//Single tap
				} break;
				case 2: {//Double tap
				} break;
			}
		} break;
		case 2: {//There was 2 touches on the screen
			redrawGrid = TRUE;
			updateGrid = FALSE;
			//Only called once per zoom
			if (zoomBool)
			{
				//Holds the top left final position if zoomed in max
				CGPoint maxEndPoint; 
				
				//Gets the positions of the touches final location
				UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
				UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
				
				maxEndPoint.x = (([touch2 locationInView:[self view]].x + [touch1 locationInView:[self view]].x)/2) - (screenWidth/2);
				maxEndPoint.y = (([touch2 locationInView:[self view]].y + [touch1 locationInView:[self view]].y)/2) - (screenHeight/2);
				
				//Works out how much bigger or smaller the tiles are to the orginial size
				float sizeDifference = imageArray[4][4].frame.size.height / tileSize;
				//float zoom = currentZoom;
				
				//Using the size difference, I work out the current zoom			
				currentZoom = 40/((40/currentZoom) * sizeDifference);
				
				//BUG When used the next slide selected will be half this slide half the next slide
				//If the user is zooming out while max zoomed out, return to the main menu
				//if (zoom == 40 && currentZoom > 200)
				//{
				//	//Will call the return a sec later to allow the animation to finish
				//	[NSTimer scheduledTimerWithTimeInterval:0 target:self
				//								   selector:@selector(returnToMenu) userInfo:Nil
				//									repeats:NO];
				//}
				
				//Clamps on the zoom in and out
				if (currentZoom < 1)
					currentZoom = 1;
				else if (currentZoom > 40)
					currentZoom = 40;
				
				//Works out the new slide coord relative to the new zoom
				slideCoord.y = (((slideCoord.y + centrePoint.y) * (previousZoom/currentZoom)) - (screenHeight/2)) - maxEndPoint.y;
				slideCoord.x = (((slideCoord.x + centrePoint.x) * (previousZoom/currentZoom)) - (screenWidth/2)) - maxEndPoint.x;
				
				//Only allows the zoom to occur 1
				zoomBool = FALSE;
				
				//Prevents the slide's x coord from going past the max or min of the slide that doesn't exist
				if (slideCoord.x < 0)
					slideCoord.x = 0;
				else if (slideCoord.x > ((maxSlideCoord.x/currentZoom) - screenWidth))
					slideCoord.x = (maxSlideCoord.x/currentZoom) - screenWidth;
				
				//Prevents the slide's y coord from going past the max or min of the slide that doesn't exist			
				if (slideCoord.y < 0)
					slideCoord.y = 0;
				else if (slideCoord.y > ((maxSlideCoord.y/currentZoom) - screenHeight))
					slideCoord.y = (maxSlideCoord.y/currentZoom)- screenHeight;
				
				background.frame = CGRectMake(-slideCoord.x,
											  -slideCoord.y,
											  maxSlideCoord.x / currentZoom,
											  maxSlideCoord.y / currentZoom);
			}
		} break;
	}
	
	centrePoint.x = 0;
	centrePoint.y = 0;
}

#pragma mark -
#pragma mark Toolbar Controls

- (IBAction)showHideDescription{
	if (descriptionVis)
		descriptionVis = FALSE;
	else
		descriptionVis = TRUE;
}

//Edits the selected annotation
- (IBAction) EditAnnotation{
	AnnotationEditViewController *controller = [[AnnotationEditViewController alloc] initWithNibName:@"AnnotationEditViewController" bundle:nil];
	
	//Creates the model view
	[controller addText:annoArray[selectedAnno].title.text Description:annoArray[selectedAnno].description.text];
	[controller drawThumbnail:currentSlide
			   SlideDirectory:slideDirectory
					   Height:annoArray[selectedAnno].height
						Width:annoArray[selectedAnno].width
					   xCoord:annoArray[selectedAnno].position.x
					   yCoord:annoArray[selectedAnno].position.y
						 Zoom:annoArray[selectedAnno].zoom];
	
	//Creates the model view
	controller.modalPresentationStyle = UIModalPresentationFullScreen;	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	controller.delegate = self;
	
	//Presents the animated Modal View
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (IBAction)Zoom1X{
	redrawGrid = TRUE;
	
	[self barButtonEnable];
	
	X1BarButton.style = UIBarButtonItemStyleDone;
	
	slideCoord.y = (int)((slideCoord.y + (screenHeight/2))*(currentZoom/40))-(screenHeight/2);
	slideCoord.x = (int)((slideCoord.x + (screenWidth/2))*(currentZoom/40))-(screenWidth/2);
	currentZoom = 40;
	
	background.frame = CGRectMake(-slideCoord.x,
								  -slideCoord.y,
								  maxSlideCoord.x / currentZoom,
								  maxSlideCoord.y / currentZoom);
	
	[self updateSlide];
}

- (IBAction)Zoom5X{
	redrawGrid = TRUE;
	
	[self barButtonEnable];
	
	X5BarButton.style = UIBarButtonItemStyleDone;
	
	slideCoord.y = (int)((slideCoord.y + (screenHeight/2))*(currentZoom/8))-(screenHeight/2);
	slideCoord.x = (int)((slideCoord.x + (screenWidth/2))*(currentZoom/8))-(screenWidth/2);
	currentZoom = 8;
	
	background.frame = CGRectMake(-slideCoord.x,
								  -slideCoord.y,
								  maxSlideCoord.x / currentZoom,
								  maxSlideCoord.y / currentZoom);
	
	[self updateSlide];
}

- (IBAction)Zoom10X{
	redrawGrid = TRUE;
	
	[self barButtonEnable];
	
	X10BarButton.style = UIBarButtonItemStyleDone;
	
	slideCoord.y = (int)((slideCoord.y + (screenHeight/2))*(currentZoom/4))-(screenHeight/2);
	slideCoord.x = (int)((slideCoord.x + (screenWidth/2))*(currentZoom/4))-(screenWidth/2);
	currentZoom = 4;
	
	background.frame = CGRectMake(-slideCoord.x,
								  -slideCoord.y,
								  maxSlideCoord.x / currentZoom,
								  maxSlideCoord.y / currentZoom);
	
	[self updateSlide];
}

- (IBAction)Zoom20X{
	redrawGrid = TRUE;
	
	[self barButtonEnable];
	
	X20BarButton.style = UIBarButtonItemStyleDone;

	slideCoord.y = (int)((slideCoord.y + (screenHeight/2))*(currentZoom/2))-(screenHeight/2);
	slideCoord.x = (int)((slideCoord.x + (screenWidth/2))*(currentZoom/2))-(screenWidth/2);
	currentZoom = 2;
	
	background.frame = CGRectMake(-slideCoord.x,
								  -slideCoord.y,
								  maxSlideCoord.x / currentZoom,
								  maxSlideCoord.y / currentZoom);
	
	[self updateSlide];
}

- (IBAction)Zoom40X{
	redrawGrid = TRUE;
	
	[self barButtonEnable];
	
	X40BarButton.style = UIBarButtonItemStyleDone;
	
	slideCoord.y = (int)((slideCoord.y + (screenHeight/2))*(currentZoom/1))-(screenHeight/2);
	slideCoord.x = (int)((slideCoord.x + (screenWidth/2))*(currentZoom/1))-(screenWidth/2);
	currentZoom = 1;
	
	background.frame = CGRectMake(-slideCoord.x,
								  -slideCoord.y,
								  maxSlideCoord.x / currentZoom,
								  maxSlideCoord.y / currentZoom);
	
	[self updateSlide];
}

- (void)barButtonEnable{
	X1BarButton.style = UIBarButtonItemStyleBordered;
	X5BarButton.style = UIBarButtonItemStyleBordered;
	X10BarButton.style = UIBarButtonItemStyleBordered;
	X20BarButton.style = UIBarButtonItemStyleBordered;
	X40BarButton.style = UIBarButtonItemStyleBordered;
}

//Updates the brightness value when the redSlider is moved
- (IBAction) brightnessSlider: (UISlider *) sender{
	brightness = brightnessSlider.value - 100;
	brightnessField.title = [@"" stringByAppendingFormat:@"%i",brightness];
	
	redrawGrid = TRUE;
	
	[self updateSlide];
}

- (void)updateSlide{
	if (slideCoord.y > ((maxSlideCoord.y/currentZoom) - screenHeight))
		slideCoord.y = (maxSlideCoord.y/currentZoom)- screenHeight;
	if (slideCoord.x > ((maxSlideCoord.x/currentZoom) - screenWidth))
		slideCoord.x = (maxSlideCoord.x/currentZoom) - screenWidth;
	
	if (slideCoord.x < 0)
		slideCoord.x = 0;
	if (slideCoord.y < 0)
		slideCoord.y = 0;
	
	currentRank = 0;
	arrayPosition.x = 1;
	arrayPosition.y = 1;
}

- (IBAction)HUDButton{
	if (miniMap.hidden == NO) {
		HUDBarButton.style = UIBarButtonItemStyleDone;
		miniMap.hidden = YES;
		miniMapView.hidden = YES;
		description.hidden = YES;
	}
	else{
		HUDBarButton.style = UIBarButtonItemStyleBordered;
		miniMap.hidden = NO;
		miniMapView.hidden = NO;
		description.hidden = NO;	
	}
	
}

#pragma mark -
#pragma mark Action Controls

//Updates the annotation when finished editing
- (void) AnnotationEditViewControllerDidFinish:(AnnotationEditViewController *)controller{
	if (selectedAnno == 0){
		//[annoArray[annoCount-1].description.text release];
		//[annoArray[annoCount-1].title.text release];
		
		annoArray[annoCount-1].description.text = controller.descriptionLabel.text;
		annoArray[annoCount-1].title.text = controller.titleLabel.text;
		[annoArray[annoCount-1] updateDescription];
		[annoArray[annoCount-1] updateTitle];
	}
	else {
		//[annoArray[selectedAnno].description.text release];
		//[annoArray[selectedAnno].title.text release];
		
		annoArray[selectedAnno].description.text = controller.descriptionLabel.text;
		annoArray[selectedAnno].title.text = controller.titleLabel.text;
		[annoArray[selectedAnno] updateDescription];
		[annoArray[selectedAnno] updateTitle];
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

//Updates the annotation when finished editing
- (void) AnnotationEditDelete:(AnnotationEditViewController *)controller{
	//Deletes the annotation
	[self deleteAnnotation];
	
	edit.enabled = NO;
	
	[self dismissModalViewControllerAnimated:YES];
}


//Creates the settings menu
- (IBAction)settings{
	HUDBarButton.style = UIBarButtonItemStyleBordered;
	
	transition = TRUE;
	
	//Removes all tiles that aren't on the screen for a smoother transistion effect
	for (int i=1; i<13; i++) {
		for (int j=1; j<10; j++) {
			if (!(i>4 && i<9 && j>3 && j<7)) {
				imageArray[i][j].frame = CGRectMake(0,
													0,
													0,
													0);
			}
		}
	}
	
	background.hidden = YES;
	
	SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController"bundle:nil];
	
	bool minimap;
	bool descript;
	bool anno;
	
	if (miniMap.hidden)
		minimap = FALSE;
	else
		minimap = TRUE;
	
	if (annoArray[1].frame.hidden)
		anno = FALSE;
	else
		anno = TRUE;
	
	if (description.hidden)
		descript = FALSE;
	else
		descript = TRUE;
	
	controller.numOfAnnos = annoCount;
	[controller addValues:red Green:green Blue:blue Brightness:brightness Contrast:contrast Slide:currentSlide Directory:slideDirectory Sharpen:sharpen Anno:anno Minimap:minimap Description:descript coordX:slideCoord.x coordY:slideCoord.y Zoom:currentZoom];
	[controller allocLabels];
	
	
	//////KNOWN BUG, CAN'T READ THE TITLE FROM LOADED SLIDES AFTER 2 OR 3 MORE ANNOTATIONS ARE CREATED AFTER THE FACT//////
	//////HENCE USING NO TITLE UNTIL IT WORKS/////
	//Hiddens the annotations for the transistion
	for (int i = 1; i < annoCount; i++) {
		//[controller createLabels:i Title:@"No Title"];
		[controller createLabels:i Title:annoArray[i].title.text];
		annoArray[i].frame.hidden = YES;
	}
	
	//Creates the model view
	controller.modalPresentationStyle = UIModalPresentationFullScreen;	
	controller.modalTransitionStyle = UIModalTransitionStylePartialCurl;
	controller.delegate = self;
	
	//Presents the animated Modal View
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

//Dismisses the settings menu and allows the creation of an rectangle
- (void) CreateRectAnno:(SettingsViewController *)controller{
	if (annoCount == 20){//Only allows for the max amount of annotations (20)
		UIAlertView *error = [[UIAlertView alloc] initWithTitle: @"Max Annotations Reached" message: @"You have created the max number of Annotations" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		[error show];
		[error release];
	}
	else
		annoCreation = 1;
	
	for (int i = 1; i < annoCount; i++) {
		annoArray[i].frame.hidden = NO;
	}
	
	[self dismissModalViewControllerAnimated:YES];
	transition = FALSE;
}

//Dismisses the settings menu and saves the current annotations
- (void) SaveAnnos:(SettingsViewController *)controller{
	if(annoCount-1 > 0){//Only saves if there are any annotations to save
		NSError *error;
		NSString* annoTextList = [NSString stringWithFormat: @"ANNONUM=%i",annoCount-1];
		//NSString* iPadID = [UIDevice currentDevice].uniqueIdentifier;
		NSArray *components = [currentSlide componentsSeparatedByString:@"."];
		
		NSString* path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat: @"anno%@",[components objectAtIndex:0]]
														 ofType:@"txt"];
		
		for (int i = 1; i < annoCount; i++) {
			NSString* currentAnno = [NSString stringWithFormat: @"$|X=%i|Y=%i|Width=%i|Height=%i|Zoom=%f|Title=%@|Description=%@",(int)annoArray[i].position.x,(int)annoArray[i].position.y,(int)annoArray[i].width,(int)annoArray[i].height,annoArray[i].zoom,annoArray[i].title.text,annoArray[i].description.text];
			annoTextList = [NSString stringWithFormat: @"%@%@",annoTextList,currentAnno];
		}
		
		[annoTextList writeToFile:path atomically:YES encoding:NSUnicodeStringEncoding error:&error];
		
		[self dismissModalViewControllerAnimated:YES];
		transition = FALSE;
	}
}

//Dismisses the settings menu and loads the current annotations
- (void) LoadAnnos:(SettingsViewController *)controller{
	
	for (int i = annoCount; i != 1; i--) {
		[self deleteAnnotation];
	}
	
	//NSString* iPadID = [UIDevice currentDevice].uniqueIdentifier;
	NSArray *components = [currentSlide componentsSeparatedByString:@"."];
	
	NSString* path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat: @"anno%@",[components objectAtIndex:0]]
													 ofType:@"txt"];
	
	NSString* fileContents = [NSString stringWithContentsOfFile:path
													   encoding:NSUnicodeStringEncoding
														  error:NULL];
	
	NSArray *annos = [fileContents componentsSeparatedByString:@"$"];
	NSArray *savedAnnos = [[annos objectAtIndex:0] componentsSeparatedByString:@"="];
	int numOfSavedAnnos = (int)[[savedAnnos objectAtIndex:1] doubleValue];
	
	for (int i = 1; i <= numOfSavedAnnos; i++) {
		NSArray *annoDetails = [[annos objectAtIndex:i] componentsSeparatedByString:@"|"];
		NSArray *eachDetail = [[annoDetails objectAtIndex:1] componentsSeparatedByString:@"="];
		int x = (int)[[eachDetail objectAtIndex:1] doubleValue];
		eachDetail = [[annoDetails objectAtIndex:2] componentsSeparatedByString:@"="];
		int y = (int)[[eachDetail objectAtIndex:1] doubleValue];
		eachDetail = [[annoDetails objectAtIndex:3] componentsSeparatedByString:@"="];
		int width = (int)[[eachDetail objectAtIndex:1] doubleValue];
		eachDetail = [[annoDetails objectAtIndex:4] componentsSeparatedByString:@"="];
		int height = (int)[[eachDetail objectAtIndex:1] doubleValue];
		eachDetail = [[annoDetails objectAtIndex:5] componentsSeparatedByString:@"="];
		double zoom = [[eachDetail objectAtIndex:1] doubleValue];
		eachDetail = [[annoDetails objectAtIndex:6] componentsSeparatedByString:@"="];
		NSString *newTitle = [eachDetail objectAtIndex:1];
		eachDetail = [[annoDetails objectAtIndex:7] componentsSeparatedByString:@"="];
		NSString *newDescription = [eachDetail objectAtIndex:1];
		
		CGPoint annoPosition;
		annoPosition.x = x;
		annoPosition.y = y;
		
		[self createAnnotation:annoPosition];
		
		[annoArray[i] finishCreating];
		[self.view addSubview:annoArray[i].title];
		[self.view bringSubviewToFront:annoArray[i].title];	
		[self.view addSubview:annoArray[i].description];
		[self.view bringSubviewToFront:annoArray[i].description];	
		
		annoArray[i].title.hidden = YES;
		annoArray[i].description.hidden = YES;
		
		[self.view bringSubviewToFront:miniMap];
		[self.view bringSubviewToFront:miniMapView];
		[self.view bringSubviewToFront:toolBar];
		[self.view bringSubviewToFront:buttonBG];
		[self.view bringSubviewToFront:slideDescription];
		[self.view bringSubviewToFront:showDescript];
		
		annoArray[i].height = height;
		annoArray[i].width = width;
		annoArray[i].zoom = zoom;
		annoArray[i].title.text = newTitle;
		annoArray[i].description.text = newDescription;
		
		[annoArray[i] updateDescription];
		[annoArray[i] updateTitle];

		[newTitle retain];
		[newDescription retain];
		[annoArray[i].title.text retain];
		[annoArray[i].description.text retain];
		[annoArray[i].title retain];
		[annoArray[i].description retain];
		
		CGPoint	annoCentre;
		
		annoCentre.x = x + (width/2);
		annoCentre.y = y + (height/2);
		annoArray[i].centre = annoCentre;
		
	}
	
	for (int i = 1; i < annoCount; i++) {
		annoArray[i].frame.hidden = NO;
	}
	
	NSLog(@"Loading");
	
	[self dismissModalViewControllerAnimated:YES];
	transition = FALSE;
}

//Dismisses the settings menu
- (void) SettingsViewControllerDidFinish:(SettingsViewController *)controller{
	annoCreation = 0;
	
	int anno = controller.selectedAnno;
	
  	       red = controller.red;
	     green = controller.green;
	      blue = controller.blue;
	brightness = controller.brightness;
	  contrast = controller.contrast;
	   sharpen = controller.sharpen;
	
	if (controller.minimapBool) {
		miniMap.hidden = NO;
		miniMapView.hidden = NO;
	}
	else {
		miniMap.hidden = YES;
		miniMapView.hidden = YES;
	}
	
	if (controller.descriptionBool) 
		description.hidden = NO;
	else 
		description.hidden = YES;
	
	if (controller.annotationBool){
		for (int i = 1; i < annoCount; i++) {
			annoArray[i].frame.hidden = NO;
		}
		annoHidden = FALSE;
	}
	else {
		for (int i = 1; i < annoCount; i++) {
			annoArray[i].frame.hidden = YES;
		}
		annoHidden = TRUE;
	}
	
	
	currentRank = 0;
	arrayPosition.x = 1;
	arrayPosition.y = 1;
	
	[self dismissModalViewControllerAnimated:YES];
	transition = FALSE;
	
	if (anno > 0) {
		[self zoomToAnnotation:anno];
	}
}

//Returns to main menu from the options menu
- (void) SlideReturnToMenu:(SettingsViewController*)controller{
	[self dismissModalViewControllerAnimated:YES];
	
	//Will call the return a sec later to allow the animation to finish
	[NSTimer scheduledTimerWithTimeInterval:0.7 target:self
								   selector:@selector(returnToMenu) userInfo:Nil
									repeats:NO];
}

//Called after the animation has finished
- (void)returnToMenu{
	
	//Removes all tiles that aren't on the screen for a smoother transistion effect
	for (int i=1; i<13; i++) {
		for (int j=1; j<10; j++) {
			if (!(i>4 && i<9 && j>3 && j<7)) {
				imageArray[i][j].frame = CGRectMake(0,
													0,
													0,
													0);
			}
		}
	}
	
	currentSlide = NULL;
	slideDirectory = NULL;
	background.image = NULL;
	
	//Returns to main menu
	[self.delegate SlideViewControllerDidFinish:self];
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

@end
