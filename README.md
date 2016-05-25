## 此项目为AFNetworking3.x访问WebService接口(SOAP方式)
以前都是使用的AF1.x和AF2.x访问的，最近项目中的AFNetworking升级到3.x,特写此测试工程以作备忘。

### 备注：java写的WebService(SOAP方式)在添加命名空间时略有差别
```
    //消息体的命名空间
    GDataXMLNode *messageNS=[GDataXMLNode namespaceWithName:@"ns1" stringValue:WEBSERVICE_NAMESPACE];
    GDataXMLElement *message=[GDataXMLElement elementWithName:[NSString stringWithFormat:@"ns1:%@",methodName]];
    [message addNamespace:messageNS];
```
