// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:state_notifier/state_notifier.dart';

class TodoSearchState extends Equatable {
  final String searchTerm;
  TodoSearchState({
    required this.searchTerm,
  });
  factory TodoSearchState.initial() {
    return TodoSearchState(searchTerm: '');
  }

  TodoSearchState copyWith({
    String? searchTerm,
  }) {
    return TodoSearchState(
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }

  @override
  List<Object?> get props => [searchTerm];

  @override
  bool get stringify => true;
}

class TodoSearch extends StateNotifier<TodoSearchState> {
  TodoSearch() : super(TodoSearchState.initial());
  void setSearchTerm(String newSearchTrem) {
    state = state.copyWith(searchTerm: newSearchTrem);
  }
}
