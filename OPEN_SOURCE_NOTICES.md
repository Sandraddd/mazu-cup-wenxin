# 开源参考说明

本项目当前不引入第三方 Swift Package，也没有复制第三方源代码。以下项目仅作为交互、无障碍和工程结构研究参考：

1. [UIOnboarding](https://github.com/lascic/UIOnboarding) — MIT License  
   参考其全屏 SwiftUI 引导思路，以及对 Dynamic Type、VoiceOver、Reduce Motion 的明确支持策略。其演示图片不属于 MIT 授权范围，本项目未使用。

2. [SwiftUIKit](https://github.com/danielsaidi/SwiftUIKit) — MIT License  
   参考其将常用 SwiftUI 视觉行为封装为小型、可组合组件的设计方式。本项目使用自有的 `GoldButtonStyle`、`GlassCard` 等实现。

3. [Rive iOS](https://github.com/rive-app/rive-ios) — MIT License  
   研究其状态机驱动动效的组织方式。MVP 为保持零依赖，当前使用 SwiftUI 原生阶段状态实现；如果未来加入专业筊杯动效，可评估 Rive Runtime。

4. [swiftui-model3dview](https://github.com/frzi/swiftui-model3dview) — MIT License  
   研究 SwiftUI 中承载 3D 模型的可行性。当前 MVP 不引入 3D 模型；后续只有在获得准确、合法授权的筊杯模型后再评估。

所有参考项目的版权归各自作者所有。若未来直接引入依赖或改编代码，必须保留其许可证文本与版权声明。
