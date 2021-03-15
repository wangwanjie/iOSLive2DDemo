//
//  KGOpenGLLive2DView.m
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/14.
//

#import "KGOpenGLLive2DView.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <GLKit/GLKit.h>
#import "L2DUserModel.h"
#import "OpenGLRender.h"
#import "UIColor+Live2D.h"
#import <CubismFramework.hpp>
#import <Math/CubismViewMatrix.hpp>

using namespace Live2D::Cubism::Framework;

@interface KGOpenGLLive2DView () <GLKViewDelegate>
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, assign) GLuint vertexBufferId;
@property (nonatomic, assign) GLuint fragmentBufferId;

@property (nonatomic, strong) L2DUserModel *model;
@property (nonatomic, strong) GLKView *contentView;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSMutableArray *textures;
@property (nonatomic, strong) EAGLContext *context;
/// render
@property (nonatomic, strong) OpenGLRender *renderer;
/// 背景色
@property (nonatomic, assign) float clearColorR;
@property (nonatomic, assign) float clearColorG;
@property (nonatomic, assign) float clearColorB;
@property (nonatomic, assign) float clearColorA;
/// モデル描画に用いるView行列
@property (nonatomic, assign) Csm::CubismMatrix44 *viewMatrix;
@end

@implementation KGOpenGLLive2DView

EAGLContext *CreateBestEAGLContext() {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (context == nil) {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    return context;
}

#pragma mark - life cycle
- (void)commonInit {
    _context = CreateBestEAGLContext();

    _contentView = [[GLKView alloc] init];
    _contentView.delegate = self;
    _contentView.context = _context;
    _contentView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [self addSubview:_contentView];

    [EAGLContext setCurrentContext:_contentView.context];

    // 画面の表示の拡大縮小や移動の変換を行う行列
    _viewMatrix = new CubismViewMatrix();

    self.backgroundColor = UIColor.clearColor;

    glClearColor(_clearColorR, _clearColorG, _clearColorB, _clearColorA);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glGenBuffers(1, &_vertexBufferId);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferId);

    glGenBuffers(1, &_fragmentBufferId);
    glBindBuffer(GL_ARRAY_BUFFER, _fragmentBufferId);

    self.preferredFramesPerSecond = 30;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView)];
    self.displayLink.preferredFramesPerSecond = MAX(1, 60.0f / _preferredFramesPerSecond);
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)loadLive2DWithJsonDir:(NSString *)dirName mocJsonName:(NSString *)mocJsonName {
    if (!dirName || !mocJsonName) {
        NSLog(@"资源路径不存在");
        return;
    }
    self.model = [[L2DUserModel alloc] initWithJsonDir:dirName mocJsonName:mocJsonName];
    [self.model createRenderer];

    if (_renderer) {
        self.renderer = nil;
    }
    self.renderer.model = self.model;
    self.renderer.viewMatrix = _viewMatrix;
    self.renderer.spriteColor = self.spriteColor;

    [self.renderer startWithView:self.contentView];
}

#pragma mark - setter

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    self.contentView.frame = self.bounds;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];

    RGBA rgba = backgroundColor.rgba;

    _clearColorR = rgba.r;
    _clearColorG = rgba.g;
    _clearColorB = rgba.b;
    _clearColorA = rgba.a;
}

- (void)setSpriteColor:(UIColor *)spriteColor {
    _spriteColor = spriteColor;

    self.renderer.spriteColor = spriteColor;
}

- (void)setPreferredFramesPerSecond:(NSInteger)preferredFramesPerSecond {
    _preferredFramesPerSecond = preferredFramesPerSecond;
    self.displayLink.preferredFramesPerSecond = MAX(1, 60.0f / _preferredFramesPerSecond);
}

- (BOOL)paused {
    return self.displayLink.paused;
}

- (void)setPaused:(BOOL)paused {
    self.displayLink.paused = paused;

    if (paused) {
        [self.displayLink setPaused:true];
    }
}

- (void)drawView {
    [self.contentView setNeedsDisplay];
}

- (CGSize)canvasSize {
    return self.model.modelSize;
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {

    glClear(GL_COLOR_BUFFER_BIT);

    glClearColor(_clearColorR, _clearColorG, _clearColorB, _clearColorA);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    NSTimeInterval time = 1.0 / (NSTimeInterval)(self.displayLink.preferredFramesPerSecond);
    [self.model updatePhysics:time];
    [self.model update];
    [self.model drawModel];

    // 各モデルが持つ描画ターゲットをテクスチャとする場合はスプライトへの描画はここ
    if (_renderTarget == SelectTarget_ModelFrameBuffer && _renderer) {
        float uvVertex[] =
            {
                0.0f,
                0.0f,
                1.0f,
                0.0f,
                0.0f,
                1.0f,
                1.0f,
                1.0f,
        };
        // サンプルとしてαに適当な差をつける
        float a = [self GetSpriteAlpha:0];

        L2DUserModel *model = self.model;
        if (model) {
            [model performExpression:nil];
            self.renderer.spriteColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:a];
            [_renderer renderImmidiate:_vertexBufferId fragmentBufferID:_fragmentBufferId textureId:self.renderer.textureId uvArray:uvVertex];
        }
    }
}

- (float)GetSpriteAlpha:(int)assign {
    // assignの数値に応じて適当に決定
    float alpha = 0.25f + static_cast<float>(assign) * 0.5f;  // サンプルとしてαに適当な差をつける
    if (alpha > 1.0f) {
        alpha = 1.0f;
    }
    if (alpha < 0.1f) {
        alpha = 0.1f;
    }

    return alpha;
}

#pragma mark - lazy load

- (OpenGLRender *)renderer {
    if (!_renderer) {
        _renderer = [[OpenGLRender alloc] init];
    }
    return _renderer;
}
@end
