# 代码混淆压缩比，在0~7之间，默认为5，一般不做修改
-optimizationpasses 5

# 忽略警告
-ignorewarnings

# 混合时不使用大小写混合，混合后的类名为小写
-dontusemixedcaseclassnames

# 指定不去忽略非公共库的类
-dontskipnonpubliclibraryclasses

# 这句话能够使我们的项目混淆后产生映射文件
# 包含有类名->混淆后类名的映射关系
-verbose

# 指定不去忽略非公共库的类成员
-dontskipnonpubliclibraryclassmembers

# 不做预校验，preverify是proguard的四个步骤之一，Android不需要preverify，去掉这一步能够加快混淆速度。
-dontpreverify

# 保留Annotation不混淆
-keepattributes *Annotation*,InnerClasses

# 避免混淆泛型
-keepattributes Signature

# 抛出异常时保留代码行号
-keepattributes SourceFile,LineNumberTable

# 指定混淆是采用的算法，后面的参数是一个过滤器
# 这个过滤器是谷歌推荐的算法，一般不做更改
-optimizations !code/simplification/cast,!field/*,!class/merging/*

# 保留R下面的资源
-keep class **.R$* { *; }

#Flutter Wrapper 禁止混淆
-dontwarn io.flutter.**
 -keep class com.shockwave.**
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

-keep class java.lang.** { *; }

# keep继承自系统组件的类
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application

# 保留我们自定义控件（继承自View）不被混淆
-keep public class * extends android.view.View{
    *** get*();
    void set*(***);
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# keep javascript注释的方法，使用到webview js回调方法的需要添加此配置
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}


#################### FaceUnity #######################
-keep class com.faceunity.wrapper.faceunity {*;}
-keep class com.faceunity.wrapper.faceunity$RotatedImage {*;}

-keepattributes InnerClasses
-dontoptimize

################ alibaba.sdk ###############
-keep class com.alibaba.sdk.android.** { *;}

-dontwarn com.alibaba.sdk.android.**


################ 腾讯云SDK混淆 ################
-keep class com.tencent.**{*;}
-dontwarn com.tencent.**
-keep class tencent.**{*;}
-dontwarn tencent.**
-keep class qalsdk.**{*;}
-dontwarn qalsdk.**

################ svga ###############
-keep class com.squareup.wire.** { *; }
-keep class com.opensource.svgaplayer.proto.** { *; }
-dontwarn com.opensource.svgaplayer.**

################ 友盟混淆 ################
-dontwarn com.umeng.**
-dontwarn com.taobao.**
-dontwarn anet.channel.**
-dontwarn anetwork.channel.**
-dontwarn org.android.**
-dontwarn org.apache.thrift.**
-dontwarn com.xiaomi.**
-dontwarn com.huawei.**
-dontwarn com.meizu.**
-keepattributes *Annotation*
-keep class com.taobao.** {*;}
-keep class org.android.** {*;}
-keep class anet.channel.** {*;}
-keep class com.umeng.** {*;}
-keep class com.xiaomi.** {*;}
-keep class com.huawei.** {*;}
-keep class com.meizu.** {*;}
-keep class org.apache.thrift.** {*;}
-keep class com.alibaba.sdk.android.**{*;}
-keep class com.ut.**{*;}
-keep class com.ta.**{*;}
-keep public class **.R$*{
   public static final int *;
}

-keepclassmembers class * {
   public <init> (org.json.JSONObject);
}
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

################ 游戏盾 ################
-keep class com.aliyun.security.yunceng.** {*;}

################ sophix ###############
#基线包使用，生成mapping.txt
-printmapping mapping.txt
#生成的mapping.txt在app/build/outputs/mapping/release路径下，移动到/app路径下
#修复后的项目使用，保证混淆结果一致
#-applymapping mapping.txt
#hotfix
-keep class com.taobao.sophix.**{*;}
-keep class com.ta.utdid2.device.**{*;}
-dontwarn com.alibaba.sdk.android.utils.**
#防止inline
-dontoptimize

#极光推送
-dontwarn cn.jiguang.**
-dontwarn cn.jpush.**

-keep public class cn.jiguang.** { *; }

-keep public class cn.jpush.** { *; }

#noinspection ShrinkerUnresolvedReference
-keep class com.kiwi.sdk.** {*;}
-keep class androidx.** {*;}
-keep public class com.netease.nis.sdkwrapper.Utils {public <methods>;}