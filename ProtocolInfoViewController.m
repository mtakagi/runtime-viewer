//
//  ProtocolInfoViewController.m
//  ClassViewer
//
//  Created by mtakagi on 10/10/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ProtocolInfoViewController.h"
#import "DecodeTypeEncoding.h"

// プロトコルの情報。
#define kProperty @"Property"
#define kProtocol @"Protocol"
#define kRecuiredMethodDescription @"Recuired Method"
#define kOptionalMethodDescription @"Optional Method"
#define kRecuiredClassMethodDescription @"Recuired Class Method"
#define kOptionalClassMethodDescription @"Optional Class Method"

// Dictionary の key
#define kTypeKey @"type"
#define kCountKey @"count"

@implementation ProtocolInfoViewController

@synthesize protocol, attribute;

#pragma mark -
#pragma mark View lifecycle

// Table View の作成と設定。
- (void)loadView
{
	UITableView *view = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStyleGrouped];
	view.delegate = self;
	view.dataSource = self;
	self.tableView = view;
}

// Protocol の情報を取得し attribute に追加する。
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSStringFromProtocol(self.protocol); // title をセット。
	self.attribute = [NSMutableArray array];
	propertys = protocol_copyPropertyList(self.protocol, &propertyCount);
	protocols = protocol_copyProtocolList(self.protocol, &protocolCount);
	recuiredMethodDescriptions = protocol_copyMethodDescriptionList(self.protocol, YES, YES, &recuiredMethodDescriptionCount);
	optionalMethodDescriptions = protocol_copyMethodDescriptionList(self.protocol, NO, YES, &optionalMethodDescriptionCount);
	recuiredClassMethodDescriptions = protocol_copyMethodDescriptionList(self.protocol, YES, NO, &recuiredClassMethodDescriptionCount);
	optionalClassMethodDescriptions = protocol_copyMethodDescriptionList(self.protocol, NO, NO, &optionalClassMethodDescriptionCount);
	
	if (protocolCount != 0) {
		[self.attribute addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								   kProtocol, kTypeKey,
								   [NSNumber numberWithUnsignedInt:protocolCount], kCountKey,
								   nil]];
	}
	if (propertyCount != 0) {
		[self.attribute addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								   kProperty, kTypeKey,
								   [NSNumber numberWithUnsignedInt:propertyCount], kCountKey,
								   nil]];
	}
	if (recuiredMethodDescriptionCount != 0) {
		[self.attribute addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								   kRecuiredMethodDescription, kTypeKey,
								   [NSNumber numberWithUnsignedInt:recuiredMethodDescriptionCount], kCountKey,
								   nil]];
	}
	if (optionalMethodDescriptionCount != 0) {
		[self.attribute addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								   kOptionalMethodDescription, kTypeKey,
								   [NSNumber numberWithUnsignedInt:optionalMethodDescriptionCount], kCountKey,
								   nil]];
	}
	if (recuiredClassMethodDescriptionCount != 0) {
		[self.attribute addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								   kRecuiredClassMethodDescription, kTypeKey,
								   [NSNumber numberWithUnsignedInt:recuiredClassMethodDescriptionCount], kCountKey,
								   nil]];
	}
	if (optionalClassMethodDescriptionCount != 0) {
		[self.attribute addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								   kOptionalClassMethodDescription, kTypeKey,
								   [NSNumber numberWithUnsignedInt:optionalClassMethodDescriptionCount], kCountKey,
								   nil]];
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.attribute count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[[self.attribute objectAtIndex:section] objectForKey:kCountKey] unsignedIntegerValue];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[self.attribute objectAtIndex:section] objectForKey:kTypeKey];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // CellIdentifier はタイプ毎によって変る。
    NSString *CellIdentifier = [[self.attribute objectAtIndex:indexPath.section] objectForKey:kTypeKey];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// TODO: Parse types
    if ([CellIdentifier isEqualToString:kProtocol]) {
		cell.textLabel.text = NSStringFromProtocol(*(protocols + indexPath.row));
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if ([CellIdentifier isEqualToString:kProperty]) {
		cell.textLabel.text = [NSString stringWithCString:property_getName(*(propertys + indexPath.row)) encoding:NSASCIIStringEncoding];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.detailTextLabel.text = decodePropertyTypeEncoding(property_getAttributes(*(propertys + indexPath.row)));
	} else if ([CellIdentifier isEqualToString:kRecuiredMethodDescription]) {
		cell.textLabel.text = NSStringFromSelector((recuiredMethodDescriptions + indexPath.row)->name);
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.detailTextLabel.text = [NSString stringWithCString:(recuiredMethodDescriptions + indexPath.row)->types encoding:NSASCIIStringEncoding];
	} else if ([CellIdentifier isEqualToString:kOptionalMethodDescription]) {
		cell.textLabel.text = NSStringFromSelector((optionalMethodDescriptions + indexPath.row)->name);
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.detailTextLabel.text = [NSString stringWithCString:(optionalMethodDescriptions + indexPath.row)->types encoding:NSASCIIStringEncoding];
	} else if ([CellIdentifier isEqualToString:kRecuiredClassMethodDescription]) {
		cell.textLabel.text = NSStringFromSelector((recuiredClassMethodDescriptions + indexPath.row)->name);
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.detailTextLabel.text = [NSString stringWithCString:(recuiredClassMethodDescriptions + indexPath.row)->types encoding:NSASCIIStringEncoding];
	} else if ([CellIdentifier isEqualToString:kOptionalClassMethodDescription]) {
		cell.textLabel.text = NSStringFromSelector((optionalClassMethodDescriptions + indexPath.row)->name);
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.detailTextLabel.text = [NSString stringWithCString:(optionalClassMethodDescriptions + indexPath.row)->types encoding:NSASCIIStringEncoding];
	}
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *section = [[self.attribute objectAtIndex:indexPath.section] objectForKey:kTypeKey];
	
	if ([section isEqualToString:kProtocol]) {
		ProtocolInfoViewController *detailViewController = [[[self class] alloc] initWithNibName:nil bundle:nil];
		detailViewController.protocol = *(protocols + indexPath.row);
		[self.navigationController pushViewController:detailViewController animated:YES];
		[detailViewController release];
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
    self.attribute = nil;
}


- (void)dealloc {
	free(propertys), propertys = NULL;
	free(protocols), protocols = NULL;
	free(recuiredMethodDescriptions), recuiredMethodDescriptions = NULL;
	free(optionalMethodDescriptions), optionalMethodDescriptions = NULL;
	[attribute release];
    [super dealloc];
}


@end

