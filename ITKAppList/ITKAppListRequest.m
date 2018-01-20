//
//  Copyright (c) 2014 itok. All rights reserved.
//


#import "ITKAppListRequest.h"
#import "ITKAppListApp.h"

static NSString* s_cacheDir = nil;

@interface ITKAppListRequest ()
{
	NSOperationQueue* queue;
	NSMutableArray* artworkQueue;
	NSMutableArray* appList;
	NSDateFormatter* dateFormatter;
}

@property (nonatomic, copy) ITKAppListRequestHandler hander;

@end

@implementation ITKAppListRequest

+(void) initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!s_cacheDir) {
            s_cacheDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ITKAppList"];
        }
        
        NSFileManager* mgr = [NSFileManager defaultManager];
        BOOL isDir = NO;
        if (![mgr fileExistsAtPath:s_cacheDir isDirectory:&isDir] || !isDir) {
            [mgr removeItemAtPath:s_cacheDir error:nil];
            [mgr createDirectoryAtPath:s_cacheDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
}

+(void) clearAllCache
{
	NSFileManager* mgr = [NSFileManager defaultManager];
	[mgr removeItemAtPath:s_cacheDir error:nil];
	[mgr createDirectoryAtPath:s_cacheDir withIntermediateDirectories:YES attributes:nil error:nil];
}

-(id) init
{
	self = [super init];
	if (self) {
		queue = [[NSOperationQueue alloc] init];
		
		_countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
		_kindMask = ITKAppListRequestKindMaskAll;
		_artworkSize = ITKAppListRequestArtworkDefault;
		_excludeList = nil;
		
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
		[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss 'GMT'"];
		[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	}
	return self;
}

-(void) performRequest:(NSString *)artistId handler:(ITKAppListRequestHandler)handler
{
	if (!self.countryCode) {
		self.countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
	}
	
	self.hander = handler;
	
	NSMutableString* link = [NSMutableString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@&entity=software&country=%@", artistId, self.countryCode];
	if ([self.searchParameters count] > 0) {
		for (NSString* key in [self.searchParameters allKeys]) {
			[link appendFormat:@"&%@=%@", key, [[self.searchParameters objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	
	appList = [NSMutableArray array];
	artworkQueue = [NSMutableArray array];
	NSURL* url = [NSURL URLWithString:link];
	[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30] queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		if (connectionError) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(nil, connectionError);
			});
			return;
		}
		if (data) {
			NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
			if (json) {
				for (NSDictionary* dic in json[@"results"]) {
					if (![dic[@"wrapperType"] isEqualToString:@"software"]) {
						continue;
					}

					NSNumber* appId = dic[@"trackId"];
					if ([self.excludeList containsObject:appId]) {
						continue;
					}
					NSString* kind = dic[@"kind"];
					if (!(([kind isEqualToString:@"software"] && (self.kindMask & ITKAppListRequestKindMaskIOS)) ||
						([kind isEqualToString:@"mac-software"] && (self.kindMask & ITKAppListRequestKindMaskMac)))) {
						continue;
					}
										
					ITKAppListApp* app = [[ITKAppListApp alloc] initWithJson:dic];
					[appList addObject:app];
				}
			}
		}
		
		if ([appList count] > 0) {
			[artworkQueue addObjectsFromArray:appList];
			
			[self performSelectorOnMainThread:@selector(getNextArtwork) withObject:nil waitUntilDone:NO];
		} else {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(nil, nil);
			});
		}
	}];
}

-(void) getNextArtwork
{
	if ([artworkQueue count] == 0) {
		dispatch_async(dispatch_get_main_queue(), ^{
			self.hander(appList, nil);
		});
		return;
	}
	
	ITKAppListApp* app = [artworkQueue objectAtIndex:0];
	NSString* link = nil;
	if (self.artworkSize == ITKAppListRequestArtworkLarge) {
		link = [app.originalJson objectForKey:@"artworkUrl100"];
	}
	if (!link) {
		link = [app.originalJson objectForKey:@"artworkUrl60"];
	}
	if (!link) {
		[artworkQueue removeObjectAtIndex:0];
		[self performSelector:@selector(getNextArtwork) withObject:nil afterDelay:0];
		return;
	}
	NSURLComponents* comp = [[NSURLComponents alloc] initWithString:link];
	if ([comp.scheme isEqualToString:@"http"] && [comp.host containsString:@".mzstatic.com"]) {
		comp.host = [comp.host stringByReplacingOccurrencesOfString:@".mzstatic.com" withString:@"-ssl.mzstatic.com"];
		comp.scheme = @"https";
	}
	NSURL* url = [comp URL];
	NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
	
    NSString* path = [s_cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.jpg", app.appId, (int)self.artworkSize]];
	NSFileManager* mgr = [NSFileManager defaultManager];
	if ([mgr fileExistsAtPath:path]) {
		UIImage* img = [UIImage imageWithContentsOfFile:path];
		if (!img) {
			[mgr removeItemAtPath:path error:nil];
		} else {
			app.artwork = img;
		}
	
		NSDate* date = [[mgr attributesOfItemAtPath:path error:nil] fileModificationDate];
		if (date) {
			NSString* str = [dateFormatter stringFromDate:date];
			[req addValue:str forHTTPHeaderField:@"If-Modified-Since"];
		}
	}
	
	[NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
		if (statusCode / 100 == 2) {
			if (data) {
				UIImage* img = [UIImage imageWithData:data];
				if (img) {
					app.artwork = img;
					[data writeToFile:path atomically:YES];
				}
			}
		}
		
		[self performSelectorOnMainThread:@selector(getNextArtwork) withObject:nil waitUntilDone:NO];
	}];
	
	[artworkQueue removeObjectAtIndex:0];
}

@end
