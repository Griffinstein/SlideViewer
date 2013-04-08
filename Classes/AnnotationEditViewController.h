//
//  AnnotationEditViewController.h
//  iSlideViewer
//
//  Created by Ed on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AnnotationEditViewControllerDelegate;

@interface AnnotationEditViewController : UIViewController {
	<AnnotationEditViewControllerDelegate>	delegate;
	
	IBOutlet UITextField					*titleField;
	IBOutlet UITextField					*descriptionField;
	
	UILabel									*titleLabel;
	UILabel									*descriptionLabel;
	
	UIImageView								*thumbnail;
}

- (void) addText:(NSString *)Title Description:(NSString *)Description;
- (void) drawThumbnail:(NSString *)Slide SlideDirectory:(NSString *)SlideDirectory Height:(int)Height Width:(int)Width xCoord:(int)xCoord yCoord:(int)yCoord Zoom:(float)Zoom;

- (IBAction) done;
- (IBAction) deleteAnnotation;

@property (nonatomic, assign) id <AnnotationEditViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, retain) IBOutlet UIImageView *thumbnail;	//The image used to represent the thumbnail

@end

@protocol AnnotationEditViewControllerDelegate

- (void)AnnotationEditViewControllerDidFinish:(AnnotationEditViewController*)controller;
- (void)AnnotationEditDelete:(AnnotationEditViewController*)controller;

@end