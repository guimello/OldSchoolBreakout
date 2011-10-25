//
//  GameLayer.mm
//  OldSchoolBreakout
//
//  Created by Guilherme da Silva Mello on 10/24/11.
//  Copyright Guimello Tecnologia 2011. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};

enum {
    kTagBall = 1,
};


// GameLayer implementation
@implementation GameLayer

+ (CCScene*)scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];

	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];

	// add layer as a child to scene
	[scene addChild: layer];

	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
- (id)init {
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self = [super init])) {

		// enable touches
		self.isTouchEnabled = YES;

		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f", screenSize.width, screenSize.height);

		// Define the gravity vector.
		//b2Vec2 gravity;
		//gravity.Set(0.0f, 0.0f);
        b2Vec2 gravity = b2Vec2(0.0f, 0.0f);

		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;

		// Construct a world object, which will hold and simulate the rigid bodies.
		_world = new b2World(gravity, doSleep);

		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		//_world->SetDebugDraw(m_debugDraw);

		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
//		flags += b2DebugDraw::e_jointBit;
//		flags += b2DebugDraw::e_aabbBit;
//		flags += b2DebugDraw::e_pairBit;
//		flags += b2DebugDraw::e_centerOfMassBit;
		m_debugDraw->SetFlags(flags);

		// Create edges around the entire screen

		// Define the ground body.
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(0, 0); // bottom-left corner

		// Call the body factory which allocates memory for the ground body
		// from a pool and creates the ground box shape (also from a pool).
		// The body is also added to the world.
		_groundBody = _world->CreateBody(&groundBodyDef);

		// Define the ground box shape.
		b2PolygonShape groundBox;
		b2FixtureDef groundBoxDef;

        groundBoxDef.shape = &groundBox;

		// bottom
		groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
		_bottomFixture = _groundBody->CreateFixture(&groundBoxDef);

        // left
        groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(0, screenSize.height/PTM_RATIO));
		_groundBody->CreateFixture(&groundBoxDef);

		// top
		groundBox.SetAsEdge(b2Vec2(0, screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO, screenSize.height/PTM_RATIO));
		_groundBody->CreateFixture(&groundBoxDef);

		// right
		groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO, screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
		_groundBody->CreateFixture(&groundBoxDef);


		// Set up sprite

        CCSprite *ball = [CCSprite spriteWithFile:@"Ball.png" rect:CGRectMake(0, 0, 52, 52)];
        ball.position = ccp(100, 100);
        ball.tag = kTagBall;
        [self addChild:ball];

        // Create ball body
        b2BodyDef ballBodyDef;
        ballBodyDef.type = b2_dynamicBody;
        ballBodyDef.position.Set(100/PTM_RATIO, 100/PTM_RATIO);
        ballBodyDef.userData = ball;
        b2Body *ballBody = _world->CreateBody(&ballBodyDef);

        // Create circle shape
        b2CircleShape circle;
        circle.m_radius = 26.0/PTM_RATIO;

        // Create shape definition and add to body
        b2FixtureDef ballShapeDef;
        ballShapeDef.shape = &circle;
        ballShapeDef.density = 1.0f;
        ballShapeDef.friction = 0.0f;
        ballShapeDef.restitution = 1.0f;
        _ballFixture = ballBody->CreateFixture(&ballShapeDef);

        // Give the shape initial impulse
        b2Vec2 force = b2Vec2(10, 10);
        ballBody->ApplyLinearImpulse(force, ballBodyDef.position);

        //Create paddle and add it to the layer
        CCSprite *paddle = [CCSprite spriteWithFile:@"Paddle.png"];
        paddle.position = ccp(screenSize.width/2, 50);
        [self addChild:paddle];

        // Create paddle body
        b2BodyDef paddleBodyDef;
        paddleBodyDef.type = b2_dynamicBody;
        paddleBodyDef.position.Set(screenSize.width/2/PTM_RATIO, 50/PTM_RATIO);
        paddleBodyDef.userData = paddle;
        _paddleBody = _world->CreateBody(&paddleBodyDef);

        // Create paddle shape
        b2PolygonShape paddleShape;
        paddleShape.SetAsBox(paddle.contentSize.width/PTM_RATIO/2, paddle.contentSize.height/PTM_RATIO/2);

        // Create shape definition and add to body
        b2FixtureDef paddleShapeDef;
        paddleShapeDef.shape = &paddleShape;
        paddleShapeDef.density = 10.0f;
        paddleShapeDef.friction = 0.4f;
        paddleShapeDef.restitution = 0.1f;
        _paddleFixture = _paddleBody->CreateFixture(&paddleShapeDef);

        // Restrict paddle along the x axis
        b2PrismaticJointDef jointDef;
        b2Vec2 worldAxis(1.0f, 0.0f);
        jointDef.collideConnected = true;
        jointDef.Initialize(_paddleBody, _groundBody, _paddleBody->GetWorldCenter(), worldAxis);
        _world->CreateJoint(&jointDef);


		[self schedule: @selector(tick:)];
	}

	return self;
}

-(void) draw {
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY,
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);

	_world->DrawDebugData();

	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

- (void)tick:(ccTime)dt {
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/

	int32 velocityIterations = 10;
	int32 positionIterations = 10;

	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	_world->Step(dt, velocityIterations, positionIterations);

	//Iterate over the bodies in the physics world
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *sprite = (CCSprite *)b->GetUserData();

            if (sprite.tag == kTagBall) {
                static int maxSpeed = 10;

                b2Vec2 velocity = b->GetLinearVelocity();
                float32 speed = velocity.Length();

                // When the ball is greater than max speed, slow it down by
                // applying linear damping.  This is better for the simulation
                // than raw adjustment of the velocity.
                if (speed > maxSpeed) {
                    b->SetLinearDamping(0.5);
                } else if (speed < maxSpeed) {
                    b->SetLinearDamping(0.0);
                }
            }

            sprite.position = ccp(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
            sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    }
}

- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    if (_mouseJoint != NULL) return;

    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];

    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);

    if (_paddleFixture->TestPoint(locationWorld)) {
        b2MouseJointDef mouseJointDef;
        mouseJointDef.bodyA = _groundBody;
        mouseJointDef.bodyB = _paddleBody;
        mouseJointDef.target = locationWorld;
        mouseJointDef.collideConnected = true;
        mouseJointDef.maxForce = 1000.0f * _paddleBody->GetMass();

        _mouseJoint = (b2MouseJoint*)_world->CreateJoint(&mouseJointDef);
        _paddleBody->SetAwake(true);
    }
}

- (void)ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    if (_mouseJoint == NULL) return;

    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);

    _mouseJoint->SetTarget(locationWorld);
}

- (void)ccTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
    if (_mouseJoint) {
        _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }
}

- (void)ccTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    if (_mouseJoint) {
        _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }
}

// on "dealloc" you need to release all your retained objects
- (void)dealloc {
	// in case you have something to dealloc, do it in this method
	delete _world;
	_world = NULL;
    _groundBody = NULL;

	delete m_debugDraw;

	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
