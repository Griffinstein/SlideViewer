//
//  MainMenuViewController.h
//  iSlideViewer
//
//  Created by Ed on 2/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideViewController.h"
#import "HistoryViewController.h"
#import "HJObjManager.h"
#import "HJManagedImageV.h"

@protocol MainMenuViewControllerDelegate;
@class	AppScrollView;

@interface MainMenuViewController : UIViewController <UIScrollViewDelegate, SlideViewControllerDelegate, HistoryViewControllerDelegate> {
	<MainMenuViewControllerDelegate>		delegate;
	AppScrollView				*imageScroll;
	
	UIImageView					*highlight;
	
	UITextField					*dir;
	
	NSString					*slideDirectory;
	
	NSMutableArray				*slideArray;
	NSMutableArray				*imageArray;
	
	UILabel						*loadingStatus;
	
	UIButton					*historyButton;
	
	UIActivityIndicatorView		*loadingLight;
	
	int							selectedSlideNum;
	int							numOfSlides;
	int							drawnSlides;
	
	BOOL						drawingBool;
	
	HJObjManager				*imgMan;
}

- (IBAction)getSlide;
- (IBAction)openHistory;

- (void)createImageScroll;
- (void)createSlides;
- (void)update;
- (void)drawSlides;
- (void)openSlide;
- (void)openHistory;
- (void)getThumbnail:(HJManagedImageV *)imageViewer slide:(NSString *)slide directory:(NSString *)directory extension:(NSString *)extension;

@property (nonatomic, assign) id <MainMenuViewControllerDelegate> delegate;

@property (nonatomic, retain) UIScrollView *imageScroll;	//The scrollview holds the thumbnails of the slides for the user to select

@property (nonatomic, retain) IBOutlet UIImageView *highlight;	//Holds the blue highlight to show the selected image

@property (nonatomic, retain) IBOutlet UITextField *dir;	//Holds the current directory for the slides

@property (readwrite) int selectedSlideNum;	//Holds the number of the current selected slide
@property (readwrite) int numOfSlides;		//Holds the total number of slides on the scrollview
@property (readwrite) int drawnSlides;		//Holds the number of slides that have been drawn

@property (readwrite) BOOL drawingBool;	//Bool called to draw when all the slides in a directory have been determined

@property (nonatomic, retain) IBOutlet UILabel *slideDirectoryLabel;	//Shows the directory of the selected slide
@property (nonatomic, retain) IBOutlet UILabel *loadingStatus;			//Shows what the program is doing in the background

@property (nonatomic, retain) IBOutlet UIButton	*historyButton;	//The button used to show history

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingLight;	//Shows the loading progress

@property (nonatomic, assign) NSString* slideDirectory;	//Holds the selected directory

@property (nonatomic, assign) NSMutableArray* slideArray;	//Holds the directory and name for each slide
@property (nonatomic, assign) NSMutableArray* imageArray;	//Holds the thumbnails for each slide

@property (nonatomic, retain) HJObjManager* imgMan;	//Manages the downloading images asycn

@end