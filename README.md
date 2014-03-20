ITKAppList
==========

Get application list from AppStore by artist id

![itkapplist.png](http://itok.jp/share/image/itkapplist.png)

## How to use

```objc
{
	ITKAppListRequest* req = [[ITKAppListRequest alloc] init];
	[req performRequest:<ArtistID> handler:^(NSArray *list, NSError *error) {
		// do something
	}];	
}
```

## License

MIT license