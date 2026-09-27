import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormTextField extends StatelessWidget {
  const FormTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.hintText,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white38),
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF111213),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2E3033)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF34D399)),
          ),
        ),
      ),
    );
  }
}

class FormDropdownField<T> extends StatelessWidget {
  const FormDropdownField({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isSearchable = false,
    this.searchHint = 'অনুসন্ধান করুন...',
  });

  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool isSearchable;
  final String searchHint;

  void _openSearchSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SearchablePickerSheet<T>(
        title: hint,
        searchHint: searchHint,
        selectedValue: value,
        items: items,
        onSelected: (val) {
          Navigator.of(ctx).pop();
          onChanged(val);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isSearchable) {
      final selectedItem =
          items.firstWhereOrNull((item) => item.value == value);
      final displayText =
          selectedItem != null ? _getItemLabel(selectedItem) : null;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => _openSearchSheet(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF111213),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2E3033)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText ?? hint,
                    style: TextStyle(
                      color: displayText != null ? Colors.white : Colors.grey,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF34D399),
                  size: 18,
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Colors.grey,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF111213),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2E3033)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            hint: Text(hint, style: const TextStyle(color: Colors.grey)),
            isExpanded: true,
            dropdownColor: const Color(0xFF1B1C1E),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

String _getItemLabel<T>(DropdownMenuItem<T> item) {
  if (item.child is Text) {
    final textWidget = item.child as Text;
    return textWidget.data ?? textWidget.textSpan?.toPlainText() ?? '';
  }
  return item.value?.toString() ?? '';
}

class _SearchablePickerSheet<T> extends StatefulWidget {
  const _SearchablePickerSheet({
    required this.title,
    required this.searchHint,
    required this.selectedValue,
    required this.items,
    required this.onSelected,
  });

  final String title;
  final String searchHint;
  final T? selectedValue;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onSelected;

  @override
  State<_SearchablePickerSheet<T>> createState() =>
      _SearchablePickerSheetState<T>();
}

class _SearchablePickerSheetState<T> extends State<_SearchablePickerSheet<T>> {
  final TextEditingController _searchController = TextEditingController();
  late List<DropdownMenuItem<T>> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.items);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredItems = List.from(widget.items);
      } else {
        final q = query.trim().toLowerCase();
        _filteredItems = widget.items.where((item) {
          final label = _getItemLabel(item).toLowerCase();
          return label.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white60, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              autofocus: false,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.searchHint,
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF34D399),
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: Colors.white54, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF111213),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2E3033)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF34D399)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.search_off_rounded,
                                color: Colors.white38, size: 36),
                            SizedBox(height: 8),
                            Text(
                              'কোনো ফলাফল পাওয়া যায়নি',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filteredItems.length,
                      separatorBuilder: (_, __) => const Divider(
                        color: Color(0xFF242528),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = item.value == widget.selectedValue;
                        final label = _getItemLabel(item);

                        return InkWell(
                          onTap: () => widget.onSelected(item.value),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF34D399)
                                      .withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFF34D399)
                                          : Colors.white,
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF34D399),
                                    size: 18,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class FormSwitchRow extends StatelessWidget {
  const FormSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF34D399),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.black;
              }
              return Colors.white54;
            }),
          ),
        ],
      ),
    );
  }
}

class PreviewRow extends StatelessWidget {
  const PreviewRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class PreviewBadge extends StatelessWidget {
  const PreviewBadge({
    super.key,
    required this.label,
    required this.active,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF34D399).withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active
              ? const Color(0xFF34D399).withValues(alpha: 0.4)
              : const Color(0xFF2E3033),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle_rounded : Icons.cancel_outlined,
            size: 13,
            color: active ? const Color(0xFF34D399) : Colors.white38,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF34D399) : Colors.white38,
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
