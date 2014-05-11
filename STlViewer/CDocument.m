//
//  CDocument.m
//  STlViewer
//
//  Created by Jonathan Wight on 5/10/14.
//  Copyright (c) 2014 schwa. All rights reserved.
//

#import "CDocument.h"

@import SceneKit;

#import "CSTLImporter.h"

#pragma mark -

@interface CDocument ()
@property (readwrite, nonatomic) SCNScene *scene;
@property (readwrite, nonatomic, assign) IBOutlet SCNView *sceneView;
@end

#pragma mark -

@implementation CDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        _scene = [SCNScene scene];
    }
    return self;
}

- (NSString *)windowNibName
{
    return @"CDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];

    self.sceneView.showsStatistics = YES;

    self.scene = [SCNScene scene];

//    SCNNode *theDemoNode = [SCNNode nodeWithGeometry:[SCNSphere sphereWithRadius:1.0]];
//    [self.scene.rootNode addChildNode:theDemoNode];

    NSError *theError = NULL;
    SCNNode *theModelNode = [[[CSTLImporter alloc] init] importBinaryFile:&theError];
    NSLog(@"%@ %@", theModelNode, theError);
    [self.scene.rootNode addChildNode:theModelNode];

    self.sceneView.scene = self.scene;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return YES;
}

@end
