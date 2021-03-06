//
//  OSBarrageInfo.m
//  OSBufferText
//
//  Created by xu jie on 16/9/22.
//  Copyright © 2016年 xujie. All rights reserved.
//

#import "OSBarrageInfo.h"
static GLubyte indices[4] = {
    0,2,1,3
};
static GLuint textureBuffer;
static GLuint vertexBuffer;
@interface OSBarrageInfo()
@property(nonatomic,assign)GLuint textureBuffer; // 纹理缓冲区
@property(nonatomic,assign)GLuint vertexArrayBuffer;


@end

@implementation OSBarrageInfo

//-----------------------------------------------------------
#pragma mark -
#pragma mark - 工厂方法创建弹幕信息
//-----------------------------------------------------------
+ (OSBarrageInfo*)barrageInfoWithUserID:(NSString*)uid
                               userRank:(OSRank)rank
                              timeStamp:(NSTimeInterval)timeStamp
                            barrageType:(OSBarrageType)type
                                barrage:(OSBarrage*)barrage{
    return [[OSBarrageInfo alloc]initWithUserID:uid userRank:rank timeStamp:timeStamp barrageType:type barrage:barrage];
}

//-----------------------------------------------------------
#pragma mark -
#pragma mark - 创建文字弹幕
//-----------------------------------------------------------

+(OSBarrageInfo *)barrageInfoWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)textColor{
    OSTextBarrage *textBarrage = [OSTextBarrage textInfoWithString:string font:font color:textColor];
    OSBarrageInfo *barrageInfo = [[OSBarrageInfo alloc]initWithBarrageType:OSBarrageText];
    barrageInfo.barrage = textBarrage;
     barrageInfo.rate = 1;
    return barrageInfo;
}

//-----------------------------------------------------------
#pragma mark -
#pragma mark - 创建图片弹幕
//-----------------------------------------------------------

+ (OSBarrageInfo*)barrageInfoWithImage:(UIImage*)image DisplaySize:(CGSize)size{
    OSImageBarrage *imageBarrage = [OSImageBarrage imageBarrageWithImage:image displaySize:size];
    OSBarrageInfo *barrageInfo = [[OSBarrageInfo alloc]initWithBarrageType:OSBarrageImage];
    barrageInfo.barrage = imageBarrage;
    barrageInfo.rate = 1;
    return barrageInfo;
}


//-----------------------------------------------------------
#pragma mark -
#pragma mark - 创建gif动画弹幕
//-----------------------------------------------------------
+(OSBarrageInfo *)barrageInfoGif:(NSArray<UIImage *> *)images DisplaySize:(CGSize)size AnimationDuration:(NSTimeInterval)duration{
    OSGIFBarrage *gifBarrage = [OSGIFBarrage gifBarrageWithImages:images displaySize:size AnimationDuration:duration];
    OSBarrageInfo *barrageInfo = [[OSBarrageInfo alloc]initWithBarrageType:OSBarrageGif];
    barrageInfo.barrage = gifBarrage;
    barrageInfo.rate = 1;
   
    return barrageInfo;
}



//-----------------------------------------------------------
#pragma mark -
#pragma mark - 初始化方法
//-----------------------------------------------------------

-(instancetype)initWithBarrageType:(OSBarrageType)type{
    if(self = [super init]){
        _type = type;
    }
    return self;
}
-(instancetype)initWithUserID:(NSString*)uid
                     userRank:(OSRank)rank
                    timeStamp:(NSTimeInterval)timeStamp
                  barrageType:(OSBarrageType)type
                      barrage:(OSBarrage*)barrage{
    if (self = [super init]){
        _uid = uid;
        _userRank = rank;
        _timeStamp = timeStamp;
        _type = type;
        _barrage = barrage;
        _rate = 1;
    }
    return self;
    
}


//-----------------------------------------------------------
#pragma mark -
#pragma mark - 导入顶点坐标和问题到GPU
//-----------------------------------------------------------
-(void)loadVertexAndTextureToGPU{

    if (!vertexBuffer){
        glGenBuffers(1, &(vertexBuffer)); // 申请内存标识
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer); // 指定这个内存标识为顶点缓冲区
    }
    
    
    if (!_textureBuffer ){
      
       
        // 绑定顶点坐标
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition , 3, GL_FLOAT, NO, sizeof(GLfloat)*3, self.barrage. vertexArray);

        // 加载纹理
        glActiveTexture(GL_TEXTURE0);
        // 给着色器指定纹理内存区域
        glGenTextures(1, &(_textureBuffer));
        glBindTexture(GL_TEXTURE_2D, textureBuffer);
       
        glBindTexture(GL_TEXTURE_2D, _textureBuffer);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,  self.barrage.width, self.barrage.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, self.barrage.data);
       
       
 
        
    }else{

        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glVertexAttribPointer(GLKVertexAttribPosition , 3, GL_FLOAT, NO, sizeof(GLfloat)*3, self.barrage.vertexArray);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        
       
        //glActiveTexture(GL_ACTIVE_TEXTURE);
        glBindTexture(GL_TEXTURE_2D, _textureBuffer);
        
        
        if (self.type == OSBarrageGif){
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,  self.barrage.width, self.barrage.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, self.barrage.data);
        }
 
    }

}

//-----------------------------------------------------------
#pragma mark -
#pragma mark - 从GPU 中释放内存和纹理坐标
//-----------------------------------------------------------
-(void)deleteVertexAndTextureFromGPU{
    static  int i = 0;
    i++;
    NSLog(@"%d",i);
   
        if(self.textureBuffer){
            glDeleteTextures(1, &_textureBuffer);
            _textureBuffer = 0;
          
        }
    

}

//-----------------------------------------------------------
#pragma mark -
#pragma mark - 绘制到GPU 上去
//-----------------------------------------------------------
-(void)drawToGPU{
    [self loadVertexAndTextureToGPU];
    glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_BYTE, indices);
   
}

//-----------------------------------------------------------
#pragma mark -
#pragma mark - 清除工作
//-----------------------------------------------------------
-(void)dealloc{
    [self deleteVertexAndTextureFromGPU];
}


@end
