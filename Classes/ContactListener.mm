//
//  ContactListener.m
//  OldSchoolBreakout
//
//  Created by Guilherme da Silva Mello on 10/25/11.
//  Copyright 2011 Guimello Tecnologia. All rights reserved.
//

#import "ContactListener.h"


ContactListener::ContactListener() : _contacts() { }

ContactListener::~ContactListener() { }

void ContactListener::BeginContact(b2Contact* contact) {
    // We need to copy out the data cause the b2Contact passed in is reused
    Contact _contact = { contact->GetFixtureA(), contact->GetFixtureB() };
    _contacts.push_back(_contact);
}

void ContactListener::EndContact(b2Contact* contact) {
    Contact _contact = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<Contact>::iterator pos;

    pos = std::find(_contacts.begin(), _contacts.end(), _contact);

    if (pos != _contacts.end()) _contacts.erase(pos);
}

void ContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) { }

void ContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) { }
