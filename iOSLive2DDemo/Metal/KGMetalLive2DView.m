//
//  KGMetalLive2DView.m
//  iOSLive2DDemo
//
//  Created by VanJay on 2020/12/19.
//

#import "KGMetalLive2DView.h"
#import "L2DUserModel.h"
#import "L2DMetalRender.h"
#import "UIColor+Live2D.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@interface KGMetalLive2DView () <MTKViewDelegate>
@property (nonatomic, strong) L2DUserModel *model;
@property (nonatomic, strong) L2DMetalRender *renderer;
@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, assign) MTLViewport viewPort;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) NSMutableArray<L2DMetalRender *> *renderers;
/// 背景色
@property (nonatomic, assign) MTLClearColor clearColor;
@end

@implementation KGMetalLive2DView

#pragma mark - life cycle
- (void)commonInit {

    self.opaque = NO;

    self.renderers = [NSMutableArray array];
    [self setupMtkView];
    [self startRenderWithMetal];

    self.backgroundColor = UIColor.clearColor;

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

- (void)dealloc {

    NSLog(@"KGMetalLive2DView dealloc - %p", self);

    [self stopMetalRender];

    [self removeRenderer:self.renderer];

    [self.mtkView releaseDrawables];
    self.mtkView.delegate = nil;
    self.mtkView = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification
- (void)applicationDidEnterBackground {
    self.paused = true;
}

#pragma mark - event response
- (void)drawView {
    [self.mtkView draw];
}

#pragma mark - setter
- (void)setDelegate:(id<MetalRenderDelegate>)delegate {
    if (!self.renderer) {
        return;
    }
    _delegate = delegate;

    self.renderer.delegate = delegate;
}

- (void)setDidCreatedTransformBuffer:(void (^)(void))didCreatedTransformBuffer {
    if (!self.renderer) {
        return;
    }
    _didCreatedTransformBuffer = didCreatedTransformBuffer;

    self.renderer.didCreatedTransformBuffer = didCreatedTransformBuffer;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    self.mtkView.frame = self.bounds;

    [self updateMTKViewPort];
}

- (void)setPreferredFramesPerSecond:(NSInteger)preferredFramesPerSecond {
    _preferredFramesPerSecond = preferredFramesPerSecond;

    self.mtkView.preferredFramesPerSecond = preferredFramesPerSecond;
}

- (BOOL)paused {
    return self.mtkView.paused;
}

- (void)setPaused:(BOOL)paused {
    self.mtkView.paused = paused;

    if (paused) {
        [self.mtkView releaseDrawables];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];

    RGBA rgba = backgroundColor.rgba;

    self.clearColor = MTLClearColorMake(rgba.r, rgba.g, rgba.b, rgba.a);
    self.mtkView.clearColor = self.clearColor;

    self.renderer.clearColor = self.clearColor;
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
    if (_renderer) {
        [self removeRenderer:self.renderer];
        self.renderer = nil;
    }
    self.renderer.model = self.model;

    [self addRenderer:self.renderer];
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

#pragma mark - private methods
- (void)startRenderWithMetal {
    if (!self.mtkView) {
        return;
    }
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (!device) {
        return;
    }
    self.commandQueue = [device newCommandQueue];

    self.mtkView.device = device;
    self.mtkView.paused = false;
    self.mtkView.hidden = false;

    for (L2DMetalRender *render in self.renderers) {
        [render startWithView:self.mtkView];
    }
}

- (void)stopMetalRender {
    self.mtkView.paused = true;
    self.mtkView.hidden = true;
    self.mtkView.device = nil;
}

- (void)addRenderer:(L2DMetalRender *)render {
    if (!self.mtkView) {
        return;
    }
    [self.renderers addObject:render];

    if (self.mtkView.paused) {
        if (self.renderers.count == 1) {
            [self startRenderWithMetal];
        }
    } else {
        [render startWithView:self.mtkView];
    }
}

- (void)removeRenderer:(L2DMetalRender *)render {
    [self.renderers removeAllObjects];

    if (self.renderers.count == 0) {
        [self stopMetalRender];
    }
}

- (void)setupMtkView {
    MTKView *mtkView = [[MTKView alloc] initWithFrame:self.bounds];
    mtkView.opaque = NO;
    mtkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:mtkView];
    mtkView.delegate = self;
    mtkView.framebufferOnly = true;
    mtkView.preferredFramesPerSecond = 30;
    mtkView.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    self.mtkView = mtkView;

    [self updateMTKViewPort];
}

- (void)updateMTKViewPort {
    CGSize size = self.mtkView.drawableSize;
    MTLViewport viewport = {};
    viewport.znear = 0.0;
    viewport.zfar = 1.0;
    if (size.width > size.height) {
        viewport.originX = 0.0;
        viewport.originY = (size.height - size.width) * 0.5;
        viewport.width = size.width;
        viewport.height = size.width;
    } else {
        viewport.originX = (size.width - size.height) * 0.5;
        viewport.originY = 0.0;
        viewport.width = size.height;
        viewport.height = size.height;
    }
    // 调整显示大小
    self.viewPort = viewport;
}

- (void)clearDrawable:(id<CAMetalDrawable>)drawable commandBuffer:(id<MTLCommandBuffer>)commandBuffer {
    MTLRenderPassDescriptor *renderOldDescriptor = [[MTLRenderPassDescriptor alloc] init];
    renderOldDescriptor.colorAttachments[0].texture = drawable.texture;
    renderOldDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    // 设置默认颜色
    renderOldDescriptor.colorAttachments[0].clearColor = self.clearColor;
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:renderOldDescriptor];
    if (encoder) {
        [encoder endEncoding];
    }
}

#pragma mark - MTKViewDelegate
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    for (L2DMetalRender *render in self.renderers) {
        [render drawableSizeWillChange:view size:size];
    }
}

- (void)drawInMTKView:(MTKView *)view {

    NSTimeInterval time = 1.0 / (NSTimeInterval)(view.preferredFramesPerSecond);

    for (L2DMetalRender *render in self.renderers) {
        [render update:time];
    }

    // Get drawable, create command buffer and pass to renderer.
    if (view.currentDrawable) {
        id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
        if (!commandBuffer) {
            return;
        }
        // 先清空一次
        [self clearDrawable:view.currentDrawable commandBuffer:commandBuffer];

        // 然后创建
        MTLRenderPassDescriptor *renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
        renderPassDescriptor.colorAttachments[0].texture = view.currentDrawable.texture;
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionLoad;
        renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        // 设置默认颜色
        renderPassDescriptor.colorAttachments[0].clearColor = self.clearColor;

        // Renderers.
        for (L2DMetalRender *render in self.renderers) {
            [render beginRenderWithTime:time viewPort:self.viewPort commandBuffer:commandBuffer passDescriptor:renderPassDescriptor];
        }
        [commandBuffer presentDrawable:view.currentDrawable];
        @try {
            [commandBuffer commit];
        } @catch (NSException *exception) {
            NSLog(@"commandBuffer commit exception");
        } @finally {
        }
    }
}

#pragma mark - lazy load
- (L2DMetalRender *)renderer {
    if (!_renderer) {
        _renderer = [[L2DMetalRender alloc] init];
        __weak __typeof(self) weakSelf = self;

        _renderer.didCreatedTransformBuffer = ^{
            __strong __typeof(weakSelf) self = weakSelf;
            if (self.didCreatedTransformBuffer) {
                self.didCreatedTransformBuffer();
            } else {
                L2DMetalRender *renderer = self.renderer;
                renderer.scale = 1 / renderer.defaultRenderScale;
            }
        };

        if (self.delegate) {
            _renderer.delegate = self.delegate;
        }
    }
    return _renderer;
}
@end
