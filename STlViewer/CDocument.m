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
    if ((self = [super init]) != NULL)
        {
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
    self.sceneView.scene = self.scene;
    }

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError;
    {
    NSError *theError = NULL;
    SCNNode *theModelNode = [[[CSTLImporter alloc] init] importFile:url error:outError];
    [self.scene.rootNode addChildNode:theModelNode];
    return YES;
    }

@end
