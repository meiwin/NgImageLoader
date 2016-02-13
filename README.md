[![Build Status](https://travis-ci.org/meiwin/NgImageLoader.svg)](https://travis-ci.org/meiwin/NgImageLoader)

# NgImageLoader

Objective-c image loading library.

## Adding to your project

If you are using CocoaPods, add to your Podfile:

```ruby
pod NgImageLoader
```

To manually add to your projects:

1. Add all files in `NgImageLoader` folder to your project.
2. Add these frameworks to your project: `MobileCoreServices`, `ImageIO`

## Features

`NgImageLoader` provides convenience APIs for loading image from file and web.

The loader provides block-based and delegate style callback for responding to loading result.

To load an image, create instance of `NgImageLoader` by specifying the image's `URL` and invoke the `load` method to start loading. Invoke `cancel` method should the loading be cancelled.

## Usage

Example: loading a web image.

```objective-c

// image URL
NSURL * url = [NSURL URLWithString:@"http://www.getyourphonefix.com/images/logo-apple.png"];

NgImageLoader * loader = [NgImageLoader imageLoaderWithURL:URL completionHandler:^(NgImageLoaderState state, id image, NgImageLoaderImageKind kind, NSError * error) {
  
  // handle loading result/error here
  // this callback can be executed in any thread

}];

// start loading
[loader load];
```

Example: loading a local image.

```objective-c

// url to image file
NSURL * URL = [NSURL fileURLWithPath:@"path-to-image-file.nef"];

NgImageLoader * loader = [NgImageLoader imageLoaderWithFileURL:URL completionHandler:^(NgImageLoaderState state, id image, NgImageLoaderImageKind kind, NSError * error) {

  // handle loading result/error here
  // this callback can be executed in any thread

}];

// start loading
[loader load];

```

## GIF Handling

If image is a GIF, loader will automatically decode it as animated `UIImage` instance. If this behavior is not desirable, it can be turned off by setting `decodeGIFAsAnimatedUIImage` to `NO`. 

When setting `decodeGIFAsAnimatedUIImage` to `NO`, `NgImageLoader` will return image as `NSData` instance. This is useful particularly when you intend to use other animated image implementation, e.g. `FLAnimatedImage`. 