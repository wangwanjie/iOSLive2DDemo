//
//  OpenGLLive2DViewController.m
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/13.
//

#import "OpenGLLive2DViewController.h"
#import "KGOpenGLLive2DView.h"

@interface OpenGLLive2DViewController ()
/// 展示 live2d 的 View
@property (nonatomic, strong) KGOpenGLLive2DView *live2DView;
/// 展示 live2d 的 View
@property (nonatomic, strong) KGOpenGLLive2DView *live2DView2;
/// 是否已经加载资源
@property (nonatomic, assign) BOOL hasLoadResource;
@end

@implementation OpenGLLive2DViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Live2D OpenGLES Render";
    self.view.backgroundColor = UIColor.whiteColor;

    [self.view addSubview:self.live2DView];
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

    //  self.live2DView.delegate = nil;

    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.live2DView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) * 0.5);
    self.live2DView2.frame = CGRectMake(0, CGRectGetMaxY(self.live2DView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) * 0.5);

    if (!self.hasLoadResource) {
        [self.live2DView loadLive2DWithJsonDir:@"Live2DResources/Mark/" mocJsonName:@"Mark.model3.json"];
        [self.live2DView2 loadLive2DWithJsonDir:@"Live2DResources/Shanbao/" mocJsonName:@"Shanbao.model3.json"];
        self.hasLoadResource = YES;
    }
}

//#pragma mark - MetalRenderDelegate
//- (void)rendererUpdateWithRender:(MetalRender *)renderer duration:(NSTimeInterval)duration {
//}

#pragma mark - lazy load
- (KGOpenGLLive2DView *)live2DView {
    if (!_live2DView) {
        _live2DView = [[KGOpenGLLive2DView alloc] init];
        // _live2DView.delegate = self;
    }
    return _live2DView;
}

- (KGOpenGLLive2DView *)live2DView2 {
    if (!_live2DView2) {
        _live2DView2 = [[KGOpenGLLive2DView alloc] init];
        //  _live2DView2.delegate = self;
    }
    return _live2DView2;
}
@end
