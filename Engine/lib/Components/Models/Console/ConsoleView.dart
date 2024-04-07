// ignore_for_file: file_names, prefer_const_constructors, unnecessary_this, must_be_immutable
import 'package:engine/Components/Message/Message.dart';
import 'package:engine/Components/Message/MessageWrapper.dart';
import 'package:engine/Components/Models/Console/MessageProvider.dart';
import 'package:engine/api/Kernel.dart';
import 'package:engine/api/Shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConsoleView extends StatefulWidget implements Shell {
  ConsoleView({
    super.key,
    required this.context,
    required this.scrollController,
  }) {
    Kernel.gui = this;
  }

  final ScrollController scrollController;

  @override
  State<ConsoleView> createState() => _ConsoleViewState();

  final BuildContext context;

  @override
  void clearMessage() {
    Provider.of<MessageModel>(context, listen: false).clearMessage();
    return;
  }

  @override
  void sendMessage(String message) {
    Provider.of<MessageModel>(context, listen: false).sendMessage(message);
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    return;
  }

  @override
  void changeLoadingStatus() {
    Provider.of<MessageModel>(context, listen: false).changeLoadingStatus();
    return;
  }
}

class _ConsoleViewState extends State<ConsoleView> {
  Widget _makeExpanderCard(BuildContext context, MessageWrapper e) {
    if (e.message != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              e.message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          ...Provider.of<MessageModel>(context).messages.map(
                (MessageWrapper e) => Container(
                  margin: const EdgeInsets.only(
                    left: 5.0,
                    right: 5.0,
                  ),
                  child: Message(
                    title: Column(
                      children: <Widget>[
                        Row(
                          children: [
                            IgnorePointer(child: Icon(e.icon, size: 18.0)),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Text(
                                e.title,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3.0),
                        _makeExpanderCard(context, e)
                      ],
                    ),
                    baseColor: e.color != null
                        ? e.color!
                        : Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 5.0,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
