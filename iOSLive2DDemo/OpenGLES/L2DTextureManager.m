//
//  L2DTextureManager.m
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/14.
//

#import "L2DTextureManager.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>

@interface L2DTextureManager ()
/// 所有纹理
@property (nonatomic, strong) NSMutableArray<NSValue *> *textures;
@end

@implementation L2DTextureManager

- (void)dealloc {
    [self releaseTextures];
}

- (TextureInfo)createTextureFromPngFile:(NSString *)fileName {
    TextureInfo info = [self getTextureInfoWithFileName:fileName];
    return info;
}

- (TextureInfo)getTextureInfoWithFileName:(NSString *)fileName {
    // 获取图片的CGImageRef
    UIImage *image = [UIImage imageNamed:fileName];
    CGImageRef spriteImage = image.CGImage;

    // 读取图片的大小
    GLuint width = (GLuint)CGImageGetWidth(spriteImage);
    GLuint height = (GLuint)CGImageGetHeight(spriteImage);

    GLubyte *spriteData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));  //rgba共4个byte

    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);

    // 在CGContextRef上绘图
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

    TextureInfo textureInfo = {};
    textureInfo.name = textureID;
    textureInfo.width = width;
    textureInfo.height = height;

    NSValue *value = [NSValue valueWithBytes:&textureInfo objCType:@encode(TextureInfo)];
    [_textures addObject:value];

    free(spriteData);

    return textureInfo;
}

- (unsigned int)pemultiply:(unsigned char)red green:(unsigned char)green blue:(unsigned char)blue alpha:(unsigned char)alpha {
    return (unsigned int)((red * (alpha + 1) >> 8) |
                          ((green * (alpha + 1) >> 8) << 8) |
                          ((blue * (alpha + 1) >> 8) << 16) |
                          (((alpha)) << 24));
}

- (void)releaseTextures {

    [self.textures removeAllObjects];
    _textures = nil;
}

- (void)releaseTextureWithId:(unsigned int)textureId {

    NSMutableArray<NSValue *> *copyed = self.textures.mutableCopy;
    for (NSValue *value in copyed) {
        TextureInfo info;
        [value getValue:&info];
        if (info.name == textureId) {
            [copyed removeObject:value];
            break;
        }
    }
    self.textures = copyed;
}

#pragma mark - lazy load
- (NSMutableArray<NSValue *> *)textures {
    if (!_textures) {
        _textures = [NSMutableArray array];
    }
    return _textures;
}
@end
