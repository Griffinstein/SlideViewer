//
//  SettingsViewController.h
//  iSlideViewer
//
//  Created by Ed on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJObjManager.h"
#import "HJManagedImageV.h"

@protocol SettingsViewControllerDelegate;
@class	AppScrollView;

@interface SettingsViewController : UIViewController <UIScrollViewDelegate> {
	<SettingsViewControllerDelegate>		delegate;
	
	int						red;
	int						green;
	int						blue;
	int						brightness;
	int						contrast;
	int						sharpen;
	int						numOfAnnos;
	int						xCoord;
	int						yCoord;
	int						selectedAnno;
	
	float					zoom;
	
	bool					minimapBool;
	bool					annotationBool;
	bool					descriptionBool;
	
	IBOutlet UISwitch		*sharpenSwitch;
	IBOutlet UISwitch		*minimapSwitch;
	IBOutlet UISwitch		*annotationSwitch;
	IBOutlet UISwitch		*descriptionSwitch;
	
	IBOutlet UISlider		*redSlider;
	IBOutlet UISlider		*greenSlider;
	IBOutlet UISlider		*blueSlider;
	IBOutlet UISlider		*brightnessSlider;
	IBOutlet UISlider		*contrastSlider;
	
	IBOutlet UITextField	*redField;
	IBOutlet UITextField	*greenField;
	IBOutlet UITextField	*blueField;
	IBOutlet UITextField	*brightnessField;
	IBOutlet UITextField	*contrastField;
	
	HJManagedImageV			*thumbnail;
	UIImageView				*minimap;
	UIImageView				*annotation;
	UIImageView				*highlight;
	
	UILabel					*descript;
	
	NSString				*currentSlide;
	NSString				*slideDirectory;
	NSString				*listOfAnnos;
	
	AppScrollView			*labelScroll;
	
	HJObjManager			*imgMan;
}

- (void)allocLabels;
- (void)setup;
- (void)createLabels:(int)annoCount Title:(NSString *)Title;
- (void)drawLabels;
- (void)addValues:(int)Red Green:(int)Green Blue:(int)Blue Brightness:(int)Brightness Contrast:(int)Contrast Slide:(NSString *)Slide Directory:(NSString *)Directory Sharpen:(int)Sharpen Anno:(bool)Anno Minimap:(bool)Minimap Description:(bool)Description coordX:(int)coordX coordY:(int)coordY Zoom:(float)Zoom;

- (IBAction)createRect;
- (IBAction)saveAnnos;
- (IBAction)loadAnnos;
- (IBAction)done;
- (IBAction)returnToMainMenu;
- (IBAction)restoreToDefault;

- (IBAction)sharpSwitch: (id) sender;
- (IBAction)minimapSwitcher: (id) sender;
- (IBAction)annotationSwitcher: (id) sender;
- (IBAction)descriptionSwitcher: (id) sender;

- (IBAction)redSlider: (id) sender;
- (IBAction)greenSlider: (id) sender;
- (IBAction)blueSlider: (id) sender;
- (IBAction)brightnessSlider: (id) sender;
- (IBAction)contrastSlider: (id) sender;

- (void)updateThumbnail;

@property (nonatomic, assign) id <SettingsViewControllerDelegate> delegate;

@property (readwrite) int red;			//Stores the red colour value for this image
@property (readwrite) int green;		//Stores the green colour value for this image
@property (readwrite) int blue;			//Stores the blue colour value for this image
@property (readwrite) int brightness;	//Stores the brightness value for this image
@property (readwrite) int contrast;		//Stores the contrast value for this image
@property (readwrite) int sharpen;		//Stores the sharpen value for this image
@property (readwrite) int numOfAnnos;	//Stores the number of annotations on the slide
@property (readwrite) int xCoord;		//Stores the Xposition of the slide
@property (readwrite) int yCoord;		//Stores the Yposition of the slide
@property (readwrite) int selectedAnno;	//Stores the selected Anno in the scroll view

@property (readwrite) float zoom;		//Stores the zoom of the slide

@property (readwrite) bool minimapBool;		//Bool to hold the minimap's visibility
@property (readwrite) bool annotationBool;	//Bool to hold the annotation's visibility
@property (readwrite) bool descriptionBool;	//Bool to hold the description label's visibility

@property (nonatomic, retain) UISwitch* sharpenSwitch;		//Switch to control the sharpen
@property (nonatomic, retain) UISwitch* minimapSwitch;		//Switch to control the visiblity of the minimap 
@property (nonatomic, retain) UISwitch* annotationSwitch;	//Switch to control the visiblity of the annotations
@property (nonatomic, retain) UISwitch* descriptionSwitch;	//Switch to control the visiblity of the description

@property (nonatomic, assign) UISlider* redSlider;			//Slides the value for the red colour
@property (nonatomic, assign) UISlider* greenSlider;		//Slides the value for the green colour
@property (nonatomic, assign) UISlider* blueSlider;			//Slides the value for the blue colour
@property (nonatomic, assign) UISlider* brightnessSlider;	//Slides the value for the brightness
@property (nonatomic, assign) UISlider* contrastSlider;		//Slides the value for the contrast

@property (nonatomic, retain) IBOutlet HJManagedImageV *thumbnail;	//Shows the thumbnail for the data values

@property (nonatomic, retain) IBOutlet UIImageView *minimap;	//Shows the minimap visibility
@property (nonatomic, retain) IBOutlet UIImageView *annotation;	//Shows the annotation visibility
@property (nonatomic, retain) IBOutlet UIImageView *highlight;	//Holds the blue highlight to show the selected anno

@property (nonatomic, retain) IBOutlet UILabel *descript;		//Shows the description visibility

@property (nonatomic, assign) NSString* currentSlide;	//Holds the selected Slide from the main menu
@property (nonatomic, assign) NSString* slideDirectory;	//Holes the directory for the slide
@property (nonatomic, assign) NSString* listOfAnnos;	//Holds the names of the annos;

@property (nonatomic, retain) IBOutlet AppScrollView *labelScroll;	//Scroll view to show all the annotations

@property (nonatomic, retain) HJObjManager* imgMan;	//Manages the downloading images asycn

@end

@protocol SettingsViewControllerDelegate

- (void) CreateRectAnno:(SettingsViewController*)controller;
- (void) SaveAnnos:(SettingsViewController*)controller;
- (void) LoadAnnos:(SettingsViewController*)controller;
- (void) SettingsViewControllerDidFinish:(SettingsViewController*)controller;
- (void) SlideReturnToMenu:(SettingsViewController*)controller;

@end