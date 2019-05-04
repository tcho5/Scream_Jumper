//
//  MenuScene.m
//  Scream_Jumper
//
//  Created by Taehyun Cho on 5/4/19.
//  Copyright © 2019 Taehyun Cho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuScene.h"

@implementation MenuScene {
SKLabelNode *_label;
}

- (void)sceneDidLoad {
    // Setup your scene here
    
}


- (void)touchDownAtPoint:(CGPoint)pos {

}

- (void)touchMovedToPoint:(CGPoint)pos {
 
}

- (void)touchUpAtPoint:(CGPoint)pos {

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

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

@end
