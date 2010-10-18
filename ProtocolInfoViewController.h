//
//  ProtocolInfoViewController.h
//  ClassViewer
//
//  Created by mtakagi on 10/10/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <objc/runtime.h>

@interface ProtocolInfoViewController : UITableViewController {
@private
	Protocol *protocol; // 情報を表示する Protocol。
	NSMutableArray *attribute; // Protocol の情報。
	
	objc_property_t *propertys; // Protocol に adapt するクラスが持つ property。
	unsigned int propertyCount; // Protocol に属する property の数。
	Protocol **protocols; // Protocol が conform している Protocol のリスト。
	unsigned int protocolCount; // Protocol が conform している Protocol の数。
	
	struct objc_method_description *recuiredMethodDescriptions; // Protocol に conform するのに必須な Method Description のリスト。
	unsigned int recuiredMethodDescriptionCount; // Protocol に conform するのに必須な Method Description の数。
	struct objc_method_description *optionalMethodDescriptions; // Optional な Method Description のリスト。
	unsigned int optionalMethodDescriptionCount; // Optional な Method Description の数。
	
	// Protocol に conform するのに必須な Class Method Description のリスト。
	struct objc_method_description *recuiredClassMethodDescriptions; 
	unsigned int recuiredClassMethodDescriptionCount; // Protocol に conform するのに必須な Class Method Description の数。
	struct objc_method_description *optionalClassMethodDescriptions; // Optional な Class Method Description のリスト。
	unsigned int optionalClassMethodDescriptionCount; // Optional な Class Method Description の数。
}

@property (nonatomic, assign) Protocol *protocol;
@property (nonatomic, retain) NSMutableArray *attribute;

@end
