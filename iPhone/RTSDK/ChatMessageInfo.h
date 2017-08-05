//
//  ChatMessageInfo.h
//  iOSDemo
//
//  Created by Gaojin Hsu on 5/6/15.
//  Copyright (c) 2015 gensee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RtSDK/RtSDK.h>

typedef NS_ENUM(NSInteger, ChatMessageType)
{
    ChatMessageTypePrivate,
    ChatMessageTypePublic,
    ChatMessageTypePanelist,
    ChatMessageTypeFromMe,
    ChatMessageTypeSystem,
};


@interface ChatMessageInfo : NSObject

@property (nonatomic, strong)NSString *senderName;

@property (nonatomic, strong)NSString *receiveTime;

@property (nonatomic, assign)ChatMessageType messageType;

@property (nonatomic, strong)GSChatMessage *message;

@property (nonatomic, assign)long long senderID;
///
@property (nonatomic, assign) GSUserRole role;

@end
