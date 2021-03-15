//
//  OpenGLRender.m
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/14.
//

#import "OpenGLRender.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import "L2DTextureManager.h"

/**
 * @brief Rect 構造体。
 */
typedef struct {
    float left;   ///< 左辺
    float right;  ///< 右辺
    float up;     ///< 上辺
    float down;   ///< 下辺
} SpriteRect;

#define BUFFER_OFFSET(bytes) ((GLubyte *)NULL + (bytes))

@interface OpenGLRender ()
@property (nonatomic, assign) GLuint textureId;  // テクスチャID
@property (nonatomic, assign) SpriteRect rect;   // 矩形
@property (nonatomic, assign) GLuint vertexBufferId;
@property (nonatomic, assign) GLuint fragmentBufferId;
/// L2DTextureManager
@property (nonatomic, strong) L2DTextureManager *textureManager;
/// GLKTextureLoader
@property (nonatomic, strong) GLKTextureLoader *textureLoader;
@end

@implementation OpenGLRender

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initailize];
    }
    return self;
}

- (void)initailize {

    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;

    self.baseEffect.texture2d0.enabled = GL_TRUE;
}

- (void)setModel:(L2DUserModel *)model {
    _model = model;

    [self.model setupTexturesWithTextureManager:self.textureManager];
}

- (void)dealloc {
    // TODO: clean up
}

- (void)SetupTextures {
}

- (void)setSpriteColor:(GLKVector4)spriteColor {
    _spriteColor = spriteColor;

    self.baseEffect.constantColor = GLKVector4Make(_spriteColor.r, _spriteColor.g, _spriteColor.b, _spriteColor.a);
}
@end

@implementation OpenGLRender (Renderer)

- (void)startWithView:(GLKView *)view {

    CGRect screenRect = view.bounds;
    int width = screenRect.size.width;
    int height = screenRect.size.height;

    float x = width * 0.5f;
    float y = height * 0.5f;
    float fWidth = (float)width;
    float fHeight = (float)height;

    _rect.left = (x - fWidth * 0.5f);
    _rect.right = (x + fWidth * 0.5f);
    _rect.up = (y + fHeight * 0.5f);
    _rect.down = (y - fHeight * 0.5f);

    self.renderRect = view.bounds;
}

- (void)setSpriteColor:(GLKVector4)spriteColor {
    _spriteColor = spriteColor;

    self.baseEffect.constantColor = GLKVector4Make(_spriteColor.r, _spriteColor.g, _spriteColor.b, _spriteColor.a);
}

- (void)drawableSizeWillChange:(GLKView *)view size:(CGSize)size {
}

- (void)update:(NSTimeInterval)time {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rendererUpdateWithRender:duration:)]) {
        [self.delegate rendererUpdateWithRender:self duration:time];
    }
    [self.model updatePhysics:time];
    [self.model update];
    // [self updateDrawables];
}

- (void)render:(GLuint)vertexBufferID fragmentBufferID:(GLuint)fragmentBufferID {
    // 描画画像変更
    self.baseEffect.texture2d0.name = _textureId;

    // color
    self.baseEffect.constantColor = GLKVector4Make(_spriteColor.r, _spriteColor.g, _spriteColor.b, _spriteColor.a);

    [self.baseEffect prepareToDraw];

    CGRect renderRect = self.renderRect;
    float maxWidth = renderRect.size.width;
    float maxHeight = renderRect.size.height;

    float positionVertex[] =
        {
            (_rect.left - maxWidth * 0.5f) / (maxWidth * 0.5f),
            (_rect.down - maxHeight * 0.5f) / (maxHeight * 0.5f),
            (_rect.right - maxWidth * 0.5f) / (maxWidth * 0.5f),
            (_rect.down - maxHeight * 0.5f) / (maxHeight * 0.5f),
            (_rect.left - maxWidth * 0.5f) / (maxWidth * 0.5f),
            (_rect.up - maxHeight * 0.5f) / (maxHeight * 0.5f),
            (_rect.right - maxWidth * 0.5f) / (maxWidth * 0.5f),
            (_rect.up - maxHeight * 0.5f) / (maxHeight * 0.5f),
    };

    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(positionVertex), positionVertex, GL_STATIC_DRAW);

    // 頂点情報の位置を、頂点処理の変数に指定する（これを用いて描画を行う）
    glEnableVertexAttribArray(GLKVertexAttribPosition);

    // 頂点情報の格納場所と書式を頂点処理に教える
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));

    glBindBuffer(GL_ARRAY_BUFFER, fragmentBufferID);

    const GLfloat uv[] =
        {
            0.0f,
            1.0f,
            1.0f,
            1.0f,
            0.0f,
            0.0f,
            1.0f,
            0.0f,
    };
    glBindBuffer(GL_ARRAY_BUFFER, fragmentBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(uv), uv, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));

    // 図形を描く
    glDisable(GL_CULL_FACE);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)renderImmidiate:(GLuint)vertexBufferID fragmentBufferID:(GLuint)fragmentBufferID TextureId:(GLuint)textureId uvArray:(float *)uvArray {
    // 描画画像変更
    self.baseEffect.texture2d0.name = textureId;

    // color
    self.baseEffect.constantColor = GLKVector4Make(_spriteColor.r, _spriteColor.g, _spriteColor.b, _spriteColor.a);

    [self.baseEffect prepareToDraw];

    CGRect renderRect = self.renderRect;
    float maxWidth = renderRect.size.width;
    float maxHeight = renderRect.size.height;

    float positionVertex[] =
        {
            (_rect.left - maxWidth * 0.5f) / (maxWidth * 0.5f),
            (_rect.down - maxHeight * 0.5f) / (maxHeight * 0.5f),
            (_rect.right - maxWidth * 0.5f) / (maxWidth * 0.5f),
            (_rect.down - maxHeight * 0.5f) / (maxHeight * 0.5f),
            (_rect.left - maxWidth * 0.5f) / (maxWidth * 0.5f),
            (_rect.up - maxHeight * 0.5f) / (maxHeight * 0.5f),
            (_rect.right - maxWidth * 0.5f) / (maxWidth * 0.5f),
            (_rect.up - maxHeight * 0.5f) / (maxHeight * 0.5f),
    };

    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(positionVertex), positionVertex, GL_STATIC_DRAW);

    // 頂点情報の位置を、頂点処理の変数に指定する（これを用いて描画を行う）
    glEnableVertexAttribArray(GLKVertexAttribPosition);

    // 頂点情報の格納場所と書式を頂点処理に教える
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));

    glBindBuffer(GL_ARRAY_BUFFER, fragmentBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 8, uvArray, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));

    // 図形を描く
    glDisable(GL_CULL_FACE);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (bool)isHit:(float)pointX PointY:(float)pointY {
    return (pointX >= _rect.left && pointX <= _rect.right &&
            pointY >= _rect.down && pointY <= _rect.up);
}

#pragma mark - lazy load
- (L2DTextureManager *)textureManager {
    if (!_textureManager) {
        _textureManager = [[L2DTextureManager alloc] init];
    }
    return _textureManager;
}
@end
