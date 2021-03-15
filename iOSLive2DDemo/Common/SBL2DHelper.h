//
//  SBL2DHelper.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/13.
//

#import <Foundation/Foundation.h>
#import <CubismFramework.hpp>
#import <string>

NS_ASSUME_NONNULL_BEGIN

using namespace Live2D::Cubism::Framework;

extern void PrintLog(const csmChar *format, ...);

extern void PrintMessage(const csmChar *message);

extern csmByte *LoadFileAsBytes(const std::string filePath, csmSizeInt *outSize);

extern void ReleaseBytes(csmByte *byteData);

extern csmByte *CreateBuffer(const csmChar *path, csmSizeInt *size);

extern void DeleteBuffer(csmByte *buffer, const csmChar *path = "");

NS_ASSUME_NONNULL_END
