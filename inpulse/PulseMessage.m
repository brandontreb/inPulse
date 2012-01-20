#import "PulseMessage.h"

@implementation PulseMessage

@synthesize title = _title;
@synthesize message = _message;
@synthesize messageType = _messageType;

- (id)initWithTitle:(NSString *)title message:(NSString *)message messageType:(PulseMessageType)messageType {
    if(self == [super init]) {
        self.title = title;
        self.message = message;
        self.messageType = messageType;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:_title forKey:@"Title"];
    [encoder encodeObject:_message forKey:@"Message"];
	[encoder encodeInt:_messageType forKey:@"Type"];
}
 
- (id)initWithCoder:(NSCoder *)decoder {
    NSString *title = (NSString *)[decoder decodeObjectForKey:@"Title"];
    NSString *message = (NSString *)[decoder decodeObjectForKey:@"Message"];
	int messageType = [decoder decodeIntForKey:@"Type"];
	return [self initWithTitle:title message:message messageType:messageType];
}

- (void)dealloc {
    [_title release];
    [_message release];
    [super dealloc];
}

@end
