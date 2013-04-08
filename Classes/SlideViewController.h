//
//  SlideViewController.h
//  iSlideViewer
//
//  Created by Ed on 2/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SettingsViewController.h"
#import "AnnotationEditViewController.h"
#import "Line.h"
#import "Circle.h"
#import "HJObjManager.h"
#import "HJManagedImageV.h"

@protocol SlideViewControllerDelegate;

@interface SlideViewController : UIViewController <SettingsViewControllerDelegate, AnnotationEditViewControllerDelegate> {
	<SlideViewControllerDelegate>		delegate;
	
	int							currentRank;
	int							annoCreation;
	int							annoCount;
	int							red;
	int							green;
	int							blue;
	int							brightness;
	int							contrast;
	int							sharpen;
	int							selectedAnno;
	int							zoomAnimCount;
	int							screenHeight;
	int							screenWidth;
	int							tileSize;
	
	bool						zoomBool;
	bool						transition;
	bool						annoHidden;
	bool						measureBool;
	bool						movedBool;
	bool						zoomTo;
	bool						redrawGrid;
	bool						updateGrid;
	bool						drawnLine;
	bool						descriptionVisible;
	
	double						miniMapZoom;
	double						maxMag;
	double						currentZoom;
	double						previousZoom;
	double						touchDistance;
	double						measureDistance;
	double						MPP;
	double						tempRatio;
	double						tempZoom;
	
	UIImageView					*miniMapView;
	UIImageView					*miniMap;
	UIImageView					*background;
	UIImageView					*buttonBG;
	
	UIButton					*showDescript;
	
	UITextView					*slideDescription;
	
	UILabel						*description;
	UILabel						*MPPDistance;

	CGPoint						maxSlideCoord;
	CGPoint						slideCoord;
	CGPoint						currentSlideCoord;
	CGPoint						arrayPosition;
	CGPoint						previousTouch;
	CGPoint						centrePoint;
	CGPoint						selectedTile;
	CGPoint						tileDisplacement;
	CGPoint						startPoint;
	CGPoint						totalDisplacement;
	CGPoint						targetPoint;
	
	NSString					*slideDirectory;
	NSString					*currentSlide;
	
	IBOutlet UISlider			*brightnessSlider;

	UIToolbar					*toolBar;
	
	UIBarButtonItem				*edit;
	UIBarButtonItem				*measureButton;
	UIBarButtonItem				*X1BarButton;
	UIBarButtonItem				*X5BarButton;
	UIBarButtonItem				*X10BarButton;
	UIBarButtonItem				*X20BarButton;
	UIBarButtonItem				*X40BarButton;
	UIBarButtonItem				*HUDBarButton;
	UIBarButtonItem				*brightnessField;
	UIBarButtonItem				*barTitle;
	
	Line						*measureLine;
	
	HJObjManager*				imgMan;
}

- (IBAction)showHideDescription;
- (IBAction)Zoom1X;
- (IBAction)Zoom5X;
- (IBAction)Zoom10X;
- (IBAction)Zoom20X;
- (IBAction)Zoom40X;
- (void)barButtonEnable;
- (IBAction) brightnessSlider: (id) sender;
- (void)updateSlide;
- (IBAction)HUDButton;

- (IBAction)EditAnnotation;
- (void)AnnotationEditViewControllerDidFinish:(AnnotationEditViewController *)controller;
- (void)AnnotationEditDelete:(AnnotationEditViewController *)controller;
- (void)updateMeasure;
- (void)zoomToPoint;

- (IBAction)settings;
- (void)CreateRectAnno:(SettingsViewController *)controller;
- (void)SaveAnnos:(SettingsViewController *)controller;
- (void)LoadAnnos:(SettingsViewController *)controller;
- (void)SettingsViewControllerDidFinish:(SettingsViewController *)controller;

- (void)hideDescription;
- (void)showDescription;

- (void)buildArray;
- (void)getInfo;
- (void)drawBorders;
- (void)slideSetup:(NSString *)slide extension:(NSString *)extension directory:(NSString *)directory;

- (void)createAnnotation:(CGPoint)Position;
- (void)deleteAnnotation;
- (void)zoomToAnnotation:(int)annoNum;
- (void)update;
- (void)redrawTheGrid;
- (void)updateTheGrid;
- (void)getImage: (HJManagedImageV *) imageViewer xcord:(int)xcord ycord:(int)ycord height:(int)height width:(int)width zoom:(float)zoom;
- (void)returnToMenu;

@property (readwrite) int currentRank;	//Stores the rank which is used to draw the grid, lowest to highest
@property (readwrite) int annoCreation;	//0 = No Annotation, 1 = Rect Anno, 2 = Circle Anno, 3 = Arrow Anno
@property (readwrite) int annoCount;	//Counts how many annotations and stores it in the arrays
@property (readwrite) int red;			//Stores the red colour value for this image
@property (readwrite) int green;		//Stores the green colour value for this image
@property (readwrite) int blue;			//Stores the blue colour value for this image
@property (readwrite) int brightness;	//Stores the brightness colour value for this image
@property (readwrite) int contrast;		//Stores the contrast colour value for this image
@property (readwrite) int sharpen;		//Stores the sharpen value for this image
@property (readwrite) int selectedAnno;	//Stores the selected annotation for use of editing
@property (readwrite) int zoomAnimCount;//Count used to allow the animation to scroll for 10 updates
@property (readwrite) int screenHeight;
@property (readwrite) int screenWidth;
@property (readwrite) int tileSize;

@property (readwrite) bool zoomBool;		//Flag used when the user zooms in
@property (readwrite) bool transition;		//Prevents the program from updating while in transition
@property (readwrite) bool annoHidden;		//Flag used to hide annotations when zooming
@property (readwrite) bool measureBool;		//Flag used when wanting to measure something
@property (readwrite) bool movedBool;		//Flag used when wanting to measure something
@property (readwrite) bool zoomTo;			//Flag used for zooming into a point on the transition
@property (readwrite) bool redrawGrid;		//Flag used to completely redraw the grid
@property (readwrite) bool updateGrid;		//Flag used to update the grid
@property (readwrite) bool drawnLine;		//Flag used when a line needs to be removed
@property (readwrite) bool descriptionVis;	//Flag used to show if the description is visible or not

@property (readwrite) double miniMapZoom;		//Stores the zoom level used for the minimap
@property (readwrite) double maxMag;			//Stores the max zoom level for this slide
@property (readwrite) double currentZoom;		//Stores the current zoom level
@property (readwrite) double previousZoom;		//Stores the previous zoom level in the last cycle
@property (readwrite) double touchDistance;		//Stores the previous touch distance in the last cycle
@property (readwrite) double measureDistance;	//Stores the distance that is being measured
@property (readwrite) double MPP;				//Stores the MPP at max zoom
@property (readwrite) double tempRatio;			//Stores the changing ratio used when zooming animation
@property (readwrite) double tempZoom;			//Stores the changing zoom value which is used for the zooming animation

@property (readwrite) CGPoint maxSlideCoord;	//Stores the max size of the slide at the max zoom
@property (readwrite) CGPoint slideCoord;		//Stores the current position on the slide relative to the current zoom
@property (readwrite) CGPoint currentSlideCoord;//Stores the current slide position of the grid, relative to the current zoom
@property (readwrite) CGPoint arrayPosition;	//Stores the current position of the row and column, used for drawing the grid
@property (readwrite) CGPoint previousTouch;	//Stores the previous touch position
@property (readwrite) CGPoint centrePoint;		//Stores the centre point between 2 fingers
@property (readwrite) CGPoint selectedTile;		//Stores the tile that is the focus of the zoom
@property (readwrite) CGPoint tileDisplacement;	//Stores the distance between the centre point and the origin of the tile
@property (readwrite) CGPoint startPoint;		//Stores the first touch on the screen
@property (readwrite) CGPoint totalDisplacement;//Stores the total displacement during a complete movement
@property (readwrite) CGPoint targetPoint;		//Stores the point the user double clicked on to zoom to

@property (nonatomic, retain) IBOutlet UIImageView *miniMapView;	//The image used to represent the current position on the minimap
@property (nonatomic, retain) IBOutlet UIImageView *miniMap;		//The image used for the minimap
@property (nonatomic, retain) IBOutlet UIImageView *background;		//The background image of the slide, only updated once
@property (nonatomic, retain) IBOutlet UIImageView *buttonBG;		//Asthetics, background of the slide button

@property (nonatomic, retain) IBOutlet UIButton *showDescript;	//Used to show and hide the description

@property (nonatomic, retain) IBOutlet UITextView *slideDescription;		//The description of the slide, only updated once

@property (nonatomic, retain) IBOutlet UILabel *description;//The label used to show the description of the slide
@property (nonatomic, retain) IBOutlet UILabel *MPPDistance;//The label used to display the distance of the line

@property (nonatomic, assign) UISlider* brightnessSlider;	//Slides the value for the brightness

@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;	//The toolbar at the bottom of screen

@property (nonatomic, retain) IBOutlet UIBarButtonItem *edit;			//The edit button used to edit annotations
@property (nonatomic, retain) IBOutlet UIBarButtonItem *measureButton;	//The measure button used to call the scale tool
@property (nonatomic, retain) IBOutlet UIBarButtonItem *X1BarButton;	//Holds the button on the toolbar for X1 Zoom
@property (nonatomic, retain) IBOutlet UIBarButtonItem *X5BarButton;	//Holds the button on the toolbar for X5 Zoom
@property (nonatomic, retain) IBOutlet UIBarButtonItem *X10BarButton;	//Holds the button on the toolbar for X10 Zoom
@property (nonatomic, retain) IBOutlet UIBarButtonItem *X20BarButton;	//Holds the button on the toolbar for X20 Zoom
@property (nonatomic, retain) IBOutlet UIBarButtonItem *X40BarButton;	//Holds the button on the toolbar for X40 Zoom
@property (nonatomic, retain) IBOutlet UIBarButtonItem *HUDBarButton;	//Holds the button on the toolbar for the HUD
@property (nonatomic, retain) IBOutlet UIBarButtonItem *brightnessField;//Displays the value of the brightness
@property (nonatomic, retain) IBOutlet UIBarButtonItem *barTitle;		//Displays the title of the slide

@property (nonatomic, retain) IBOutlet Line *measureLine;//The view used to hold the line on the scale

@property (nonatomic, assign) NSString* currentSlide;	//Holds the selected Slide from the main menu
@property (nonatomic, assign) NSString* slideDirectory;	//Holds the directory for the slide

@property (nonatomic, assign) id <SlideViewControllerDelegate> delegate;

@property (nonatomic, retain) HJObjManager* imgMan;

@end

@protocol SlideViewControllerDelegate

- (void) SlideViewControllerDidFinish:(SlideViewController*)controller;

@end