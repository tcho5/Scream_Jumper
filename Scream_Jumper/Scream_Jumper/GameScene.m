//
//  GameScene.m
//  Scream_Jumper
//
//  Created by Taehyun Cho on 5/3/19.
//  Copyright © 2019 Taehyun Cho. All rights reserved.
//

#import "GameScene.h"
#import "MenuScene.h"

@implementation GameScene {
    NSTimeInterval _lastUpdateTime;
    SKShapeNode *_spinnyNode;
    SKLabelNode *_label;
    SKSpriteNode *_musicNote;
    SKNode* _moving;
    SKNode* _restNote;
    BOOL _canRestart;
    NSInteger _score;
    SKLabelNode* _scoreLabelNode;
    SKLabelNode* _highScoreLabelNode;
    NSInteger _highScore;
    SKAction* _moveAndRemoveRests;
    SKNode* restartNode;
    SKLabelNode* gameLabel;
}

@synthesize audioEngine;

static const uint32_t worldCategory = 1 << 1;
static const uint32_t musicNoteCategory = 1 << 0;
static const uint32_t restNoteCategory = 1 << 2;
static const uint32_t scoreCategory = 1 << 3;


- (void)sceneDidLoad {
    // Setup your scene here
    gameLabel = [self gameLabelSetUp];
    [self addChild:gameLabel];
    
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
        NSLog(@"V yeet: %f\n", v);
        if( _moving.speed > 0) {
            if(v > 500){
            _musicNote.physicsBody.velocity = CGVectorMake(0, 0);
            [_musicNote.physicsBody applyImpulse:CGVectorMake(0, 175)];
            }
        }
    }];
    
    NSError *err;
    [audioEngine startAndReturnError:&err];
    
    self.physicsWorld.gravity = CGVectorMake( 0.0, -5.0 );
    self.physicsWorld.contactDelegate = self;
    self.backgroundColor = UIColor.whiteColor;
    
    _canRestart = NO;
    
    _score = 0;
    _scoreLabelNode = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    _scoreLabelNode.fontColor = UIColor.blackColor;
    _scoreLabelNode.position = CGPointMake(self.frame.size.width/20 -100 , CGRectGetMidY(self.frame) + 550);
    _scoreLabelNode.zPosition = 100;
    _scoreLabelNode.text = [NSString stringWithFormat:@"Score: %ld", _score];
    [self addChild:_scoreLabelNode];
    
    _highScore = 0;
    _highScoreLabelNode = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    _highScoreLabelNode.fontColor = UIColor.blackColor;
    _highScoreLabelNode.position = CGPointMake(self.frame.size.width/20 - 100, CGRectGetMidY(self.frame) + 525);
    _highScoreLabelNode.zPosition = 100;
    _highScoreLabelNode.text = [NSString stringWithFormat:@"High Score: %ld", _score];
    [self addChild:_highScoreLabelNode];
    
    _moving = [SKNode node];
    _restNote = [SKNode node];
    
    [_moving addChild:_restNote];
    [self addChild:_moving];
    
    
    
    //[_moving addChild:_restNote];
    
    
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
        //[_moving addChild:sprite];
    }
    
    // Create background
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
        //[_moving addChild:sprite];
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

    
    SKTexture* noteTexture = [SKTexture textureWithImageNamed:@"musicNote"];
    noteTexture.filteringMode = SKTextureFilteringNearest;
    SKTexture* noteTexture2 = [SKTexture textureWithImageNamed:@"musicNote2"];
    noteTexture2.filteringMode = SKTextureFilteringNearest;

    

    _musicNote = [SKSpriteNode spriteNodeWithTexture:noteTexture];
    [_musicNote setScale:0.2];
    _musicNote.position = CGPointMake(self.frame.size.width / 20, CGRectGetMidY(self.frame));
    _musicNote.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_musicNote.size.height / 2];
    _musicNote.physicsBody.dynamic = YES;
    _musicNote.physicsBody.allowsRotation = NO;
    _musicNote.physicsBody.categoryBitMask = musicNoteCategory;
    _musicNote.physicsBody.collisionBitMask = worldCategory | restNoteCategory;
    _musicNote.physicsBody.contactTestBitMask = worldCategory | restNoteCategory;
    //[_musicNote runAction:flap];
    [self addChild:_musicNote];
    
    SKNode* dummy = [SKNode node];
    dummy.position = CGPointMake(0, -485);
    dummy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width, 200)];
    dummy.physicsBody.dynamic = NO;
    dummy.physicsBody.categoryBitMask = worldCategory;
    [self addChild:dummy];
    
    
    SKAction* spawn = [SKAction performSelector:@selector(spawnRests) onTarget:self];
    SKAction* delay = [SKAction waitForDuration:2.0];
    SKAction* spawnThenDelay = [SKAction sequence:@[spawn, delay]];
    SKAction* spawnThenDelayForever = [SKAction repeatActionForever:spawnThenDelay];
    [self runAction:spawnThenDelayForever];
    
    restartNode = [self restartMenu];
    [self addChild:restartNode];
    
}
//-(void)buttonTouch:(id)sender {
//    button1.hidden =  !button1.hidden;
//}

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
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    if( _moving.speed > 0 ) {
        _musicNote.physicsBody.velocity = CGVectorMake(0, 0);
        [_musicNote.physicsBody applyImpulse:CGVectorMake(0, 175)];
    }
    if ([node.name isEqualToString:@"restartMenu"]) {
        if( _canRestart ) {
            [self resetScene];
        }
    }
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

-(void)spawnRests {
    if(_moving.speed == 0){
        return;
    }
    NSArray* imageList = [NSArray arrayWithObjects: @"obstacle2.png", @"obstacle1.png", @"obstacle3.png", @"obstacle4.png", nil];
    int randomNumber = rand() % 4;
    NSString *imageName = [imageList objectAtIndex: randomNumber];
    SKTexture* _restTexture1 = [SKTexture textureWithImageNamed:imageName];
    _restTexture1.filteringMode = SKTextureFilteringNearest;
    
    CGFloat y = arc4random() % (NSInteger)(550);
    SKNode* restNotes = [SKNode node];
    restNotes.position = CGPointMake(-100,0);// self.frame.size.width + _blockerTexture1.size.width * 2, 0 );
    restNotes.zPosition = -10;
    
    SKSpriteNode* note1 = [SKSpriteNode spriteNodeWithTexture:_restTexture1];
    [note1 setScale:.3];
    note1.position = CGPointMake( 500 , y );
    note1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:note1.size];
    note1.physicsBody.dynamic = NO;
    note1.physicsBody.categoryBitMask = restNoteCategory;
    note1.physicsBody.contactTestBitMask = musicNoteCategory;
    SKAction* moveRests = [SKAction repeatActionForever:[SKAction moveByX:-4 y:0 duration:0.02]];
    SKAction* removeRests = [SKAction removeFromParent];
    [restNotes runAction:moveRests];
    [restNotes addChild:note1];
    _moveAndRemoveRests = [SKAction sequence:@[moveRests, removeRests]];

    [self addChild:restNotes];
    [restNotes runAction:_moveAndRemoveRests];
    
    _score++;
    _scoreLabelNode.text = [NSString stringWithFormat:@"Score: %ld", _score];
    if(_score > _highScore){
        _highScore = _score;
        _highScoreLabelNode.text = [NSString stringWithFormat:@"High Score: %ld", _score];
    }
    
//    [_moving addChild:restNotes];
    //[_restNote addChild:restNotes];
    
    
    //[_moving addChild:restNotes];
    
//    SKNode* contactNode = [SKNode node];
//    contactNode.position = CGPointMake(note1.size.width + _musicNote.size.width / 2, CGRectGetMidY( self.frame ) );
//    contactNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(note1.size.width, self.frame.size.height )];
//    contactNode.physicsBody.dynamic = NO;
//    contactNode.physicsBody.categoryBitMask = scoreCategory;
//    contactNode.physicsBody.contactTestBitMask = musicNoteCategory;
//    [restNotes addChild:contactNode];
    
}
- (void)didBeginContact:(SKPhysicsContact *)contact {
    if(_moving.speed > 0){
        _moving.speed = 0;
        _canRestart = YES;
        [self removeActionForKey:@"flash"];
        [self runAction:[SKAction sequence:@[[SKAction repeatAction:[SKAction sequence:@[[SKAction runBlock:^{
            self.backgroundColor = [SKColor redColor];
        }], [SKAction waitForDuration:0.10], [SKAction runBlock:^{
            self.backgroundColor = [SKColor whiteColor];
        }], [SKAction waitForDuration:0.10]]] count:8]]] withKey:@"flash"];
        gameLabel.text = @"Game Over!";
        //[NSThread sleepForTimeInterval: 2.0f];
    }
    
//        if( ( contact.bodyA.categoryBitMask & scoreCategory ) == scoreCategory || ( contact.bodyB.categoryBitMask & scoreCategory ) == scoreCategory ) {
//            // Ball has contact with score entity
//
//            _score++;
//            _scoreLabelNode.text = [NSString stringWithFormat:@"Score: %ld", _score];
//            if(_score > _highScore){
//                _highScore = _score;
//                _highScoreLabelNode.text = [NSString stringWithFormat:@"High Score: %ld", _score];
//            }
//            //_highScoreLabelNode.text = [NSString stringWithFormat:@"Score: %ld", _score];
//        } else {
//            // Ball has been blocked
//            _moving.speed = 0;
//            _canRestart = YES;
//            [blockSound runAction:[SKAction changeVolumeTo:10 duration:5.0]];
//            [blockSound runAction:[SKAction play]];
//        }
//    }
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
//
//    if( _moving.speed > 0 ) {
//        _musicNote.zRotation = clamp( -1, 0.5, _musicNote.physicsBody.velocity.dy * ( _musicNote.physicsBody.velocity.dy < 0 ? 0.003 : 0.001 ) );
//    }
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

-(void)resetScene {
    // Move bird to original position and reset velocity
    _musicNote.position = CGPointMake(self.frame.size.width / 20, CGRectGetMidY(self.frame));
    _musicNote.physicsBody.velocity = CGVectorMake( 0, 0 );
    _musicNote.physicsBody.collisionBitMask = worldCategory | restNoteCategory;
    _musicNote.speed = 1.0;
    _musicNote.zRotation = 0.0;

    // Remove all existing pipes
    [_restNote removeAllChildren];

    // Reset _canRestart
    _canRestart = NO;

    // Restart animation
    _moving.speed = 1;

    _score = 0;
    _scoreLabelNode.text = [NSString stringWithFormat:@"Score: %ld", _score];
    
    gameLabel.text = @"Yell to move notes higher!";
}

- (SKSpriteNode *)restartMenu{
    SKSpriteNode *restartNode = [SKSpriteNode spriteNodeWithImageNamed:@"restartButton.png"];
    [restartNode setScale:1.5];
    restartNode.position = CGPointMake(175,550);
    restartNode.name = @"restartMenu";//how the node is identified later
    restartNode.zPosition = 1.0;
    return restartNode;
}

- (SKLabelNode *)gameLabelSetUp{
    SKLabelNode* gameLabel = [SKLabelNode node];
    gameLabel.text = @"Yell to move notes higher!";
    gameLabel.fontSize = 30;
    gameLabel.name = @"gameLabel";
    gameLabel.position = CGPointMake(0, 175);
    gameLabel.fontColor = [UIColor blackColor];
    return gameLabel;
}

@end
