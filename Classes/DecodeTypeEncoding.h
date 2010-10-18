/*
 *  DecodeTypeEncoding.h
 *  ClassViewer
 *
 *  Created by mtakagi on 10/10/12.
 *  Copyright 2010 http://outofboundary.web.fc2.com/. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#include <objc/runtime.h>

// @encode された型情報をデコードした NSString にする。
NSString * decodeTypeEncoding(const char *encoding);

// エンコードされたプロパティをデコードした NSString にする。
NSString * decodePropertyTypeEncoding(const char *attributes);

// エンコードされた引数と返り値をデコードした NSString にする。
NSString * ParseMethod(const Method aMethod);