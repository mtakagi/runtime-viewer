//
//  ProtocolRootViewController.h
//  ClassViewer
//
//  Created by mtakagi on 10/10/05.
//  Copyright 2010 http://outofboundary.web.fc2.com/. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <objc/runtime.h>

@interface ProtocolRootViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate> {
@private
	UISearchDisplayController *searchController;
	NSMutableArray *filteredList; // 検索文字にマッチしたプロトコル。
	Protocol **protocolList; // ロードされているプロトコルのリスト。
	unsigned int protocolCount; // ロードされているプロトコルの数。
}

@property (nonatomic, retain) NSMutableArray *filteredList;

@end
