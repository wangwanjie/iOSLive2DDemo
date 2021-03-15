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
/// 是否已经加载资源
@property (nonatomic, assign) BOOL hasLoadResource;
@end

@implementation OpenGLLive2DViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Live2D OpenGLES Render";
    self.view.backgroundColor = UIColor.redColor;

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

    // self.live2DView.delegate = nil;

    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.live2DView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) * 1);

    if (!self.hasLoadResource) {
        [self.live2DView loadLive2DModelWithDir:@"Live2DResources/Shanbao/" mocJsonName:@"Shanbao.model3.json"];
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
@end
