import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeatmapWidget extends StatefulWidget {
  final Map<DateTime, dynamic> data;
  final Color baseColor;
  final String title;
  final Function(DateTime, dynamic)? onCellTap;
  final Widget Function(DateTime, dynamic)? tooltipBuilder;
  final bool isMultiValue;
  final double cellSize;
  final double spacing;

  const HeatmapWidget({
    Key? key,
    required this.data,
    required this.baseColor,
    required this.title,
    this.onCellTap,
    this.tooltipBuilder,
    this.isMultiValue = false,
    this.cellSize = 12.0,
    this.spacing = 2.0,
  }) : super(key: key);

  @override
  State<HeatmapWidget> createState() => _HeatmapWidgetState();
}

class _HeatmapWidgetState extends State<HeatmapWidget> {
  OverlayEntry? _overlayEntry;
  final GlobalKey _containerKey = GlobalKey();

  @override
  void dispose() {
    _removeTooltip();
    super.dispose();
  }

  void _removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showTooltip(BuildContext context, DateTime date, dynamic value, Offset position) {
    _removeTooltip();

    if (widget.tooltipBuilder == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 60,
        top: position.dy - 80,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: widget.tooltipBuilder!(date, value),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto-remove tooltip after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _removeTooltip();
    });
  }

  Color _getIntensityColor(dynamic value) {
    if (value == null) return Colors.grey.shade800;

    double intensity = 0.0;
    
    if (widget.isMultiValue && value is Map<String, int>) {
      // For multi-value data, use the sum or a specific calculation
      int total = value.values.fold(0, (sum, val) => sum + val);
      intensity = _calculateIntensity(total);
    } else if (value is int) {
      intensity = _calculateIntensity(value);
    }

    return Color.lerp(
      Colors.grey.shade800,
      widget.baseColor,
      intensity.clamp(0.0, 1.0),
    )!;
  }

  double _calculateIntensity(int value) {
    if (value == 0) return 0.0;
    
    // Find max value in dataset for normalization
    int maxValue = 0;
    for (var data in widget.data.values) {
      if (widget.isMultiValue && data is Map<String, int>) {
        int total = data.values.fold(0, (sum, val) => sum + val);
        if (total > maxValue) maxValue = total;
      } else if (data is int && data > maxValue) {
        maxValue = data;
      }
    }

    if (maxValue == 0) return 0.0;
    
    // Use logarithmic scale for better visual distribution
    return (value / maxValue).clamp(0.1, 1.0);
  }

  Widget _buildDayCell(DateTime date, dynamic value) {
    final color = _getIntensityColor(value);
    
    return GestureDetector(
      onTap: () {
        widget.onCellTap?.call(date, value);
      },
      onTapDown: (details) {
        if (widget.tooltipBuilder != null) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final position = renderBox.localToGlobal(details.globalPosition);
          _showTooltip(context, date, value, position);
        }
      },
      child: Container(
        width: widget.cellSize,
        height: widget.cellSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: Colors.grey.shade700,
            width: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthGrid(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month label
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            DateFormat('MMM').format(month),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Calendar grid
        SizedBox(
          width: 7 * (widget.cellSize + widget.spacing) - widget.spacing,
          child: Wrap(
            spacing: widget.spacing,
            runSpacing: widget.spacing,
            children: [
              // Empty cells for days before month starts
              ...List.generate(
                firstWeekday,
                (index) => SizedBox(
                  width: widget.cellSize,
                  height: widget.cellSize,
                ),
              ),
              // Days of the month
              ...List.generate(daysInMonth, (index) {
                final date = DateTime(month.year, month.month, index + 1);
                final normalizedDate = DateTime(date.year, date.month, date.day);
                final value = widget.data[normalizedDate];
                
                return _buildDayCell(normalizedDate, value);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYearView() {
    final now = DateTime.now();
    final currentYear = now.year;
    
    // Generate months for the current year
    final months = List.generate(12, (index) => DateTime(currentYear, index + 1, 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year label
        Text(
          currentYear.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Months grid
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: months.map((month) => _buildMonthGrid(month)).toList(),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Less',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          final intensity = index / 4.0;
          final color = Color.lerp(
            Colors.grey.shade800,
            widget.baseColor,
            intensity,
          )!;
          
          return Container(
            width: widget.cellSize,
            height: widget.cellSize,
            margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: Colors.grey.shade700,
                width: 0.5,
              ),
            ),
          );
        }),
        const SizedBox(width: 4),
        const Text(
          'More',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _removeTooltip,
      child: Container(
        key: _containerKey,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Heatmap
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildYearView(),
            ),
            const SizedBox(height: 16),
            // Legend
            _buildLegend(),
          ],
        ),
      ),
    );
  }
}