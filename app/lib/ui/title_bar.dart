import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import 'tokens.dart';

/// 应用标题栏。
///
/// 无边框窗口、拖动区与窗口按钮依赖 window_manager 的原生库，构建需要
/// Visual Studio C++ 工具链；当前开发机未安装，M5 接入（见 PLAN.md M0/M5）。
class SonoraTitleBar extends StatelessWidget {
  const SonoraTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return SizedBox(
      height: SonoraLayout.titleBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              'Sonora',
              style: AppTextStyle.footnote
                  .of(context, emphasized: true)
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
            const Spacer(),
            Text(
              '本地 + 在线',
              style: AppTextStyle.caption1
                  .of(context)
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
