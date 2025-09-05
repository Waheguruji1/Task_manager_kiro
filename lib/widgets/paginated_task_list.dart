import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/theme.dart';

/// Paginated Task List Widget
/// 
/// Provides pagination for long task lists to improve performance
class PaginatedTaskList extends StatefulWidget {
  final List<Task> tasks;
  final Widget Function(Task task) taskBuilder;
  final int itemsPerPage;
  final Widget? emptyState;
  
  const PaginatedTaskList({
    super.key,
    required this.tasks,
    required this.taskBuilder,
    this.itemsPerPage = 20,
    this.emptyState,
  });
  
  @override
  State<PaginatedTaskList> createState() => _PaginatedTaskListState();
}

class _PaginatedTaskListState extends State<PaginatedTaskList> {
  int _currentPage = 0;
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }
  
  void _loadMore() {
    if (_isLoadingMore) return;
    
    final totalPages = (widget.tasks.length / widget.itemsPerPage).ceil();
    if (_currentPage >= totalPages - 1) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    // Simulate loading delay for smooth UX
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _currentPage++;
          _isLoadingMore = false;
        });
      }
    });
  }
  
  List<Task> get _visibleTasks {
    final endIndex = (_currentPage + 1) * widget.itemsPerPage;
    return widget.tasks.take(endIndex).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) {
      return widget.emptyState ?? const SizedBox.shrink();
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
      itemCount: _visibleTasks.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _visibleTasks.length) {
          // Loading indicator at the bottom
          return const Padding(
            padding: EdgeInsets.all(AppTheme.spacingM),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.greyPrimary),
              ),
            ),
          );
        }
        
        return widget.taskBuilder(_visibleTasks[index]);
      },
    );
  }
}

/// Paginated Task Container List
/// 
/// Provides pagination for grouped task containers
class PaginatedTaskContainerList extends StatefulWidget {
  final Map<DateTime, List<Task>> groupedTasks;
  final Widget Function(DateTime date, List<Task> tasks) containerBuilder;
  final int containersPerPage;
  final Widget? emptyState;
  
  const PaginatedTaskContainerList({
    super.key,
    required this.groupedTasks,
    required this.containerBuilder,
    this.containersPerPage = 10,
    this.emptyState,
  });
  
  @override
  State<PaginatedTaskContainerList> createState() => _PaginatedTaskContainerListState();
}

class _PaginatedTaskContainerListState extends State<PaginatedTaskContainerList> {
  int _currentPage = 0;
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  late List<DateTime> _sortedDates;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _updateSortedDates();
  }
  
  @override
  void didUpdateWidget(PaginatedTaskContainerList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.groupedTasks != oldWidget.groupedTasks) {
      _updateSortedDates();
      _currentPage = 0; // Reset pagination when data changes
    }
  }
  
  void _updateSortedDates() {
    _sortedDates = widget.groupedTasks.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }
  
  void _loadMore() {
    if (_isLoadingMore) return;
    
    final totalPages = (_sortedDates.length / widget.containersPerPage).ceil();
    if (_currentPage >= totalPages - 1) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    // Simulate loading delay for smooth UX
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _currentPage++;
          _isLoadingMore = false;
        });
      }
    });
  }
  
  List<DateTime> get _visibleDates {
    final endIndex = (_currentPage + 1) * widget.containersPerPage;
    return _sortedDates.take(endIndex).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.groupedTasks.isEmpty) {
      return widget.emptyState ?? const SizedBox.shrink();
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
      itemCount: _visibleDates.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _visibleDates.length) {
          // Loading indicator at the bottom
          return const Padding(
            padding: EdgeInsets.all(AppTheme.spacingM),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.greyPrimary),
              ),
            ),
          );
        }
        
        final date = _visibleDates[index];
        final tasks = widget.groupedTasks[date]!;
        return widget.containerBuilder(date, tasks);
      },
    );
  }
}