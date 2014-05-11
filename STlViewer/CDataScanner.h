//
//	CDataScanner.h
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

#import <Foundation/Foundation.h>

typedef enum {
	DataScannerEndianness_Native,
	DataScannerEndianness_Little,
	DataScannerEndianness_Big,
	} EDataScannerEndianness;

@interface CDataScanner : NSObject {
	NSData *data;

	u_int8_t *start;
	u_int8_t *end;
	u_int8_t *current;
	NSUInteger length;
}

@property (readwrite, nonatomic, strong) NSData *data;
@property (readwrite, nonatomic, assign) NSUInteger scanLocation;
@property (readonly, nonatomic, assign) NSUInteger bytesRemaining;
@property (readonly, nonatomic, assign) BOOL isAtEnd;
@property (readwrite, nonatomic, assign) EDataScannerEndianness endianness;

- (id)initWithData:(NSData *)inData;

- (unichar)currentCharacter;
- (unichar)scanCharacter;
- (BOOL)scanCharacter:(unichar)inCharacter;

- (BOOL)scanUTF8String:(const char *)inString intoString:(NSString **)outValue;
- (BOOL)scanString:(NSString *)inString intoString:(NSString **)outValue;
- (BOOL)scanCharactersFromSet:(NSCharacterSet *)inSet intoString:(NSString **)outValue; // inSet must only contain 7-bit ASCII characters

- (BOOL)scanUpToString:(NSString *)string intoString:(NSString **)outValue;
- (BOOL)scanUpToCharactersFromSet:(NSCharacterSet *)set intoString:(NSString **)outValue; // inSet must only contain 7-bit ASCII characters

// Binary
- (BOOL)scanUInt32:(uint32_t *)outValue;
- (BOOL)scanFloat:(float *)outValue;

// ASCII
- (BOOL)scanNumber:(NSNumber **)outValue;
- (BOOL)scanDecimalNumber:(NSDecimalNumber **)outValue;

- (BOOL)scanDataOfLength:(NSUInteger)inLength intoPointer:(void **)outPointer;
- (BOOL)scanDataOfLength:(NSUInteger)inLength intoData:(NSData **)outData;

- (void)skipWhitespace;

- (NSString *)remainingString;
- (NSData *)remainingData;

- (BOOL)scanIntoShort:(short *)outValue;

@end
