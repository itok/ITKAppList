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

-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		_originalJson = [aDecoder decodeObjectForKey:@"json"];
		self.artwork = [aDecoder decodeObjectForKey:@"artwork"];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.originalJson forKey:@"json"];
	if (self.artwork) {
		[aCoder encodeObject:self.artwork forKey:@"artwork"];
	}
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
