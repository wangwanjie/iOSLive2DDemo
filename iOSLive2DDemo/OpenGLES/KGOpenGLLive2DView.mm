//
//  KGOpenGLLive2DView.m
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/14.
//

#import "KGOpenGLLive2DView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <GLKit/GLKit.h>
#import "L2DUserModel.h"
#import "OpenGLRender.h"
#import "UIColor+Live2D.h"

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
@property (nonatomic, assign) GLKVector4 clearColor;
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

    self.backgroundColor = UIColor.clearColor;

    glClearColor(_clearColor.r, _clearColor.g, _clearColor.b, _clearColor.a);

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

    if (_renderer) {
        // [self removeRenderer:self.renderer];
        self.renderer = nil;
    }
    self.renderer.model = self.model;

    RGBA rgba = self.spriteColor.rgba;
    self.renderer.spriteColor = GLKVector4Make(rgba.r, rgba.g, rgba.b, rgba.a);

    [self.renderer startWithView:self.contentView];

    //  [self addRenderer:self.renderer];
}

#pragma mark - setter

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    self.contentView.frame = self.bounds;

    // [self updateMTKViewPort];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];

    RGBA rgba = backgroundColor.rgba;

    self.clearColor = GLKVector4Make(rgba.r, rgba.g, rgba.b, rgba.a);
}

- (void)setSpriteColor:(UIColor *)spriteColor {
    _spriteColor = spriteColor;

    RGBA rgba = spriteColor.rgba;

    self.renderer.spriteColor = GLKVector4Make(rgba.r, rgba.g, rgba.b, rgba.a);
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

    glClearColor(_clearColor.r, _clearColor.g, _clearColor.b, _clearColor.a);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    CGFloat modelWidth = self.canvasSize.width;
    CGFloat modelHeight = self.canvasSize.height;

    glLoadIdentity();

    glOrthof(0, modelWidth, modelHeight, 0, 0.5f, -0.5f);

    NSTimeInterval time = 1.0 / (NSTimeInterval)(self.displayLink.preferredFramesPerSecond);
    [self.model updatePhysics:time];
    [self.model update];

    // 各モデルが持つ描画ターゲットをテクスチャとする場合はスプライトへの描画はここ
    // if (_renderTarget == SelectTarget_ModelFrameBuffer) {
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

    float a = [self GetSpriteAlpha:0];  // サンプルとしてαに適当な差をつける

    L2DUserModel *model = self.model;
    if (model) {
        [model performExpression:nil];
        // model->SetExpression("");
        //            Csm::Rendering::CubismOffscreenFrame_OpenGLES2 &useTarget = model.renderBuffer;
        //            GLuint id = useTarget.GetColorBuffer();
        [_renderer renderImmidiate:_vertexBufferId fragmentBufferID:_fragmentBufferId TextureId:self.renderer.textureId uvArray:uvVertex];
    }
    //    }
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
