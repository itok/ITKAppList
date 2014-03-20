//
//  Copyright (c) 2014 itok. All rights reserved.
//



#import "ITKAppListApp.h"

@implementation ITKAppListApp

-(id) initWithJson:(NSDictionary*)json
{
	self = [super init];
	if (self) {
		_originalJson = [json copy];
	}
	return self;
}

-(NSString*) name
{
	return _originalJson[@"trackName"];
}

-(NSString*) version
{
    return _originalJson[@"version"];
}

-(NSString*) desc
{
    return _originalJson[@"description"];
}

-(NSString*) kind
{
    return _originalJson[@"kind"];
}

-(NSNumber*) appId
{
    return _originalJson[@"trackId"];
}

-(NSURL*) appStoreURL
{
	NSString* url = _originalJson[@"trackViewUrl"];
	return (url) ? [NSURL URLWithString:url] : nil;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"%@:%@(%@) %@", self.name, self.appId, self.version, self.appStoreURL];
}

@end
