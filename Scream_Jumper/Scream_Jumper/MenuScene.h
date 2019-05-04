//
//  MenuScene.h
//  Scream_Jumper
//
//  Created by Taehyun Cho on 5/4/19.
//  Copyright © 2019 Taehyun Cho. All rights reserved.
//

#ifndef MenuScene_h
#define MenuScene_h

#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MenuScene : SKScene

@property (nonatomic) NSMutableArray<GKEntity *> *entities;
@property (nonatomic) NSMutableDictionary<NSString*, GKGraph *> *graphs;
@property (nonatomic, strong) AVAudioEngine *audioEngine;

@end

#endif /* MenuScene_h */
