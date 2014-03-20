//
//  Copyright (c) 2014 itok. All rights reserved.
//

// http://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html

#import <Foundation/Foundation.h>

typedef void(^ITKAppListRequestHandler)(NSArray* list, NSError* error);

// platform mask : iOS or Mac
typedef NS_ENUM(UInt8, ITKAppListRequestKindMask) {
	ITKAppListRequestKindMaskIOS = 1 << 0,
	ITKAppListRequestKindMaskMac = 1 << 1,

	ITKAppListRequestKindMaskAll = 0xFF,
};

// artwork size
typedef NS_ENUM(UInt8, ITKAppListRequestArtwork) {
	ITKAppListRequestArtworkSmall = 0, // 57px
	ITKAppListRequestArtworkLarge = 1, // 512 or 1024px if exists
	
	ITKAppListRequestArtworkDefault = ITKAppListRequestArtworkSmall,
};

@interface ITKAppListRequest : NSObject

// country code : http://en.wikipedia.org/wiki/%20ISO_3166-1_alpha-2
@property (nonatomic, copy) NSString* countryCode;
// additional search parameters : http://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html
@property (nonatomic, strong) NSDictionary* searchParameters;
// platform mask
@property (nonatomic) ITKAppListRequestKindMask kindMask;
// artwork size
@property (nonatomic) ITKAppListRequestArtwork artworkSize;
// exclude app is list (array of NSNumber)
@property (nonatomic, strong) NSArray* excludeList;

-(void) performRequest:(NSString*)artistId handler:(ITKAppListRequestHandler)handler;

+(void) clearAllCache;

@end
