//
//  ProtocolRootViewController.m
//  ClassViewer
//
//  Created by mtakagi on 10/10/05.
//  Copyright 2010 http://outofboundary.web.fc2.com/. All rights reserved.
//

#import "ProtocolRootViewController.h"
#import "ProtocolInfoViewController.h"

// UISearchBar の height。
#define UISearchBarHeight 44.0

@implementation ProtocolRootViewController

@synthesize filteredList;

#pragma mark -
#pragma mark View lifecycle

- (void)loadView
{
	// Table View と Search Bar の作成。
	UITableView *view = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStylePlain];
	UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, UISearchBarHeight)];
	
	searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	
	// Search Bar の設定。
	searchBar.keyboardType = UIKeyboardTypeAlphabet;
	searchBar.delegate = self;
	searchController.delegate = self;
	searchController.searchResultsDelegate = self;
	searchController.searchResultsDataSource = self;
	
	// Table View の設定。
	view.delegate = self;
	view.dataSource = self;
	view.tableHeaderView = searchBar;
	self.tableView = view;
	
	[view release];
	[searchBar release];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Protocols";
	// ロードされているプロトコルのリストをコピーし、プロトコルの数を取得する。
	protocolList = objc_copyProtocolList(&protocolCount);
	// ロードされているプロトコルの数分 Array を確保。
	self.filteredList = [NSMutableArray arrayWithCapacity:protocolCount];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Table View が検索の結果の場合はマッチした数を返し、それ以外はロードされているプロトコルの数を返す。
    if (tableView == self.searchDisplayController.searchResultsTableView) {
		return [self.filteredList count];
	} else {
		return protocolCount;
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
	
	// Table View が検索結果の場合は filteredListから、それ以外は Protocol List から Cell に表示する Text をセットする。
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		cell.textLabel.text = [self.filteredList objectAtIndex:indexPath.row];
	} else {
		cell.textLabel.text = NSStringFromProtocol(*(protocolList + indexPath.row));
	}
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

/* Cell が選択された際の処理。ProtocolInfoVIewController のインスタンスに Protocol 変数を渡しプッシュする。
 * nib ファイルを使用していないので、nib name と bundle には nil を渡している。
 * Table View が検索結果の場合は filteredList から、それ以外は Protocol list から Protocol 変数を取得して View Controller に渡す。
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ProtocolInfoViewController *detailViewController = [[ProtocolInfoViewController alloc] initWithNibName:nil bundle:nil];
	
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		// FIXME: Protocol -> NSString -> Protocol と変換するのは非効率的。
		detailViewController.protocol = NSProtocolFromString([self.filteredList objectAtIndex:indexPath.row]);
	} else {
		detailViewController.protocol = *(protocolList + indexPath.row);
	}
	
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    self.filteredList = nil;
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

// Protocol list から searchText にマッチする Protocol を探して filteredList に追加する。
- (void)search:(NSString*)searchText
{
	int i;
	[self.filteredList removeAllObjects]; // First clear the filtered array.
	
	for (i = 0; i < protocolCount; i++) {
		NSString *protocolName = NSStringFromProtocol(*(protocolList + i));
		NSComparisonResult result = [protocolName compare:searchText 
												  options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) 
													range:NSMakeRange(0, [searchText length])];
		if (result == NSOrderedSame) {
			[self.filteredList addObject:protocolName];
		}
	}
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{    
	[self search:searchString];
    return YES;
}

- (void)dealloc {
	[filteredList release];
	free(protocolList), protocolList = NULL;
    [super dealloc];
}


@end

