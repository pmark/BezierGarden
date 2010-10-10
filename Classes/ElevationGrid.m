//
//  ElevationGrid.m
//  BezierGarden
//
//  Created by P. Mark Anderson on 10/9/10.
//  Copyright 2010 Spot Metrix, Inc. All rights reserved.
//

#import "ElevationGrid.h"
#import "NSDictionary+BSJSONAdditions.h"

#define RADIUS_EQUATORIAL 6378137
#define RADIUS_POLAR 6356752.3

@implementation ElevationGrid

CLLocationDistance elevationData[ELEVATION_PATH_SAMPLES][ELEVATION_PATH_SAMPLES];

@synthesize gridOrigin;

- (void) dealloc
{
	self.gridOrigin = nil;
    [super dealloc];
}

- (id) initAroundLocation:(CLLocation*)origin
{
    if (self = [super init])
    {
        self.gridOrigin = origin;
        
        [self buildArray];
        
    }
    
    return self;
}

- (NSArray*) getChildren:(id)data parent:(NSString*)parent
{	    
    if ( ! data || [data count] == 0) 
        return nil;
    
    if ([parent length] > 0)
    {
        data = [data objectForKey:parent]; 

        if ( ! data || [data count] == 0) 
            return nil;
    }
    
    if ([data isKindOfClass:[NSArray class]]) 
        return data;
    
    if ([data isKindOfClass:[NSDictionary class]]) 
        return [NSArray arrayWithObject:data];
    
    return nil;
}

- (NSArray*) googlePathElevationBetween:(CLLocation*)point1 and:(CLLocation*)point2 samples:(NSInteger)samples
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSLog(@"[EG] Fetching elevation data...");
    
    // Build the request.
    NSString *requestURI = [NSString stringWithFormat:
                            GOOGLE_ELEVATION_API_URL_FORMAT,
                            point1.coordinate.latitude, 
                            point1.coordinate.longitude,
                            point2.coordinate.latitude, 
                            point2.coordinate.longitude,
                            samples];
    
	// Fetch the elevations from google as JSON.
    NSError *error;
    NSLog(@"[EG] URL:\n\n%@\n\n", requestURI);
	NSString *responseJSON = [NSString stringWithContentsOfURL:[NSURL URLWithString:requestURI] 
                                                  encoding:NSUTF8StringEncoding error:&error];    

    if ([responseJSON length] == 0)
    {
        NSLog(@"[EG] Empty response. %@", [error localizedDescription]);
        return nil;
    }
    
    /* Example response:
    {
        "status": "OK",
        "results": [ {}, {} ]
    }
     Status code may be one of the following:
     - OK indicating the API request was successful
     - INVALID_REQUEST indicating the API request was malformed
     - OVER_QUERY_LIMIT indicating the requestor has exceeded quota
     - REQUEST_DENIED indicating the API did not complete the request, likely because the requestor failed to include a valid sensor parameter
     - UNKNOWN_ERROR indicating an unknown error
    */
    
    // Parse the JSON response.
    id data = [NSDictionary dictionaryWithJSONString:responseJSON];

    // Get the request status.
    NSString *status = [data objectForKey:@"status"];    
    NSLog(@"[EG] Request status: %@", status);    

    // Get the result data items. See example below.
    /* 
     {
         "location": 
         {
             "lat": 36.5718491,
             "lng": -118.2620657
         },
         "elevation": 3303.3430176
     }
    */
    
	NSArray *results = [self getChildren:data parent:@"results"];        
    NSLog(@"RESULTS:\n\n%@", results);
    
    NSMutableArray *pathElevations = [NSMutableArray arrayWithCapacity:[results count]];
    
    for (NSDictionary *oneResult in results)
    {
        NSString *str = [oneResult objectForKey:@"elevation"];        
        [pathElevations addObject:str];
    }
    
    [pool release];
    
    return pathElevations;
}

- (CLLocation*) locationAtDistanceInMetersNorth:(CLLocationDistance)northMeters 
                                           East:(CLLocationDistance)eastMeters 
                                   fromLocation:(CLLocation*)origin
{
    CLLocationDegrees latitude, longitude;
    
    // Latitude
    if (northMeters == 0) 
    {
        latitude = origin.coordinate.latitude;
    }
    else
    {
        CGFloat deltaLat = atanf( (ELEVATION_LINE_LENGTH/2) / [self ellipsoidRadius:origin.coordinate.latitude]);
     	latitude = origin.coordinate.latitude + deltaLat;
    }
    
    // Longitude
    if (eastMeters == 0) 
    {
        longitude = origin.coordinate.longitude;
    }
    else
    {
        CGFloat deltaLng = atanf((ELEVATION_LINE_LENGTH/2) / [self longitudinalRadius:origin.coordinate.latitude]);
     	longitude = origin.coordinate.longitude + deltaLng;
    }
    
	return [[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] autorelease];
}

- (CLLocation*) pathEndpointFrom:(CLLocation*)startPoint
{
    return [self locationAtDistanceInMetersNorth:-ELEVATION_LINE_LENGTH
                                            East:0
                                    fromLocation:startPoint];
}

- (void) buildArray
{    
    CGFloat northStartOffsetMeters = ELEVATION_LINE_LENGTH / 2;
    CGFloat eastStartOffsetMeters = -ELEVATION_LINE_LENGTH / 2;
    CGFloat segmentLengthMeters = ELEVATION_LINE_LENGTH / ELEVATION_PATH_SAMPLES;
    
    for (int i=0; i < ELEVATION_PATH_SAMPLES; i++)
    {        
        // Make N/S lines.
        CGFloat eastOffsetMeters = eastStartOffsetMeters + (i * segmentLengthMeters);
        
        CLLocation *point1 = [self locationAtDistanceInMetersNorth:northStartOffsetMeters
                                                              East:eastOffsetMeters
                                                      fromLocation:gridOrigin];
        
        CLLocation *point2 = [self pathEndpointFrom:point1];
        
        NSArray *elevations = [self googlePathElevationBetween:point1 
                                                           and:point2 
                                                       samples:ELEVATION_PATH_SAMPLES];    

        for (int j=0; j < ELEVATION_PATH_SAMPLES; j++)
        {
            NSString *elevationString = [elevations objectAtIndex:i];
            elevationData[i][j] = [elevationString doubleValue];
        }
    }
}

- (CGFloat) ellipsoidRadius:(CLLocationDegrees)latitude
{
    CGFloat phi = latitude * M_PI / 180.0;

    CGFloat a = RADIUS_EQUATORIAL;
    CGFloat b = RADIUS_POLAR;
    
    CGFloat part1 = powf(( (a*a) * cosf(phi) ), 2);
    CGFloat part2 = powf(( (b*b) * sinf(phi) ), 2);
    CGFloat part3 = powf(( a * cosf(phi) ), 2);
    CGFloat part4 = powf(( b * sinf(phi) ), 2);
    
	return sqrtf( (part1 + part2) / (part3 + part4));
}

- (CGFloat) longitudinalRadius:(CLLocationDegrees)latitude
{
    CGFloat phi = latitude * M_PI / 180.0;
    
    return cosf(phi) * [self ellipsoidRadius:latitude];    
}


@end
