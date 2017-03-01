#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "APCountry.h"
#import "APReverseGeocoding.h"
#import "APCountryInfoBuilder.h"
#import "APCountryInfoBuilderDefines.h"
#import "APPolygon.h"

FOUNDATION_EXPORT double APOfflineReverseGeocodingVersionNumber;
FOUNDATION_EXPORT const unsigned char APOfflineReverseGeocodingVersionString[];

