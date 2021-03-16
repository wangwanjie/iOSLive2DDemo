//
//  MetalLive2DViewController.m
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/13.
//

#import "MetalLive2DViewController.h"
#import "KGMetalLive2DView.h"

@interface MetalLive2DViewController () <MetalRenderDelegate>
/// 渲染线程
@property (nonatomic, strong) dispatch_queue_t renderQueue;
/// 展示 live2d 的 View
@property (nonatomic, strong) KGMetalLive2DView *live2DView;
/// 展示 live2d 的 View
@property (nonatomic, strong) KGMetalLive2DView *live2DView2;
/// 是否已经加载资源
@property (nonatomic, assign) BOOL hasLoadResource;
@end

@implementation MetalLive2DViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        // Metal 可异步渲染
        _renderQueue = dispatch_queue_create("com.virtualsingler.render.home", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Live2D Metal Render";
    self.view.backgroundColor = UIColor.greenColor;

    [self.view addSubview:self.live2DView];
    self.live2DView.backgroundColor = UIColor.redColor;
    [self.view addSubview:self.live2DView2];

    self.live2DView.preferredFramesPerSecond = 30;
    self.live2DView2.preferredFramesPerSecond = 30;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (!self.live2DView.paused) {
        self.live2DView.paused = YES;
    }

    if (!self.live2DView2.paused) {
        self.live2DView2.paused = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.live2DView.paused) {
        self.live2DView.paused = NO;
    }
    if (self.live2DView2.paused) {
        self.live2DView2.paused = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.live2DView.paused) {
        self.live2DView.paused = NO;
    }
    if (self.live2DView2.paused) {
        self.live2DView2.paused = NO;
    }
}

- (void)dealloc {

    self.live2DView.delegate = nil;
    self.live2DView2.delegate = nil;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat height = CGRectGetHeight(self.view.frame) / 2;

    self.live2DView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), height);
    self.live2DView2.frame = CGRectMake(0, CGRectGetMaxY(self.live2DView.frame), CGRectGetWidth(self.view.frame), height);

    if (!self.hasLoadResource) {
        [self.live2DView loadLive2DModelWithDir:@"Live2DResources/Mark/" mocJsonName:@"Mark.model3.json"];
        [self.live2DView2 loadLive2DModelWithDir:@"Live2DResources/Shanbao/" mocJsonName:@"Shanbao.model3.json"];
        self.hasLoadResource = YES;
    }
}

#pragma mark - MetalRenderDelegate
- (void)rendererUpdateWithRender:(L2DMetalRender *)renderer duration:(NSTimeInterval)duration {
}

#pragma mark - lazy load
- (KGMetalLive2DView *)live2DView {
    if (!_live2DView) {
        _live2DView = [[KGMetalLive2DView alloc] init];
        _live2DView.delegate = self;
    }
    return _live2DView;
}

- (KGMetalLive2DView *)live2DView2 {
    if (!_live2DView2) {
        _live2DView2 = [[KGMetalLive2DView alloc] init];
        _live2DView2.delegate = self;
    }
    return _live2DView2;
}
@end
