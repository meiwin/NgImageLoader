//
//  NgImageLoader.h
//  NgImageLoader
//
//  Created by Meiwin Fu on 24/5/15.
//  Copyright (c) 2015 Meiwin Fu. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * NgImageLoaderErrorDomain;

extern NSInteger NgImageLoaderNotImplemented;
extern NSInteger NgImageLoaderResourceNotFound;
extern NSInteger NgImageLoaderResourceNotImage;
extern NSInteger NgImageLoaderResourceNotAccessible;

#pragma mark -
typedef NS_ENUM(int32_t, NgImageLoaderState) {
  NgImageLoaderStateNew = 0,
  NgImageLoaderStateLoading,
  NgImageLoaderStateLoaded,
  NgImageLoaderStateCancelled,
  NgImageLoaderStateError
};

#pragma mark -
typedef NS_ENUM(int32_t, NgImageLoaderImageKind) {
  NgImageLoaderImageKindNSData = 1,
  NgImageLoaderImageKindUIImage,
};

#pragma mark -
@class NgImageLoader;
@protocol NgImageLoaderDelegate <NSObject>
@optional
- (void)imageLoaderDidLoad:(NgImageLoader *)loader;
- (void)imageLoaderDidFailLoad:(NgImageLoader *)loader;
- (void)imageLoaderDidCancelLoad:(NgImageLoader *)loader;
@end

#pragma mark -
typedef void(^NgImageLoaderCompletionBlock)(NgImageLoaderState, id, NgImageLoaderImageKind, NSError *);

@interface NgImageLoader : NSObject

@property (nonatomic)                   CGFloat                         imageScale;
@property (nonatomic)                   BOOL                            decodeGIFAsAnimatedUIImage; // default = YES

@property (nonatomic, strong, readonly) id                              image;
@property (nonatomic, readonly)         NgImageLoaderImageKind          kind;
@property (nonatomic, strong, readonly) NSError *                       error;
@property (nonatomic, readonly)         NgImageLoaderState              state;
@property (nonatomic, weak)             id<NgImageLoaderDelegate>       delegate;

- (void)load;
- (void)cancel;

@end

@interface NgImageLoader (WebImage)
+ (instancetype)imageLoaderWithURL:(NSURL *)URL;
+ (instancetype)imageLoaderWithURL:(NSURL *)URL
                 completionHandler:(NgImageLoaderCompletionBlock)completionHandler;
@end

@interface NgImageLoader (LocalImage)
+ (instancetype)imageLoaderWithFileURL:(NSURL *)URL;
+ (instancetype)imageLoaderWithFileURL:(NSURL *)URL
                     completionHandler:(NgImageLoaderCompletionBlock)completionHandler;
@end
