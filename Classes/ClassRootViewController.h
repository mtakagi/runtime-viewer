//
//  RootViewController.h
//  ClassViewer
//
//  Created by mtakagi on 10/10/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface ClassRootViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate> {
@private
	UISearchDisplayController *searchController;
	NSMutableArray *filteredList; // 検索文字にマッチしたクラス。
	unsigned int classCount; // ロードされているクラスの数。
	Class *classes; // ロードされたクラス。
}

@property (nonatomic, retain) NSMutableArray *filteredList;

@end
