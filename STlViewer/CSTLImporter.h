//
//  CSTLImporter.h
//  STlViewer
//
//  Created by Jonathan Wight on 5/10/14.
//  Copyright (c) 2014 schwa. All rights reserved.
//

@import Foundation;
@import SceneKit;

@interface CSTLImporter : NSObject

- (SCNNode *)importBinaryFile:(NSError *__autoreleasing *)outError;
- (SCNNode *)importTextFile:(NSError *__autoreleasing *)outError;

@end
