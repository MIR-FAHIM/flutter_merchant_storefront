import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef ItemMatcher<T> = bool Function(T item, String query);
typedef ItemTitleBuilder<T> = String Function(T item);
typedef ItemSubtitleBuilder<T> = String? Function(T item);

class LocationSearchDropdown<T> extends StatelessWidget {
  const LocationSearchDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.itemTitle,
    this.itemSubtitle,
    required this.itemMatcher,
    this.prefixIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.disabledHint,
    this.errorText,
    this.sheetTitle,
    this.onClear,
  });

  final String label;
  final String hint;
  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T?> onChanged;
  final ItemTitleBuilder<T> itemTitle;
  final ItemSubtitleBuilder<T>? itemSubtitle;
  final ItemMatcher<T> itemMatcher;
  final IconData? prefixIcon;
  final bool isLoading;
  final bool isDisabled;
  final String? disabledHint;
  final String? errorText;
  final String? sheetTitle;
  final VoidCallback? onClear;

  void _openSearchSheet(BuildContext context) {
    if (isDisabled) {
      if (disabledHint != null && disabledHint!.isNotEmpty) {
        Get.rawSnackbar(
          message: disabledHint!,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF334155),
          borderRadius: 8,
          margin: const EdgeInsets.all(12),
        );
      }
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SearchBottomSheet<T>(
        title: sheetTitle ?? label,
        items: items,
        selectedItem: selectedItem,
        itemTitle: itemTitle,
        itemSubtitle: itemSubtitle,
        itemMatcher: itemMatcher,
        onSelected: (selected) {
          Navigator.of(ctx).pop();
          onChanged(selected);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayText = selectedItem != null ? itemTitle(selectedItem as T) : null;
    final subText = selectedItem != null && itemSubtitle != null
        ? itemSubtitle!(selectedItem as T)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: isLoading ? null : () => _openSearchSheet(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDisabled ? const Color(0xFFF1F5F9) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: errorText != null
                      ? Colors.redAccent
                      : (isDisabled
                          ? const Color(0xFFE2E8F0)
                          : Colors.transparent),
                  width: errorText != null ? 1.2 : 1,
                ),
              ),
              child: Row(
                children: [
                  if (prefixIcon != null) ...[
                    Icon(
                      prefixIcon,
                      size: 22,
                      color: isDisabled
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDisabled
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (displayText != null)
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  displayText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDisabled
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF111827),
                                  ),
                                ),
                              ),
                              if (subText != null && subText.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F766E).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    subText,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F766E),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          )
                        else
                          Text(
                            isDisabled && disabledHint != null
                                ? disabledHint!
                                : hint,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDisabled
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0F766E),
                      ),
                    )
                  else if (selectedItem != null && onClear != null && !isDisabled)
                    InkWell(
                      onTap: onClear,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: isDisabled
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF64748B),
                    ),
                ],
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text(
                errorText!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchBottomSheet<T> extends StatefulWidget {
  const _SearchBottomSheet({
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.itemTitle,
    this.itemSubtitle,
    required this.itemMatcher,
    required this.onSelected,
  });

  final String title;
  final List<T> items;
  final T? selectedItem;
  final ItemTitleBuilder<T> itemTitle;
  final ItemSubtitleBuilder<T>? itemSubtitle;
  final ItemMatcher<T> itemMatcher;
  final ValueChanged<T> onSelected;

  @override
  State<_SearchBottomSheet<T>> createState() => _SearchBottomSheetState<T>();
}

class _SearchBottomSheetState<T> extends State<_SearchBottomSheet<T>> {
  final TextEditingController _searchController = TextEditingController();
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = List<T>.from(widget.items);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      if (query.trim().isEmpty) {
        _filteredItems = List<T>.from(widget.items);
      } else {
        _filteredItems = widget.items
            .where((item) => widget.itemMatcher(item, query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.78;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF1B1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: Color(0xFF2E3033), width: 1),
          left: BorderSide(color: Color(0xFF2E3033), width: 1),
          right: BorderSide(color: Color(0xFF2E3033), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF475569),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E3033),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_filteredItems.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white70, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'sellerRegister.searchLocationHint'.tr.isEmpty
                    ? 'Search name or বাংলা...'
                    : 'sellerRegister.searchLocationHint'.tr,
                hintStyle: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF2DD4BF),
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: Colors.white60, size: 18),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF111213),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2E3033)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2E3033)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFF2DD4BF), width: 1.2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: _filteredItems.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_off_outlined,
                          size: 40,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'sellerRegister.noLocationsFound'.tr.isEmpty
                              ? 'No locations found'
                              : 'sellerRegister.noLocationsFound'.tr,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: _filteredItems.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFF2E3033)),
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = widget.selectedItem != null &&
                          widget.selectedItem == item;
                      final title = widget.itemTitle(item);
                      final subtitle = widget.itemSubtitle != null
                          ? widget.itemSubtitle!(item)
                          : null;

                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        tileColor: isSelected
                            ? const Color(0xFF0F766E).withOpacity(0.2)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF2DD4BF)
                                : Colors.white,
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w900
                                : FontWeight.w600,
                          ),
                        ),
                        subtitle: subtitle != null && subtitle.isNotEmpty
                            ? Text(
                                subtitle,
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : null,
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF2DD4BF),
                                size: 20,
                              )
                            : null,
                        onTap: () => widget.onSelected(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
