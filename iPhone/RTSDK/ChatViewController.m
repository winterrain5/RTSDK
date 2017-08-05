//
//  ChatViewController.m
//  RTSDK
//
//  Created by 石冬冬 on 2017/7/19.
//  Copyright © 2017年 Derrick. All rights reserved.
//

#import "ChatViewController.h"
#import "GHInputToolView.h"
#import "ChatCell.h"
#import "ChatMessageInfo.h"
#import <RtSDK/RtSDK.h>
#import <Masonry.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height*0.58 - 40



@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource,GHToolViewDelegate,GSBroadcastChatDelegate>
@property (nonatomic, strong)GSBroadcastManager *broadcastManager;

@property (nonatomic, strong)UITableView *chatTableView;

@property (nonatomic, strong)NSMutableArray *chatMessage;
@property (nonatomic, strong)NSMutableArray *chatPrivateMessage;

@property (nonatomic, strong)GHInputToolView *inputToolView;

@property (nonatomic, assign)long long myUserID;

@property (nonatomic, strong)NSDictionary *key2fileDic;

@property (nonatomic, strong)NSDictionary *text2keyDic;
@end

@implementation ChatViewController

- (UITableView *)chatTableView {
    if (_chatTableView == nil) {
        
        _chatTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT - 50)];
        _chatTableView.delegate = self;
        _chatTableView.dataSource = self;
        _chatTableView.backgroundColor = [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:1];
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        [_chatTableView setTableFooterView:view];
        
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTableViewTap:)];
        ges.numberOfTouchesRequired = 1;
        [self.chatTableView addGestureRecognizer:ges];
        
    }
    return _chatTableView;
}

- (GHInputToolView *)inputToolView {
    if (_inputToolView == nil) {
        NSBundle *resourceBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RtSDK" ofType:@"bundle"]];
        _key2fileDic = [NSDictionary dictionaryWithContentsOfFile:[resourceBundle pathForResource:@"key2file" ofType:@"plist"]];
        _text2keyDic = [NSDictionary dictionaryWithContentsOfFile:[resourceBundle pathForResource:@"text2key" ofType:@"plist"]];
        
        
        _inputToolView = [[GHInputToolView alloc]initWithParentFrame:CGRectMake(0, SCREEN_HEIGHT - 50, SCREEN_WIDTH, 50) emojiPlistFileName:@"text2file" inBundle:resourceBundle];
        _inputToolView.backgroundColor = [UIColor whiteColor];
        _inputToolView.delegate = self;
    }
    return _inputToolView;
}

- (NSMutableArray *)chatMessage {
    if (_chatMessage == nil) {
        _chatMessage = @[].mutableCopy;
    }
    return _chatMessage;
}
- (NSMutableArray *)chatPrivateMessage {
    if (_chatPrivateMessage == nil) {
        _chatPrivateMessage = @[].copy;
    }
    return _chatPrivateMessage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(53, 53, 53);
    
    [self initSubViews];
    
    [self initBroadCastManager];
    
    [self setupNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}
- (void)initSubViews {
    [self.view addSubview:self.chatTableView];
    [self.view addSubview:self.inputToolView];
}

- (void)setupNotifications {
    
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)initBroadCastManager {
    _broadcastManager = [GSBroadcastManager sharedBroadcastManager];
    _broadcastManager.chatDelegate = self;
}



#pragma mark GSBroadcastChatDelegate

// 聊天模块连接代理
- (void)broadcastManager:(GSBroadcastManager*)broadcastManager didReceiveChatModuleInitResult:(BOOL)result
{
    
}

// 收到私人聊天代理, 只有自己能看到。
- (void)broadcastManager:(GSBroadcastManager*)broadcastManager didReceivePrivateMessage:(GSChatMessage*)msg fromUser:(GSUserInfo*)user
{
    [self receiveChatMessage:msg from:user messageType:ChatMessageTypePrivate];
}

// 收到公共聊天代理，所有人都能看到
- (void)broadcastManager:(GSBroadcastManager*)broadcastManager didReceivePublicMessage:(GSChatMessage*)msg fromUser:(GSUserInfo*)user
{
    [self receiveChatMessage:msg from:user messageType:ChatMessageTypePublic];
}

// 收到嘉宾聊天代理
- (void)broadcastManager:(GSBroadcastManager*)broadcastManager didReceivePanelistMessage:(GSChatMessage*)msg fromUser:(GSUserInfo*)user
{
    [self receiveChatMessage:msg from:user messageType:ChatMessageTypePanelist];
}

// 针对个人禁止或允许聊天/问答 状态改变代理，如果想设置整个房间禁止聊天，请用其他的代理
- (void)broadcastManager:(GSBroadcastManager*)broadcastManager didSetChattingEnabled:(BOOL)enabled
{
    if (!enabled) {
//        [BaseMethod showError:@"您已被禁言"];
        self.inputToolView.inputTextView.editable = NO;
        self.inputToolView.emojiButton.enabled    = NO;
        self.inputToolView.inputTextView.text     = @"您已被禁言";
    }else {
//        [BaseMethod showError:@"您已被允许发言"];
        self.inputToolView.inputTextView.editable = YES;
        self.inputToolView.emojiButton.enabled    = YES;
        self.inputToolView.inputTextView.text     = @"";
    }
    
}



#pragma mark - UITableViewDataSource && Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatMessage.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    
    ChatCell *chatCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!chatCell) {
        chatCell = [[[NSBundle mainBundle] loadNibNamed:@"ChatCell" owner:self options:nil] lastObject];
        chatCell.key2fileDic = _key2fileDic;
    }
    if (indexPath.row == self.chatMessage.count - 1) {
        chatCell.bottomLineView.hidden = YES;
        chatCell.topLineView.hidden    = NO;
    } else {
        chatCell.bottomLineView.hidden = NO;
        chatCell.topLineView.hidden    = NO;
    }
    chatCell.selectionStyle  = UITableViewCellSelectionStyleNone;
    chatCell.backgroundColor = [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:1];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    ChatMessageInfo *messageInfo = self.chatMessage[indexPath.row];
    [chatCell setContent:messageInfo];
   
    return chatCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = ((ChatMessageInfo*)_chatMessage[indexPath.row]).message.richText;
    int height     = [self heightOfText:[self transfromString2:text] width:self.view.frame.size.width - 20 fontSize:12.f];
    return height + 25;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.inputToolView endEditting];
}

#pragma mark - GHInputViewDelegate

// 发送消息
- (void)sendMessage:(NSString *)content
{
    
    
    [_broadcastManager setUser:1000000001 chatEnabled:NO];
    
    if (!content || [[content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]isEqualToString:@""])
    {
        
        return;
    }
    
    
    
    GSChatMessage *message = [GSChatMessage new];
    message.text = [NSString stringWithFormat:@"<span>%@</span>", content];
    message.richText = [self chatString:content];
    
    
    // 发送公共消息
    if ([_broadcastManager sendMessageToPublic:message]) {
        
        
        [self receiveChatMessage:message from:nil messageType:ChatMessageTypeFromMe];
        
    }
    else
    {
        // 发送失败
    }
    
}

#pragma mark - notifications

- (void)keyNotification:(NSNotification *)noti {
    

}

#pragma mark - ges

- (void)handleTableViewTap:(UITapGestureRecognizer*)ges
{
    [self.inputToolView endEditting];
}

#pragma mark Utilities

- (CGFloat)heightOfText:(NSString*)content width:(CGFloat)width fontSize:(CGFloat)fontSize
{
    CGSize constraint = CGSizeMake(width, CGFLOAT_MAX);
    CGSize  size = [content sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:constraint lineBreakMode:NSLineBreakByCharWrapping];
    return MAX(size.height, 20);
}

- (NSString*)transfromString2:(NSString*)originalString
{
    //匹配表情，将表情转化为html格式
    NSString *text = originalString;
    //【伤心】
    //NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    
    NSRegularExpression* preRegex = [[NSRegularExpression alloc]
                                     initWithPattern:@"<IMG.+?src=\"(.*?)\".*?>"
                                     options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                     error:nil]; //2
    NSArray* matches = [preRegex matchesInString:text options:0
                                           range:NSMakeRange(0, [text length])];
    int offset = 0;
    
    for (NSTextCheckingResult *match in matches) {
        //NSRange srcMatchRange = [match range];
        NSRange imgMatchRange = [match rangeAtIndex:0];
        imgMatchRange.location += offset;
        
        NSString *imgMatchString = [text substringWithRange:imgMatchRange];
        
        
        NSRange srcMatchRange = [match rangeAtIndex:1];
        srcMatchRange.location += offset;
        
        NSString *srcMatchString = [text substringWithRange:srcMatchRange];
        
        NSString *i_transCharacter = [self.key2fileDic objectForKey:srcMatchString];
        if (i_transCharacter) {
            NSString *imageHtml =@"表情表情表情";//表情占位，用于计算文本长度
            text = [text stringByReplacingCharactersInRange:NSMakeRange(imgMatchRange.location, [imgMatchString length]) withString:imageHtml];
            offset += (imageHtml.length - imgMatchString.length);
        }
        
    }
    
    //返回转义后的字符串
    return text;
    
}


- (void)receiveChatMessage:(GSChatMessage*)msg from:(GSUserInfo*)user messageType:(ChatMessageType)messageType
{
    
    ChatMessageInfo *messageInfo = [ChatMessageInfo new];
    
    if (messageType == ChatMessageTypeFromMe) {
        messageInfo.senderName = @"我";
        messageInfo.senderID = _myUserID;
    }
    else if (messageType == ChatMessageTypeSystem)
    {
        messageInfo.senderName = @"系统消息";
    }
    else
    {
        messageInfo.senderID = user.userID;
        messageInfo.senderName = user.userName;
    }
    messageInfo.role = user.role;
    
    NSDateFormatter *formater = [[ NSDateFormatter alloc] init];
    NSDate *curDate = [NSDate date];//获取当前日期
    [formater setDateFormat:@"HH:mm:ss"];//这里去掉 具体时间 保留日期
    NSString *curTime = [formater stringFromDate:curDate];
    messageInfo.receiveTime = curTime;
    
    messageInfo.messageType = messageType;
    
    messageInfo.message = msg;
    
    [self.chatMessage addObject:messageInfo];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatMessage.count - 1 inSection:0];
    NSMutableArray *indexPaths = [NSMutableArray array];
    [indexPaths addObject:indexPath];
    [self.chatTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.chatTableView reloadData];
}


- (NSString*)chatString:(NSString*)originalStr
{
    
    NSArray *textTailArray =  [[NSArray alloc]initWithObjects: @"【太快了】", @"【太慢了】", @"【赞同】", @"【反对】", @"【鼓掌】", @"【值得思考】",nil];
    
    NSRegularExpression* preRegex = [[NSRegularExpression alloc]
                                     initWithPattern:@"【([\u4E00-\u9FFF]*?)】"
                                     options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                     error:nil]; //2
    NSArray* matches = [preRegex matchesInString:originalStr options:0
                                           range:NSMakeRange(0, [originalStr length])];
    
    int offset = 0;
    
    for (NSTextCheckingResult *match in matches) {
        //NSRange srcMatchRange = [match range];
        NSRange emotionRange = [match rangeAtIndex:0];
        emotionRange.location += offset;
        
        NSString *emotionString = [originalStr substringWithRange:emotionRange];
        
        NSString *i_transCharacter = [_text2keyDic objectForKey:emotionString];
        if (i_transCharacter) {
            NSString *imageHtml = nil;
            if([textTailArray containsObject:emotionString])
            {
                imageHtml = [NSString stringWithFormat:@"<IMG src=\"%@\" custom=\"false\">%@", i_transCharacter, emotionString];
            }
            else
            {
                imageHtml = [NSString stringWithFormat:@"<IMG src=\"%@\" custom=\"false\">", i_transCharacter];
            }
            originalStr = [originalStr stringByReplacingCharactersInRange:NSMakeRange(emotionRange.location, [emotionString length]) withString:imageHtml];
            offset += (imageHtml.length - emotionString.length);
            
        }
        
    }
    
    
    NSMutableString *richStr = [[NSMutableString alloc]init];
    [richStr appendString:@"<SPAN style=\"FONT-SIZE: 10pt; FONT-WEIGHT: normal; COLOR: #000000; FONT-STYLE: normal\">"];
    [richStr appendString:originalStr];
    [richStr appendString:@"</SPAN>"];
    
    return richStr;
    
}

@end
