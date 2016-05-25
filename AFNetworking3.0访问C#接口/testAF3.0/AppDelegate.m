//
//  AppDelegate.m
//  testAF3.0
//
//  Created by Alan on 16/4/11.
//  Copyright © 2016年 创博龙智 移动应用开发部 Alan. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "GDataXMLNode.h"

#define WEBSERVICE_NAMESPACE @"http://tempuri.org/"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /*
     //第一种方式
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:@"18075168519",@"mobile", nil];
    [self soapWithRESTful:@"http://172.21.1.174:8089/webservice/UserWs.asmx/YZMGet" params:params];
     */
    
    /*
     //第二种方式：采用的是自己创建request
    NSDictionary *params2=@{@"data":@"{\"UserName\":\"18166234973\",\"Password\":\"123456\",\"PageIndex\":\"0\",\"PageSize\":\"0\"}",@"authKey":@"0290D5FC888563EC55761A4B4FB637AC"};
    [self soapWithRequest:@"http://device.sjkd189.com/SmartHomeService.asmx" methodName:@"GetDevicesByUid" params:params2];
     */
    
    //第三种：去掉自己创建的request
    NSDictionary *params3=@{@"data":@"{\"UserName\":\"18166234973\",\"Password\":\"123456\",\"PageIndex\":\"0\",\"PageSize\":\"0\"}",@"authKey":@"0290D5FC888563EC55761A4B4FB637AC"};
    [self soapWithSessionManager:@"http://device.sjkd189.com/SmartHomeService.asmx" methodName:@"GetDevicesByUid" params:params3];
    
    return YES;
}


- (void)soapWithSessionManager:(NSString *)urlString methodName:(NSString *)methodName params:(NSDictionary *)params
{
    
    //组装soap请求xml
    //根节点
    GDataXMLElement *root=[GDataXMLElement elementWithName:@"soap:Envelope"];
    //根节点的命名空间
    [root addNamespace:[GDataXMLNode namespaceWithName:@"soap" stringValue:@"http://schemas.xmlsoap.org/soap/envelope/"]];
    //body
    GDataXMLElement *body=[GDataXMLElement elementWithName:@"soap:Body"];
    //消息体的命名空间
    GDataXMLNode *messageNS=[GDataXMLNode namespaceWithName:@"" stringValue:WEBSERVICE_NAMESPACE]; //方法上采用的是默认命名空间
    GDataXMLElement *message=[GDataXMLElement elementWithName:[NSString stringWithFormat:@"%@",methodName]];
    [message addNamespace:messageNS];
    //参数列表
    NSArray *keys=[params allKeys];
    for (int i=0; i<[keys count]; i++) {
        id key=[keys objectAtIndex:i];
        id value=[params objectForKey:key];
        GDataXMLElement *methodParam=[GDataXMLElement elementWithName:key stringValue:value];
        [message addChild:methodParam];
    }
    [body addChild:message];
    [root addChild:body];
    
    //组装ASIHttpRequest请求
    NSString *soapMessage=[root XMLString];
    NSLog(@"请求的结构：%@",soapMessage);
    NSString *msgLength = [NSString stringWithFormat:@"%zd",[soapMessage length]];
    
    
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    [manager setSecurityPolicy:securityPolicy];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@%@",WEBSERVICE_NAMESPACE,methodName] forHTTPHeaderField:@"SOAPAction"];
    [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        return soapMessage;
    }];
    
    [manager POST:urlString parameters:soapMessage  progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"&&&&&&&&&--->%@",responseString);
        
        GDataXMLDocument *doc=[[GDataXMLDocument alloc] initWithData:responseObject options:0 error:nil];
        GDataXMLElement *root=[doc rootElement];
        //组装xml解析的命名空间
        NSDictionary *ns=[NSDictionary dictionaryWithObjectsAndKeys:@"http://schemas.xmlsoap.org/soap/envelope/",@"soap",WEBSERVICE_NAMESPACE,@"x", nil];
        NSString *path=[NSString stringWithFormat:@"//soap:Body/x:%@Response/x:%@Result",methodName,methodName];
        //采用XPath方式解析xml
        NSArray *resultArray=[root nodesForXPath:path namespaces:ns error:nil];
        if ([resultArray count] > 0) {
            GDataXMLElement *node=[resultArray objectAtIndex:0];

//            NSLog(@"&&&&&&&&&--->%@",[node stringValue]);
            NSData *data=[[node stringValue] dataUsingEncoding:NSUTF8StringEncoding];

            id result=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"返回的结果：%@",result);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"错误：%@",error);
    }];

}

- (void)soapWithRequest:(NSString *)urlString methodName:(NSString *)methodName params:(NSDictionary *)params
{
    
    //组装soap请求xml
    //根节点
    GDataXMLElement *root=[GDataXMLElement elementWithName:@"soap:Envelope"];
    //根节点的命名空间
    [root addNamespace:[GDataXMLNode namespaceWithName:@"soap" stringValue:@"http://schemas.xmlsoap.org/soap/envelope/"]];
    //body
    GDataXMLElement *body=[GDataXMLElement elementWithName:@"soap:Body"];
    //消息体的命名空间
    GDataXMLNode *messageNS=[GDataXMLNode namespaceWithName:@"" stringValue:WEBSERVICE_NAMESPACE]; //方法上采用的是默认命名空间
    GDataXMLElement *message=[GDataXMLElement elementWithName:[NSString stringWithFormat:@"%@",methodName]];
    [message addNamespace:messageNS];
    //参数列表
    NSArray *keys=[params allKeys];
    for (int i=0; i<[keys count]; i++) {
        id key=[keys objectAtIndex:i];
        id value=[params objectForKey:key];
        GDataXMLElement *methodParam=[GDataXMLElement elementWithName:key stringValue:value];
        [message addChild:methodParam];
    }
    [body addChild:message];
    [root addChild:body];
    
    //组装ASIHttpRequest请求
    NSString *soapMessage=[root XMLString];
    NSLog(@"请求的结构：%@",soapMessage);
    NSString *msgLength = [NSString stringWithFormat:@"%zd",[soapMessage length]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    [manager setSecurityPolicy:securityPolicy];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:[NSString stringWithFormat:@"%@%@",WEBSERVICE_NAMESPACE,methodName] forHTTPHeaderField:@"SOAPAction"];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"&&&&&&&&&--->%@",responseString);
        }
    }];
    [dataTask resume];

}

- (void)soapWithRESTful:(NSString *)urlString params:(NSDictionary *)params
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    [manager setSecurityPolicy:securityPolicy];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
//    NSString *urlString=[NSString stringWithFormat:@"http://172.21.1.174:8089/webservice/UserWs.asmx/YZMGet?mobile=%@",@"18075168519"];
    //参数列表
    if (params) {
        urlString=[urlString stringByAppendingString:@"?"];
        NSArray *keys=[params allKeys];
        for (int i=0; i<[keys count]; i++) {
            id key=[keys objectAtIndex:i];
            id value=[params objectForKey:key];
            urlString =[urlString stringByAppendingFormat:@"%@=%@&",key,value];
        }
        urlString = [urlString substringToIndex:urlString.length-1];
    }
    NSLog(@"%@",urlString);
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSData *data=responseObject;
        NSString *result=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"成功：%@",result);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"失败：%@",error);
    }];

}


@end
