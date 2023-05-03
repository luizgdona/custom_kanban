import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Provider/provider_list.dart';
import '../models/item_state.dart';

class Item extends ConsumerStatefulWidget {
  const Item({
    super.key,
    required this.itemIndex,
    this.color = Colors.pink,
    required this.listIndex,
  });
  final int itemIndex;
  final int listIndex;
  final Color color;
  @override
  ConsumerState<Item> createState() => _ItemState();
}

class _ItemState extends ConsumerState<Item> {
  Offset location = Offset.zero;
  bool newAdded = false;
  var node = FocusNode();
  @override
  Widget build(BuildContext context) {
    // log("BUILDED ${widget.itemIndex}");
    var prov = ref.read(ProviderList.reorderProvider.notifier);
    var cardProv = ref.read(ProviderList.cardProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      cardProv.calculateCardPositionSize(
          listIndex: widget.listIndex,
          itemIndex: widget.itemIndex,
          context: context,
          setsate: () => {setState(() {})});
    });
    return ValueListenableBuilder(
        valueListenable: prov.valueNotifier,
        builder: (ctx, a, b) {
          if (prov.board.isElementDragged == true) {
            // item added by system in empty list, its widget/UI should not be manipulated on movements //
            if (prov.board.lists[widget.listIndex].items.isEmpty) return b!;

            // CALCULATE SIZE AND POSITION OF ITEM //
            if (cardProv.calculateSizePosition(
                listIndex: widget.listIndex, itemIndex: widget.itemIndex)) {
              return b!;
            }
            // DO NOT COMPARE ANYTHING WITH DRAGGED ITEM, IT WILL CAUSE ERRORS BECUSE ITS HIDDEN //
            if ((prov.draggedItemState!.itemIndex == widget.itemIndex &&
                prov.draggedItemState!.listIndex == widget.listIndex)) {
              //log("DRAGGED ITEM RETURNED ${widget.itemIndex}");
              return b!;
            }

            if (cardProv.getYAxisCondition(
                listIndex: widget.listIndex, itemIndex: widget.itemIndex)) {
              cardProv.checkForYAxisMovement(
                  listIndex: widget.listIndex, itemIndex: widget.itemIndex);
            } else if (cardProv.getXAxisCondition(
                listIndex: widget.listIndex, itemIndex: widget.itemIndex)) {
              cardProv.checkForXAxisMovement(
                  listIndex: widget.listIndex, itemIndex: widget.itemIndex);
            }
          }
          return b!;
        },
        child: GestureDetector(
          onLongPress: () {
            cardProv.onLongpressCard(
                listIndex: widget.listIndex,
                itemIndex: widget.itemIndex,
                context: context,
                setsate: () => {setState(() {})});
          },
          child: prov.board.isElementDragged &&
                  prov.board.dragItemIndex == widget.itemIndex &&
                  prov.draggedItemState!.itemIndex == widget.itemIndex &&
                  prov.draggedItemState!.listIndex == widget.listIndex &&
                  prov.board.dragItemOfListIndex! == widget.listIndex
              ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(6),
                    color: prov.board.lists[widget.listIndex]
                            .items[widget.itemIndex].backgroundColor ??
                        Colors.white,
                  ),
                  margin: const EdgeInsets.only(
                      bottom: 15, left: 10, right: 10, top: 15),
                  width: prov.board.lists[widget.listIndex]
                      .items[widget.itemIndex].actualSize!.width,
                  height: prov.board.lists[widget.listIndex]
                      .items[widget.itemIndex].actualSize!.height,
                )
              : cardProv.isCurrentElementDragged(
                      listIndex: widget.listIndex, itemIndex: widget.itemIndex)
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(6),
                        color: prov.board.lists[widget.listIndex]
                                .items[widget.itemIndex].backgroundColor ??
                            Colors.white,
                      ),
                      width: prov.board.lists[widget.listIndex]
                          .items[widget.itemIndex].width,
                    )
                  : SizedBox(
                      width: prov.board.lists[widget.listIndex]
                          .items[widget.itemIndex].width,
                      child: prov.board.lists[widget.listIndex]
                          .items[widget.itemIndex].child,
                    ),
        ));
  }
}
