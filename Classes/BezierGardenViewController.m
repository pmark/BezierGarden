//
//  BezierGardenViewController.m
//  BezierGarden
//
//  Created by P. Mark Anderson on 10/6/10.
//  Copyright 2010 Spot Metrix, Inc. All rights reserved.
//

#import "BezierGardenViewController.h"
#import "GridView.h"
#import "NSDictionary+BSJSONAdditions.h"
#import "PDX911.h"

#define MAX_CAMERA_ALTITUDE_METERS 3000.0

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

    
    self.elevationGrid = [[[ElevationGrid alloc] initFromFile:@"elevation_grid_25km_100s.txt"] autorelease];
    
    CLLocation *theOffice = [[[CLLocation alloc] initWithLatitude:45.523563 longitude:-122.675099] autorelease];
    [sm3dar setCurrentLocation:theOffice];
    

//    self.elevationGrid = [[[ElevationGrid alloc] initFromFile:@"elevation_grid_oregon.txt"] autorelease];
//    CLLocation *centerOfOregon = [[[CLLocation alloc] initWithLatitude:46.065608 longitude:-125.496826] autorelease];
//    self.elevationGrid = [[[ElevationGrid alloc] initAroundLocation:centerOfOregon] autorelease];
//    [sm3dar setCurrentLocation:centerOfOregon];

//    CLLocation *mtHood = [[[CLLocation alloc] initWithLatitude:45.53806 longitude:-121.56722] autorelease];
//    [sm3dar setCurrentLocation:mtHood];
//    self.elevationGrid = [[[ElevationGrid alloc] initAroundLocation:mtHood] autorelease];

    
    [self addGridAtX:0 Y:0 Z:-80];
    
    NSLog(@"[BGVC] Remember to undisable location services for real positioning.");
    
    [self addCityNamePoints];
}

- (void) sm3darViewDidLoad
{
}

- (void) addGridAtX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z
{
    // Create point.
    SM3DAR_Fixture *p = [[SM3DAR_Fixture alloc] init];
    
    Coord3D coord = {
        x, y, z
    };
    
    p.worldPoint = coord;

    GridView *gridView = [[GridView alloc] init];

    // Give the point a view.
    gridView.point = p;
    p.view = gridView;
    [gridView release];
    
    // Add point to 3DAR scene.
    [sm3dar addPointOfInterest:p];
    [p release];
}

- (void) loadPointsOfInterest
{
    NSLog(@"loadPointsOfInterest");

}

- (void)viewDidLoad 
{
    [super viewDidLoad];   
    
    PDX911 *incidents = [[PDX911 alloc] init];
    [incidents parseIncidents];
    [incidents release];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[sm3dar startCamera];    
}

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
    NSLog(@"[BGVC] didReceiveMemoryWarning");
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    NSLog(@"[BGVC] viewDidUnload");
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
    [manager stopUpdatingLocation];

    NSLog(@"[BGVC] New location: %@", newLocation);
    
    // Fetch elevation grid points around current location
    //self.elevationGrid = [[[ElevationGrid alloc] initAroundLocation:newLocation] autorelease];    

    // Load elevation grid from cache.
    //self.elevationGrid = [[[ElevationGrid alloc] initFromCache] autorelease];
    
    // Load elevation grid from bundled data file.
//    self.elevationGrid = [[[ElevationGrid alloc] initFromFile:@"elevation_grid.txt"] autorelease];
//
//    [self addGridAtX:0 Y:0 Z:-100];

    
}


#pragma mark -

- (void) addCityNamePoints
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"pdx_cities" ofType:@"json"];            
    NSError *error = nil;
    NSLog(@"[BGVC] Loading cities from %@", filePath);
    NSString *citiesJSON = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    if (error)
    {
        NSLog(@"[BGVC] ERROR parsing cities: ", [error localizedDescription]);
    }
    else
    {
/*
 {"geonames":[
                     
 {"fcodeName":"populated place", "countrycode":"US", "fcl":"P", "fclName":"city,village,...", "name":"Portland", "wikipedia":"en.wikipedia.org/wiki/Portland", 
 "lng":-122.6762071, "fcode":"PPL", "geonameId":5746545, 
 "lat":45.5234515, "population":540513},
*/
                     
        NSDictionary *data = [NSDictionary dictionaryWithJSONString:citiesJSON];
        
        NSArray *cities = [data objectForKey:@"geonames"];
        
        NSMutableArray *allPoints = [NSMutableArray arrayWithCapacity:[cities count]];
        
        for (NSDictionary *city in cities)
        {
            NSString *poiTitle = [city objectForKey:@"name"];
            NSString *poiSubtitle = [city objectForKey:@"population"];
            NSString *latString = [city objectForKey:@"lat"];
            NSString *lngString = [city objectForKey:@"lng"];

            CLLocationDegrees latitude = [latString doubleValue];
            CLLocationDegrees longitude = [lngString doubleValue];
            
            SM3DAR_Point *point = [sm3dar initPointOfInterestWithLatitude:latitude 
                                          longitude:longitude 
                                           altitude:0 
                                              title:poiTitle 
                                           subtitle:poiSubtitle 
                                    markerViewClass:[SM3DAR_IconMarkerView class] 
                                         properties:nil];
            
            [allPoints addObject:point];
            [point release];            
        }

        
        [sm3dar addPointsOfInterest:allPoints];
        
    }
	    
}


@end
