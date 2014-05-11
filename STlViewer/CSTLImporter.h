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

- (SCNNode *)importFile:(NSURL *)inURL error:(NSError *__autoreleasing *)outError;
- (SCNNode *)importBinaryFile:(NSURL *)inURL error:(NSError *__autoreleasing *)outError;
- (SCNNode *)importTextFile:(NSURL *)inURL error:(NSError *__autoreleasing *)outError;

@end
