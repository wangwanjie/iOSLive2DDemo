//
//  L2DTextureManager.m
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/14.
//

#import <Foundation/Foundation.h>

/**
 * @brief 画像情報構造体
 */
typedef struct {
    unsigned int name;  ///< テクスチャID
    int width;          ///< 横幅
    int height;         ///< 高さ
} TextureInfo;

@interface L2DTextureManager : NSObject

/**
 * @brief プリマルチプライ処理
 *
 * @param[in] red  画像のRed値
 * @param[in] green  画像のGreen値
 * @param[in] blue  画像のBlue値
 * @param[in] alpha  画像のAlpha値
 *
 * @return プリマルチプライ処理後のカラー値
 */
- (unsigned int)pemultiply:(unsigned char)red green:(unsigned char)green blue:(unsigned char)blue alpha:(unsigned char)alpha;

/**
 * @brief 画像読み込み
 *
 * @param[in] fileName  読み込む画像ファイルパス名
 * @return 画像情報。読み込み失敗時はNULLを返す
 */
- (TextureInfo)createTextureFromPngFile:(NSString *)fileName;

/**
 * @brief 画像の解放
 *
 * 配列に存在する画像全てを解放する
 */
- (void)releaseTextures;

/**
 * @brief 画像の解放
 *
 * 指定したテクスチャIDの画像を解放する
 * @param[in] textureId  解放するテクスチャID
 **/
- (void)releaseTextureWithId:(unsigned int)textureId;

@end
