//
//  DataScanner.swift
//  STlViewer
//
//  Created by Jonathan Wight on 8/15/14.
//  Copyright (c) 2014 schwa. All rights reserved.
//

import Foundation

enum Endianness {
	case Native
	case Little
	case Big
	}

class DataScanner {

    typealias Scalar = UInt8

    var data : ContiguousArray <Scalar> { didSet {
        self.start = 0
        self.end = data.count
        self.current = self.start
        } }
    var endianness : Endianness = .Native
    var scanLocation : Int {
        get { return self.current - self.start }
        set { self.current = self.start + newValue }
        }
    var bytesRemaining : Int { get { return self.end - self.current } }
    var isAtEnd : Bool { get { return self.current >= self.end } }

    var start : Int = 0
    var end : Int = 0
    var current : Int = 0

    init(data:ContiguousArray <Scalar>) {
        self.data = data
    }

    func characterAtIndex(index:Int) -> Character? {
        // TODO: Doesn't do uncide yet
        let byte = UnicodeScalar(UInt32(self.data[index]))
        return Character(byte)
    }

    var currentCharacter : Character! { get { return self.characterAtIndex(self.current) } }

//    typealias BufferType = ContiguousArray <Scalar>
//
////    func buffer(length:Int) -> BufferType {
////        return BufferType(self.current, length)
////    }
//
//
    func scanCharacter() -> Character! {
        if self.isAtEnd {
            return nil
        }
        else {
            return self.characterAtIndex(self.current++)
        }
    }

    func scanCharacter(expectedCharacter:Character) -> Bool {
        let scannedCharacter = self.characterAtIndex(self.current)
        if scannedCharacter == expectedCharacter {
            self.current++
            return true
        }
        else {
            return false
        }
    }

    func scanUTF8String(expectedString:String) -> Bool {
        let expectedUTF8 = expectedString.nulTerminatedUTF8
        if self.bytesRemaining < expectedUTF8.count {
            return false
        }
        
        let buffer = self.data[self.current..<self.current + expectedUTF8.count]
//        if buffer == expectedUTF8 {
//            return true
//        }
        

        return false
        
    }
//
////- (BOOL)scanUTF8String:(const char *)inString intoString:(NSString **)outValue
////    {
////    const size_t theLength = strlen(inString);
////    if ((size_t)(end - current) < theLength)
////        return(NO);
////    if (strncmp((char *)current, inString, theLength) == 0)
////        {
////        current += theLength;
////        if (outValue)
////            *outValue = [NSString stringWithUTF8String:inString];
////        return(YES);
////        }
////    return(NO);
////    }


}

let sDoubleCharacters = NSCharacterSet(charactersInString:"0123456789eE-+.")
