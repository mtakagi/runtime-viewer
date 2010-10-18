/*
 *  DecodeTypeEncoding.m
 *  ClassViewer
 *
 *  Created by mtakagi on 10/10/12.
 *  Copyright 2010 http://outofboundary.web.fc2.com/ All rights reserved.
 *
 */

// FIXME: Need more fix and improvement?

#include "DecodeTypeEncoding.h"

enum AccesserType {
	AccesserTypeGetter,
	AccesserTypeSetter,
};

static NSString * parseArray(const char *ptr)
{
	const char *start = ptr;
	NSString *array = nil;
	
	while((*ptr >= '0') && (*ptr <= '9')) {
		ptr += 1;
	}
	
	array = [NSString stringWithFormat:@"%@[%d]", decodeTypeEncoding(ptr), ptr - start];
	
	return array;
}

static NSString * parseStructure(const char *ptr)
{
	int n;
	char *structureName;
	NSString *structure = nil;
	
	for(n = 0; *ptr != '='; ptr++, n++);	
	if (n > 0) {
		structureName = (char *)calloc(sizeof(char), n + 1);
		strncpy(structureName, ptr - n, n);
		structure = [NSString stringWithCString:structureName encoding:NSASCIIStringEncoding];
		free(structureName);
		if ([structure isEqualToString:@"?"]) structure = @"UnknownType";
	}
	
	return structure;
}

static NSString * getClassName(const char *encoding)
{
	int n;
	char *className;
	NSString *classNameString = nil;
	
	for(n = 0; *encoding != '"'; encoding++, n++);
	if (n > 0) {
		className = (char *)calloc(sizeof(char), n + 1);
		strncpy(className, encoding - n, n);
		if (*className == '<') {
			classNameString = [NSString stringWithFormat:@"id%s", className];
		} else {
			classNameString = [NSString stringWithFormat:@"%s*", className];
		}
		
		free(className);
	}
	
	return classNameString;
}

NSString * decodeTypeEncoding(const char *encoding)
{
	NSString *type = nil;
	
	switch (*encoding) {
		case 'c':
			type = @"char";
			break;
		case 'i':
			type = @"int";
			break;
		case 's':
			type = @"short";
			break;
		case 'l':
			type = @"long";
			break;
		case 'q':
			type = @"long long";
			break;
		case 'C':
			type = @"unsigned char";
			break;
		case 'I':
			type = @"unsigned int";
			break;
		case 'S':
			type = @"unsigned short";
			break;
		case 'L':
			type = @"unsigned long";
			break;
		case 'Q':
			type = @"unsigned long long";
			break;
		case 'f':
			type = @"float";
			break;
		case 'd':
			type = @"double";
			break;
		case 'B':
			type = @"bool or _BOOL";
			break;
		case 'v':
			type = @"void";
			break;
		case '*':
			type = @"char *";
			break;
		case '@':
			if (*(encoding + 1) == '"') {
				type = getClassName(encoding + 2);
			} else {
				type = @"id";
			}
			break;
		case '#':
			type = @"Class";
			break;
		case ':':
			type = @"SEL";
			break;
		case '[':
			encoding += 1;
			type = parseArray(encoding);
			break;
		case '{':
			encoding++;
			type = parseStructure(encoding);
			break;
		case '(':
			encoding++;
			type = parseStructure(encoding);
			break;
		case 'b':
			type = @"Bit filed";
			break;
		case '^':
			encoding++;
			type = [NSString stringWithFormat:@"%@*", decodeTypeEncoding(encoding)];
			break;
		case '?':
			type = @"Unknown type or function pointer";
			break;
		default:
			break;
	}
	
	return type;
}

static int seekEndOfCharacter(const char *ptr, const char separater)
{
	int lebel = 1;
	int pos = 0;
	char endCharacter = '\0';
	
	if (separater == '{') {
		endCharacter = '}';
	} else if (separater == '(') {
		endCharacter = ')';
	}
	
	while(1) {
		if (*ptr == separater) {
			lebel++;
		} else if (*ptr == endCharacter) {
			lebel--;
			if (lebel == 0) {
				break;
			}
		}
		ptr++;
		pos++;
	}
	
	return pos;
}

static int addSelectorString(const char *name, NSMutableArray **array, enum AccesserType type)
{
	int n;
	char *sel;
	NSString *selectorName = nil;
	
	for(n = 0; *name != ','; name++, n++);
	if (n > 0) {
		sel = (char *)calloc(sizeof(char), n + 1);
		strncpy(sel, name - n, n);
		if (type == AccesserTypeGetter) {
			selectorName = [NSString stringWithFormat:@"getter=%s", sel];
		} else if (type == AccesserTypeSetter) {
			selectorName = [NSString stringWithFormat:@"setter=%s", sel];
		}
		
		[*array addObject:selectorName];
		free(sel);
	}
	
	return n;
}

NSString * decodePropertyTypeEncoding(const char *attributes)
{
	NSString *type = nil;
	NSMutableArray *declaredTypes = [NSMutableArray array];
	NSMutableString *property = [NSMutableString string];
	BOOL isDynamic = NO;
	int i, count;
	
	while(*attributes) {
		switch (*attributes) {
			case 'T':
				attributes += 1;
				type = decodeTypeEncoding(attributes);
				if (*attributes == '{' || *attributes == '(') {
					attributes += seekEndOfCharacter(attributes + 1, *attributes);
				} else if (*attributes == '@' && *(attributes + 1) == '"') {
					attributes += [type length];
				} else if (*attributes == '@' && *(attributes + 2) == '<') {
					attributes += [type length] + 2;
				}
				attributes++;
				break;
			case 'R':
				[declaredTypes addObject:@"readonly"];
				break;
			case 'C':
				[declaredTypes addObject:@"copy"];
				break;
			case '&':
				[declaredTypes addObject:@"retain"];
				break;
			case 'N':
				[declaredTypes addObject:@"nonatomic"];
				break;
			case 'G':
				attributes++;
				attributes += addSelectorString(attributes, &declaredTypes, AccesserTypeGetter);
				break;
			case 'S':
				attributes++;
				attributes += addSelectorString(attributes, &declaredTypes, AccesserTypeSetter);
				break;
			case 'D':
				isDynamic = YES;
				break;
			case 'W':
				NSLog(@"__weak");
				break;
			case 'P':
				NSLog(@"GC");
				break;
			case ',':
			default:
				break;
		}
		attributes++;
	}
	
	[property appendString:(isDynamic ? @"@dynamic " : @"@property ")];
	count = [declaredTypes count];
	
	if (count == 1) {
		[property appendFormat:@"(%@) ", [declaredTypes objectAtIndex:0]];
	} else if (count > 1) {
		for(i = 0; i < count; i++) {
			if (i == 0) {
				[property appendFormat:@"(%@, ", [declaredTypes objectAtIndex:i]];
			} else if (i == [declaredTypes count] - 1) {
				[property appendFormat:@"%@) ", [declaredTypes objectAtIndex:i]];
			} else {
				[property appendFormat:@"%@, ", [declaredTypes objectAtIndex:i]];
			}
		}
	}
	
	if (type != nil) [property appendString:type];
	
	return property;
}

static NSString * decodeMethodEncoding(const char *ptr)
{
	switch (*ptr) {
		case 'r':
			@"const";
			break;
		case 'n':
			@"in";
			break;
		case 'N':
			@"inout";
			break;
		case 'o':
			@"out";
			break;
		case 'O':
			@"bycopy";
			break;
		case 'R':
			@"byref";
			break;
		case 'V':
			@"oneway";
			break;
		default:
			decodeTypeEncoding(ptr);
			break;
	}
	return @"";
}

NSString * ParseMethod(const Method aMethod)
{
	NSMutableString *string = [NSMutableString string];
	NSString *decoded;
	char *returnType = method_copyReturnType(aMethod);
	unsigned int index = method_getNumberOfArguments(aMethod);
	
	decoded = decodeTypeEncoding(returnType);
	[string appendFormat:@"(%@)", decoded];
	
	for (; index > 0; index--) {
		char *argumentType = method_copyArgumentType(aMethod, index - 1);
		[string appendFormat:@"%@ ", decodeTypeEncoding(argumentType)];
		free(argumentType), argumentType = NULL;
	}

	free(returnType), returnType = NULL;
	
	return string;
}