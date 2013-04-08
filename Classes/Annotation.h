//
//  Annotation.h
//  iSlideViewer
//
//  Created by Ed on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Annotation : NSObject {
	
	CGPoint			position;
	CGPoint			centre;
	int				height;
	int				width;
	double			zoom;
	UILabel			*description;
	UILabel			*title;
	UIImageView		*frame;
}

- (void)updateDescription;
- (void)updateTitle;
- (void)remove;
- (void)finishCreating;
- (void)update:(CGPoint)slidePosition Zoom:(double)Zoom;
- (void)create:(CGPoint)Position Height:(int)Height Width:(int)Width Zoom:(double)Zoom;
- (BOOL)onAnnotation:(CGPoint)slidePosition clickPosition:(CGPoint)clickPosition Zoom:(double)Zoom;

@property (readwrite) CGPoint position;
@property (readwrite) CGPoint centre;
@property (readwrite) int height;
@property (readwrite) int width;
@property (readwrite) double zoom;
@property (nonatomic, retain) IBOutlet UIImageView *frame;
@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *description;

@end
