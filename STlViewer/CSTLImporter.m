//
//  CSTLImporter.m
//  STlViewer
//
//  Created by Jonathan Wight on 5/10/14.
//  Copyright (c) 2014 schwa. All rights reserved.
//

#import "CSTLImporter.h"

@import SceneKit;

#import "CDataScanner.h"

#define DO_ERROR(variable, domain, incode, description) \
    { \
    if (variable != NULL) \
        { \
        NSDictionary *theUserInfo = @{ \
            NSLocalizedDescriptionKey: (description), \
            }; \
        *variable = [NSError errorWithDomain:(domain) code:(incode) userInfo:theUserInfo]; \
        } \
    }

@implementation CSTLImporter

- (SCNNode *)importBinaryFile:(NSError *__autoreleasing *)outError
    {
    NSURL *theURL = [NSURL fileURLWithPath:@"/Users/schwa/Desktop/STlViewer/STlViewer/Multicopter Rail Bracket.stl"];
    NSError *theError = NULL;
    NSData *theData = [NSData dataWithContentsOfURL:theURL options:0 error:&theError];

    CDataScanner *theScanner = [[CDataScanner alloc] initWithData:theData];
    theScanner.endianness = DataScannerEndianness_Little;

    NSData *theHeaderData = NULL;
    if ([theScanner scanDataOfLength:80 intoData:&theHeaderData] == NO)
        {
        DO_ERROR(outError, @"TODO_DOMAIN", -1, @"File too short to be binary");
        return NO;
        }
    NSString *theHeaderString = [[NSString alloc] initWithData:theHeaderData encoding:NSASCIIStringEncoding];
    if ([theHeaderString hasPrefix:@"solid "] == YES)
        {
        DO_ERROR(outError, @"TODO_DOMAIN", -1, @"File looks like a text file.");
        return NO;
        }

    NSMutableData *theVertices = [NSMutableData data];
    NSMutableData *theNormals = [NSMutableData data];
    NSMutableData *theElements = [NSMutableData data];


    uint32_t theNumberOfTriangles;
    if ([theScanner scanUInt32:&theNumberOfTriangles] == NO)
        {
        DO_ERROR(outError, @"TODO_DOMAIN", -1, @"TODO");
        return NO;
        }

    for (uint32_t N = 0; N != theNumberOfTriangles; ++N)
        {
        SCNVector3 theNormal;
        if ([self _dataScanner:theScanner scanVector3:&theNormal] == NO)
            {
            DO_ERROR(outError, @"TODO_DOMAIN", -1, @"Could not scan normal");
            return NO;
            }

        for (uint32_t theVertexIndex = 0; theVertexIndex != 3; ++theVertexIndex)
            {
            SCNVector3 theVertex;
            if ([self _dataScanner:theScanner scanVector3:&theVertex] == NO)
                {
                DO_ERROR(outError, @"TODO_DOMAIN", -1, @"Could not scan vertex");
                return NO;
                }

            [theVertices appendBytes:&theVertex length:sizeof(theVertex)];
            [theNormals appendBytes:&theNormal length:sizeof(theNormal)];


            }
        theScanner.scanLocation += sizeof(uint16_t);

        int theIndices[3] = { N * 3 + 0, N * 3 + 1, N * 3 + 2 };
        [theElements appendBytes:&theIndices[0] length:sizeof(theIndices)];
        }

    SCNGeometrySource *theVerticesSource = [SCNGeometrySource geometrySourceWithData:theVertices semantic:SCNGeometrySourceSemanticVertex vectorCount:theNumberOfTriangles * 3 floatComponents:YES componentsPerVector:3 bytesPerComponent:sizeof(CGFloat) dataOffset:0 dataStride:sizeof(SCNVector3)];
    SCNGeometrySource *theNormalsSource = [SCNGeometrySource geometrySourceWithData:theNormals semantic:SCNGeometrySourceSemanticNormal vectorCount:theNumberOfTriangles * 3 floatComponents:YES componentsPerVector:3 bytesPerComponent:sizeof(CGFloat) dataOffset:0 dataStride:sizeof(SCNVector3)];

    SCNGeometryElement *theElement = [SCNGeometryElement geometryElementWithData:theElements primitiveType:SCNGeometryPrimitiveTypeTriangles primitiveCount:theNumberOfTriangles bytesPerIndex:sizeof(int)];

    SCNGeometry *theGeometry = [SCNGeometry geometryWithSources:@[ theVerticesSource, theNormalsSource ] elements:@[ theElement ]];
    SCNNode *theNode = [SCNNode nodeWithGeometry:theGeometry];

    return theNode;
    }

- (SCNNode *)importTextFile:(NSError *__autoreleasing *)outError
    {
    NSURL *theURL = [NSURL fileURLWithPath:@"/Users/schwa/Desktop/STlViewer/STlViewer/cube.stl"];
    NSStringEncoding theEncoding = NSASCIIStringEncoding;
    NSError *theError = NULL;
    NSString *theString = [NSString stringWithContentsOfURL:theURL usedEncoding:&theEncoding error:&theError];
    NSScanner *theScanner = [NSScanner scannerWithString:theString];

    if ([theScanner scanString:@"solid" intoString:NULL] == NO)
        {
        DO_ERROR(outError, @"TODO_DOMAIN", -1, @"STL file did not start with 'solid'");
        return NULL;
        }

    NSCharacterSet *theNameCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz_"];

    NSString *theName = NULL;
    if ([theScanner scanCharactersFromSet:theNameCharacterSet intoString:&theName] == NO)
        {
        DO_ERROR(outError, @"TODO_DOMAIN", -1, @"Could not find name.");
        return NULL;
        }

    SCNNode *theModelNode = [SCNNode node];

    SCNGeometry *theGeometry = NULL;
    while ([self _scanner:theScanner scanFacet:&theGeometry error:&theError] == YES)
        {
        SCNNode *theNode = [SCNNode nodeWithGeometry:theGeometry];
        [theModelNode addChildNode:theNode];
        }

    if ([theScanner scanString:@"endsolid" intoString:NULL] == NO)
        {
        DO_ERROR(outError, @"TODO_DOMAIN", -1, @"STL file did not end with 'endsolid'");
        return NULL;
        }

    return theModelNode;
    }

- (BOOL)_scanner:(NSScanner *)inScanner scanFacet:(SCNGeometry *__autoreleasing *)outGeometry error:(NSError *__autoreleasing *)outError
    {
    const NSUInteger theScanLocation = inScanner.scanLocation;

    if ([inScanner scanString:@"facet" intoString:NULL] == NO)
        {
        DO_ERROR(outError, @"TODO_DOMAIN", -1, @"TODO");
        inScanner.scanLocation = theScanLocation;
        return NO;
        }

    if ([inScanner scanString:@"normal" intoString:NULL] == NO)
        {
        DO_ERROR(outError, @"TODO_DOMAIN", -1, @"TODO");
        inScanner.scanLocation = theScanLocation;
        return NO;
        }

    SCNVector3 theNormal;
    if ([self _scanner:inScanner scanVector3:&theNormal error:NULL] == NO)
        {
        DO_ERROR(outError, @"TODO_DOMAIN", -1, @"TODO");
        inScanner.scanLocation = theScanLocation;
        return NO;
        }

    if ([inScanner scanString:@"outer loop" intoString:NULL] == NO)
        {
        DO_ERROR(outError, @"TODO_DOMAIN", -1, @"TODO");
        inScanner.scanLocation = theScanLocation;
        return NO;
        }


    NSInteger theCount = 0;
    NSMutableData *theVertices = [NSMutableData data];
    NSMutableData *theNormals = [NSMutableData data];

    while (YES)
        {
        if ([inScanner scanString:@"vertex" intoString:NULL] == NO)
            {
            break;
            }

        SCNVector3 theVertex;
        if ([self _scanner:inScanner scanVector3:&theVertex error:NULL] == NO)
            {
            DO_ERROR(outError, @"TODO_DOMAIN", -1, @"TODO");
            inScanner.scanLocation = theScanLocation;
            return NO;
            }
        [theVertices appendBytes:&theVertex length:sizeof(theVertex)];
        [theNormals appendBytes:&theNormal length:sizeof(theNormal)];

        theCount++;
        }

    SCNGeometrySource *theVerticesSource = [SCNGeometrySource geometrySourceWithData:theVertices semantic:SCNGeometrySourceSemanticVertex vectorCount:theCount floatComponents:YES componentsPerVector:3 bytesPerComponent:sizeof(CGFloat) dataOffset:0 dataStride:sizeof(SCNVector3)];
    SCNGeometrySource *theNormalsSource = [SCNGeometrySource geometrySourceWithData:theNormals semantic:SCNGeometrySourceSemanticNormal vectorCount:theCount floatComponents:YES componentsPerVector:3 bytesPerComponent:sizeof(CGFloat) dataOffset:0 dataStride:sizeof(SCNVector3)];

    NSParameterAssert(theCount == 3);
    int theIndexes[] = { 0, 1, 2 };

    SCNGeometryElement *theElement = [SCNGeometryElement geometryElementWithData:[NSData dataWithBytes:&theIndexes[0] length:sizeof(theIndexes)] primitiveType:SCNGeometryPrimitiveTypeTriangles primitiveCount:1 bytesPerIndex:sizeof(int)];

    SCNGeometry *theGeometry = [SCNGeometry geometryWithSources:@[ theVerticesSource, theNormalsSource ] elements:@[ theElement ]];

    if ([inScanner scanString:@"endloop" intoString:NULL] == NO)
        {
        DO_ERROR(outError, @"TODO_DOMAIN", -1, @"TODO");
        inScanner.scanLocation = theScanLocation;
        return NO;
        }

    if ([inScanner scanString:@"endfacet" intoString:NULL] == NO)
        {
        DO_ERROR(outError, @"TODO_DOMAIN", -1, @"TODO");
        inScanner.scanLocation = theScanLocation;
        return NO;
        }

    if (outGeometry != NULL)
        {
        *outGeometry = theGeometry;
        }

    return YES;
    }

- (BOOL)_scanner:(NSScanner *)inScanner scanVector3:(SCNVector3 *)outVector error:(NSError *__autoreleasing *)outError
    {
    const NSUInteger theScanLocation = inScanner.scanLocation;

    SCNVector3 theVector;

    if ([inScanner scanDouble:&theVector.x] == NO)
        {
        inScanner.scanLocation = theScanLocation;
        DO_ERROR(outError, @"TODO_DOMAIN", -1, @"TODO");
        return NO;
        }
    if ([inScanner scanDouble:&theVector.y] == NO)
        {
        inScanner.scanLocation = theScanLocation;
        DO_ERROR(outError, @"TODO_DOMAIN", -1, @"TODO");
        return NO;
        }
    if ([inScanner scanDouble:&theVector.z] == NO)
        {
        inScanner.scanLocation = theScanLocation;
        DO_ERROR(outError, @"TODO_DOMAIN", -1, @"TODO");
        return NO;
        }

    if (outVector != NULL)
        {
        *outVector = theVector;
        }

    return YES;
    }

- (BOOL)_dataScanner:(CDataScanner *)inScanner scanVector3:(SCNVector3 *)outVector3
    {
    NSInteger theScanLocation = inScanner.scanLocation;

    float x, y, z;
    if ([inScanner scanFloat:&x] == NO)
        {
        inScanner.scanLocation = theScanLocation;
        return NO;
        }
    if ([inScanner scanFloat:&y] == NO)
        {
        inScanner.scanLocation = theScanLocation;
        return NO;
        }
    if ([inScanner scanFloat:&z] == NO)
        {
        inScanner.scanLocation = theScanLocation;
        return NO;
        }
    if (outVector3)
        {
        *outVector3 = (SCNVector3){ x, y, z };
        }
    return YES;
    }



@end
