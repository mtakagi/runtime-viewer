//
//  ClassInfoViewController.m
//  ClassViewer
//
//  Created by mtakagi on 10/10/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ClassInfoViewController.h"
#import "ProtocolInfoViewController.h"
#import "DecodeTypeEncoding.h"

// Section の header、 変数のタイプ。
#define kSuperClass @"Super Class"
#define kProtocol @"Protocol"
#define kProperty @"Property"
#define kInstanceVariable @"Instance Variable"
#define kClassMethod @"Class Method"
#define kInstanceMethod @"Instance Method"

// Dictionary の key。
#define kCountKey @"count"
#define kTypeKey @"type"

@implementation ClassInfoViewController

@synthesize aClass, headers;

#pragma mark -
#pragma mark View lifecycle

// Table View のセットアップ。headers の生成もしている。
- (void)loadView
{
	UITableView *view = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStyleGrouped];
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:6];
	
	view.delegate = self;
	view.dataSource = self;
	self.tableView = view;
	self.headers = array;
	
	[view release];
	[array release];
}

// Class の各種情報を取得し、存在する情報のタイプを headers に追加する。
- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = NSStringFromClass(self.aClass);
	
	[self.headers addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithUnsignedInteger:1], kCountKey,
							 kSuperClass, kTypeKey,
							 nil]];
	protocols = class_copyProtocolList(self.aClass, &protocolCount);
	if (protocolCount != 0) {
		[self.headers addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithUnsignedInteger:protocolCount], kCountKey,
								 kProtocol, kTypeKey,
								 nil]];
	}
	propertys = class_copyPropertyList(self.aClass, &propertyCount);
	if (propertyCount != 0) {
		[self.headers addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithUnsignedInteger:propertyCount], kCountKey,
								 kProperty, kTypeKey,
								 nil]];
	}
	ivars = class_copyIvarList(self.aClass, &ivarCount);
	if (ivarCount != 0) {
		[self.headers addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithUnsignedInteger:ivarCount], kCountKey,
								 kInstanceVariable, kTypeKey,
								 nil]];
	}
	classMethods = class_copyMethodList(object_getClass(self.aClass), &classMethodCount);
	if (classMethodCount != 0) {
		[self.headers addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithUnsignedInteger:classMethodCount], kCountKey,
								 kClassMethod, kTypeKey,
								 nil]];
	}
	instanceMethods = class_copyMethodList(self.aClass, &instanceMethodCount);
	if (instanceMethodCount != 0) {
		[self.headers addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithUnsignedInteger:instanceMethodCount], kCountKey,
								 kInstanceMethod, kTypeKey,
								 nil]];
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.headers count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[self.headers objectAtIndex:section] objectForKey:kCountKey] unsignedIntegerValue];
}


// Customize tance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // CellIdentifier はタイプ毎によって変る。
    NSString *CellIdentifier = [[self.headers objectAtIndex:indexPath.section] objectForKey:kTypeKey];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
	// TODO: Clean up
    NSString *aString = nil;

	if ([CellIdentifier isEqualToString:kSuperClass]) {
		Class superclass = class_getSuperclass(self.aClass);
		
		if (superclass == Nil) {
			aString = [[NSString alloc] initWithString:@"Root Class"];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
		} else {
			aString = [[NSString alloc] initWithCString:class_getName(superclass) encoding:NSASCIIStringEncoding];
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	} else if ([CellIdentifier isEqualToString:kProtocol]) {
		aString = [[NSString alloc] initWithCString:protocol_getName(*(protocols + indexPath.row)) encoding:NSASCIIStringEncoding];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if ([CellIdentifier isEqualToString:kProperty]) {
		aString = [[NSString alloc] initWithCString:property_getName(*(propertys + indexPath.row)) encoding:NSASCIIStringEncoding];
		cell.detailTextLabel.text = decodePropertyTypeEncoding(property_getAttributes(*(propertys + indexPath.row)));
	} else if ([CellIdentifier isEqualToString:kInstanceVariable]) {
		aString = [[NSString stringWithFormat:@"%@ %@", 
				   decodeTypeEncoding(ivar_getTypeEncoding(*(ivars + indexPath.row))), 
				   [NSString stringWithCString:ivar_getName(*(ivars + indexPath.row)) encoding:NSASCIIStringEncoding]] retain]; 
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.textLabel.minimumFontSize = 1.0;
	} else if ([CellIdentifier isEqualToString:kClassMethod]) {
		aString = [[NSString alloc] initWithString:NSStringFromSelector(method_getName(*(classMethods + indexPath.row)))];
		cell.detailTextLabel.text = ParseMethod(*(classMethods + indexPath.row));
	} else if ([CellIdentifier isEqualToString:kInstanceMethod]) {
		aString = [[NSString alloc] initWithString:NSStringFromSelector(method_getName(*(instanceMethods + indexPath.row)))];
		cell.detailTextLabel.text = ParseMethod(*(instanceMethods + indexPath.row));
	}
	
	cell.textLabel.text = aString;
	[aString release];
	
    return cell;
}

// Section の header のタイトルを返す。
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[self.headers objectAtIndex:section] objectForKey:kTypeKey];
}


#pragma mark -
#pragma mark Table view delegate

// 選択できる Cell は Super Class と Protocol の2つ。
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *section = [[self.headers objectAtIndex:indexPath.section] objectForKey:kTypeKey];
	
	if ([section isEqualToString:kSuperClass]) {
		Class superclass = class_getSuperclass(self.aClass);
		
		if (superclass == Nil) return;
		
		ClassInfoViewController *detailViewController = [[[self class] alloc] initWithNibName:nil bundle:nil];
		
		detailViewController.aClass = superclass;
		[self.navigationController pushViewController:detailViewController animated:YES];
		[detailViewController release];
	} else if ([section isEqualToString:kProtocol]) {
		ProtocolInfoViewController *infoViewController = [[ProtocolInfoViewController alloc] initWithNibName:nil bundle:nil];
		
		infoViewController.protocol = *(protocols + indexPath.row);
		[self.navigationController pushViewController:infoViewController animated:YES];
		[infoViewController release];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    self.headers = nil;
}

- (void)dealloc {
	free(protocols), protocols = NULL;
	free(propertys), propertys = NULL;
	free(ivars), ivars = NULL;
	free(classMethods), classMethods = NULL;
	free(instanceMethods), instanceMethods = NULL;
	[headers release];
    [super dealloc];
}


@end

