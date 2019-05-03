//
//  GameScene.m
//  Scream_Jumper
//
//  Created by Taehyun Cho on 5/3/19.
//  Copyright © 2019 Taehyun Cho. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene {
    NSTimeInterval _lastUpdateTime;
    SKShapeNode *_spinnyNode;
    SKLabelNode *_label;
    SKSpriteNode *_musicNote;
}

@synthesize audioEngine;
static const uint32_t worldCategory = 1 << 1;



- (void)sceneDidLoad {
    // Setup your scene here
    self.backgroundColor = UIColor.whiteColor;

    
    audioEngine = [[AVAudioEngine alloc] init];
    AudioStreamBasicDescription audioDescription = {
        .mFormatID          = kAudioFormatLinearPCM,
        .mFormatFlags       = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved,
        .mChannelsPerFrame  = 2,
        .mBytesPerPacket    = sizeof(float),
        .mFramesPerPacket   = 1,
        .mBytesPerFrame     = sizeof(float),
        .mBitsPerChannel    = 8 * sizeof(float),
        .mSampleRate        = 44100.0
    };
    AVAudioFormat *fmt = [[AVAudioFormat alloc] initWithStreamDescription:&audioDescription];
    
    AVAudioInputNode *input = [audioEngine inputNode];
    [input installTapOnBus:0 bufferSize:1024 format:fmt block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        float v = 0;
        const AudioBufferList *bufferList = [buffer audioBufferList];
        float *rawData = (float *) bufferList->mBuffers[0].mData;
        for (int i = 0; i < [buffer frameLength]; ++i)
        {
            v += fabsf(rawData[i]);
        }
        NSLog(@"V: %f\n", v);
    }];
    
    NSError *err;
    [audioEngine startAndReturnError:&err];
    
    
    //Create Ground
    SKTexture* groundTexture = [SKTexture textureWithImageNamed:@"Rest2"];
    groundTexture.filteringMode = SKTextureFilteringNearest;
    
    SKAction* moveGroundSprite = [SKAction moveByX:-groundTexture.size.width*2 y:0 duration:0.02 * groundTexture.size.width*2];
    SKAction* resetGroundSprite = [SKAction moveByX:groundTexture.size.width*2 y:0 duration:0];
    SKAction* moveGroundSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveGroundSprite, resetGroundSprite]]];
    for( int i = 0; i < 2 + self.frame.size.width / ( groundTexture.size.width * 2 ); ++i ) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:groundTexture];
        [sprite setScale:3.0];
        sprite.position = CGPointMake(i * sprite.size.width, -500);
        [sprite runAction:moveGroundSpritesForever];
        [self addChild:sprite];
    }
    
    // Create skyline
    SKTexture* skylineTexture = [SKTexture textureWithImageNamed:@"background"];
    skylineTexture.filteringMode = SKTextureFilteringNearest;
    
    SKAction* moveSkylineSprite = [SKAction moveByX:-skylineTexture.size.width*2 y:0 duration:0.1 * skylineTexture.size.width*2];
    SKAction* resetSkylineSprite = [SKAction moveByX:skylineTexture.size.width*2 y:0 duration:0];
    SKAction* moveSkylineSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveSkylineSprite, resetSkylineSprite]]];
    
    for( int i = 0; i < 2 + self.frame.size.width / ( skylineTexture.size.width * 2 ); ++i ) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:skylineTexture];
        [sprite setScale:7.0];
        sprite.zPosition = -20;
        sprite.position = CGPointMake(i * sprite.size.width, 100);
        [sprite runAction:moveSkylineSpritesForever];
        [self addChild:sprite];
    }
    // Initialize update time
    _lastUpdateTime = 0;
    
//    // Get label node from scene and store it for use later
//    _label = (SKLabelNode *)[self childNodeWithName:@"//helloLabel"];
//
//    _label.alpha = 0.0;
//    [_label runAction:[SKAction fadeInWithDuration:2.0]];
//
//    CGFloat w = (self.size.width + self.size.height) * 0.05;
//
//    // Create shape node to use during mouse interaction
//    _spinnyNode = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(w, w) cornerRadius:w * 0.3];
//    _spinnyNode.lineWidth = 2.5;
//
//    [_spinnyNode runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:M_PI duration:1]]];
//    [_spinnyNode runAction:[SKAction sequence:@[
//                                                [SKAction waitForDuration:0.5],
//                                                [SKAction fadeOutWithDuration:0.5],
//                                                [SKAction removeFromParent],
//                                                ]]];
    self.physicsWorld.gravity = CGVectorMake( 0.0, -5.0 );
    self.physicsWorld.contactDelegate = self;
    
    SKTexture* noteTexture = [SKTexture textureWithImageNamed:@"musicNote"];
    noteTexture.filteringMode = SKTextureFilteringNearest;
    SKTexture* noteTexture2 = [SKTexture textureWithImageNamed:@"musicNote2"];
    noteTexture2.filteringMode = SKTextureFilteringNearest;
    SKAction* flap = [SKAction repeatActionForever:[SKAction animateWithTextures:@[noteTexture, noteTexture2] timePerFrame:0.5]];

    

    _musicNote = [SKSpriteNode spriteNodeWithTexture:noteTexture];
    [_musicNote setScale:0.4];
    _musicNote.position = CGPointMake(self.frame.size.width / 20, CGRectGetMidY(self.frame));
    _musicNote.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_musicNote.size.height / 2];
    _musicNote.physicsBody.dynamic = YES;
    _musicNote.physicsBody.allowsRotation = NO;
    //[_musicNote runAction:flap];
    [self addChild:_musicNote];
    
    SKNode* dummy = [SKNode node];
    dummy.position = CGPointMake(0, -500);
    dummy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width, 200)];
    dummy.physicsBody.dynamic = NO;
    [self addChild:dummy];
}


- (void)touchDownAtPoint:(CGPoint)pos {
    SKShapeNode *n = [_spinnyNode copy];
    n.position = pos;
    n.strokeColor = [SKColor greenColor];
    [self addChild:n];
}

- (void)touchMovedToPoint:(CGPoint)pos {
    SKShapeNode *n = [_spinnyNode copy];
    n.position = pos;
    n.strokeColor = [SKColor blueColor];
    [self addChild:n];
}

- (void)touchUpAtPoint:(CGPoint)pos {
    SKShapeNode *n = [_spinnyNode copy];
    n.position = pos;
    n.strokeColor = [SKColor redColor];
    [self addChild:n];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Run 'Pulse' action from 'Actions.sks'
//    [_label runAction:[SKAction actionNamed:@"Pulse"] withKey:@"fadeInOut"];
//
//    for (UITouch *t in touches) {[self touchDownAtPoint:[t locationInNode:self]];}
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    for (UITouch *t in touches) {[self touchMovedToPoint:[t locationInNode:self]];}
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}

CGFloat clamp(CGFloat min, CGFloat max, CGFloat value) {
    if( value > max ) {
        return max;
    } else if( value < min ) {
        return min;
    } else {
        return value;
    }
}

-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
    
    // Initialize _lastUpdateTime if it has not already been
    if (_lastUpdateTime == 0) {
        _lastUpdateTime = currentTime;
    }
    
    // Calculate time since last update
    CGFloat dt = currentTime - _lastUpdateTime;
    
    // Update entities
    for (GKEntity *entity in self.entities) {
        [entity updateWithDeltaTime:dt];
    }
    
    _lastUpdateTime = currentTime;
    _musicNote.zRotation = clamp( -1, 0.5, _musicNote.physicsBody.velocity.dy * ( _musicNote.physicsBody.velocity.dy < 0 ? 0.003 : 0.001 ) );
}

@end
