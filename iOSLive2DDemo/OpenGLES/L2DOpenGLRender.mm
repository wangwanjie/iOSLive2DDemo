//
//  L2DOpenGLRender.m
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/14.
//

#import "L2DOpenGLRender.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import "L2DTextureManager.h"
#import "UIColor+Live2D.h"
#import "L2DUserModel.h"
#import "L2DCOCBridge.h"

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

@interface L2DOpenGLRender ()
@property (nonatomic, assign) GLuint textureId;  // テクスチャID
@property (nonatomic, assign) SpriteRect rect;   // 矩形
@property (nonatomic, assign) GLuint vertexBufferId;
@property (nonatomic, assign) GLuint fragmentBufferId;
/// L2DTextureManager
@property (nonatomic, strong) L2DTextureManager *textureManager;
/// GLKTextureLoader
@property (nonatomic, strong) GLKTextureLoader *textureLoader;
/// 前景色
@property (nonatomic, assign) float spriteColorR;
@property (nonatomic, assign) float spriteColorG;
@property (nonatomic, assign) float spriteColorB;
@property (nonatomic, assign) float spriteColorA;
/// 桥接对象
@property (nonatomic, strong) L2DCOCBridge *bridge;
@end

@implementation L2DOpenGLRender

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

    self.textureId = 0;

    self.scale = 1.0 / self.defaultRenderScale;
}

- (void)setModel:(L2DUserModel *)model {
    _model = model;

    [self.model setupTexturesWithTextureManager:self.textureManager];
}

- (void)dealloc {
    _baseEffect = nil;
    
    NSLog(@"L2DOpenGLRender dealloc - %p", self);
}

- (void)setSpriteColor:(UIColor *)spriteColor {
    _spriteColor = spriteColor;

    RGBA rgba = spriteColor.rgba;

    _spriteColorR = rgba.r;
    _spriteColorG = rgba.g;
    _spriteColorB = rgba.b;
    _spriteColorA = rgba.a;

    self.baseEffect.constantColor = GLKVector4Make(_spriteColorR, _spriteColorG, _spriteColorB, _spriteColorA);
}

#pragma mark - getter
- (float)defaultRenderScale {
    return 210.0 / 1046.0;
}
@end

@implementation L2DOpenGLRender (Renderer)

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

- (void)update:(NSTimeInterval)time {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rendererUpdateWithRender:duration:)]) {
        [self.delegate rendererUpdateWithRender:self duration:time];
    }

    [self.model updateWithDeltaTime:time];
    [self.model update];

    Csm::CubismMatrix44 projection;

    if (self.bridgeOutSet.viewMatrix != nil) {
        projection.MultiplyByMatrix(self.bridgeOutSet.viewMatrix);
    }

    CGRect renderRect = self.renderRect;
    int width = renderRect.size.width;
    int height = renderRect.size.height;

    projection.Scale(1.0f, static_cast<float>(width) / static_cast<float>(height));
    projection.ScaleRelative(_scale, _scale);

    self.bridge.viewMatrix = &projection;

    [self.model drawModelWithBridge:self.bridge];
}

- (void)render:(GLuint)vertexBufferID fragmentBufferID:(GLuint)fragmentBufferID {
    // 描画画像変更
    self.baseEffect.texture2d0.name = _textureId;

    // color
    self.baseEffect.constantColor = GLKVector4Make(_spriteColorR, _spriteColorG, _spriteColorB, _spriteColorA);

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

- (void)renderImmidiate:(GLuint)vertexBufferID fragmentBufferID:(GLuint)fragmentBufferID textureId:(GLuint)textureId uvArray:(float *)uvArray {
    // 描画画像変更
    self.baseEffect.texture2d0.name = textureId;

    // color
    self.baseEffect.constantColor = GLKVector4Make(_spriteColorR, _spriteColorG, _spriteColorB, _spriteColorA);

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

- (L2DCOCBridge *)bridge {
    if (!_bridge) {
        _bridge = [[L2DCOCBridge alloc] init];
    }
    return _bridge;
}
@end
