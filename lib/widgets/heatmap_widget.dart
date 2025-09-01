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
    this.cellSize = 14.0,
    this.spacing = 3.0,
  });

  @override
  State<HeatmapWidget> createState() => _HeatmapWidgetState();
}

class _HeatmapWidgetState extends State<HeatmapWidget> {
  OverlayEntry? _overlayEntry;
  final GlobalKey _containerKey = GlobalKey();
  DateTime _selectedMonth = DateTime.now();

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
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildMonthGrid(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

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
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        
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
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onTap: _showMonthPicker,
        child: Row(
          children: [
            Text(
              DateFormat('MMMM yyyy').format(_selectedMonth),
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.calendar_month,
              color: Color(0xFF8E8E93),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6B7280),
              onPrimary: Colors.white,
              surface: Color(0xFF1C1C1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  Widget _buildSelectedMonthView() {
    return _buildMonthGrid(_selectedMonth);
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'low',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Text(
                'high',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade800,
                  widget.baseColor.withValues(alpha: 0.3),
                  widget.baseColor.withValues(alpha: 0.6),
                  widget.baseColor,
                ],
              ),
            ),
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
        key: _containerKey,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with info icon
            Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E8E93),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Month picker
            _buildMonthPicker(),
            const SizedBox(height: 20),
            
            // Heatmap container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF000000),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: _buildSelectedMonthView(),
              ),
            ),
            const SizedBox(height: 20),
            
            // Legend
            _buildLegend(),
            const SizedBox(height: 16),
            
            // Completion Status label
            const Center(
              child: Text(
                'Completion Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}