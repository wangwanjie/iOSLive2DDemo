//
//  SBL2DHelper.m
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/13.
//

#import "SBL2DHelper.h"
#import <stdio.h>
#import <stdlib.h>
#import <stdarg.h>
#import <sys/stat.h>
#import <iostream>
#import <fstream>

using std::endl;
using namespace Csm;
using namespace std;

csmByte *CreateBuffer(const csmChar *path, csmSizeInt *size) {

    return LoadFileAsBytes(path, size);
}

void DeleteBuffer(csmByte *buffer, const csmChar *path) {

    ReleaseBytes(buffer);
}

void PrintLog(const csmChar *format, ...) {
    va_list args;
    Csm::csmChar buf[256];
    va_start(args, format);
    vsnprintf(buf, sizeof(buf), format, args);  // 標準出力でレンダリング;
    NSLog(@"%@", [NSString stringWithCString:buf encoding:NSUTF8StringEncoding]);
    va_end(args);
}

void PrintMessage(const csmChar *message) {
    PrintLog("%s", message);
}

csmByte *LoadFileAsBytes(const string filePath, csmSizeInt *outSize) {
    int path_i = static_cast<int>(filePath.find_last_of("/") + 1);
    int ext_i = static_cast<int>(filePath.find_last_of("."));
    std::string pathname = filePath.substr(0, path_i);
    std::string extname = filePath.substr(ext_i, filePath.size() - ext_i);
    std::string filename = filePath.substr(path_i, ext_i - path_i);
    NSString *castFilePath = [[NSBundle mainBundle]
        pathForResource:[NSString stringWithUTF8String:filename.c_str()]
                 ofType:[NSString stringWithUTF8String:extname.c_str()]
            inDirectory:[NSString stringWithUTF8String:pathname.c_str()]];

    NSData *data = [NSData dataWithContentsOfFile:castFilePath];
    NSUInteger len = [data length];
    Byte *byteData = (Byte *)malloc(len);
    memcpy(byteData, [data bytes], len);

    *outSize = static_cast<Csm::csmSizeInt>(len);
    return static_cast<Csm::csmByte *>(byteData);
}

void ReleaseBytes(csmByte *byteData) {
    free(byteData);
}
