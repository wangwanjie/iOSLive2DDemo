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
#import "UIColor+Live2D.h"
#import "SBNSObjectProxy.h"
#import "L2DMatrix44Bridge.h"

@interface KGOpenGLLive2DView () <GLKViewDelegate> {
    GLuint _vertexBufferId;
    GLuint _fragmentBufferId;
    /// 背景色
    float _clearColorR;
    float _clearColorG;
    float _clearColorB;
    float _clearColorA;
}

@property (nonatomic, strong) L2DUserModel *model;
@property (nonatomic, strong) GLKView *glkView;
/// 定时器代理
@property (nonatomic, strong) SBNSObjectProxy *displayLinkProxy;
/// 定时器
@property (nonatomic, strong) CADisplayLink *displayLink;
/// render
@property (nonatomic, strong) L2DOpenGLRender *renderer;
/// 桥接对象
@property (nonatomic, strong) L2DMatrix44Bridge *bridge;
@end

@implementation KGOpenGLLive2DView

NS_INLINE EAGLContext *CreateBestEAGLContext() {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (context == nil) {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    return context;
}

#pragma mark - life cycle
- (void)commonInit {
    EAGLContext *context = CreateBestEAGLContext();

    _glkView = [[GLKView alloc] init];
    _glkView.delegate = self;
    _glkView.context = context;
    _glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [self addSubview:_glkView];

    [EAGLContext setCurrentContext:_glkView.context];

    self.backgroundColor = UIColor.whiteColor;

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

    self.displayLink = [CADisplayLink displayLinkWithTarget:[SBNSObjectProxy proxyWithObj:self] selector:@selector(drawView)];
    self.displayLink.preferredFramesPerSecond = MAX(1, 60.0f / _preferredFramesPerSecond);
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
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

- (void)destoryRenderAndFrameBuffer {
    glDeleteFramebuffers(1, &_vertexBufferId);
    _vertexBufferId = 0;
    glDeleteRenderbuffers(1, &_fragmentBufferId);
    _fragmentBufferId = 0;
}

- (void)dealloc {
    NSLog(@"KGOpenGLLive2DView dealloc - %p", self);

    [self destoryRenderAndFrameBuffer];

    [self.glkView deleteDrawable];
    [EAGLContext setCurrentContext:nil];

    [self.displayLink invalidate];
    self.displayLink = nil;

    self.renderer = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification
- (void)applicationDidEnterBackground {
    self.paused = true;
}

#pragma mark - setter

- (void)setDelegate:(id<OpenGLRenderDelegate>)delegate {
    if (!self.renderer) {
        return;
    }
    _delegate = delegate;

    self.renderer.delegate = delegate;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    self.glkView.frame = self.bounds;
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

    self.displayLink.preferredFramesPerSecond = _preferredFramesPerSecond;
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
    [self.glkView setNeedsDisplay];
}

#pragma mark - L2DModelActionProtocol

- (float)getPartsOpacityNamed:(NSString *)name {
    return [self.model getPartsOpacityNamed:name];
}

- (float)getValueForModelParameterNamed:(NSString *)name {
    return [self.model getValueForModelParameterNamed:name];
}

- (void)performExpression:(SBProductioEmotionExpression *)expression {
    [self.model performExpression:expression];
}

- (void)performExpressionWithExpressionID:(NSString *)expressionID {
    [self.model performExpressionWithExpressionID:expressionID];
}

- (void)performMotion:(NSString *)groupName index:(NSUInteger)index priority:(L2DPriority)priority {
    [self.model performMotion:groupName index:index priority:priority];
}

- (void)performRandomExpression {
    [self.model performRandomExpression];
}

- (void)setModelParameterNamed:(NSString *)name blendMode:(L2DBlendMode)blendMode value:(float)value {
    [self.model setModelParameterNamed:name blendMode:blendMode value:value];
}

- (void)setModelParameterNamed:(NSString *)name value:(float)value {
    [self.model setModelParameterNamed:name value:value];
}

- (void)setPartsOpacityNamed:(NSString *)name opacity:(float)opacity {
    [self.model setPartsOpacityNamed:name opacity:opacity];
}

#pragma mark - L2DViewRenderer

- (void)loadLive2DModelWithDir:(NSString *)dirName mocJsonName:(NSString *)mocJsonName {
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
    self.renderer.bridgeOutSet = self.bridge;
    self.renderer.spriteColor = self.spriteColor;

    [self.renderer startWithView:self.glkView];
}

- (void)setParameterWithDictionary:(NSDictionary<NSString *, NSNumber *> *)params {
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSNumber *_Nonnull obj, BOOL *_Nonnull stop) {
        [self setModelParameterNamed:key value:[obj floatValue]];
    }];
}

- (void)setPartOpacityWithDictionary:(NSDictionary<NSString *, NSNumber *> *)parts {
    [parts enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSNumber *_Nonnull obj, BOOL *_Nonnull stop) {
        [self setPartsOpacityNamed:key opacity:[obj floatValue]];
    }];
}

@synthesize preferredFramesPerSecond = _preferredFramesPerSecond;
@synthesize paused = _paused;

- (CGSize)canvasSize {
    return self.model.modelSize;
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {

    glClear(GL_COLOR_BUFFER_BIT);

    glClearColor(_clearColorR, _clearColorG, _clearColorB, _clearColorA);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    NSTimeInterval time = 1.0 / (NSTimeInterval)(self.displayLink.preferredFramesPerSecond);

    [self.renderer update:time];

    // [self.renderer render:_vertexBufferId fragmentBufferID:_fragmentBufferId];
}

- (float)GetSpriteAlpha:(int)assign {
    // assignの数値に応じて適当に決定
    float alpha = 0.25f + (float)assign * 0.5f;  // サンプルとしてαに適当な差をつける
    if (alpha > 1.0f) {
        alpha = 1.0f;
    }
    if (alpha < 0.1f) {
        alpha = 0.1f;
    }

    return alpha;
}

#pragma mark - lazy load

- (L2DOpenGLRender *)renderer {
    if (!_renderer) {
        _renderer = [[L2DOpenGLRender alloc] init];

        if (self.delegate) {
            _renderer.delegate = self.delegate;
        }
    }
    return _renderer;
}

- (L2DMatrix44Bridge *)bridge {
    if (!_bridge) {
        _bridge = [[L2DMatrix44Bridge alloc] init];
    }
    return _bridge;
}
@end
