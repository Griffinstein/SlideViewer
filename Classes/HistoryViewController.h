//
//  HistoryViewController.h
//  iSlideViewer
//
//  Created by Ed on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol HistoryViewControllerDelegate;

@interface HistoryViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>{
	<HistoryViewControllerDelegate>	delegate;
	
	UIPickerView		*picker;
	NSMutableArray		*pickerArray;
	NSString			*slideDirectory;
	UILabel				*directory;
}

- (IBAction)cancel;
- (IBAction)loadHistory;

- (void)testSetup:(NSMutableArray *)array;

@property (nonatomic, assign) id <HistoryViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIPickerView *picker;
@property (nonatomic, assign) NSMutableArray *pickerArray;
@property (nonatomic, assign) NSString* slideDirectory;	//Holds the selected directory

@property (nonatomic, retain) IBOutlet UILabel *directory;	//Shows the whole directory

@end

@protocol HistoryViewControllerDelegate

- (void)HistoryViewControllerCancel:(HistoryViewController*)controller;
- (void)HistoryViewControllerLoadHistory:(HistoryViewController*)controller directory:(NSString *)directory;

@end