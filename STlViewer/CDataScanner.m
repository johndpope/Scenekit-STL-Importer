//
//	CDataScanner.m
//	ACVObject
//
//	Created by Jonathan Wight on 04/16/08.
//	Copyright 2012 Jonathan Wight. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//
//	   1. Redistributions of source code must retain the above copyright notice, this list of
//	      conditions and the following disclaimer.
//
//	   2. Redistributions in binary form must reproduce the above copyright notice, this list
//	      of conditions and the following disclaimer in the documentation and/or other materials
//	      provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of Jonathan Wight.

#import "CDataScanner.h"

#if TARGET_OS_IPHONE == 1
#include <Endian.h>
#endif /* TARGET_OS_IPHONE == 1 */

@interface CDataScanner ()
@end

#pragma mark -

inline static unichar CharacterAtPointer(void *start)
    {
    const u_int8_t theByte = *(u_int8_t *)start;
    if (theByte & 0x80)
        {
        // TODO -- UNICODE!!!! (well in theory nothing todo here)
        }
    const unichar theCharacter = theByte;
    return(theCharacter);
    }

static NSCharacterSet *sDoubleCharacters = NULL;

@implementation CDataScanner

@synthesize endianness = _endianness;

+ (void)initialize
    {
    if (sDoubleCharacters == NULL)
        {
        sDoubleCharacters = [NSCharacterSet characterSetWithCharactersInString:@"0123456789eE-+."];
        }
    }

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        }
    return(self);
    }

- (id)initWithData:(NSData *)inData;
    {
    if ((self = [self init]) != NULL)
        {
        [self setData:inData];
        }
    return(self);
    }

- (NSUInteger)scanLocation
    {
    return(current - start);
    }

- (NSUInteger)bytesRemaining
    {
    return(end - current);
    }

- (NSData *)data
    {
    return(data);
    }

- (void)setData:(NSData *)inData
    {
    if (data != inData)
        {
        data = inData;
        }

    if (data)
        {
        start = (u_int8_t *)data.bytes;
        end = start + data.length;
        current = start;
        length = data.length;
        }
    else
        {
        start = NULL;
        end = NULL;
        current = NULL;
        length = 0;
        }
    }

- (void)setScanLocation:(NSUInteger)inScanLocation
    {
    current = start + inScanLocation;
    }

- (BOOL)isAtEnd
    {
    return(self.scanLocation >= length);
    }

- (unichar)currentCharacter
    {
    return(CharacterAtPointer(current));
    }

#pragma mark -

- (unichar)scanCharacter
    {
    const unichar theCharacter = CharacterAtPointer(current++);
    return(theCharacter);
    }

- (BOOL)scanCharacter:(unichar)inCharacter
    {
    unichar theCharacter = CharacterAtPointer(current);
    if (theCharacter == inCharacter)
        {
        ++current;
        return(YES);
        }
    else
        return(NO);
    }

- (BOOL)scanUTF8String:(const char *)inString intoString:(NSString **)outValue
    {
    const size_t theLength = strlen(inString);
    if ((size_t)(end - current) < theLength)
        return(NO);
    if (strncmp((char *)current, inString, theLength) == 0)
        {
        current += theLength;
        if (outValue)
            *outValue = [NSString stringWithUTF8String:inString];
        return(YES);
        }
    return(NO);
    }

- (BOOL)scanString:(NSString *)inString intoString:(NSString **)outValue
    {
    if ((size_t)(end - current) < inString.length)
        return(NO);
    if (strncmp((char *)current, [inString UTF8String], inString.length) == 0)
        {
        current += inString.length;
        if (outValue)
            *outValue = inString;
        return(YES);
        }
    return(NO);
    }

- (BOOL)scanCharactersFromSet:(NSCharacterSet *)inSet intoString:(NSString **)outValue
    {
    u_int8_t *P;
    for (P = current; P < end && [inSet characterIsMember:*P] == YES; ++P)
        ;

    if (P == current)
        {
        return(NO);
        }

    if (outValue)
        {
        *outValue = [[NSString alloc] initWithBytes:current length:P - current encoding:NSUTF8StringEncoding];
        }

    current = P;

    return(YES);
    }

- (BOOL)scanUpToString:(NSString *)inString intoString:(NSString **)outValue
    {
    const char *theToken = [inString UTF8String];
    const char *theResult = strnstr((char *)current, theToken, end - current);
    if (theResult == NULL)
        {
        return(NO);
        }

    if (outValue)
        {
        *outValue = [[NSString alloc] initWithBytes:current length:theResult - (char *)current encoding:NSUTF8StringEncoding];
        }

    current = (u_int8_t *)theResult;

    return(YES);
    }

- (BOOL)scanUpToCharactersFromSet:(NSCharacterSet *)inSet intoString:(NSString **)outValue
    {
    u_int8_t *P;
    for (P = current; P < end && [inSet characterIsMember:*P] == NO; ++P)
        ;

    if (P == current)
        {
        return(NO);
        }

    if (outValue)
        {
        *outValue = [[NSString alloc] initWithBytes:current length:P - current encoding:NSUTF8StringEncoding];
        }

    current = P;

    return(YES);
    }

- (BOOL)scanUInt32:(uint32_t *)outValue
    {
    if (current > (end - sizeof(*outValue)))
        {
        return NO;
        }

    *outValue = *(typeof(outValue))current;

    current += sizeof(*outValue);
    return YES;
    }

- (BOOL)scanFloat:(float *)outValue;
    {
    if (current > (end - sizeof(*outValue)))
        {
        NSLog(@"Not enough space left (need %d bytes, have %d)", sizeof(*outValue), end - current);
        return NO;
        }

    *outValue = *(typeof(outValue))current;

    current += sizeof(*outValue);
    return YES;
    }

- (BOOL)scanNumber:(NSNumber **)outValue
        {
        NSString *theString = NULL;
        if ([self scanCharactersFromSet:sDoubleCharacters intoString:&theString])
            {
            if ([theString rangeOfString:@"."].location != NSNotFound)
                {
                if (outValue)
                    {
                    *outValue = [NSDecimalNumber decimalNumberWithString:theString];
                    }
                return(YES);
                }
            else if ([theString rangeOfString:@"-"].location != NSNotFound)
                {
                if (outValue != NULL)
                    {
                    *outValue = [NSNumber numberWithLongLong:[theString longLongValue]];
                    }
                return(YES);
                }
            else
                {
                if (outValue != NULL)
                    {
                    *outValue = [NSNumber numberWithUnsignedLongLong:strtoull([theString UTF8String], NULL, 0)];
                    }
                return(YES);
                }
            
            }
        return(NO);
        }
            
- (BOOL)scanDecimalNumber:(NSDecimalNumber **)outValue;
        {
        NSString *theString = NULL;
        if ([self scanCharactersFromSet:sDoubleCharacters intoString:&theString])
            {
            if (outValue)
                {
                *outValue = [NSDecimalNumber decimalNumberWithString:theString];
                }
            return(YES);
            }
        return(NO);
        }

- (BOOL)scanDataOfLength:(NSUInteger)inLength intoPointer:(void **)outPointer
    {
        if (self.bytesRemaining < inLength)
            {
            return(NO);
            }
        
        if (outPointer)
            {
            *outPointer = current;
            }

        current += inLength;
        return(YES);
    }

- (BOOL)scanDataOfLength:(NSUInteger)inLength intoData:(NSData **)outData;
        {
        if (self.bytesRemaining < inLength)
            {
            return(NO);
            }
        
        if (outData)
            {
            *outData = [NSData dataWithBytes:current length:inLength];
            }

        current += inLength;
        return(YES);
        }


- (void)skipWhitespace
    {
    u_int8_t *P;
    for (P = current; P < end && (isspace(*P)); ++P)
        ;

    current = P;
    }

- (NSString *)remainingString
    {
    NSData *theRemainingData = [NSData dataWithBytes:current length:end - current];
    NSString *theString = [[NSString alloc] initWithData:theRemainingData encoding:NSUTF8StringEncoding];
    return(theString);
    }

- (NSData *)remainingData;
    {
    NSData *theRemainingData = [NSData dataWithBytes:current length:end - current];
    return(theRemainingData);
    }

- (BOOL)scanIntoShort:(short *)outValue;
	{
	const size_t theLength = sizeof(*outValue);
	if (self.bytesRemaining < theLength)
		{
		return(NO);
		}
	
	if (outValue)
		{
		if (_endianness == DataScannerEndianness_Native)
			{
			*outValue = *(short *)current;
			}
		else if (_endianness == DataScannerEndianness_Big)
			{
			*outValue = EndianS16_BtoN(*(short *)current);
			}
		else if (_endianness == DataScannerEndianness_Little)
			{
			*outValue = EndianS16_LtoN(*(short *)current);
			}
		}



	current += theLength;
	return(YES);
	}


@end
