//
//  APReverseGeocoding.m
//  APReverseGeocodingExample
//
//  Created by Sergii Kryvoblotskyi on 4/15/15.
//  Copyright (c) 2015 Sergii Kryvoblotskyi. All rights reserved.
//

#import "APReverseGeocoding.h"
#import "APPolygon.h"

static NSString *const APReverseGeocodingDefaultDBName = @"countries.geo";
static NSString *const APReverseGeocodingCountriesKey  = @"features";

@interface APReverseGeocoding ()

@property (nonatomic, strong, readwrite) NSArray *countries;
@property (nonatomic, strong, readwrite) NSDictionary *geoJSON;

@end

@implementation APReverseGeocoding

PSPDF_NOT_DESIGNATED_INITIALIZER_CUSTOM(init)

+ (instancetype)defaultGeocoding
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:APReverseGeocodingDefaultDBName withExtension:@"json"];
    return [self geocodingWithGeoJSONURL:url];
}

+ (instancetype)geocodingWithGeoJSONURL:(NSURL *)url
{
    return [[self alloc] initWithGeoJSONURL:url];
}

- (instancetype)initWithGeoJSONURL:(NSURL *)url
{
    NSParameterAssert(url);
    self = [super init];
    if (self) {
        _url = url;
    }
    return self;
}

#pragma mark - Public

- (APCountry *)geocodeCountryWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    return [self _geocodeCountryWithCoordinate:coordinate];
}

- (MKCoordinateRegion) regionForCountryWithCode:(NSString *)countryCode {
	NSArray *countryData = self.countries;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", countryCode];
	NSDictionary *countryDict = [countryData filteredArrayUsingPredicate:predicate].firstObject;
	
	NSDictionary *geometry = [countryDict objectForKey:@"geometry"];
	NSString *geometryType = [geometry valueForKey:@"type"];
	NSArray *coordinates = [geometry objectForKey:@"coordinates"];
	
	double minLat = CGFLOAT_MAX;
	double minLon = CGFLOAT_MAX;
	double maxLat = CGFLOAT_MIN;
	double maxLon = CGFLOAT_MIN;
	
	BOOL modified = NO;
	
	if ([geometryType isEqualToString:@"Polygon"]) {
		NSArray *polygonPoints  = [coordinates objectAtIndex:0];
		for (NSArray *points in polygonPoints) {
			minLat = MIN(minLat, [points[1] doubleValue]);
			maxLat = MAX(maxLat, [points[1] doubleValue]);
			minLon = MIN(minLon, [points[0] doubleValue]);
			maxLon = MAX(maxLon, [points[0] doubleValue]);
			modified = YES;
		}
	} else if([geometryType isEqualToString:@"MultiPolygon"]){
		for (int j = 0; j < [coordinates count]; j++){
			NSArray *polygonPoints = [[coordinates objectAtIndex:j] objectAtIndex:0];
			for (NSArray *points in polygonPoints) {
				minLat = MIN(minLat, [points[1] doubleValue]);
				maxLat = MAX(maxLat, [points[1] doubleValue]);
				minLon = MIN(minLon, [points[0] doubleValue]);
				maxLon = MAX(maxLon, [points[0] doubleValue]);
				modified = YES;
			}
		}
	}
	
	if (modified) {
		CLLocationCoordinate2D center = CLLocationCoordinate2DMake((minLat + maxLat) / 2, (minLon + maxLon) / 2);
		MKCoordinateSpan span = MKCoordinateSpanMake((maxLat - minLat), (maxLon - minLon));
		return MKCoordinateRegionMake(center, span);
	} else {
		return MKCoordinateRegionForMapRect(MKMapRectWorld);
	}
}

#pragma mark - Private

- (APCountry *)_geocodeCountryWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSArray *countryData = self.countries;

    for (int i = 0; i < [countryData count]; i++){
		
        NSDictionary *countryDict = [countryData objectAtIndex:i];
        NSDictionary *geometry = [countryDict objectForKey:@"geometry"];
        NSString *geometryType = [geometry valueForKey:@"type"];
        NSArray *coordinates = [geometry objectForKey:@"coordinates"];
        
        /* Check the polygon type */
        if ([geometryType isEqualToString:@"Polygon"]) {
            
            /* Create the polygon */
            NSArray *polygonPoints  = [coordinates objectAtIndex:0];
            APPolygon *polygon = [APPolygon polygonWithPoints:polygonPoints];
            
            /* Cehck containment */
            if ([polygon containsLocation:coordinate]) {
                return [APCountry countryWithGEODictionary:countryDict];
            }

        /* Loop through all sub-polygons and make the checks */
        } else if([geometryType isEqualToString:@"MultiPolygon"]){
            for (int j = 0; j < [coordinates count]; j++){
                
                NSArray *polygonPoints = [[coordinates objectAtIndex:j] objectAtIndex:0];
                APPolygon *polygon = [APPolygon polygonWithPoints:polygonPoints];
                
                if([polygon containsLocation:coordinate]) {
                    return [APCountry countryWithGEODictionary:countryDict];
                }
            }
        }
    }
    return nil;
}

#pragma mark - Lazy Accessors

- (NSArray *)countries
{
    if (!_countries) {
        _countries = self.geoJSON[APReverseGeocodingCountriesKey];
    }
    return _countries;
}

- (NSDictionary *)geoJSON
{
    if (!_geoJSON) {
        
        NSError *error = nil;
        NSData *jsonData = [[NSData alloc] initWithContentsOfURL:self.url];
        NSDictionary *parsedJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        
        if (!error) {
            _geoJSON = [parsedJSON copy];
        } else {
            [NSException raise:@"Cannot parse JSON." format:@"JSON URL - %@\nError:%@", self.url, parsedJSON];
        }
    }
    return _geoJSON;
}

@end
