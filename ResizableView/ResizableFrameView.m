//
//  ResizableFrameView.m
//  ResizableView
//
//  Created by Fran Kostella on 5/31/13.
//  Copyright (c) 2013 Sea Green Dream LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h> // for layers
#import "ResizableFrameView.h"


@implementation ResizableFrameView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Need to set these two so that background outside the path is transparent.
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;

        // This makes the view stand out from the background a bit.
        self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 8.0;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat corners = 10.0;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                               byRoundingCorners:UIRectCornerAllCorners
                                                     cornerRadii:CGSizeMake(corners, corners)];

    // Create rect and set color for the resize border.
    [[UIColor colorWithRed:0.5 green:0.7 blue:0.7 alpha:1.0] set];
    [path fill];

    // Color the center drag area covering the above with a smaller rect.
    UIBezierPath *innerPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, PAD, PAD)
                                                    cornerRadius:corners];
    [[UIColor colorWithRed:0.35 green:0.65 blue:0.75 alpha:1.0] setFill];
    [innerPath fill];

}


@end
