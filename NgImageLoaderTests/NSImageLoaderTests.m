//
//  NSImageLoaderTests.m
//  NgImageLoader
//
//  Created by Meiwin Fu on 24/5/15.
//  Copyright (c) 2015 BlockThirty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NgImageLoader.h"

#pragma mark -
@interface NSImageLoaderTests : XCTestCase

@end

@implementation NSImageLoaderTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark Network Image
- (void)testNetworkImagePNG {
  
  XCTestExpectation * expectation = [self expectationWithDescription:@"network PNG image"];
  
  NSURL * URL = [NSURL URLWithString:@"http://www.getyourphonefix.com/images/logo-apple.png"];
  NgImageLoader * loader = [NgImageLoader imageLoaderWithURL:URL completionHandler:^(NgImageLoaderState state, id image, NgImageLoaderImageKind kind, NSError * error) {
    
    XCTAssertEqual(state, NgImageLoaderStateLoaded);
    XCTAssertNotNil(image);
    XCTAssertEqual(kind, NgImageLoaderImageKindUIImage);
    
    [expectation fulfill];
    
  }];
  
  [loader load];
  [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testNetworkImageGIF {
  
  XCTestExpectation * expectation = [self expectationWithDescription:@"network GIF image"];
  
  NSURL * URL = [NSURL URLWithString:@"http://i.imgur.com/nt9MS.gif"];
  NgImageLoader * loader = [NgImageLoader imageLoaderWithURL:URL completionHandler:^(NgImageLoaderState state, id image, NgImageLoaderImageKind kind, NSError * error) {
    
    XCTAssertEqual(state, NgImageLoaderStateLoaded);
    XCTAssertNotNil(image);
    XCTAssertEqual(kind, NgImageLoaderImageKindUIImage);
    XCTAssert(((UIImage *)image).images.count > 0);
    
    [expectation fulfill];
    
  }];
  
  [loader load];
  [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testNetworkImageGIFDoNotDecode {
  
  XCTestExpectation * expectation = [self expectationWithDescription:@"network GIF image (do not decode)"];
  
  NSURL * URL = [NSURL URLWithString:@"http://i.imgur.com/nt9MS.gif"];
  NgImageLoader * loader = [NgImageLoader imageLoaderWithURL:URL completionHandler:^(NgImageLoaderState state, id image, NgImageLoaderImageKind kind, NSError * error) {
    
    XCTAssertEqual(state, NgImageLoaderStateLoaded);
    XCTAssertNotNil(image);
    XCTAssertEqual(kind, NgImageLoaderImageKindNSData);
    
    [expectation fulfill];
    
  }];
  loader.decodeGIFAsAnimatedUIImage = NO;
  [loader load];
  [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testNetworkImageCancel {
  
  XCTestExpectation * expectation = [self expectationWithDescription:@"cancel network image"];
  
  NSURL * URL = [NSURL URLWithString:@"http://www.getyourphonefix.com/images/logo-apple.png"];
  NgImageLoader * loader = [NgImageLoader imageLoaderWithURL:URL completionHandler:^(NgImageLoaderState state, id image, NgImageLoaderImageKind kind, NSError * error) {
    
    XCTAssertEqual(state, NgImageLoaderStateCancelled);
    XCTAssertNil(image);
    XCTAssertEqual(kind, 0);
    
    [expectation fulfill];
    
  }];
  
  [loader load];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [loader cancel];
  });
  [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testNetworkImageError {

  XCTestExpectation * expectation = [self expectationWithDescription:@"cancel network image"];
  
  NSURL * URL = [NSURL URLWithString:@"http://www.getyourphonefix.com/images/logo-apple-no-such-file.png"];
  NgImageLoader * loader = [NgImageLoader imageLoaderWithURL:URL completionHandler:^(NgImageLoaderState state, id image, NgImageLoaderImageKind kind, NSError * error) {
    
    XCTAssertEqual(state, NgImageLoaderStateError);
    XCTAssertNil(image);
    XCTAssertEqual(kind, 0);
    XCTAssertNotNil(error);
    
    [expectation fulfill];
    
  }];
  
  [loader load];
  [self waitForExpectationsWithTimeout:5 handler:nil];

}

#pragma mark Local Image
- (void)testFileImagePNG {
  
  XCTestExpectation * expectation = [self expectationWithDescription:@"file PNG image"];
  
  NSBundle * bundle = [NSBundle bundleForClass:[self class]];
  NSURL * fileURL = [bundle URLForResource:@"test" withExtension:@"png"];

  NgImageLoader * loader = [NgImageLoader imageLoaderWithFileURL:fileURL completionHandler:^(NgImageLoaderState state, id image, NgImageLoaderImageKind kind, NSError * error) {
    
    NSLog(@"error: %@", error);
    XCTAssertEqual(state, NgImageLoaderStateLoaded);
    XCTAssertNotNil(image);
    XCTAssertEqual(kind, NgImageLoaderImageKindUIImage);
    
    [expectation fulfill];
    
  }];
  
  [loader load];
  [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testFileImageGIF {
  
  XCTestExpectation * expectation = [self expectationWithDescription:@"file GIF image"];
  
  NSBundle * bundle = [NSBundle bundleForClass:[self class]];
  NSURL * fileURL = [bundle URLForResource:@"test" withExtension:@"gif"];
  
  NgImageLoader * loader = [NgImageLoader imageLoaderWithFileURL:fileURL completionHandler:^(NgImageLoaderState state, id image, NgImageLoaderImageKind kind, NSError * error) {
    
    XCTAssertEqual(state, NgImageLoaderStateLoaded);
    XCTAssertNotNil(image);
    XCTAssertEqual(kind, NgImageLoaderImageKindUIImage);
    XCTAssert(((UIImage *)image).images.count > 0);
    
    [expectation fulfill];
    
  }];
  
  [loader load];
  [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testFileImageGIFDoNotDecode {
  
  XCTestExpectation * expectation = [self expectationWithDescription:@"file GIF image (do not decode)"];
  
  NSBundle * bundle = [NSBundle bundleForClass:[self class]];
  NSURL * fileURL = [bundle URLForResource:@"test" withExtension:@"gif"];

  NgImageLoader * loader = [NgImageLoader imageLoaderWithFileURL:fileURL completionHandler:^(NgImageLoaderState state, id image, NgImageLoaderImageKind kind, NSError * error) {
    
    XCTAssertEqual(state, NgImageLoaderStateLoaded);
    XCTAssertNotNil(image);
    XCTAssertEqual(kind, NgImageLoaderImageKindNSData);
    
    [expectation fulfill];
    
  }];
  loader.decodeGIFAsAnimatedUIImage = NO;
  [loader load];
  [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testFileImageCancel {

  XCTestExpectation * expectation = [self expectationWithDescription:@"cancel file image"];
  
  NSBundle * bundle = [NSBundle bundleForClass:[self class]];
  NSURL * fileURL = [bundle URLForResource:@"test" withExtension:@"gif"];
  
  NgImageLoader * loader = [NgImageLoader imageLoaderWithFileURL:fileURL completionHandler:^(NgImageLoaderState state, id image, NgImageLoaderImageKind kind, NSError * error) {
    
    XCTAssertEqual(state, NgImageLoaderStateCancelled);
    XCTAssertNil(image);
    XCTAssertEqual(kind, 0);
    
    [expectation fulfill];
    
  }];
  
  [loader load];
  [loader cancel];

  [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testFileImageError {
  
  XCTestExpectation * expectation = [self expectationWithDescription:@"error file image"];
  
  NSURL * fileURL = [[NSURL alloc] initWithString:@"file:///folder/abc.gif"];
  
  NgImageLoader * loader = [NgImageLoader imageLoaderWithFileURL:fileURL completionHandler:^(NgImageLoaderState state, id image, NgImageLoaderImageKind kind, NSError * error) {
    
    XCTAssertEqual(state, NgImageLoaderStateError);
    XCTAssertNil(image);
    XCTAssertEqual(kind, 0);
    XCTAssertNotNil(error);
    
    [expectation fulfill];
    
  }];
  
  [loader load];
  [self waitForExpectationsWithTimeout:5 handler:nil];
  
}
@end
