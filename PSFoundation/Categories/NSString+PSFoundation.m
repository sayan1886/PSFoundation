//
//  NSString+PSFoundation.m
//  PSFoundation
//
//  Includes code by the following:
//   - Shaun Harrison.     2009.  BSD.
//   - Sam Soffes.         2010.  MIT.
//   - Peter Steinberger.  2010.  MIT.
//   - Matthias Tretter.   2011.  MIT.
//

#import "NSString+PSFoundation.h"
#import "NSData+CommonCrypto.h"
#import "GTMBase64.h"
#import <CommonCrypto/CommonDigest.h>

int const GGCharacterIsNotADigit = 10;

@implementation NSString (PSFoundation)

+ (NSString *)stringWithUUID {
	CFUUIDRef uuidObj = CFUUIDCreate(nil);
	NSString *UUIDstring = (NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return [UUIDstring autorelease];
}

- (BOOL)containsString:(NSString *)string {
	return [self containsString:string options:NSCaseInsensitiveSearch];
}

- (BOOL)containsString:(NSString *)string options:(NSStringCompareOptions)options {
	return [self rangeOfString:string options:options].location == NSNotFound ? NO : YES;
}

- (BOOL)hasSubstring:(NSString *)substring {
    return [self containsString:substring];
}

- (NSString*) substringAfterSubstring:(NSString*)substring {
    return ([self containsString:substring]) ? [self substringFromIndex:NSMaxRange([self rangeOfString:substring])] : nil; 
}

- (NSComparisonResult)compareToVersionString:(NSString *)version {
	// Break version into fields (separated by '.')
	NSMutableArray *leftFields  = [[NSMutableArray alloc] initWithArray:[self  componentsSeparatedByString:@"."]];
	NSMutableArray *rightFields = [[NSMutableArray alloc] initWithArray:[version componentsSeparatedByString:@"."]];
	
	// Implict ".0" in case version doesn't have the same number of '.'
	if ([leftFields count] < [rightFields count]) {
		while ([leftFields count] != [rightFields count]) {
			[leftFields addObject:@"0"];
		}
	} else if ([leftFields count] > [rightFields count]) {
		while ([leftFields count] != [rightFields count]) {
			[rightFields addObject:@"0"];
		}
	}
	
	// Do a numeric comparison on each field
	for (NSUInteger i = 0; i < [leftFields count]; i++) {
		NSComparisonResult result = [[leftFields objectAtIndex:i] compare:[rightFields objectAtIndex:i] options:NSNumericSearch];
		if (result != NSOrderedSame) {
			[leftFields release];
			[rightFields release];
			return result;
		}
	}
	
	[leftFields release];
	[rightFields release];	
	return NSOrderedSame;
}

- (BOOL)isEqualToStringIgnoringCase:(NSString*)otherString {
	if (otherString.empty)
		return NO;
	return ([self compare:otherString options:NSCaseInsensitiveSearch | NSWidthInsensitiveSearch] == NSOrderedSame);
}

- (NSString *)md5 {
    NSData *sum = [[self dataUsingEncoding:NSUTF8StringEncoding] MD5Sum];
    return [[[NSString alloc] initWithData:sum encoding:NSUTF8StringEncoding] autorelease];
}

- (NSString *)sha1 {
    NSData *sum = [[self dataUsingEncoding:NSUTF8StringEncoding] SHA1Hash];
    return [[[NSString alloc] initWithData:sum encoding:NSUTF8StringEncoding] autorelease];
}

- (NSString *)base64 {
    return [GTMBase64 stringByEncodingData:[self dataUsingEncoding:NSUTF8StringEncoding]];
}

@end