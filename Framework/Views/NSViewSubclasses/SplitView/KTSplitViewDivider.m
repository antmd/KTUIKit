//
//  KTSplitViewDivider.m
//  KTUIKit
//
//  Created by Cathy on 30/03/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import "KTSplitViewDivider.h"
#import "KTSplitView.h"
#import <Quartz/Quartz.h>

@interface NSObject (KTSplitViewDividerSplitView)
- (void)dividerAnimationDidEnd;
@end

@interface KTSplitViewDivider ()
@property (nonatomic, readwrite, retain) NSCursor * currentCursor;
@end

@interface KTSplitViewDivider (Private)
- (void)_resetTrackingArea;
- (NSRect)_trackingRect;
- (void)_setCursor:(NSCursor *)theCursor;
@end

@implementation KTSplitViewDivider
@synthesize splitView = wSplitView;
@synthesize isInDrag = mIsInDrag;
@synthesize currentCursor = mCurrentCursor;

//=========================================================== 
// - initWithSplitView
//===========================================================
- (id)initWithSplitView:(KTSplitView*)theSplitView
{
	if(self = [self initWithFrame:NSZeroRect])
	{
		wSplitView = theSplitView;
		[self _resetTrackingArea];
	}
	return self;
}


//=========================================================== 
// - initWithFrame
//===========================================================
- (id)initWithFrame:(NSRect)theFrame
{
	if(self = [super initWithFrame:theFrame])
	{
		[self _resetTrackingArea];
	}
	return self;
}

//=========================================================== 
// - initWithCoder
//===========================================================
- (id)initWithCoder:(NSCoder*)theCoder
{
	if(self = [super initWithCoder:theCoder])
	{
		[self _resetTrackingArea];
	}
	return self;
}

//=========================================================== 
// - dealloc
//===========================================================
- (void)dealloc
{
	[mTrackingArea release];
	[mCurrentCursor release];
	[super dealloc];
}


//=========================================================== 
// - _resetTrackingArea
//===========================================================
- (void)_resetTrackingArea
{
	if([[self splitView] userInteractionEnabled] == NO)
		return;
		
	if(mTrackingArea)
	{
		[self removeTrackingArea:mTrackingArea];
		[mTrackingArea release];
	}
	NSRect	aTrackingRect = [self _trackingRect];
	mTrackingArea = [[NSTrackingArea alloc] initWithRect:aTrackingRect
												 options:(NSTrackingActiveInActiveApp | NSTrackingMouseEnteredAndExited | NSTrackingAssumeInside | NSTrackingEnabledDuringMouseDrag) 
												   owner:self userInfo:nil];
	[self addTrackingArea:mTrackingArea];	
}

//=========================================================== 
// - _trackingRect
//===========================================================
- (NSRect)_trackingRect
{
	NSRect	aTrackingRect = [self bounds];
	CGFloat	aPadding = 7;
	if([[self splitView] dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
	{
		if(aTrackingRect.size.height < aPadding)
		{
			CGFloat aCenterY = NSMidY(aTrackingRect);
			aTrackingRect.size.height = aPadding;
			aTrackingRect.origin.y = aCenterY - aPadding*.5;
		}
	}
	else
	{
		if(aTrackingRect.size.width < aPadding)
		{
			CGFloat aCenterX = NSMidX(aTrackingRect);
			aTrackingRect.size.width = aPadding;
			aTrackingRect.origin.x = aCenterX - aPadding*.5;
		}
	}
	return aTrackingRect;
}

//=========================================================== 
// - setFrame:time
//===========================================================
- (void)setFrame:(NSRect)theFrame
{	
//	if([[self splitView] dividerOrientation] == KTSplitViewDividerOrientation_Vertical)
//		theFrame.origin.x-=(theFrame.size.width*.5);
//	else
//		theFrame.origin.y-=(theFrame.size.height*.5);
		
//	//NSLog(@"%@ setFrame:", self);
//	if([[self splitView] dividerOrientation] == KTSplitViewDividerOrientation_Vertical)
//	{
//		// clip min & max positions
//		float aPositionToCheck = 0;//[self minPosition];
//		
//		if(		aPositionToCheck > 0
//			&&	theFrame.origin.x <= aPositionToCheck)
//		{
//			theFrame.origin.x = aPositionToCheck;
//			if(mIsInDrag == YES)
//				[[NSCursor resizeRightCursor] set];
//		}
//		
//		aPositionToCheck = 0;//[self maxPosition];
//		if(		aPositionToCheck > 0
//			&&	theFrame.origin.x >= aPositionToCheck)
//		{
//			theFrame.origin.x = aPositionToCheck;
//			if(mIsInDrag == YES)
//				[[NSCursor resizeLeftCursor] set];
//		}
//	}
//	else if([[self splitView] dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
//	{
//		float aPositionToCheck = 0;//[self minPosition];
//		if(		aPositionToCheck > 0
//			&&	theFrame.origin.y < aPositionToCheck)
//		{
//			theFrame.origin.y = aPositionToCheck;
//			if(mIsInDrag == YES)
//				[[NSCursor resizeUpCursor] set];
//		}	
//		
//		aPositionToCheck = 0;//[self maxPosition];
//		if(		aPositionToCheck > 0
//			&&	theFrame.origin.y >= aPositionToCheck)
//		{
//			theFrame.origin.y = aPositionToCheck;
//			if(mIsInDrag == YES)
//				[[NSCursor resizeDownCursor] set];
//		}
//	}

	
	[super setFrame:theFrame];
	[self _resetTrackingArea];
//	[[self splitView] resetResizeInformation];
	[[self splitView] layoutViews];
}

//=========================================================== 
// - hitTest
//===========================================================
- (NSView*)hitTest:(NSPoint)thePoint
{
	if([[self splitView] userInteractionEnabled] == NO)
		return nil;
		
	if(NSPointInRect([self convertPoint:thePoint fromView:nil], [mTrackingArea rect]))
		return self;
	else
		return [super hitTest:thePoint];
}


//=========================================================== 
// - mouseDown
//===========================================================
- (void)mouseDown:(NSEvent*)theEvent
{
	if([[self splitView] userInteractionEnabled] == NO)
		return;
	
	NSEvent *anUpOrDraggedEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask|NSLeftMouseUpMask)];
	while ([anUpOrDraggedEvent type] != NSLeftMouseUp) {
		[self mouseDragged:anUpOrDraggedEvent];
		anUpOrDraggedEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask|NSLeftMouseUpMask)]; // Block until we get an up or dragged event. If multiple events come in, |anUpOrDraggedEvent| will be the oldest in the queue.
		if ([anUpOrDraggedEvent type] == NSLeftMouseUp) {
			break;
		}
		
		// |anUpOrDraggedEvent| is a dragged event. See if there are any NSLeftMouseUp events that may have also come in. +[NSDate distantPast] makes us wait with zero timeout.
		NSEvent *anUpEvent = [[self window] nextEventMatchingMask:NSLeftMouseUpMask untilDate:[NSDate distantPast] inMode:NSEventTrackingRunLoopMode dequeue:YES];
		if (anUpEvent != nil) {
			// |anUpEvent| may not be the most recent in the queue, discard any possible preceding (unhandled) drag events.
			[[self window] discardEventsMatchingMask:NSLeftMouseDraggedMask beforeEvent:anUpEvent];
			break;
		}
		
		// There were no NSLeftMouseUp events in the queue. Eat up any pending drag events until there's nothing left in the queue. If we don't we try to process too many drag events and the split view lags the mouse when the views are expensive to draw/resize.
		// +[NSDate distantPast] ensures that we don't block until a new event comes it if there's nothing in the queue.
		NSEvent *anEatenEvent = nil;
		do {
			anEatenEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask) 
													  untilDate:[NSDate distantPast] 
														 inMode:NSEventTrackingRunLoopMode 
														dequeue:YES];
		} while (anEatenEvent != nil);
		
	}
	[self mouseUp:anUpOrDraggedEvent];
}


//=========================================================== 
// - mouseDragged
//===========================================================
- (void)mouseDragged:(NSEvent*)theEvent
{
	if([[self splitView] userInteractionEnabled] == NO)
		return;
		
	NSPoint	aMousePoint = [[self splitView] convertPoint:[theEvent locationInWindow] fromView:nil];
	NSRect	aSplitViewBounds = [[self splitView] bounds];
	NSRect	aSplitViewFrame = [[self splitView] frame];
	NSRect	aDividerBounds = [self bounds];
	NSRect	aDividerFrame = [self frame];
	
	if([[self splitView] dividerOrientation]  == KTSplitViewDividerOrientation_Horizontal)
	{
		float aPoint = floor(aMousePoint.y - aDividerBounds.size.height*.5);
		
		if(		aPoint >= aSplitViewBounds.origin.x 
			&&	aPoint <= aSplitViewFrame.size.height-aDividerBounds.size.height )
		{
			[[NSCursor resizeUpDownCursor] set];
			NSRect aRect = aDividerFrame;
			[self setFrame:NSMakeRect(aRect.origin.x, aPoint,
									  aRect.size.width, aRect.size.height) ];
		}
	}
	else 
	{
		float aPoint = floor(aMousePoint.x-aDividerBounds.size.width*.5);
		if(aPoint >= aSplitViewBounds.origin.y && aPoint <= aSplitViewFrame.size.width-aDividerBounds.size.width)
		{
			[[NSCursor resizeLeftRightCursor] set];
			NSRect aRect = aDividerFrame;
			[self setFrame:NSMakeRect(aPoint, aRect.origin.y,
									  aRect.size.width, aRect.size.height) ];
			
		}
	}
	mIsInDrag = YES;
}



//=========================================================== 
// - mouseUp
//===========================================================
- (void)mouseUp:(NSEvent*)theEvent
{
	if([[self splitView] userInteractionEnabled] == NO)
		return;
		
//	NSLog(@"%@ mouseUP", self);
	mIsInDrag = NO;
	[self _resetTrackingArea];
	[[self splitView] resetResizeInformation];
//	[[self window] enableCursorRects];
}


//=========================================================== 
// - mouseEntered
//===========================================================
- (void)mouseEntered:(NSEvent*)theEvent
{	
	if([[self splitView] userInteractionEnabled] == NO)
		return;
		
	if([[self splitView] userInteractionEnabled])
	{
		if([[self splitView] dividerOrientation]  == KTSplitViewDividerOrientation_Horizontal)
		{
//			NSLog(@"setting up/down cursor");
			[self _setCursor:[NSCursor resizeUpDownCursor]];
		}
		else
		{
//			NSLog(@"setting left/right cursor");	
			[self _setCursor:[NSCursor resizeLeftRightCursor]];	
		}
	}
}


//=========================================================== 
// - refreshCursors
//===========================================================
- (void)refreshCursors
{
	if([[self splitView] userInteractionEnabled] == NO)
		return;
		
	if([[self splitView] dividerOrientation]  == KTSplitViewDividerOrientation_Horizontal)
	{
		//NSLog(@"setting up/down cursor");
		[self _setCursor:[NSCursor resizeUpDownCursor]];
	}
	else
	{
		//NSLog(@"setting left/right cursor");	
		[self _setCursor:[NSCursor resizeLeftRightCursor]];	
	}
}

//=========================================================== 
// - _setCursor
//===========================================================
- (void)_setCursor:(NSCursor*)theCursor
{
	if([[self splitView] userInteractionEnabled] == NO)
		return;
		
	if([[self window] isKeyWindow] == NO)
		return;
	if(theCursor)
	{	
		[NSCursor unhide];
		[theCursor set];
		[self addCursorRect:[self _trackingRect] cursor:theCursor];
		[self setCurrentCursor:theCursor];
	}
}


//=========================================================== 
// - resetCursorRects
//===========================================================
- (void)resetCursorRects
{
	if([[self splitView] userInteractionEnabled] == NO)
		[super resetCursorRects];
		
	//NSLog(@"reset cursor rects");
	if([self currentCursor] != nil)
		[self addCursorRect:[self _trackingRect] cursor:[self currentCursor]];
}


@end
