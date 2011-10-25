//
//  GameLayer.h
//  OldSchoolBreakout
//
//  Created by Guilherme da Silva Mello on 10/24/11.
//  Copyright Guimello Tecnologia 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

// GameLayer
@interface GameLayer : CCLayer {
	GLESDebugDraw *m_debugDraw;

    b2World *_world;
    b2Body *_groundBody;
    b2Body *_paddleBody;
    b2Fixture *_paddleFixture;
    b2Fixture *_ballFixture;
    b2Fixture *_bottomFixture;
    b2MouseJoint *_mouseJoint;
}

// returns a CCScene that contains the GameLayer as the only child
+ (CCScene*)scene;

@end
