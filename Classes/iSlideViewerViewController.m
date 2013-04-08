//
//  iSlideViewerViewController.m
//  iSlideViewer
//
//  Created by Ed on 2/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//PASSWORD PROTECTION CAN BE INPUT HERE

#import "iSlideViewerViewController.h"

@implementation iSlideViewerViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Creates a timer for the interval between each display of falling words:
	[NSTimer scheduledTimerWithTimeInterval:0 target:self
								   selector:@selector(Update) userInfo:Nil
									repeats:NO];
}

//Will call the mainMenu method once
-(void)Update{
	[self mainMenu];
}

//Creates the MainMenu view
- (void)mainMenu {
	MainMenuViewController *controller = [[MainMenuViewController alloc] initWithNibName:@"MainMenuViewController"bundle:nil];
	
	//Creates Model View
	controller.modalPresentationStyle = UIModalPresentationFullScreen;	
	controller.delegate = self;
	
	//Presents the animated Modal View
	[self presentModalViewController:controller animated:NO];
	
	[controller release];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
