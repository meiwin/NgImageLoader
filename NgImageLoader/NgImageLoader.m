//
//  NgImageLoader.m
//  NgImageLoader
//
//  Created by Meiwin Fu on 24/5/15.
//  Copyright (c) 2015 Meiwin Fu. All rights reserved.
//

#import "NgImageLoader.h"
#import "NgImageLoaderSubclass.h"
#import "NgImageLoaderWebURL.h"
#import "NgImageLoaderFileURL.h"
#import "NgImageFileIO.h"

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

#pragma mark -
NSString * NgImageLoaderErrorDomain                       = @"NgImageLoaderErrorDomain";
NSInteger NgImageLoaderNotImplemented                     = -1000;
NSInteger NgImageLoaderResourceNotFound                   = -1001;
NSInteger NgImageLoaderResourceNotImage                   = -1002;
NSInteger NgImageLoaderResourceNotAccessible              = -1003;

#pragma mark -
// implementation is based on
// https://github.com/mattt/AnimatedGIFImageSerialization
BOOL NgImageLoaderIsGIFData(NSData * data) {
  if (data.length > 4) {
    const unsigned char * bytes = [data bytes];
    return bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46;
  }
  return NO;
}

// implementation is based on
// https://github.com/mattt/AnimatedGIFImageSerialization
UIImage * NgImageLoaderAnimatedImageFromData(NSData * data, CGFloat scale, NSError * __autoreleasing * error) {
  
  NSMutableDictionary *mutableOptions = [NSMutableDictionary dictionary];
  [mutableOptions setObject:@(YES) forKey:(NSString *)kCGImageSourceShouldCache];
  [mutableOptions setObject:(NSString *)kUTTypeGIF forKey:(NSString *)kCGImageSourceTypeIdentifierHint];
  
  CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data,
                                                             (__bridge CFDictionaryRef)mutableOptions);
  
  size_t numberOfFrames = CGImageSourceGetCount(imageSource);
  NSMutableArray *mutableImages = [NSMutableArray arrayWithCapacity:numberOfFrames];
  
  NSTimeInterval duration = 0.0f;
  for (size_t idx = 0; idx < numberOfFrames; idx++) {
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, idx, (__bridge CFDictionaryRef)mutableOptions);
    
    NSDictionary *properties = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imageSource, idx, NULL);
    duration += [[[properties objectForKey:(__bridge NSString *)kCGImagePropertyGIFDictionary] objectForKey:(__bridge  NSString *)kCGImagePropertyGIFDelayTime] doubleValue];
    
    [mutableImages addObject:[UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp]];
    
    CGImageRelease(imageRef);
  }
  
  CFRelease(imageSource);
  
  if (numberOfFrames == 1) {
    return [mutableImages firstObject];
  } else {
    return [UIImage animatedImageWithImages:mutableImages duration:duration];
  }
  
}

UIImage * NgImageLoaderImageFromData(NSData * data, CGFloat scale, NSError * __autoreleasing * error) {
  
  NgImageFileIO * io = [NgImageFileIO imageFileIOWithData:data error:error];
  return io.image;
}

id NgImageLoaderSerializeData(NSData * data, CGFloat scale, BOOL decodeGIF, NSError * __autoreleasing * error) {

  if (data == nil) return nil;
  
  id imageOrData = nil;

  if (data) {

    BOOL isGIF = NgImageLoaderIsGIFData(data);
    if (isGIF) {
      if (decodeGIF) {
        imageOrData = NgImageLoaderAnimatedImageFromData(data, scale, error);
      } else {
        imageOrData = data;
      }
    } else {
      imageOrData = NgImageLoaderImageFromData(data, scale, error);
    }
  }

  if (!imageOrData && !(*error)) {
    *error = [NSError errorWithDomain:NgImageLoaderErrorDomain
                                 code:NgImageLoaderResourceNotImage
                             userInfo:nil];
  }
  return imageOrData;
}

#pragma mark -
@interface NgImageLoader () {
  
  struct {
    int didLoad;
    int didFailLoad;
    int didCancelLoad;
  } _delegateFlags;
  
  NSRecursiveLock * _lock;
}
@property (nonatomic, copy) NgImageLoaderCompletionBlock completionHandler;
@end

@implementation NgImageLoader

- (instancetype)init {
  self = [super init];
  if (self) {
    _decodeGIFAsAnimatedUIImage = YES;
    _imageScale = [UIScreen mainScreen].scale;
    _lock = [[NSRecursiveLock alloc] init];
  }
  return self;
}
- (void)dealloc {
  _completionHandler = nil;
}

#pragma mark Privates
- (void)didLoadWithImageData:(NSData *)data {
  
  NSError * tmperror = nil;

  [_lock lock];
  
  _image = NgImageLoaderSerializeData(data, _imageScale, _decodeGIFAsAnimatedUIImage, &tmperror);

  if (!tmperror) {
    _kind = [_image isKindOfClass:[UIImage class]] ? NgImageLoaderImageKindUIImage : NgImageLoaderImageKindNSData;
    _state = NgImageLoaderStateLoaded;
  }
  
  [_lock unlock];
  
  if (tmperror) {
    [self didFailLoadWithError:tmperror];
  } else {
    [self didLoad];
  }
}
- (void)didFailLoadWithError:(NSError *)error {

  [_lock lock];
  _state = NgImageLoaderStateError;
  _image = nil;
  _kind = 0;
  _error = error;
  [_lock unlock];
  
  [self didFailLoad];
}
- (void)didCancel {

  [_lock lock];
  _state = NgImageLoaderStateCancelled;
  _image = nil;
  _kind = 0;
  _error = nil;
  [_lock unlock];
  
  [self didCancelLoad];
}

#pragma mark Delegate
- (void)setDelegate:(id<NgImageLoaderDelegate>)delegate {
  
  _delegate = delegate;
  _delegateFlags.didLoad = delegate && [(id)delegate respondsToSelector:@selector(imageLoaderDidLoad:)];
  _delegateFlags.didFailLoad = delegate && [(id)delegate respondsToSelector:@selector(imageLoaderDidFailLoad:)];
  _delegateFlags.didCancelLoad = delegate && [(id)delegate respondsToSelector:@selector(imageLoaderDidCancelLoad:)];
}
- (void)invokeCompletionHandler {
  if (_completionHandler) _completionHandler(self.state,
                                             self.image,
                                             self.kind,
                                             self.error);
  _completionHandler = nil;
}
- (void)didLoad {
  
  if (_delegateFlags.didLoad) {
    [_delegate imageLoaderDidLoad:self];
  }
  [self invokeCompletionHandler];
}
- (void)didFailLoad {
  
  if (_delegateFlags.didFailLoad) {
    [_delegate imageLoaderDidFailLoad:self];
  }
  [self invokeCompletionHandler];
}
- (void)didCancelLoad {
  if (_delegateFlags.didCancelLoad) {
    [_delegate imageLoaderDidCancelLoad:self];
  }
  [self invokeCompletionHandler];
}

#pragma mark Load/Cancel
- (void)load {

  NSAssert1(_state == NgImageLoaderStateNew, @"invalid state: %d", _state);
  
  [_lock lock];
  _state = NgImageLoaderStateLoading;
  [self loadImageData:^(NSData * data, NSError * error, BOOL cancelled) {
    
    if (cancelled) {
      
      [self didCancel];
      
    } else if (error) {
      
      [self didFailLoadWithError:error];
      
    } else {
      
      [self didLoadWithImageData:data];
    }
    
  }];
  [_lock unlock];
}
- (void)cancel {

  [_lock lock];
  if (_state == NgImageLoaderStateLoading) {
    [self cancelLoad];
  }
  [_lock unlock];
}

#pragma mark Subclass override
- (void)loadImageData:(void (^)(NSData *, NSError *, BOOL))completion {
  completion(nil, [NSError errorWithDomain:NgImageLoaderErrorDomain code:NgImageLoaderNotImplemented userInfo:nil], NO);
}
- (void)cancelLoad {}

@end

#pragma mark -
@implementation NgImageLoader (WebImage)

+ (instancetype)imageLoaderWithURL:(NSURL *)URL {
  return [self imageLoaderWithURL:URL completionHandler:nil];
}
+ (instancetype)imageLoaderWithURL:(NSURL *)URL completionHandler:(NgImageLoaderCompletionBlock)completionHandler {
  NgImageLoaderWebURL * loader = [[NgImageLoaderWebURL alloc] initWithURL:URL];
  loader.completionHandler = completionHandler;
  return loader;
}
@end

#pragma mark -
@implementation NgImageLoader (FileImage)

+ (instancetype)imageLoaderWithFileURL:(NSURL *)URL {
  return [self imageLoaderWithFileURL:URL completionHandler:nil];
}
+ (instancetype)imageLoaderWithFileURL:(NSURL *)URL completionHandler:(NgImageLoaderCompletionBlock)completionHandler {
  NgImageLoaderFileURL * loader = [[NgImageLoaderFileURL alloc] initWithFileURL:URL];
  loader.completionHandler = completionHandler;
  return loader;
}
@end