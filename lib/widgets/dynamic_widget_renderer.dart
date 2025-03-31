import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DynamicWidgetRenderer extends StatelessWidget {
  final Map<String, dynamic>? jsonData;
  final Map<String, TextEditingController>? controllers;
  final Function(String, Map<String, dynamic>)? onActionCallback;

  const DynamicWidgetRenderer({
    Key? key,
    required this.jsonData,
    this.controllers,
    this.onActionCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (jsonData == null) {
      return const SizedBox();
    }

    return _buildWidgetFromJson(jsonData!, context);
  }

  Widget _buildWidgetFromJson(Map<String, dynamic> json, BuildContext context) {
    final type = json['type'] as String? ?? 'container';
    final args = json['args'] as Map<String, dynamic>? ?? {};

    switch (type) {
      case 'container':
        return _buildContainer(args, context);
      case 'column':
        return _buildColumn(args, context);
      case 'row':
        return _buildRow(args, context);
      case 'text':
        return _buildText(args);
      case 'card':
        return _buildCard(args, context);
      case 'padding':
        return _buildPadding(args, context);
      case 'textField':
        return _buildTextField(args);
      case 'elevatedButton':
        return _buildElevatedButton(args, context);
      case 'textButton':
        return _buildTextButton(args, context);

      default:
        return Text('Unknown widget type: $type');
    }
  }

  Widget _buildContainer(Map<String, dynamic> args, BuildContext context) {
    final padding = args['padding'];
    final child = args['child'];
    final color = args['color'];
    final width = args['width'];
    final height = args['height'];
    final margin = args['margin'];

    return Container(
      padding: padding is double
          ? EdgeInsets.all(padding)
          : padding is Map
              ? EdgeInsets.only(
                  left: padding['left'] ?? 0.0,
                  top: padding['top'] ?? 0.0,
                  right: padding['right'] ?? 0.0,
                  bottom: padding['bottom'] ?? 0.0,
                )
              : null,
      margin: margin is Map
          ? EdgeInsets.only(
              left: margin['left'] ?? 0.0,
              top: margin['top'] ?? 0.0,
              right: margin['right'] ?? 0.0,
              bottom: margin['bottom'] ?? 0.0,
            )
          : null,
      color: color != null ? _parseColor(color) : null,
      width: width?.toDouble(),
      height: height?.toDouble(),
      child: child != null ? _buildWidgetFromJson(child, context) : null,
    );
  }

  Widget _buildColumn(Map<String, dynamic> args, BuildContext context) {
    final children = args['children'] as List<dynamic>? ?? [];
    final mainAxisAlignment =
        _parseMainAxisAlignment(args['mainAxisAlignment']);
    final crossAxisAlignment =
        _parseCrossAxisAlignment(args['crossAxisAlignment']);

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children
          .map((child) => _buildWidgetFromJson(child, context))
          .toList(),
    );
  }

  Widget _buildRow(Map<String, dynamic> args, BuildContext context) {
    final children = args['children'] as List<dynamic>? ?? [];
    final mainAxisAlignment =
        _parseMainAxisAlignment(args['mainAxisAlignment']);
    final crossAxisAlignment =
        _parseCrossAxisAlignment(args['crossAxisAlignment']);

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children
          .map((child) => _buildWidgetFromJson(child, context))
          .toList(),
    );
  }

  Widget _buildText(Map<String, dynamic> args) {
    final text = args['text'] as String? ?? '';
    final style = args['style'] as Map<String, dynamic>? ?? {};
    final textAlign = _parseTextAlign(args['textAlign']);

    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: style['fontSize']?.toDouble(),
        fontWeight: _parseFontWeight(style['fontWeight']),
        color: style['color'] != null ? _parseColor(style['color']) : null,
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> args, BuildContext context) {
    final child = args['child'];
    final elevation = args['elevation']?.toDouble() ?? 1.0;

    return Card(
      elevation: elevation,
      child: child != null ? _buildWidgetFromJson(child, context) : null,
    );
  }

  Widget _buildPadding(Map<String, dynamic> args, BuildContext context) {
    final padding = args['padding'];
    final child = args['child'];

    return Padding(
      padding: padding is double
          ? EdgeInsets.all(padding)
          : padding is Map
              ? EdgeInsets.only(
                  left: padding['left'] ?? 0.0,
                  top: padding['top'] ?? 0.0,
                  right: padding['right'] ?? 0.0,
                  bottom: padding['bottom'] ?? 0.0,
                )
              : EdgeInsets.zero,
      child: child != null ? _buildWidgetFromJson(child, context) : null,
    );
  }

  Widget _buildTextField(Map<String, dynamic> args) {
    final labelText = args['labelText'] as String? ?? '';
    final hintText = args['hintText'] as String? ?? '';
    final obscureText = args['obscureText'] as bool? ?? false;
    final controllerName = args['controllerName'] as String?;
    final keyboardType = _parseTextInputType(args['keyboardType']);

    return TextField(
      controller: controllerName != null && controllers != null
          ? controllers![controllerName]
          : null,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
    );
  }

  Widget _buildElevatedButton(Map<String, dynamic> args, BuildContext context) {
    final text = args['text'] as String? ?? '';
    final action = args['action'] as Map<String, dynamic>?;
    final iconName = args['icon'] as String?;

    return ElevatedButton(
      onPressed: () {
        if (action != null && onActionCallback != null) {
          final actionType = action['type'] as String;
          onActionCallback!(actionType, action);
        }
      },
      child: iconName != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIcon(iconName),
                const SizedBox(width: 8.0),
                Text(text),
              ],
            )
          : Text(text),
    );
  }

  Widget _buildIcon(String iconName) {
    switch (iconName) {
      case 'google':
        return const Icon(FontAwesomeIcons.google, size: 24.0);
      case 'apple':
        return const Icon(Icons.apple, size: 24.0);
      case 'phone':
        return const Icon(Icons.phone, size: 24.0);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextButton(Map<String, dynamic> args, BuildContext context) {
    final text = args['text'] as String? ?? '';
    final action = args['action'] as Map<String, dynamic>?;

    return TextButton(
      onPressed: () {
        if (action != null && onActionCallback != null) {
          final actionType = action['type'] as String;
          onActionCallback!(actionType, action);
        }
      },
      child: Text(text),
    );
  }

  // Helper methods for parsing values
  Color _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      String hexColor = colorString.substring(1);
      if (hexColor.length == 6) {
        hexColor = 'FF' + hexColor;
      }
      return Color(int.parse(hexColor, radix: 16));
    }
    return Colors.black; // Default
  }

  MainAxisAlignment _parseMainAxisAlignment(String? alignment) {
    switch (alignment) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment _parseCrossAxisAlignment(String? alignment) {
    switch (alignment) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      default:
        return CrossAxisAlignment.center;
    }
  }

  TextAlign _parseTextAlign(String? align) {
    switch (align) {
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      case 'center':
        return TextAlign.center;
      case 'justify':
        return TextAlign.justify;
      default:
        return TextAlign.left;
    }
  }

  FontWeight _parseFontWeight(String? weight) {
    switch (weight) {
      case 'bold':
        return FontWeight.bold;
      case 'normal':
        return FontWeight.normal;
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }

  TextInputType _parseTextInputType(String? type) {
    switch (type) {
      case 'text':
        return TextInputType.text;
      case 'number':
        return TextInputType.number;
      case 'phone':
        return TextInputType.phone;
      case 'emailAddress':
        return TextInputType.emailAddress;
      case 'url':
        return TextInputType.url;
      case 'multiline':
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }
}
