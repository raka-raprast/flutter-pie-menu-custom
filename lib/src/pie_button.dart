import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_action.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_theme.dart';

/// Displays [PieAction]s of the [PieMenu] on the [PieCanvas].
class PieButton extends StatefulWidget {
  /// Creates a [PieButton] that is specialized for a [PieAction].
  const PieButton({
    super.key,
    required this.action,
    required this.menuOpen,
    required this.hovered,
    required this.theme,
    required this.fadeDuration,
    required this.hoverDuration,
  });

  /// Action to display.
  final PieAction action;

  /// Whether the [PieMenu] this [PieButton] belongs to is open.
  final bool menuOpen;

  /// Whether this [PieButton] is currently hovered.
  final bool hovered;

  /// Behavioral and visual structure of this button.
  final PieTheme theme;

  /// Duration of the [PieMenu] fade animation.
  final Duration fadeDuration;

  /// Duration of the [PieButton] hover animation.
  final Duration hoverDuration;

  @override
  State<PieButton> createState() => _PieButtonState();
}

class _PieButtonState extends State<PieButton>
    with SingleTickerProviderStateMixin {
  /// Controls [_animation].
  late final AnimationController _controller = AnimationController(
    duration: widget.fadeDuration,
    vsync: this,
  )..addListener(() => setState(() {}));

  /// Fade animation for the [PieButton]s.
  late final Animation _animation = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.ease,
  ));

  /// Wether the [PieButton] is visible.
  bool visible = false;

  PieAction get _action => widget.action;
  PieTheme get _theme => widget.theme;

  PieButtonTheme get _buttonTheme {
    return _action.buttonTheme ?? _theme.buttonTheme;
  }

  PieButtonTheme get _buttonThemeHovered {
    return _action.buttonThemeHovered ?? _theme.buttonThemeHovered;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.menuOpen) {
      visible = false;
    } else if (widget.menuOpen && !visible) {
      visible = true;
      _controller.forward(from: 0);
    }

    return OverflowBox(
      maxHeight: _theme.buttonSize * 2,
      maxWidth: _theme.buttonSize * 2,
      child: AnimatedScale(
        scale: widget.hovered ? 1.2 : 1,
        duration: widget.hoverDuration,
        curve: Curves.ease,
        child: Transform.scale(
          scale: _animation.value,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: widget.hoverDuration,
                curve: Curves.ease,
                top: widget.hovered
                    ? _theme.buttonSize / 2 -
                        sin(_action.angle) * _theme.hoverDisplacement
                    : _theme.buttonSize / 2,
                right: widget.hovered
                    ? _theme.buttonSize / 2 -
                        cos(_action.angle) * _theme.hoverDisplacement
                    : _theme.buttonSize / 2,
                child: Container(
                  height: _theme.buttonSize,
                  width: _theme.buttonSize,
                  decoration: (widget.hovered
                          ? _buttonThemeHovered.decoration
                          : _buttonTheme.decoration) ??
                      BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.hovered
                            ? _buttonThemeHovered.backgroundColor
                            : _buttonTheme.backgroundColor,
                      ),
                  child: Center(
                    child: Padding(
                      padding: _action.padding,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          iconTheme: IconThemeData(
                            color: widget.hovered
                                ? _buttonThemeHovered.iconColor
                                : _buttonTheme.iconColor,
                            size: _theme.iconSize,
                          ),
                        ),
                        child: widget.hovered
                            ? (_action.childHovered ?? _action.child)
                            : _action.child,
                      ),
                    ),
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
