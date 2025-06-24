
# 架构设计
[参考](https://javafamily.blog.csdn.net/article/details/122076643)
## 四个角色
- 客户端：前端页面等，需要访问微服务资源
- 网关：负责转发、认证、鉴权
- 授权服务：负责认证授权颁发令牌（所有项目都是使用OAuth2.0）
- 资源服务：也就是后端业务的微服务集合
  
## 处理流程
1. 客户端发出登录请求给网关，获取令牌
2. 网关收到请求，直接转发给授权服务
3. 授权服务验证用户名、密码等一系列身份，通过则颁发令牌给客户端
4. 客户端携带令牌请求资源，请求直接到了网关层
5. 网关对令牌进行校验
   - 验签、过期时间校验等
   - 鉴权：对当前令牌携带的权限和访问资源所需的权限进行比对，如果权限有交集则通过校验，直接转发给微服务
6. 微服务进行逻辑处理














# Spring Security
[参考](https://www.kancloud.cn/zhangchio/springboot/663133)

Spring Security是如何完成身份认证的？
1. 创建 Authentication 实例
   - 用户名和密码被过滤器获取到，封装成Authentication
   - 通常情况下是UsernamePasswordAuthenticationToken这个实现类。

2. 执行 AuthenticationManager
   - 身份管理器负责验证这个Authentication

3. 填充 Authentication 更多附加信息
   - 认证成功后，AuthenticationManager身份管理器返回一个被填充满了信息的（包括权限信息，身份信息，细节信息，但密码通常会被移除）实例。

4. 填充 SecurityContextHolder
   - 安全上下文容器将第3步填充了信息的Authentication，通过SecurityContextHolder.getContext().setAuthentication(…)方法，设置到其中。

## 1. AuthenticationManager
AuthenticationManager，ProviderManager ，AuthenticationProvider 等等相似的Spring认证类看起来会晕？
1. AuthenticationManager接口
   - 它是认证相关的核心接口，也是发起认证的出发点。
   - 因为在实际需求中，我们可能会允许用户同时使用多少登录方式：用户名+密码登录，邮箱+密码，手机+密码，指纹登录，所以说AuthenticationManager一般不直接认证。
2. ProviderManager
   - 它是AuthenticationManager接口的常用实现类。
   - 它内部会维护一个List<AuthenticationProvider>列表，存放多种认证方式，实际上这是委托者模式的应用（Delegate）。
   - 不同的认证方式：用户名+密码（UsernamePasswordAuthenticationToken），邮箱+密码，手机号码+密码登录则对应了三个AuthenticationProvider。
3. AuthenticationProvider
   - 在默认策略下，只需要通过一个AuthenticationProvider的认证，即可被认为是登录成功。

也就是说，核心的认证入口始终只有一个：AuthenticationManager。  
不同的认证方式：用户名+密码（UsernamePasswordAuthenticationToken），邮箱+密码，手机号码+密码登录则对应了三个AuthenticationProvider。

所以，开发项目时，需要继承AuthenticationProvider来实现自己的认证逻辑

## 2. 过滤器
通过日志可以看到过滤器链条：
```txt
Creating filter chain: o.s.s.web.util.matcher.AnyRequestMatcher@1, 
[o.s.s.web.context.SecurityContextPersistenceFilter@8851ce1, 
o.s.s.web.header.HeaderWriterFilter@6a472566, o.s.s.web.csrf.CsrfFilter@61cd1c71, 
o.s.s.web.authentication.logout.LogoutFilter@5e1d03d7, 
o.s.s.web.authentication.UsernamePasswordAuthenticationFilter@122d6c22, 
o.s.s.web.savedrequest.RequestCacheAwareFilter@5ef6fd7f, 
o.s.s.web.servletapi.SecurityContextHolderAwareRequestFilter@4beaf6bd, 
o.s.s.web.authentication.AnonymousAuthenticationFilter@6edcad64, 
o.s.s.web.session.SessionManagementFilter@5e65afb6, 
o.s.s.web.access.ExceptionTranslationFilter@5b9396d3, 
o.s.s.web.access.intercept.FilterSecurityInterceptor@3c5dbdf8
]
```
- **SecurityContextPersistenceFilter** 两个主要职责：请求来临时，创建SecurityContext安全上下文信息，请求结束时清空SecurityContextHolder。
- HeaderWriterFilter (文档中并未介绍，非核心过滤器) 用来给http响应添加一些Header,比如X-Frame-Options, X-XSS-Protection*，X-Content-Type-Options.
- CsrfFilter 在spring4这个版本中被默认开启的一个过滤器，用于防止csrf攻击，了解前后端分离的人一定不会对这个攻击方式感到陌生，前后端使用json交互需要注意的一个问题。
- LogoutFilter 顾名思义，处理注销的过滤器
- **UsernamePasswordAuthenticationFilter** 这个会重点分析，表单提交了username和password，被封装成token进行一系列的认证，便是主要通过这个过滤器完成的，在表单认证的方法中，这是最最关键的过滤器。
- RequestCacheAwareFilter (文档中并未介绍，非核心过滤器) 内部维护了一个RequestCache，用于缓存request请求
- SecurityContextHolderAwareRequestFilter 此过滤器对ServletRequest进行了一次包装，使得request具有更加丰富的API
- **AnonymousAuthenticationFilter** 匿名身份过滤器，这个过滤器个人认为很重要，需要将它与UsernamePasswordAuthenticationFilter 放在一起比较理解，spring security为了兼容未登录的访问，也走了一套认证流程，只不过是一个匿名的身份。
- SessionManagementFilter 和session相关的过滤器，内部维护了一个SessionAuthenticationStrategy，两者组合使用，常用来防止session-fixation protection attack，以及限制同一用户开启多个会话的数量
- **ExceptionTranslationFilter** 直译成异常翻译过滤器，还是比较形象的，这个过滤器本身不处理异常，而是将认证过程中出现的异常交给内部维护的一些类去处理，具体是那些类下面详细介绍
- **FilterSecurityInterceptor** 这个过滤器决定了访问特定路径应该具备的权限，访问的用户的角色，权限是什么？访问的路径需要什么样的角色和权限？这些判断和处理都是由该类进行的。

其中加粗的过滤器可以被认为是Spring Security的核心过滤器。

### 2.1 SecurityContextPersistenceFilter
如果我们不使用Spring Security，如果保存用户信息呢，大多数情况下会考虑使用Session对吧？在Spring Security中也是如此，用户在登录过一次之后，后续的访问便是通过sessionId来识别，从而认为用户已经被认证。
它的两个主要作用：
- 请求来临时，创建SecurityContext安全上下文信息
- 请求结束时，清空SecurityContextHolder

在微服务架构中，因为要实现通讯的无状态，所以Session不再需要，这并不意味着SecurityContextPersistenceFilter变得无用，因为它还需要负责清除用户信息



# Jwt
- JWT是一种规范，它强调了两个组织之间传递安全的信息
- JWS是JWT的一种实现，包含三部分header(头部）、payload(载荷）、signature(签名）
- JWE也是JWT的一种实现，包含五部分内容。

生成和解析JWT令牌有两种算法
1. 对称加密(HMAC)： 使用相同的密钥进行加密和解密。
2. 非对称加密(RSA)： 使用公钥和私钥进行加密和解密。
   - 对于加密操作，公钥负责加密，私钥负责解密
   - 对于签名操作，私钥负责签名，公钥负责验签
   例如：A向B发送信息进行签名和加密的具体流程


# 处理架构
```
      Application(Client)  -----(1)---->    Authorization Server
      （前端/手机App等）      <----(2)-----    认证服务器：发放访问资源服务器的令牌
            |
            |-----(3)---->      Your API
                           （Resource Server）
```

