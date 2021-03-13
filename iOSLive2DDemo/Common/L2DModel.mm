//
//  L2DModel.mm
//  ShanBao
//
//  Created by VanJay on 2020/12/19.
//

#import "L2DModel.h"
#import "Live2DCubismCore.hpp"
#import "CubismUserModel.hpp"
#import "CubismFramework.hpp"
#import "CubismModelSettingJson.hpp"
#import "CubismIdManager.hpp"
#import "L2DAppDefine.h"

using namespace ::L2DAppDefine;
using namespace Live2D::Cubism::Core;
using namespace Live2D::Cubism::Framework;
using namespace Live2D::Cubism::Framework::Rendering;

@interface L2DModel () {
  @private
    NSURL *baseURL;
    CubismUserModel *model;
    CubismPhysics *physics;
    ICubismModelSetting *modelSetting;
}

@property (nonatomic, assign, readonly, getter=userModel) CubismUserModel *userModel;
@property (nonatomic, assign, readonly, getter=cubismModel) CubismModel *cubismModel;

@end

@implementation L2DModel

- (instancetype)initWithJsonPath:(NSString *)jsonPath {
    if (self = [super init]) {
        NSURL *url = [NSURL fileURLWithPath:jsonPath];
        // Get base directory name.
        baseURL = [url URLByDeletingLastPathComponent];

        // Read json file.
        NSData *data = [NSData dataWithContentsOfURL:url];

        // Create settings.
        modelSetting = new CubismModelSettingJson((const unsigned char *)[data bytes], (unsigned int)[data length]);

        // Get model file.
        NSString *modelFileName = [NSString stringWithCString:modelSetting->GetModelFileName() encoding:NSUTF8StringEncoding];
        NSData *modelData = [NSData dataWithContentsOfURL:[baseURL URLByAppendingPathComponent:modelFileName]];

        // Create model.
        model = CSM_NEW CubismUserModel();

        model->LoadModel((const unsigned char *)[modelData bytes], (unsigned int)[modelData length]);

        // Create physics.
        NSString *physicsFileName = [NSString stringWithCString:modelSetting->GetPhysicsFileName() encoding:NSUTF8StringEncoding];
        if (physicsFileName.length > 0) {
            NSData *physicsData = [NSData dataWithContentsOfURL:[baseURL URLByAppendingPathComponent:physicsFileName]];
            physics = CubismPhysics::Create((const unsigned char *)[physicsData bytes], (unsigned int)[physicsData length]);
        }
    }

    return self;
}

- (void)dealloc {
    NSLog(@"L2DModel dealloc - %p", self);

    if (model != NULL) {
        CSM_DELETE_SELF(CubismUserModel, model);
    }

    if (modelSetting != NULL) {
        CSM_DELETE_SELF(ICubismModelSetting, modelSetting);
    }

    if (physics != NULL) {
        CubismPhysics::Delete(physics);
    }
}

- (CubismUserModel *)userModel {
    return model;
}

- (CubismModel *)cubismModel {
    return model->GetModel();
}

- (CubismMotionManager *)expressionManager {
    return model->_expressionManager;
}

- (CGSize)modelSize {
    return CGSizeMake(self.cubismModel->GetCanvasWidth(), self.cubismModel->GetCanvasHeight());
}

- (void)setModelParameterNamed:(NSString *)name value:(float)value {
    [self setModelParameterNamed:name blendMode:L2DBlendModeNormal value:value];
}

- (void)performExpression:(SBProductioEmotionExpression *)expression {
    NSString *str = [expression.action yy_modelToJSONString];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger len = [data length];
    Byte *byteData = (Byte *)malloc(len);
    memcpy(byteData, [data bytes], len);

    csmByte *buffer = static_cast<Csm::csmByte *>(byteData);
    ACubismMotion *csmMotion = model->LoadExpression(buffer, (unsigned int)len, "", expression.fadeTime);
    if (csmMotion != NULL) {
        self.expressionManager->StartMotionPriority(csmMotion, true, PriorityForce);
    }
    free(byteData);
}

- (void)setModelParameterNamed:(NSString *)name blendMode:(L2DBlendMode)blendMode value:(float)value {
    const auto cubismParamID = CubismFramework::GetIdManager()->GetId((const char *)[name UTF8String]);
    switch (blendMode) {
        case L2DBlendModeNormal: {
            self.cubismModel->SetParameterValue(cubismParamID, value);
            break;
        }
        case L2DBlendModeAdditive: {
            self.cubismModel->AddParameterValue(cubismParamID, value);
            break;
        }
        case L2DBlendModeMultiplicative: {
            self.cubismModel->MultiplyParameterValue(cubismParamID, value);
            break;
        }
        default:
            self.cubismModel->SetParameterValue(cubismParamID, value);
            break;
    }
}

- (float)getValueForModelParameterNamed:(NSString *)name {
    const auto cubismParamID = CubismFramework::GetIdManager()->GetId((const char *)[name UTF8String]);
    float value = self.cubismModel->GetParameterValue(cubismParamID);
    return value;
}

- (void)setPartsOpacityNamed:(NSString *)name opacity:(float)opacity {
    const auto cubismPartID = CubismFramework::GetIdManager()->GetId((const char *)[name UTF8String]);
    self.cubismModel->SetPartOpacity(cubismPartID, opacity);
}

- (float)getPartsOpacityNamed:(NSString *)name {
    const auto cubismPartID = CubismFramework::GetIdManager()->GetId((const char *)[name UTF8String]);
    float opacity = self.cubismModel->GetPartOpacity(cubismPartID);
    return opacity;
}

- (NSArray *)textureURLs {
    NSMutableArray<NSURL *> *urls = [NSMutableArray array];
    for (int i = 0; i < modelSetting->GetTextureCount(); ++i) {
        @autoreleasepool {
            NSString *name = [NSString stringWithCString:modelSetting->GetTextureFileName(i) encoding:NSUTF8StringEncoding];
            [urls addObject:[NSURL URLWithString:name relativeToURL:baseURL]];
        }
    }
    return urls;
}

- (int)textureIndexForDrawable:(int)index {
    return self.cubismModel->GetDrawableTextureIndices(index);
}

- (int)drawableCount {
    return self.cubismModel->GetDrawableCount();
}

- (RawFloatArray *)vertexPositionsForDrawable:(int)index {
    int vertexCount = self.cubismModel->GetDrawableVertexCount(index);
    const float *positions = self.cubismModel->GetDrawableVertices(index);

    return [[RawFloatArray alloc] initWithCArray:positions count:vertexCount];
}

- (RawFloatArray *)vertexTextureCoordinateForDrawable:(int)index {
    int vertexCount = self.cubismModel->GetDrawableVertexCount(index);
    const csmVector2 *uvs = self.cubismModel->GetDrawableVertexUvs(index);

    return [[RawFloatArray alloc] initWithCArray:reinterpret_cast<const csmFloat32 *>(uvs) count:vertexCount];
}

- (RawUShortArray *)vertexIndicesForDrawable:(int)index {
    int indexCount = self.cubismModel->GetDrawableVertexIndexCount(index);
    const unsigned short *indices = self.cubismModel->GetDrawableVertexIndices(index);

    return [[RawUShortArray alloc] initWithCArray:indices count:indexCount];
}

- (RawIntArray *)masksForDrawable:(int)index {
    const int *maskCounts = self.cubismModel->GetDrawableMaskCounts();
    const int **masks = self.cubismModel->GetDrawableMasks();

    return [[RawIntArray alloc] initWithCArray:masks[index] count:maskCounts[index]];
}

- (bool)cullingModeForDrawable:(int)index {
    return (self.cubismModel->GetDrawableCulling(index) != 0);
}

- (float)opacityForDrawable:(int)index {
    return self.cubismModel->GetDrawableOpacity(index);
}

- (bool)visibilityForDrawable:(int)index {
    return self.cubismModel->GetDrawableDynamicFlagIsVisible(index);
}

- (L2DBlendMode)blendingModeForDrawable:(int)index {
    switch (self.cubismModel->GetDrawableBlendMode(index)) {
        case CubismRenderer::CubismBlendMode_Normal:
            return L2DBlendModeNormal;
        case CubismRenderer::CubismBlendMode_Additive:
            return L2DBlendModeAdditive;
        case CubismRenderer::CubismBlendMode_Multiplicative:
            return L2DBlendModeMultiplicative;
        default:
            return L2DBlendModeNormal;
    }
}

- (RawIntArray *)renderOrders {
    return [[RawIntArray alloc] initWithCArray:self.cubismModel->GetDrawableRenderOrders() count:[self drawableCount]];
}

- (bool)isRenderOrderDidChangedForDrawable:(int)index {
    return self.cubismModel->GetDrawableDynamicFlagRenderOrderDidChange(index);
}

- (bool)isOpacityDidChangedForDrawable:(int)index {
    return self.cubismModel->GetDrawableDynamicFlagOpacityDidChange(index);
}

- (bool)isVisibilityDidChangedForDrawable:(int)index {
    return self.cubismModel->GetDrawableDynamicFlagVisibilityDidChange(index);
}

- (bool)isVertexPositionDidChangedForDrawable:(int)index {
    return self.cubismModel->GetDrawableDynamicFlagVertexPositionsDidChange(index);
}

- (void)handleDealloc {
    model = nil;
    physics = nil;
    modelSetting = nil;
}
@end

@implementation L2DModel (UpdateAndPhysics)

- (void)update {
    self.cubismModel->Update();

    if (self.expressionManager != NULL) {
        self.expressionManager->UpdateMotion(self.cubismModel, 5.0);  // 表情でパラメータ更新（相対変化）
    }
}

- (void)updatePhysics:(NSTimeInterval)dt {
    if (physics != nil) {
        physics->Evaluate(self.cubismModel, dt);
    }
}

@end
