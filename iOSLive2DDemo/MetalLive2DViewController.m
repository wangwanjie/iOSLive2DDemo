//
//  MetalLive2DViewController.m
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/13.
//

#import "MetalLive2DViewController.h"
#import "KGLive2DView.h"

@interface MetalLive2DViewController () <MetalRenderDelegate>
/// 渲染线程
@property (nonatomic, strong) dispatch_queue_t renderQueue;
/// 展示 live2d 的 View
@property (nonatomic, strong) KGlive2DView *live2DView;
/// 是否已经加载资源
@property (nonatomic, assign) BOOL hasLoadResource;
@end

@implementation MetalLive2DViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _renderQueue = dispatch_queue_create("com.virtualsingler.render.home", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.live2DView];

    self.live2DView.preferredFramesPerSecond = 30;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (!self.live2DView.paused) {
        self.live2DView.paused = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.live2DView.paused) {
        self.live2DView.paused = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.live2DView.paused) {
        self.live2DView.paused = NO;
    }
}

- (void)dealloc {

    self.live2DView.delegate = nil;
    [self.live2DView handleDealloc];

    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect frame = {};
    frame.origin.x = 0;
    frame.origin.y = self.view.frame.size.height * (175.0 / 812.0);
    frame.size.width = self.view.frame.size.width;
    frame.size.height = self.view.frame.size.height * (482.0 / 812.0);
    self.live2DView.frame = frame;

    if (!self.hasLoadResource) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Live2DResources/Shanbao/Shanbao.model3" ofType:@"json"];
        [self.live2DView loadLive2DResourcesWithPath:path];
        self.hasLoadResource = YES;
    }
}

#pragma mark - MetalRenderDelegate
- (void)rendererUpdateWithRender:(MetalRender *)renderer duration:(NSTimeInterval)duration {
}

- (KGlive2DView *)live2DView {
    if (!_live2DView) {
        _live2DView = [[KGlive2DView alloc] init];
        _live2DView.delegate = self;
    }
    return _live2DView;
}
@end
