#pragma once
#include <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>

@interface iLVServer: NSObject{
	BOOL isClosed;
	int fd;
}
-(void) initServer;
-(void) readData:(NSNumber*) clientSocket;
-(void) sendData:(const char*) data;
-(void) start;
-(void) close;
@end
