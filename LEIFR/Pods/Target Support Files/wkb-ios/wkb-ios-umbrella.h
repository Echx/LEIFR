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

#import "WKBCircularString.h"
#import "WKBCompoundCurve.h"
#import "WKBCurve.h"
#import "WKBCurvePolygon.h"
#import "WKBGeometry.h"
#import "WKBGeometryCollection.h"
#import "WKBGeometryEnvelope.h"
#import "WKBGeometryTypes.h"
#import "WKBLineString.h"
#import "WKBMultiCurve.h"
#import "WKBMultiLineString.h"
#import "WKBMultiPoint.h"
#import "WKBMultiPolygon.h"
#import "WKBMultiSurface.h"
#import "WKBPoint.h"
#import "WKBPolygon.h"
#import "WKBPolyhedralSurface.h"
#import "WKBSurface.h"
#import "WKBTIN.h"
#import "WKBTriangle.h"
#import "WKBByteReader.h"
#import "WKBByteWriter.h"
#import "WKBGeometryReader.h"
#import "WKBGeometryWriter.h"
#import "WKBGeometryEnvelopeBuilder.h"
#import "WKBGeometryJSONCompatible.h"
#import "WKBGeometryPrinter.h"
#import "wkb-ios-Bridging-Header.h"
#import "wkb_ios.h"

FOUNDATION_EXPORT double wkb_iosVersionNumber;
FOUNDATION_EXPORT const unsigned char wkb_iosVersionString[];

