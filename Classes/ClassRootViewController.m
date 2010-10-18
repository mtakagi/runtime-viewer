//
//  RootViewController.m
//  ClassViewer
//
//  Created by mtakagi on 10/10/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ClassRootViewController.h"
#import "ClassInfoViewController.h"

#include "dlfcn.h"

// UISearchBar の height。
#define UISearchBarHeight 44.0

@implementation ClassRootViewController


@synthesize filteredList;

#pragma mark -
#pragma mark View lifecycle

- (void)loadView
{
	// Table View と Search Bar の作成。
	UITableView *view = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStylePlain];
	UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, UISearchBarHeight)];
	
	searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar 
														  contentsController:self];
	
	// Table View の設定。
	view.delegate = self;
	view.dataSource = self;
	view.tableHeaderView = searchBar;
	self.tableView = view;
	
	// Search Bar の設定。
	searchBar.keyboardType = UIKeyboardTypeAlphabet;
	searchBar.delegate = self;
	searchController.delegate =self;
	searchController.searchResultsDataSource = self;
	searchController.searchResultsDelegate = self;
	
	[searchBar release];
	[view release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"Classes";

	// ロードされているクラスの数を取得。
	classCount = (NSUInteger)objc_getClassList(NULL, 0);
	
	if (classCount > 0) {
		// ロードされているクラス分のメモリを確保してクラスのリストを取得。
		classes = (Class *)malloc(sizeof(Class) * classCount);
		classCount = objc_getClassList(classes, classCount);
	}
	
	// ロードされているクラスの数を上限として Array を生成。
	self.filteredList = [NSMutableArray arrayWithCapacity:classCount];
	// TODO: dlopen を使用して他のフレームワークを動的にロードして、それらに含まれるクラスをブラウズできるようにする。
	// 以下のコメントアウトされたコードはそのためのテスト。
//	void *handle = dlopen("/System/Library/Frameworks/AVFoundation.framework/AVFoundation", RTLD_LOCAL);
//	char * err = dlerror();
	
//	if (err != NULL) {
//		NSLog(@"%s", err);
//	} else {
//		NSLog(@"%p", handle);
//	}
	
//	NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/System/Library/Frameworks" error:nil];
	
//	dlclose(handle);
}

- (void)viewDidUnload
{
	// Array の中身を削除。
	self.filteredList = nil;
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Table View が検索の結果の場合はマッチした数を返し、それ以外の場合はロードされたクラスの数を返す。
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredList count];
    } else {
		return classCount;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // テンプレートの Cell を返すものと同一。
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Table View が検索結果の場合は filteredListから、それ以外は Class List から Cell に表示する Text をセットする。
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [self.filteredList objectAtIndex:indexPath.row];
    } else {
		cell.textLabel.text = NSStringFromClass(*(classes + (int)indexPath.row));
	}
	
    return cell;
}



#pragma mark -
#pragma mark Table view delegate

/* Cell が選択された際の処理。ClassInfoVIewController のインスタンスに Class 変数を渡しプッシュする。
 * nib ファイルを使用していないので、nib name と bundle には nil を渡している。
 * Table View が検索結果の場合は filteredList から、それ以外は Class list から Class 変数を取得して View Controller に渡す。
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ClassInfoViewController *infoViewController = [[ClassInfoViewController alloc] initWithNibName:nil bundle:nil];
	
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        // FIXME: Class -> NSString -> Class と変換するのは非効率的。
		NSString *className = [self.filteredList objectAtIndex:indexPath.row];
		infoViewController.aClass = NSClassFromString(className);
    } else {
		infoViewController.aClass = *(classes + indexPath.row);
	}
	
	[self.navigationController pushViewController:infoViewController animated:YES];
	[infoViewController release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

// Class list から searchText にマッチする Class を探して filteredList に追加する。

- (void)search:(NSString*)searchText
{
	int i;
	[self.filteredList removeAllObjects]; // First clear the filtered array.
	
	for (i = 0; i < classCount; i++) {
		NSString *className = [[NSString alloc] initWithCString:class_getName(*(classes + i)) 
													   encoding:NSASCIIStringEncoding];
		// TODO: 他の比較方法を試す。
		NSComparisonResult result = [className compare:searchText 
											   options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) 
												 range:NSMakeRange(0, [searchText length])];
		if (result == NSOrderedSame) {
			[self.filteredList addObject:className];
		}
		[className release];
	}
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{    
	[self search:searchString];
    return YES;
}


- (void)dealloc {
	free(classes), classes = NULL;
	[searchController release];
	[filteredList release];
    [super dealloc];
}


@end

