//
//  APCountry.h
//  APReverseGeocodingExample
//
//  Created by Sergii Kryvoblotskyi on 4/15/15.
//  Copyright (c) 2015 Sergii Kryvoblotskyi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PSPDF_NOT_DESIGNATED_INITIALIZER() PSPDF_NOT_DESIGNATED_INITIALIZER_CUSTOM(init)
#define PSPDF_NOT_DESIGNATED_INITIALIZER_CUSTOM(initName) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wobjc-designated-initializers\"") \
- (instancetype)initName \
{ do { \
NSAssert2(NO, @"%@ is not the designated initializer for instances of %@.", NSStringFromSelector(_cmd), NSStringFromClass([self class])); \
return nil; \
} while (0); } \
_Pragma("clang diagnostic pop")

@interface APCountry : NSObject

/**
 *  Convenience initializer
 *
 *  @param dictionary NSDictionary with json data. See more here:
 *  https://github.com/johan/world.geo.json
 *
 *  @return APCountry
 */
+ (instancetype)countryWithGEODictionary:(NSDictionary *)dictionary;

/**
 *  Designated initializer.
 *
 *  @param dictionary NSDictionary See +countryWithGEODictionary:(NSDictionary *)
 *
 *  @return APCountry
 */
- (instancetype)initWithGeoDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

/* Represents country 3 digits code ISO 3166-1 Alpha 3 */
@property (nonatomic, copy, readonly) NSString *code;

/* Represents country 2 digits code ISO 3166-1 Alpha 2 */
@property (nonatomic, copy, readonly) NSString *shortCode;

/* Represents country name */
@property (nonatomic, copy, readonly) NSString *name;

/* Represents country name in current locale */
@property (nonatomic, copy, readonly) NSString *localizedName;

/* Represents country currency code */
@property (nonatomic, copy, readonly) NSString *currencyCode;

/* Represents country currency symbol */
@property (nonatomic, copy, readonly) NSString *currencySymbol;

/* Represents country calendar */
@property (nonatomic, strong, readonly) NSCalendar *calendar;

@end

@interface APCountry (Unavailable)

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end
