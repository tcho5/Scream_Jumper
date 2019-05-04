//
//  GameScene.h
//  Scream_Jumper
//
//  Created by Taehyun Cho on 5/3/19.
//  Copyright © 2019 Taehyun Cho. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface GameScene : SKScene

@property (nonatomic) NSMutableArray<GKEntity *> *entities;
@property (nonatomic) NSMutableDictionary<NSString*, GKGraph *> *graphs;
@property (nonatomic, strong) AVAudioEngine *audioEngine;
//@property(nonatomic,retain) IBOutlet UIButton* button1;

//-(IBAction)buttonTouch:(id)sender ;

@end
