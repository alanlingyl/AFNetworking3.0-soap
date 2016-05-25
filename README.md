## 此项目为AFNetworking3.x访问WebService接口(SOAP方式)，公司的新项目接口都采用了RESTFul方式.
- 写此项目的目的是为了备忘
- 最开始是因为网上都找不到AFNetworking访问java开发的webservice(soap方式)的完整资料
- 以前都是使用的AF1.x和AF2.x访问的，最近项目中的AFNetworking升级到3.x, 3.x和以前的有点区别，特写此测试工程以作备忘。
- 此项目中访问的是C#开发的接口，java的一样可以访问. 只是例子,所以没有封装.


### 备注：java写的WebService(SOAP方式)在添加命名空间时略有差别
```
    //消息体的命名空间
    GDataXMLNode *messageNS=[GDataXMLNode namespaceWithName:@"ns1" stringValue:WEBSERVICE_NAMESPACE];
    GDataXMLElement *message=[GDataXMLElement elementWithName:[NSString stringWithFormat:@"ns1:%@",methodName]];
    [message addNamespace:messageNS];
```
