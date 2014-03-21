ITKAppList
==========

Get application list (NSArray) from AppStore by artist id

It uses iTunes' search API : http://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html

## How to use

```objc
#import "ITKAppList.h"

{
	ITKAppListRequest* req = [[ITKAppListRequest alloc] init];
	[req performRequest:<ArtistID> handler:^(NSArray *list, NSError *error) {
		// do something
	}];	
}
```

## Sample

Get list and insert table rows.

![itkapplist.png](http://itok.jp/share/image/itkapplist_2.png)

## Install

Use CocoaPods,

```ruby
pod 'ITKAppList', :git => 'https://github.com/itok/ITKAppList.git'
```

## License

MIT license