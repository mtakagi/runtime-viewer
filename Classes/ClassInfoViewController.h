//
//  ClassInfoViewController.h
//  ClassViewer
//
//  Created by mtakagi on 10/10/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <objc/runtime.h>

@interface ClassInfoViewController : UITableViewController {
@private
	Class aClass; // 情報を表示する Class 。
	NSMutableArray *headers; // Table View の header (Class によって可変)。
	
	Protocol **protocols; // Class が conform している Protocol のリスト。
	NSUInteger protocolCount; // Class が conform している Protocol の数。
	
	objc_property_t *propertys; // Class が保持している property のリスト。
	NSUInteger propertyCount; // Class が保持している property の数。
	
	Ivar *ivars; // Class が保持している Instance Variable のリスト。
	NSUInteger ivarCount; // Class が保持している Instance Variable の数。
	
	// Method の数は可変だと思われる(Category によって追加できるので)。
	Method *instanceMethods; // Instance Method のリスト。
	NSUInteger instanceMethodCount; // Instatnce Method の数。
	
	Method *classMethods; // Class Method のリスト。
	NSUInteger classMethodCount; // Class Method の数。
}

@property (assign) Class aClass;
@property (nonatomic, retain) NSMutableArray *headers;

@end
