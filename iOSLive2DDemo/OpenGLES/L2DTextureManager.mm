/**
 * Copyright(c) Live2D Inc. All rights reserved.
 *
 * Use of this source code is governed by the Live2D Open Software license
 * that can be found at https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html.
 */

#import "L2DTextureManager.h"
#import <GLKit/GLKit.h>
#import <iostream>

#define STBI_NO_STDIO
#define STBI_ONLY_PNG
#define STB_IMAGE_IMPLEMENTATION

@interface L2DTextureManager ()

@property (nonatomic) Csm::csmVector<TextureInfo *> textures;

@end

@implementation L2DTextureManager

- (void)dealloc {
    [self releaseTextures];
}

- (TextureInfo *)createTextureFromPngFile:(std::string)fileName {

    NSString *str = [NSString stringWithCString:fileName.c_str() encoding:NSUTF8StringEncoding];
    UIImage *image = [UIImage imageNamed:str];
    CGImageRef spriteImage = image.CGImage;

    GLKTextureInfo *info = [GLKTextureLoader textureWithCGImage:spriteImage options:nil error:nil];
    TextureInfo *textureInfo = new TextureInfo;
    textureInfo->fileName = fileName;
    textureInfo->width = info.width;
    textureInfo->height = info.height;
    textureInfo->id = info.name;
    _textures.PushBack(textureInfo);

    return textureInfo;
}

- (TextureInfo *)gerTextureInfoWithFileName:(NSString *)fileName {
    // 1获取图片的CGImageRef
    UIImage *image = [UIImage imageNamed:fileName];
    CGImageRef spriteImage = image.CGImage;

    // 2 读取图片的大小
    GLuint width = (GLuint)CGImageGetWidth(spriteImage);
    GLuint height = (GLuint)CGImageGetHeight(spriteImage);

    GLubyte *spriteData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));  //rgba共4个byte

    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);

    // 3在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);

    CGContextRelease(spriteContext);

    glActiveTexture(GL_TEXTURE0);
    glEnable(GL_TEXTURE_2D);

    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    float fw = width, fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);

    TextureInfo *textureInfo = new TextureInfo;
    textureInfo->fileName = [fileName cStringUsingEncoding:NSUTF8StringEncoding];
    textureInfo->width = width;
    textureInfo->height = height;
    textureInfo->id = textureID;
    _textures.PushBack(textureInfo);

    free(spriteData);

    return textureInfo;
}

- (unsigned int)pemultiply:(unsigned char)red Green:(unsigned char)green Blue:(unsigned char)blue Alpha:(unsigned char)alpha {
    return static_cast<unsigned>(
        (red * (alpha + 1) >> 8) |
        ((green * (alpha + 1) >> 8) << 8) |
        ((blue * (alpha + 1) >> 8) << 16) |
        (((alpha)) << 24));
}

- (void)releaseTextures {
    for (Csm::csmUint32 i = 0; i < _textures.GetSize(); i++) {
        delete _textures[i];
    }

    _textures.Clear();
}

- (void)releaseTextureWithId:(Csm::csmUint32)textureId {
    for (Csm::csmUint32 i = 0; i < _textures.GetSize(); i++) {
        if (_textures[i]->id != textureId) {
            continue;
        }
        delete _textures[i];
        _textures.Remove(i);
        break;
    }
}

- (void)releaseTextureByName:(std::string)fileName {
    for (Csm::csmUint32 i = 0; i < _textures.GetSize(); i++) {
        if (_textures[i]->fileName == fileName) {
            delete _textures[i];
            _textures.Remove(i);
            break;
        }
    }
}
@end
