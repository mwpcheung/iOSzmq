#import "server.h"

// vim:ft=objc
#define PORT 6677
#define MAXDATASIZE 100
#define BUFFER_SIZE 1024

@implementation iLVServer

-(void) initServer{
		//设置一个socket地址结构server_addr,代表服务器internet地址, 端口
	struct sockaddr_in server_addr;
	bzero(&server_addr,sizeof(server_addr)); //把一段内存区的内容全部设置为0
	server_addr.sin_family = AF_INET;
	server_addr.sin_addr.s_addr = htons(INADDR_ANY);
	server_addr.sin_port = htons(PORT);
	
			int server_socket = socket(AF_INET,SOCK_STREAM,0);
	if( server_socket < 0){
		printf("Create Socket Failed!");
		exit(1);
	}

	if( bind(server_socket,(struct sockaddr*)&server_addr,sizeof(server_addr))){
		printf("Server Bind Port : %d Failed!", PORT);
		exit(1);
	}
	const int LENGTH_OF_LISTEN_QUEUE = 20;

	if ( listen(server_socket, LENGTH_OF_LISTEN_QUEUE) ){
		printf("Server Listen Failed!");
		exit(1);
	}
	
	isClosed = NO;
	
	while(!isClosed){
		printf("Server start......\n");
			//定义客户端的socket地址结构client_addr
		struct sockaddr_in client_addr;
		socklen_t length = sizeof(client_addr);
		int new_client_socket = accept(server_socket,(struct sockaddr*)&client_addr,&length);
		if ( new_client_socket < 0){
			printf("Server Accept Failed!/n");
			break;
		}
		fd = new_client_socket;
		printf(" one client connted..\n");
		[NSThread detachNewThreadSelector:@selector(readData:)
								 toTarget:self
							   withObject:[NSNumber numberWithInt:new_client_socket]];
	}

	close(server_socket);
	NSLog(@"%@",@"server closed....");
}

-(void) readData:(NSNumber*) clientSocket{
	char buffer[BUFFER_SIZE];
	int intSocket = [clientSocket intValue];
	
	while(buffer[0] != '-'){
		
		bzero(buffer,BUFFER_SIZE);

		recv(intSocket,buffer,BUFFER_SIZE,0);
		
		printf("client: %s \n",buffer);
		[self sendData:"received message from client. it's the server reply."];
	}

	printf("client:close\n");
	close(intSocket);
}
-(void) sendData:(const char*) data{
	int len = send(fd, data, strlen(data), 0);
	len = 0;
}
-(void) start{
	[NSThread detachNewThreadSelector:@selector(initServer)
							 toTarget:self withObject:nil];
}
-(void) close{
	isClosed = YES;
	fd = 0;
}
@end
