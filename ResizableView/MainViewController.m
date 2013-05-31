//
//  MainViewController.m
//  ResizableView
//
//  Created by Fran Kostella on 5/30/13.
//  Copyright (c) 2013 Sea Green Dream LLC. All rights reserved.
//

#import "MainViewController.h"
#import "ResizableFrameView.h"


@interface MainViewController ()
- (CGRect)forceFrameToStayVisible:(CGRect)oldFrame;
@end

@implementation MainViewController {

    CGRect containerFrame;              // The frame for this view.
    ResizableFrameView *resizableView;  // The target view.

    UIPanGestureRecognizer *panGesture;
    UIPinchGestureRecognizer *pinchGesture;

    // These direction flags store the movement direction from pan gesture event to event.
    int xDirection;
    int yDirection;
}

// MainViewController *vc = [[MainViewController alloc] init];
- (id)init
{
    if (self) {
        xDirection = 0;
        yDirection = 0;
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [self init]; // above
    if (self) {
        containerFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    }
    return self;
}


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (nibBundleOrNil) {
        ALog(@"\n\t\t DO NOT CALL THIS! Creating view in code.\n\n");
    }
    return [self init];
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    UIView *mainView = [[UIView alloc] initWithFrame:containerFrame];
    mainView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.view = mainView;

    // Make a view with some arbitrary size.
    resizableView = [[ResizableFrameView alloc] initWithFrame:CGRectMake(50, 50, 220, 220)];
    [self.view addSubview:resizableView];

    // The pan gesture detects movement and resize by touches on the edges.
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [panGesture setMaximumNumberOfTouches:1];
    [resizableView addGestureRecognizer:panGesture];

    // The pinch gesture scales the entire larger or smaller.
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [resizableView addGestureRecognizer:pinchGesture];
}


// Force some sane position and size on the frame.
- (CGRect) forceFrameToStayVisible:(CGRect)oldFrame
{
    return CGRectMake(
            MAX(0, MIN(oldFrame.origin.x, self.view.bounds.size.width - PAD)),
            MAX(0, MIN(oldFrame.origin.y, self.view.bounds.size.height - PAD)),
            MAX(oldFrame.size.width, PAD),
            MAX(oldFrame.size.height, PAD));
}


// Determine how much to change the shape or position of the view and apply it.
- (void)panView:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
        [gestureRecognizer state] == UIGestureRecognizerStateChanged) {

        CGPoint touchInThisView = [gestureRecognizer locationInView:resizableView];

        // If on edges, mark -1 for touch on decreasing coord side, +1 for increasing, 0 for middle.
        if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
            xDirection = (touchInThisView.x < PAD) ? -1 : (touchInThisView.x > (resizableView.frame.size.width - PAD)) ? 1 : 0;
            yDirection = (touchInThisView.y < PAD) ? -1 : (touchInThisView.y > (resizableView.frame.size.height - PAD)) ? 1 : 0;
        }

        // Take current frame and modify it according to known direction and change in touch.
        CGRect frame = resizableView.frame;
        CGPoint translation = [gestureRecognizer translationInView:self.view];
        float xCenterOffset = translation.x;
        float yCenterOffset = translation.y;

        if (xDirection != 0) { // User is touching an edge on sides.
            xCenterOffset = 0;
            if (xDirection > 0) { // Touch on right side edge, leave left side as is.
                frame.size.width = frame.size.width + translation.x; // Increase right by translation amount.
            } else { // Must be touching on left side edge.
                frame.origin.x = frame.origin.x + translation.x; // Move left by translation amount.
                frame.size.width = frame.size.width - translation.x; // Subtract negative translation value.
            }
        } else if (yDirection != 0) { // User touching inside, ignore X offset.
            frame.origin.x = resizableView.frame.origin.x;
            xCenterOffset = 0;
        }

        if (yDirection != 0) { // User is touching an edge, top or bottom.
            yCenterOffset = 0;
            if (yDirection > 0) { // Touch on bottom edge, leave top as is.
                frame.size.height = frame.size.height + translation.y;  // Increase by positive translation.
            } else { // Must be touch on top edge.
                frame.origin.y = frame.origin.y + translation.y; // Move top up by adding negative translation value.
                frame.size.height = frame.size.height - translation.y; // Subtract negative translation value.
            }
        } else if (xDirection != 0) { // Then ignore Y offset if we are not in center.
            frame.origin.y = resizableView.frame.origin.y;
            yCenterOffset = 0;
        }

        // Then apply to view, but force a sane CGRect.
        resizableView.frame = [self forceFrameToStayVisible:frame];

        CGPoint newcenter = CGPointMake([resizableView center].x +  xCenterOffset, [resizableView center].y + yCenterOffset);
        [resizableView setCenter:newcenter];
        [gestureRecognizer setTranslation:CGPointZero inView:self.view];

        // NOTE: Skip this setNeedsDisplay depending on the application's needs. Comment out to see why.
        [resizableView setNeedsDisplay];

    } else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        xDirection = 0;
        yDirection = 0;
        [resizableView setNeedsDisplay]; // On the final event have it redraw.
    }
}


// Scale the frame by the current scale and set the scale to 1 after applying so the next
// call is a delta from the current scale.
- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
        [gestureRecognizer state] == UIGestureRecognizerStateChanged) {

        // Apply the scale to size and fudge the number by dividing by a constant.
        float delta = MIN(((resizableView.frame.size.width * [gestureRecognizer scale]) - resizableView.frame.size.width),
                      ((resizableView.frame.size.height * [gestureRecognizer scale]) - resizableView.frame.size.height)) / 4.0;

        // Alternately, take the velocity as the delta, which is inaccurate. A Hack.
        //float delta = 2.0 * [gestureRecognizer velocity];

        CGRect frame = CGRectMake(resizableView.frame.origin.x - delta, resizableView.frame.origin.y - delta,
                resizableView.frame.size.width + delta + delta, resizableView.frame.size.height + delta + delta);

        resizableView.frame = [self forceFrameToStayVisible:frame];
        [gestureRecognizer setScale:1];

        // NOTE: Skip this setNeedsDisplay depending on the application's needs. Comment out to see why.
        [resizableView setNeedsDisplay];

    } else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [resizableView setNeedsDisplay]; // On the final event have it redraw.
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
