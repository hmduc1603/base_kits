// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class OnboardingModel {
  final String assetImage;
  final String? title;
  final String? desc;
  OnboardingModel({
    required this.assetImage,
    this.title,
    this.desc,
  });
}

class OnboardingWidget extends StatefulWidget {
  final List<OnboardingModel> list;
  final BoxFit? assetFit;
  final EdgeInsets? assetPadding;
  final double? assetHeight;
  final BorderRadius? assetBorderRadius;
  final TextStyle titleStyle;
  final EdgeInsets? titlePadding;
  final EdgeInsets? descPadding;
  final TextStyle? descStyle;
  final Color? backgroundColor;
  final List<Color> btnColors;
  final Color indicatorColor;
  final TextStyle btnTextStyle;
  final BorderRadius? btnBorderRadius;
  final VoidCallback onDone;
  final Function(int page)? onPageChanged;
  final double? btnHeight;
  final Widget Function(int index)? assetBuilder;

  const OnboardingWidget({
    Key? key,
    required this.indicatorColor,
    required this.list,
    this.assetPadding,
    this.assetFit,
    this.assetHeight,
    required this.titleStyle,
    this.titlePadding,
    this.descPadding,
    this.descStyle,
    this.backgroundColor,
    required this.btnColors,
    required this.btnTextStyle,
    this.btnBorderRadius,
    required this.onDone,
    this.btnHeight,
    this.onPageChanged,
    this.assetBorderRadius,
    this.assetBuilder,
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
      backgroundColor: widget.backgroundColor ?? Colors.transparent,
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
                  Padding(
                    padding: widget.assetPadding ?? const EdgeInsets.all(0),
                    child: ClipRRect(
                      borderRadius:
                          widget.assetBorderRadius ?? BorderRadius.circular(0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: widget.assetHeight ??
                                MediaQuery.of(context).size.height * 0.6),
                        child: widget.assetBuilder != null
                            ? widget.assetBuilder!(index)
                            : Image.asset(
                                thisItem.assetImage,
                                fit: widget.assetFit ?? BoxFit.fitWidth,
                                height: widget.assetHeight,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Flexible(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: 80,
                        child: LinearProgressIndicator(
                            backgroundColor:
                                widget.indicatorColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(100),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                widget.indicatorColor),
                            value: ((currentIndex + 1) / widget.list.length)
                                .toDouble()),
                      ),
                      const SizedBox(height: 20),
                      if (thisItem.title != null) ...{
                        Padding(
                          padding: widget.titlePadding ??
                              const EdgeInsets.symmetric(horizontal: 15),
                          child: AutoSizeText(
                            thisItem.title!,
                            style: widget.titleStyle,
                            textAlign: TextAlign.center,
                          ),
                        )
                      },
                      if (thisItem.desc != null) ...{
                        const SizedBox(height: 10),
                        Padding(
                          padding: widget.descPadding ??
                              const EdgeInsets.symmetric(horizontal: 15),
                          child: AutoSizeText(
                            thisItem.desc!,
                            style: widget.descStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      },
                      const SizedBox(height: 20),
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
                    gradient: LinearGradient(colors: widget.btnColors),
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
