//
//  L2DUserModel.mm
//  iOSLive2DDemo
//
//  Created by VanJay on 2020/12/19.
//

#import "L2DUserModel.h"
#import "Live2DCubismCore.hpp"
#import "CubismUserModel.hpp"
#import "CubismFramework.hpp"
#import "CubismModelSettingJson.hpp"
#import "CubismIdManager.hpp"
#import "L2DAppDefine.h"
#import "L2DHelper.h"
#import <CubismDefaultParameterId.hpp>
#import <Utils/CubismString.hpp>
#import <Motion/CubismMotion.hpp>
#import "L2DTextureManager.h"
#import <Rendering/OpenGL/CubismRenderer_OpenGLES2.hpp>
#import "L2DCOCBridge.h"
#import <Math/CubismMatrix44.hpp>

using namespace ::L2DAppDefine;
using namespace Live2D::Cubism::Core;
using namespace Live2D::Cubism::Framework;
using namespace Live2D::Cubism::Framework::Rendering;
using namespace Live2D::Cubism::Framework::DefaultParameterId;

@interface L2DUserModel () {
  @private
    NSURL *_baseURL;
    Csm::csmFloat32 _userTimeSeconds;  ///< 增量时间的积分值[秒]
    Csm::csmString _modelHomeDir;      ///< 模型设置所在的目录
    CubismUserModel *_model;
    CubismModelSettingJson *_modelSetting;                           ///< 型号设定信息
    Csm::csmMap<Csm::csmString, Csm::ACubismMotion *> _motions;      ///< 加载的动作列表
    Csm::csmMap<Csm::csmString, Csm::ACubismMotion *> _expressions;  ///< 已加载的面部表情列表
    Csm::csmVector<Csm::CubismIdHandle> _eyeBlinkIds;                ///< 模型中设置的眨眼功能的参数ID
    Csm::csmVector<Csm::CubismIdHandle> _lipSyncIds;                 ///< 模型中设置的口型同步功能的参数ID
    const Csm::CubismId *_idParamAngleX;                             ///< 参数ID: ParamAngleX
    const Csm::CubismId *_idParamAngleY;                             ///< 参数ID: ParamAngleX
    const Csm::CubismId *_idParamAngleZ;                             ///< 参数ID: ParamAngleX
    const Csm::CubismId *_idParamBodyAngleX;                         ///< 参数ID: ParamBodyAngleX
    const Csm::CubismId *_idParamEyeBallX;                           ///< 参数ID: ParamEyeBallX
    const Csm::CubismId *_idParamEyeBallY;                           ///< 参数ID: ParamEyeBallXY
}

@property (nonatomic, assign, readonly) CubismUserModel *userModel;
@property (nonatomic, assign, readonly) CubismModel *cubismModel;

@end

@implementation L2DUserModel

- (instancetype)initWithJsonDir:(NSString *)dirName mocJsonName:(NSString *)mocJsonName {
    if (self = [super init]) {

        _modelHomeDir = (csmChar *)[dirName cStringUsingEncoding:NSUTF8StringEncoding];

        // Get base directory name.
        NSString *baseDir = [NSBundle.mainBundle.bundlePath stringByAppendingPathComponent:dirName];
        _baseURL = [NSURL fileURLWithPath:baseDir];

        // Read json file.
        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[baseDir stringByAppendingPathComponent:mocJsonName]]];

        // Create settings.
        _modelSetting = new CubismModelSettingJson((csmByte *)[data bytes], (csmSizeInt)[data length]);

        // Get _model file.
        NSString *modelFileName = [NSString stringWithCString:_modelSetting->GetModelFileName() encoding:NSUTF8StringEncoding];
        data = [NSData dataWithContentsOfURL:[_baseURL URLByAppendingPathComponent:modelFileName]];

        // Create _model.
        _model = CSM_NEW CubismUserModel();

        csmByte *buffer = (csmByte *)[data bytes];
        csmSizeInt size = (unsigned int)[data length];
        _model->LoadModel(buffer, size);

        // Expression
        if (_modelSetting->GetExpressionCount() > 0) {
            const csmInt32 count = _modelSetting->GetExpressionCount();
            for (csmInt32 i = 0; i < count; i++) {
                csmString name = _modelSetting->GetExpressionName(i);
                csmString path = _modelSetting->GetExpressionFileName(i);
                path = _modelHomeDir + path;

                const unsigned char *buffer = CreateBuffer(path.GetRawString(), &size);
                ACubismMotion *motion = _model->LoadExpression(buffer, size, name.GetRawString());

                if (_expressions[name] != NULL) {
                    ACubismMotion::Delete(_expressions[name]);
                    _expressions[name] = NULL;
                }
                _expressions[name] = motion;
            }
            DeleteBuffer(buffer);
        }

        // Physics
        if (strcmp(_modelSetting->GetPhysicsFileName(), "") != 0) {
            csmString path = _modelSetting->GetPhysicsFileName();
            path = _modelHomeDir + path;

            buffer = CreateBuffer(path.GetRawString(), &size);
            _model->LoadPhysics(buffer, size);
            DeleteBuffer(buffer, path.GetRawString());
        }

        // Pose
        if (strcmp(_modelSetting->GetPoseFileName(), "") != 0) {
            csmString path = _modelSetting->GetPoseFileName();
            path = _modelHomeDir + path;

            buffer = CreateBuffer(path.GetRawString(), &size);
            _model->LoadPose(buffer, size);
            DeleteBuffer(buffer, path.GetRawString());
        }

        // EyeBlink
        if (_modelSetting->GetEyeBlinkParameterCount() > 0) {
            _model->_eyeBlink = CubismEyeBlink::Create(_modelSetting);
        }

        // Breath
        {
            _model->_breath = CubismBreath::Create();

            csmVector<CubismBreath::BreathParameterData> breathParameters;

            breathParameters.PushBack(CubismBreath::BreathParameterData(_idParamAngleX, 0.0f, 15.0f, 6.5345f, 0.5f));
            breathParameters.PushBack(CubismBreath::BreathParameterData(_idParamAngleY, 0.0f, 8.0f, 3.5345f, 0.5f));
            breathParameters.PushBack(CubismBreath::BreathParameterData(_idParamAngleZ, 0.0f, 10.0f, 5.5345f, 0.5f));
            breathParameters.PushBack(CubismBreath::BreathParameterData(_idParamBodyAngleX, 0.0f, 4.0f, 15.5345f, 0.5f));
            breathParameters.PushBack(CubismBreath::BreathParameterData(CubismFramework::GetIdManager()->GetId(ParamBreath), 0.5f, 0.5f, 3.2345f, 0.5f));

            _model->_breath->SetParameters(breathParameters);
        }

        // UserData
        if (strcmp(_modelSetting->GetUserDataFile(), "") != 0) {
            csmString path = _modelSetting->GetUserDataFile();
            path = _modelHomeDir + path;
            buffer = CreateBuffer(path.GetRawString(), &size);
            _model->LoadUserData(buffer, size);
            DeleteBuffer(buffer, path.GetRawString());
        }

        // EyeBlinkIds
        {
            csmInt32 eyeBlinkIdCount = _modelSetting->GetEyeBlinkParameterCount();
            for (csmInt32 i = 0; i < eyeBlinkIdCount; ++i) {
                _eyeBlinkIds.PushBack(_modelSetting->GetEyeBlinkParameterId(i));
            }
        }

        // LipSyncIds
        {
            csmInt32 lipSyncIdCount = _modelSetting->GetLipSyncParameterCount();
            for (csmInt32 i = 0; i < lipSyncIdCount; ++i) {
                _lipSyncIds.PushBack(_modelSetting->GetLipSyncParameterId(i));
            }
        }

        // Layout
        csmMap<csmString, csmFloat32> layout;
        _modelSetting->GetLayoutMap(layout);
        _model->GetModelMatrix()->SetupFromLayout(layout);

        _model->GetModel()->SaveParameters();

        // Motion
        for (csmInt32 i = 0; i < _modelSetting->GetMotionGroupCount(); i++) {
            const csmChar *group = _modelSetting->GetMotionGroupName(i);
            [self preloadMotionGroup:group];
        }
    }

    return self;
}

- (void)createRenderer {
    if (_model->_renderer) {
        _model->DeleteRenderer();
    }
    _model->_renderer = Rendering::CubismRenderer::Create();

    _model->_renderer->Initialize(self.cubismModel);
}

- (void)dealloc {
    NSLog(@"L2DUserModel dealloc - %p", self);

    [self releaseMotions];
    [self releaseExpressions];

    if (_modelSetting != NULL && _modelSetting->GetMotionGroupCount() > 0) {
        for (csmInt32 i = 0; i < _modelSetting->GetMotionGroupCount(); i++) {
            const csmChar *group = _modelSetting->GetMotionGroupName(i);
            [self releaseMotionGroup:group];
        }
    }

    if (_model != NULL) {
        CSM_DELETE_SELF(CubismUserModel, _model);
    }

    if (_modelSetting != NULL) {
        CSM_DELETE_SELF(CubismModelSettingJson, _modelSetting);
    }
}

- (CubismUserModel *)userModel {
    return _model;
}

- (CubismModel *)cubismModel {
    return _model->GetModel();
}

- (CubismMotionManager *)expressionManager {
    return _model->_expressionManager;
}

- (CGSize)modelSize {
    return CGSizeMake(self.cubismModel->GetCanvasWidth(), self.cubismModel->GetCanvasHeight());
}

- (void)setModelParameterNamed:(NSString *)name value:(float)value {
    [self setModelParameterNamed:name blendMode:L2DBlendModeNormal value:value];
}

- (void)performExpressionWithExpressionID:(NSString *)expressionID {
    ACubismMotion *motion = _expressions[[expressionID cStringUsingEncoding:NSUTF8StringEncoding]];

    if (motion != NULL) {
        _model->_expressionManager->StartMotionPriority(motion, false, PriorityForce);
    }
}

- (void)performMotion:(NSString *)groupName index:(NSUInteger)index priority:(L2DPriority)priority {
    const csmChar *groupNameCStr = [groupName cStringUsingEncoding:NSUTF8StringEncoding];
    [self startMotion:groupNameCStr no:(csmInt32)index priority:(csmInt32)priority onFinishedMotionHandler:NULL];
}

- (void *)startMotion:(const csmChar *)group no:(csmInt32)no priority:(csmInt32)priority onFinishedMotionHandler:(ACubismMotion::FinishedMotionCallback)onFinishedMotionHandler {
    if (priority == PriorityForce) {
        _model->_motionManager->SetReservePriority(priority);
    } else if (!_model->_motionManager->ReserveMotion(priority)) {
        return InvalidMotionQueueEntryHandleValue;
    }

    const csmString fileName = _modelSetting->GetMotionFileName(group, no);

    // ex) idle_0
    csmString name = Utils::CubismString::GetFormatedString("%s_%d", group, no);
    CubismMotion *motion = static_cast<CubismMotion *>(_motions[name.GetRawString()]);
    csmBool autoDelete = false;

    if (motion == NULL) {
        csmString path = fileName;
        path = _modelHomeDir + path;

        csmByte *buffer;
        csmSizeInt size;
        buffer = CreateBuffer(path.GetRawString(), &size);
        motion = static_cast<CubismMotion *>(_model->LoadMotion(buffer, size, NULL, onFinishedMotionHandler));
        csmFloat32 fadeTime = _modelSetting->GetMotionFadeInTimeValue(group, no);
        if (fadeTime >= 0.0f) {
            motion->SetFadeInTime(fadeTime);
        }

        fadeTime = _modelSetting->GetMotionFadeOutTimeValue(group, no);
        if (fadeTime >= 0.0f) {
            motion->SetFadeOutTime(fadeTime);
        }
        motion->SetEffectIds(_eyeBlinkIds, _lipSyncIds);
        autoDelete = true;

        // 退出时从内存中删除
        DeleteBuffer(buffer, path.GetRawString());
    } else {
        motion->SetFinishedMotionHandler(onFinishedMotionHandler);
    }

    // voice
    csmString voice = _modelSetting->GetMotionSoundFileName(group, no);
    if (strcmp(voice.GetRawString(), "") != 0) {
        csmString path = voice;
        path = _modelHomeDir + path;
    }

    // NSLog(@"%p --- 执行 motion: [%s_%d]", self, group, no);

    return _model->_motionManager->StartMotionPriority(motion, autoDelete, priority);
}

- (void *)startRandomMotion:(const csmChar *)group priority:(csmInt32)priority onFinishedMotionHandler:(ACubismMotion::FinishedMotionCallback)onFinishedMotionHandler {
    if (_modelSetting->GetMotionCount(group) == 0) {
        return InvalidMotionQueueEntryHandleValue;
    }

    csmInt32 no = rand() % _modelSetting->GetMotionCount(group);
    return [self startMotion:group no:no priority:priority onFinishedMotionHandler:onFinishedMotionHandler];
}

- (void)performRandomExpression {
    if (_expressions.GetSize() == 0) {
        return;
    }

    csmInt32 no = rand() % _expressions.GetSize();
    csmMap<csmString, ACubismMotion *>::const_iterator map_ite;
    csmInt32 i = 0;
    for (map_ite = _expressions.Begin(); map_ite != _expressions.End(); map_ite++) {
        if (i == no) {
            csmString name = (*map_ite).First;
            [self performExpressionWithExpressionID:[NSString stringWithCString:name.GetRawString() encoding:NSUTF8StringEncoding]];
            return;
        }
        i++;
    }
}

- (BOOL)hitTest:(const char *)hitAreaName x:(float)x y:(float)y {
    // 透明时没有碰撞检测
    if (_model->_opacity < 1) {
        return false;
    }
    const csmInt32 count = _modelSetting->GetHitAreasCount();
    for (csmInt32 i = 0; i < count; i++) {
        if (strcmp(_modelSetting->GetHitAreaName(i), hitAreaName) == 0) {
            const CubismIdHandle drawID = _modelSetting->GetHitAreaId(i);
            return _model->IsHit(drawID, x, y);
        }
    }
    return false;  // 如果不存在则为 false
}

- (void)onDrag:(float)x floatY:(float)y {
    _model->SetDragging(x, y);
}

- (void)onTap:(float)x floatY:(float)y {
    if ([self hitTest:L2DAppDefine::HitAreaNameHead x:x y:y]) {
        [self performRandomExpression];
    } else if ([self hitTest:L2DAppDefine::HitAreaNameBody x:x y:y]) {
        [self startRandomMotion:L2DAppDefine::HitAreaNameBody priority:L2DPriorityNormal onFinishedMotionHandler:FinishedMotion];
    }
}

static void FinishedMotion(Csm::ACubismMotion *self) {
    NSLog(@"Motion 执行结束");
}

- (void)performExpression:(SBProductioEmotionExpression *)expression {
    if (!expression) {
        _model->_expressionManager->StopAllMotions();
        return;
    }

    NSString *str = [expression.action yy_modelToJSONString];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger len = [data length];
    Byte *byteData = (Byte *)malloc(len);
    memcpy(byteData, [data bytes], len);

    csmByte *buffer = static_cast<Csm::csmByte *>(byteData);
    ACubismMotion *csmMotion = _model->LoadExpression(buffer, (unsigned int)len, "", expression.fadeTime);
    if (csmMotion != NULL) {
        self.expressionManager->StartMotionPriority(csmMotion, true, PriorityForce);
    }
    ReleaseBytes(byteData);
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

- (NSArray<NSURL *> *)textureURLs {
    NSMutableArray<NSURL *> *urls = [NSMutableArray array];
    for (int i = 0; i < _modelSetting->GetTextureCount(); ++i) {
        @autoreleasepool {
            NSString *name = [NSString stringWithCString:_modelSetting->GetTextureFileName(i) encoding:NSUTF8StringEncoding];
            [urls addObject:[NSURL URLWithString:name relativeToURL:_baseURL]];
        }
    }
    return urls;
}

- (void)setupTexturesWithTextureManager:(L2DTextureManager *)textureManager {
    NSArray<NSURL *> *textureURLs = self.textureURLs;
    if (textureURLs.count <= 0) return;

    for (unsigned int modelTextureNumber = 0; modelTextureNumber < textureURLs.count; modelTextureNumber++) {
        // テクスチャ名が空文字だった場合はロード・バインド処理をスキップ
        if (strcmp(_modelSetting->GetTextureFileName(modelTextureNumber), "") == 0) {
            continue;
        }

        // OpenGLのテクスチャユニットにテクスチャをロードする
        csmString texturePath = _modelSetting->GetTextureFileName(modelTextureNumber);
        texturePath = _modelHomeDir + texturePath;

        TextureInfo *texture = [textureManager createTextureFromPngFile:texturePath.GetRawString()];
        csmInt32 glTextueNumber = texture->id;

        // OpenGL
        _model->GetRenderer<Rendering::CubismRenderer_OpenGLES2>()->BindTexture(modelTextureNumber, glTextueNumber);
    }
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

#pragma mark - Motion
- (void)preloadMotionGroup:(const csmChar *)group {
    const csmInt32 count = _modelSetting->GetMotionCount(group);

    for (csmInt32 i = 0; i < count; i++) {
        // ex) idle_0
        csmString name = Utils::CubismString::GetFormatedString("%s_%d", group, i);
        csmString path = _modelSetting->GetMotionFileName(group, i);
        path = _modelHomeDir + path;

        csmByte *buffer;
        csmSizeInt size;
        buffer = CreateBuffer(path.GetRawString(), &size);
        CubismMotion *tmpMotion = static_cast<CubismMotion *>(_model->LoadMotion(buffer, size, name.GetRawString()));

        csmFloat32 fadeTime = _modelSetting->GetMotionFadeInTimeValue(group, i);
        if (fadeTime >= 0.0f) {
            tmpMotion->SetFadeInTime(fadeTime);
        }

        fadeTime = _modelSetting->GetMotionFadeOutTimeValue(group, i);
        if (fadeTime >= 0.0f) {
            tmpMotion->SetFadeOutTime(fadeTime);
        }
        tmpMotion->SetEffectIds(_eyeBlinkIds, _lipSyncIds);

        if (_motions[name] != NULL) {
            ACubismMotion::Delete(_motions[name]);
        }
        _motions[name] = tmpMotion;

        DeleteBuffer(buffer, path.GetRawString());
    }
}

- (void)releaseMotionGroup:(const csmChar *)group {
    const csmInt32 count = _modelSetting->GetMotionCount(group);
    for (csmInt32 i = 0; i < count; i++) {
        csmString voice = _modelSetting->GetMotionSoundFileName(group, i);
        if (strcmp(voice.GetRawString(), "") != 0) {
            csmString path = voice;
            path = _modelHomeDir + path;
        }
    }
}

- (void)releaseMotions {
    for (csmMap<csmString, ACubismMotion *>::const_iterator iter = _motions.Begin(); iter != _motions.End(); ++iter) {
        ACubismMotion::Delete(iter->Second);
    }

    _motions.Clear();
}

- (void)releaseExpressions {
    for (csmMap<csmString, ACubismMotion *>::const_iterator iter = _expressions.Begin(); iter != _expressions.End(); ++iter) {
        ACubismMotion::Delete(iter->Second);
    }

    _expressions.Clear();
}

#pragma mark - Update

- (void)update {

    self.cubismModel->Update();

    if (self.expressionManager != NULL) {
        self.expressionManager->UpdateMotion(self.cubismModel, 5.0);  // 使用面部表情进行参数更新（相对变化）
    }
}

- (void)drawModel {
    if (_model == NULL) {
        return;
    }

    _model->GetRenderer<Rendering::CubismRenderer_OpenGLES2>()->DrawModel();
}

- (void)drawModelWithBridge:(L2DCOCBridge *)bridge {
    if (_model == NULL || !bridge) {
        return;
    }

    bridge.viewMatrix->MultiplyByMatrix(_model->_modelMatrix);

    _model->GetRenderer<Rendering::CubismRenderer_OpenGLES2>()->SetMvpMatrix(bridge.viewMatrix);

    [self drawModel];
}

- (void)updateWithDeltaTime:(NSTimeInterval)dt {

    const csmFloat32 deltaTimeSeconds = dt;
    _userTimeSeconds += deltaTimeSeconds;

    _model->_dragManager->Update(deltaTimeSeconds);
    _model->_dragX = _model->_dragManager->GetX();
    _model->_dragY = _model->_dragManager->GetY();

    // 是否存在通过运动进行参数更新
    csmBool motionUpdated = false;

    // -----------------------------------------------------------------
    self.cubismModel->LoadParameters();  // 加载先前保存的状态
    if (_model->_motionManager->IsFinished()) {
        // 如果没有动作播放，它将从待机动作中随机播放。
        [self startRandomMotion:MotionGroupIdle priority:PriorityIdle onFinishedMotionHandler:NULL];
    } else {
        motionUpdated = _model->_motionManager->UpdateMotion(self.cubismModel, deltaTimeSeconds);  // 更新动作
    }
    self.cubismModel->SaveParameters();  // 保存状态
    // -----------------------------------------------------------------

    // 闪烁
    if (!motionUpdated) {
        if (_model->_eyeBlink != NULL) {
            // メインモーションの更新がないとき
            _model->_eyeBlink->UpdateParameters(self.cubismModel, deltaTimeSeconds);  // 目パチ
        }
    }

    if (_model->_expressionManager != NULL) {
        _model->_expressionManager->UpdateMotion(self.cubismModel, deltaTimeSeconds);  // 表情でパラメータ更新（相対変化）
    }

    // 由于拖动而发生的变化
    // 通过拖动来调整脸部方向
    self.cubismModel->AddParameterValue(_idParamAngleX, _model->_dragX * 30);  // -30から30の値を
    self.cubismModel->AddParameterValue(_idParamAngleY, _model->_dragY * 30);
    self.cubismModel->AddParameterValue(_idParamAngleZ, _model->_dragX * _model->_dragY * -30);

    // 通过拖动来调整身体方向
    self.cubismModel->AddParameterValue(_idParamBodyAngleX, _model->_dragX * 10);  // -10から10の値を加える

    // 拖动以调整眼睛方向
    self.cubismModel->AddParameterValue(_idParamEyeBallX, _model->_dragX);  // -1から1の値を加える
    self.cubismModel->AddParameterValue(_idParamEyeBallY, _model->_dragY);

    // 呼吸等
    if (_model->_breath != NULL) {
        _model->_breath->UpdateParameters(self.cubismModel, deltaTimeSeconds);
    }

    // 物理设置
    if (_model->_physics != NULL) {
        _model->_physics->Evaluate(self.cubismModel, deltaTimeSeconds);
    }

    // 嘴唇同步设置
    if (_model->_lipSync) {
        csmFloat32 value = 0;  // リアルタイムでリップシンクを行う場合、システムから音量を取得して0〜1の範囲で値を入力します。

        for (csmUint32 i = 0; i < _lipSyncIds.GetSize(); ++i) {
            self.cubismModel->AddParameterValue(_lipSyncIds[i], value, 0.8f);
        }
    }

    // 姿势设定
    if (_model->_pose != NULL) {
        _model->_pose->UpdateParameters(self.cubismModel, deltaTimeSeconds);
    }

    if (_model->_physics != nil) {
        _model->_physics->Evaluate(self.cubismModel, dt);
    }
}

@end
