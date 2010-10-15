//
//  BezierGardenViewController.m
//  BezierGarden
//
//  Created by P. Mark Anderson on 10/6/10.
//  Copyright 2010 Spot Metrix, Inc. All rights reserved.
//

#import "BezierGardenViewController.h"
#import "GridView.h"

#define MAX_CAMERA_ALTITUDE_METERS 12000.0
#define ALTITUDE_INTERVAL_METERS 2

@implementation BezierGardenViewController

@synthesize elevationGrid;

- (void)dealloc 
{
    self.elevationGrid = nil;
    [super dealloc];
}


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) 
    {
    }
    return self;
}

- (void) loadView 
{
    sm3dar = [SM3DAR_Controller sharedController];
    sm3dar.delegate = self;
    sm3dar.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    self.view = sm3dar.view;
}

- (void) addDotAtX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z
{
    // Create point.
    SM3DAR_Fixture *p = [[SM3DAR_Fixture alloc] init];
    
    Coord3D coord = {
        x, y, z
    };
    
    p.worldPoint = coord;

    GridView *dotView = [[GridView alloc] init];

    // Give the point a view.
    dotView.point = p;
    p.view = dotView;
    [dotView release];
    
    // Add point to 3DAR scene.
    [sm3dar addPointOfInterest:p];
    [p release];
}

- (void) loadPointsOfInterest
{
    NSLog(@"loadPointsOfInterest");

}

- (void)viewDidLoad {
    [super viewDidLoad];    
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


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];    
    CGPoint touchPoint = [touch locationInView:self.view];
    [self screenTouched:touchPoint];    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];

    [self screenTouched:touchPoint];    
}

#pragma mark Touches

- (void) screenTouched:(CGPoint)p {
    CGFloat max = MAX_CAMERA_ALTITUDE_METERS;
    CGFloat altitude = (p.y / 480.0) * max;
    
    sm3dar.cameraAltitudeMeters = altitude;
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"[BGVC] New location: %@", newLocation);
    
    //self.elevationGrid = [[[ElevationGrid alloc] initAroundLocation:newLocation] autorelease];

    [self addDotAtX:0 Y:0 Z:50];
    

    [manager stopUpdatingLocation];
}


@end
