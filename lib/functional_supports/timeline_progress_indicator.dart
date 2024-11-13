// Widget that displays a timeline progress indicator with numbered steps in the appointment process
import 'package:flutter/material.dart';

class TimelineProgressIndicator extends StatefulWidget {
  final int currentIndex;
  final int totalSteps;

  const TimelineProgressIndicator({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
  });

  @override
  State<TimelineProgressIndicator> createState() =>
      _TimelineProgressIndicatorState();
}

class _TimelineProgressIndicatorState extends State<TimelineProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    // Calculate dimensions based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    // Calculate the width of connecting lines between steps
    double lineContainerWidth =
        (screenWidth - (widget.totalSteps * 50)) / (widget.totalSteps - 1);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        // Generate timeline steps
        children: List.generate(widget.totalSteps, (index) {
          int displayIndex = index + 1;

          return Row(
            children: [
              // Circle indicator for each step
              Center(
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    // Color based on whether step is complete or active
                    color: displayIndex <= widget.currentIndex
                        ? Colors.orange
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  // Show checkmark for completed steps, number for others
                  child: displayIndex < widget.currentIndex
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 15,
                        )
                      : Center(
                          child: Text(
                          displayIndex.toString(),
                          style: const TextStyle(color: Colors.white),
                        )),
                ),
              ),
              // Connecting line between steps
              if (index < widget.totalSteps - 1)
                Container(
                  width: lineContainerWidth,
                  height: 3,
                  color: displayIndex < widget.currentIndex
                      ? Colors.orange
                      : Colors.grey,
                ),
            ],
          );
        }),
      ),
    );
  }
}
