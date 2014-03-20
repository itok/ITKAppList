//
//  Copyright (c) 2014 itok. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface ITKAppListApp : NSObject

@property (nonatomic, strong, readonly) NSString* name;
@property (nonatomic, strong, readonly) NSString* version;
@property (nonatomic, strong, readonly) NSString* kind;
@property (nonatomic, strong, readonly) NSString* desc;
@property (nonatomic, strong, readonly) NSNumber* appId;
@property (nonatomic, strong) UIImage* artwork;
@property (nonatomic, strong, readonly) NSDictionary* originalJson;
@property (nonatomic, strong, readonly) NSURL* appStoreURL;

-(id) initWithJson:(NSDictionary*)json;

@end
