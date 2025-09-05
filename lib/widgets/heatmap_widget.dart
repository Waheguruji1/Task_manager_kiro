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
    super.key,
    required this.data,
    required this.baseColor,
    required this.title,
    this.onCellTap,
    this.tooltipBuilder,
    this.isMultiValue = false,
    this.cellSize = 12.0,
    this.spacing = 2.0,
  });

  @override
  State<HeatmapWidget> createState() => _HeatmapWidgetState();
}

class _HeatmapWidgetState extends State<HeatmapWidget> {
  OverlayEntry? _overlayEntry;
  late DateTime _selectedMonth;
  final int _currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(_currentYear, DateTime.now().month, 1);
  }

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
        left: (position.dx - 60).clamp(10.0, MediaQuery.of(context).size.width - 130),
        top: (position.dy - 80).clamp(10.0, MediaQuery.of(context).size.height - 80),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade900,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: widget.tooltipBuilder!(date, value),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    Future.delayed(const Duration(seconds: 2), _removeTooltip);
  }

  Color _getIntensityColor(dynamic value) {
    if (value == null) return Colors.deepPurple.shade800;

    double intensity = 0.0;

    if (widget.isMultiValue && value is Map<String, int>) {
      int total = value.values.fold(0, (sum, val) => sum + val);
      intensity = _calculateIntensity(total);
    } else if (value is int) {
      intensity = _calculateIntensity(value);
    }

    // Purple shades from deep purple to lighter purple
    return Color.lerp(
      Colors.deepPurple.shade900,
      Colors.deepPurple.shade300,
      intensity.clamp(0.0, 1.0),
    )!;
  }

  double _calculateIntensity(int value) {
    if (value == 0) return 0.0;

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

    return (value / maxValue).clamp(0.2, 1.0);
  }

  Widget _buildDayCell(DateTime date, dynamic value) {
    final color = _getIntensityColor(value);

    return GestureDetector(
      onTap: () => widget.onCellTap?.call(date, value),
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
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: Colors.deepPurple.shade700.withOpacity(0.4),
            width: 0.7,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthGrid(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Weekday headers
        SizedBox(
          width: 7 * (widget.cellSize + widget.spacing) - widget.spacing,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => SizedBox(
                      width: widget.cellSize,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.deepPurple.shade200,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 12),

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

  Widget _buildMonthPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade700),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade900.withOpacity(0.7),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          dropdownColor: Colors.deepPurple.shade900,
          value: _selectedMonth.month,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.deepPurple.shade200),
          style: TextStyle(
            color: Colors.deepPurple.shade100,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          items: List.generate(12, (index) {
            final month = index + 1;
            final monthName = DateFormat('MMMM').format(DateTime(_currentYear, month));
            return DropdownMenuItem<int>(
              value: month,
              child: Text('$monthName $_currentYear'),
            );
          }),
          onChanged: (int? month) {
            if (month != null) {
              setState(() {
                _selectedMonth = DateTime(_currentYear, month, 1);
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade700),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade900.withOpacity(0.7),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Level',
            style: TextStyle(
              color: Colors.deepPurple.shade100,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Low',
                style: TextStyle(
                  color: Colors.deepPurple.shade200,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade900,
                        Colors.deepPurple.shade700.withOpacity(0.7),
                        Colors.deepPurple.shade500.withOpacity(0.7),
                        Colors.deepPurple.shade300,
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'High',
                style: TextStyle(
                  color: Colors.deepPurple.shade200,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _removeTooltip,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade900,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.deepPurple.shade700),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.shade900.withOpacity(0.9),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.deepPurple.shade100,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade800,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.deepPurple.shade200,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Month picker
            _buildMonthPicker(),
            const SizedBox(height: 24),

            // Heatmap container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade800,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple.shade700),
              ),
              child: Center(
                child: _buildMonthGrid(_selectedMonth),
              ),
            ),
            const SizedBox(height: 20),

            // Legend
            _buildLegend(),
          ],
        ),
      ),
    );
  }
}
