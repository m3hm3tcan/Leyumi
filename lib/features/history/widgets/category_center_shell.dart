import 'package:flutter/material.dart';

class CategoryCenterOption {
  const CategoryCenterOption({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

class CategoryCenterShell extends StatelessWidget {
  const CategoryCenterShell({
    super.key,
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
    required this.children,
  }) : assert(options.length == children.length);

  final String title;
  final List<CategoryCenterOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selected = options[selectedIndex];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: theme.dividerColor.withAlpha(isDark ? 60 : 75),
                ),
                boxShadow: [
                  BoxShadow(
                    color: selected.color.withAlpha(isDark ? 28 : 20),
                    blurRadius: 22,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(options.length, (index) {
                  return Expanded(
                    child: _CategoryButton(
                      option: options[index],
                      selected: selectedIndex == index,
                      onTap: () => onSelected(index),
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(index: selectedIndex, children: children),
          ),
        ],
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final CategoryCenterOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: option.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [option.color, option.color.withAlpha(205)],
                  )
                : null,
            borderRadius: BorderRadius.circular(17),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: option.color.withAlpha(52),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                option.icon,
                size: 19,
                color: selected ? Colors.white : option.color.withAlpha(210),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : theme.textTheme.bodyMedium?.color?.withAlpha(185),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
