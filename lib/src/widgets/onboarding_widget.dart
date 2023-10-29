// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class OnboardingModel {
  final String assetImage;
  final String title;
  final String? desc;
  OnboardingModel({
    required this.assetImage,
    required this.title,
    this.desc,
  });
}

class OnboardingWidget extends StatefulWidget {
  final List<OnboardingModel> list;
  final BoxFit? assetFit;
  final EdgeInsets? assetPadding;
  final TextStyle titleStyle;
  final EdgeInsets? titlePadding;
  final EdgeInsets? descPadding;
  final TextStyle? descStyle;
  final Color backgroundColor;
  final Color btnColor;
  final TextStyle btnTextStyle;
  final BorderRadius? btnBorderRadius;
  final VoidCallback onDone;
  final Function(int page)? onPageChanged;
  final double? btnHeight;

  const OnboardingWidget({
    Key? key,
    required this.list,
    this.assetPadding,
    this.assetFit,
    required this.titleStyle,
    this.titlePadding,
    this.descPadding,
    this.descStyle,
    required this.backgroundColor,
    required this.btnColor,
    required this.btnTextStyle,
    this.btnBorderRadius,
    required this.onDone,
    this.btnHeight,
    this.onPageChanged,
  }) : super(key: key);

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  final _pageCtr = PageController();
  int currentIndex = 0;

  @override
  void dispose() {
    _pageCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: PageView.builder(
            controller: _pageCtr,
            onPageChanged: (value) {
              setState(() {
                currentIndex = value;
              });
              widget.onPageChanged?.call(value);
            },
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.list.length,
            itemBuilder: (context, index) {
              final thisItem = widget.list[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6),
                    child: Image.asset(
                      thisItem.assetImage,
                      fit: widget.assetFit ?? BoxFit.fitWidth,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: 80,
                        child: LinearProgressIndicator(
                            backgroundColor: widget.btnColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(100),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(widget.btnColor),
                            value: ((currentIndex + 1) / widget.list.length)
                                .toDouble()),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: widget.titlePadding ??
                            const EdgeInsets.symmetric(horizontal: 15),
                        child: AutoSizeText(
                          thisItem.title,
                          style: widget.titleStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (thisItem.desc != null) ...{
                        Padding(
                          padding: widget.descPadding ??
                              const EdgeInsets.symmetric(horizontal: 15),
                          child: AutoSizeText(
                            thisItem.desc!,
                            style: widget.descStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      }
                    ],
                  ))
                ],
              );
            },
          )),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  if (currentIndex == widget.list.length - 1) {
                    widget.onDone();
                  } else {
                    _pageCtr.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.linear);
                  }
                },
                child: Container(
                  height: widget.btnHeight ?? 50,
                  decoration: BoxDecoration(
                    borderRadius:
                        widget.btnBorderRadius ?? BorderRadius.circular(1000),
                    color: widget.btnColor,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.center,
                    child: Text(
                      (currentIndex == widget.list.length - 1)
                          ? "Done"
                          : "Next",
                      style: widget.btnTextStyle,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
