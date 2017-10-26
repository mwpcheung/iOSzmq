#import "server.h"
#include <stdio.h>
#include <zmq.h>
#include <zmq.hpp>
#include "stdio.h"
int test(int argc, char **argv, char **envp) {
	iLVServer* server = [[iLVServer alloc] init];
	[server start];
	printf("server started...\n");
	while (true) {
		int ch = getchar();
		if (ch == 'c'){
			break;
		}else{
			printf("press c to exit...\n");
		}
	}
	printf("over.\n");
	return 0;
}

static CFDataRef DictionaryToPlist(CFDictionaryRef dict)
{
	CFErrorRef myError = nullptr;
	CFDataRef xmlData = CFPropertyListCreateData(kCFAllocatorDefault, dict, kCFPropertyListXMLFormat_v1_0, 0, &myError);
	
	if (myError) {
		auto desc = CFErrorCopyDescription(myError);
			//DebugPrint(ALL, "error:", myError);
			//CFDumpObject(ALL, desc);
		CFRelease(desc);
		CFRelease(myError);
		return nullptr;
	}
	
	return xmlData;
}

static CFPropertyListRef PlistToDictionary(CFDataRef plist)
{
	CFErrorRef myError = nullptr;
	CFPropertyListRef property = CFPropertyListCreateWithData(
															  kCFAllocatorDefault, plist, kCFPropertyListImmutable, NULL, &myError);
	if (myError) {
		auto desc = CFErrorCopyDescription(myError);
			//printf("error: %s", myError);
		NSLog(@"%@", desc);
		CFRelease(desc);
		CFRelease(myError);
		return nullptr;
	}
	
	return property;
}

// vim:ft=objc
	//包含zmq的头文件
 int  NetworkThread(void* threadContext) {
 	//myThreads.push_back(GetCurrentThreadId());
 	//  Prepare our context and socket
 	zmq::context_t context(1);
 	zmq::socket_t socket(context, ZMQ_REP);
 	socket.bind("tcp://*:5555");

 #define MSG_HANDLER(name, func) if (kCFCompareEqualTo == CFStringCompare(action, CFSTR(name), kCFCompareWidthInsensitive)) { resp = func(args); }

 	while (true) {
 		zmq::message_t request;

 		//  Wait for next request from client
 		socket.recv(&request);
 		printf("Receive ZMQ message\n");
 		try {
 			CFDictionaryRef resp = nullptr;

 			auto xmlData = CFDataCreate(kCFAllocatorDefault, (const UInt8*)request.data(), request.size());
 			CFDictionaryRef msg = (CFDictionaryRef)PlistToDictionary(xmlData);
 			//CFDumpObject(ALL, xmlData);

 			CFStringRef action = (CFStringRef)CFDictionaryGetValue(msg, CFSTR("action"));
 			CFDictionaryRef args = (CFDictionaryRef)CFDictionaryGetValue(msg, CFSTR("body"));
			action = nil;
			args = 0;
// 			MSG_HANDLER("getdevInfo", OnGetDeviceInfo)
// 			MSG_HANDLER("getcpim", OnGetCPIM);
// 			MSG_HANDLER("req1", OnGetRequest1);
// 			MSG_HANDLER("req2", OnParseResponse1);
// 			MSG_HANDLER("req3", OnParseResponse2);

 			CFRelease(xmlData);

			CFDataRef respXml;
			if (resp){
				respXml = DictionaryToPlist(resp);
			}
 			zmq::message_t reply(CFDataGetBytePtr(respXml), CFDataGetLength(respXml));
 			socket.send(reply);


 			CFRelease(respXml);
 			CFRelease(msg);
 			CFRelease(resp);

 		}
 		catch (const std::exception& err) {
 			printf("process fail: %s\n", err.what());
 		}
 	}
 }

int main(int argc, char * argv[]){
	NetworkThread(0);
	void * context = NULL;
	void * _socket = NULL;
	const char * szPort = "tcp://*:7766";
	
		//创建context，zmq的socket 需要在context上进行创建
	if((context = zmq_ctx_new()) == NULL){
		return 0;
	}
		//创建zmq socket ，socket目前有6中属性 ，这里使用dealer方式
		//具体使用方式请参考zmq官方文档（zmq手册）
	if((_socket = zmq_socket(context, ZMQ_DEALER)) == NULL){
		zmq_ctx_destroy(context);
		return 0;
	}
	int iRcvTimeout = 5000;// millsecond
		//设置zmq的接收超时时间为5秒
	if(zmq_setsockopt(_socket, ZMQ_RCVTIMEO, &iRcvTimeout, sizeof(iRcvTimeout)) < 0){
		zmq_close(_socket);
		zmq_ctx_destroy(context);
		return 0;
	}

	if(zmq_bind(_socket, szPort) < 0){
		zmq_close(_socket);
		zmq_ctx_destroy(context);
		return 0;
	}
	printf("bind at : %s\n", szPort);
	while(1){
		char szMsg[1024] = {0};
		printf("waitting...\n");
		errno = 0;
			//循环等待接收到来的消息，当超过5秒没有接到消息时，
			//zmq_recv函数返回错误信息 ，并使用zmq_strerror函数进行错误定位
		if(zmq_recv(_socket, szMsg, sizeof(szMsg), 0) < 0){
			printf("error = %s\n", zmq_strerror(errno));
			continue;
		}
		printf("received message : %s\n", szMsg);
	}
	
	return 0;
}
