import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inq_app/functional_supports/responsive.dart';

class MyOtpRow extends StatefulWidget {
  final TextEditingController controller;

  const MyOtpRow({Key? key, required this.controller}) : super(key: key);

  @override
  State<MyOtpRow> createState() => _MyOtpRowState();
}

class _MyOtpRowState extends State<MyOtpRow> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return ResponsiveWidget(
      mobile: _buildOtpRow(SizeConfig.width(12)),
      tablet: _buildOtpRow(SizeConfig.width(8)),
      desktop: _buildOtpRow(SizeConfig.width(5)),
    );
  }

  Widget _buildOtpRow(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (index) => SizedBox(
          width: size,
          child: MyOtpTextfield(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            onChanged: (value) => _handleOtpInput(index, value),
          ),
        ),
      ),
    );
  }

  void _handleOtpInput(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    String otp = _controllers.map((controller) => controller.text).join();
    widget.controller.text = otp;
  }
}

class MyOtpTextfield extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;

  const MyOtpTextfield({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: SizeConfig.text(4)),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(SizeConfig.width(2)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: SizeConfig.width(0.3)),
          borderRadius: BorderRadius.circular(SizeConfig.width(2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange, width: SizeConfig.width(0.3)),
          borderRadius: BorderRadius.circular(SizeConfig.width(2)),
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(1)
      ],
      onChanged: onChanged,
    );
  }
}
