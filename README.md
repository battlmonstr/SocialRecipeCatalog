## Build instructions

1. Open "SocialRecipeCatalog.xcodeproj" in Xcode 7.
1. Build and run.
1. Optional: run tests using Product -> Test.


## Implementation details

The app is based on a Master-Detail Xcode template, which set up navigation controller and a split view for iPad for free.

Small icons are not shown for efficiency (because the API doesn't offer small images), and because the big photos all have various aspect ratios that would look ugly if downsized to squares.

Links are shown in a SFSafariViewController (and not a web view), which allows to keep Apple Transport Security enabled.

If the ingredient text is too long to fit, you can tap on it to see it fully.

SDWebImage was chosen to download and cache recipe images, because that's what I know. For a production app I would spend more time on looking for alternatives and justifying the choice.

Don't blame me for PromiseKit and some reactive style elements (SRCSignal inspired by ReactiveCocoa). I wouldn't use those in an existing codebase. I wanted to try them since it's a test app and I had enough time, I hope it's fine. The idea with promises was to wrap network requests and async JSON parsing and chain them seamlessly with other processing. The idea with signals was to implement searching as a data-flow where each typed character produces an event, which initiates the processing chain:

1. A text field change produces a query text.
1. The UI is updated to show a loading spinner.
1. The typing events are throttled to not send too many network requests.
1. Each throttled event can produce a search API request (as a promise).
1. When the results of API promises arrive, they update the UI.

Parts of the network response handling and JSON parsing code were adapted from NSURLConnection+PromiseKit.h, that's why there's a bit of style mismatch. It uses NSURLSession, because NSURLConnection is deprecated.

GTMNSString-HTML was needed, because some recipe titles from the API contain HTML entities.


### Tests

A simple unit test is implemented in SRCF2FServiceTests to test the recipe parsing.

An integration UI test is implemented in SRCSocialRecipeCatalogUITests to click through all the app screens and check that it works as expected. This test is not using the network, instead it uses canned responses served by SRCF2FTestURLProtocol.

If you want to avoid real API requests during debugging, set isTestMode to YES in SRCF2FService.m. This is useful, because the free API access has limited number of requests. To simulate network latency go to SRCF2FTestURLProtocol.m and adjust a "delay" constant.


### Missing features and bugs

* Pagination: currently only the first page is queried, but the service supports "page" number parameter. There can be several strategies: either populate more and more into the collection view, or have a "load more" button. On the other hand, the API doesn't offer sorting by relevancy, so it might be better to query several pages in advance and then combine results using smarter logic.
* Cancel previous outstanding search requests. Currently the search requests are throttled to happen not more often than 1 second (see kSRCThrottleTimeout). On bad network conditions this is not be enough, and it would be better to cancel pending requests instead of queueing more and more of them.
* Publisher name and social rank font sizes can be different (if the publisher name is long).
* Unit tests for SRCSignal.
* Error messages can be improved. For example when the service is not available or the API key is bad etc.


## Libraries

Used libraries:
* PromiseKit legacy-1.x, tag: 1.7.3  
  https://github.com/mxcl/PromiseKit/commit/723f4ae15ebc349830c944e4973371ed8f010481
* SDWebImage 4.0.0-beta2  
  https://github.com/rs/SDWebImage/commit/032ab1dd6d633ed30b8850eddc27f7073191f317
* GTMNSString-HTML  
  https://github.com/siriusdely/GTMNSString-HTML/commit/5d81a06cc5ef42cf57821ae1a7afa468ef6f83ce

Icon is taken from:
https://commons.wikimedia.org/wiki/File:Emoji_u1f35d.svg


## Screenshots

![search for "pie" on iPhone](screenshots/01_iphone_search_pie.png)
![banana pie recipe details on iPhone](screenshots/02_iphone_banana_pie.png)
![long ingredient text expansion on iPhone](screenshots/03_iphone_long_ingredient.png)
![search for "pie" and details on iPad](screenshots/04_ipad_pie_info.png)
![crust pie recipe web site view on iPad](screenshots/05_ipad_crust_pie_on_site.png)
