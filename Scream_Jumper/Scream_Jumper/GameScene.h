//
//  GameScene.h
//  Scream_Jumper
//
//  Created by Taehyun Cho on 5/3/19.
//  Copyright © 2019 Taehyun Cho. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>

@interface GameScene : SKScene

@property (nonatomic) NSMutableArray<GKEntity *> *entities;
@property (nonatomic) NSMutableDictionary<NSString*, GKGraph *> *graphs;

@end
