
### 使用 BOM 来维护第三方依赖
借鉴 Spring IO Platform 来编写自己的基础项目platform-bom

### 使用构造器注入
错误的代码：
```java
@RestController
public class YoursController {
	@Autowired
    private YoursService service;
}
```

正确的代码：
```java
@RestController
public class YoursController {
	private final YoursService service;

	@Autowired
    public YoursController(YoursService service) {
		this.service = service;
    }
}
```
1. 使用`final`关键字
2. 在构造函数中注入

### 使用`HandlerExceptionResolver`定义全局异常处理

### 代码测试
1. 使用 Spring Cloud Contract
2. 使用测试切片。诸如初始化数据、连接大量服务、模拟事务等事情都变的简单了


