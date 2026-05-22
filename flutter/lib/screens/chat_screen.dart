import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/finance_scaffold.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
        text:
            'Hello! I am your AI Finance Assistant. I can help you analyze your spending or log new transactions for you. How can I help today?',
        fromUser: false),
  ];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();
    final hasKey = appState.aiApiKey != null && appState.aiApiKey!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Chat', style: TextStyle(fontSize: 20.r(context), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Responsive.constrained(
          context,
          Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16.r(context), 8.r(context), 16.r(context), 16.r(context)),
                  reverse: false,
                  children: [
                    Wrap(
                      spacing: 8.r(context),
                      children: [
                        ActionChip(
                            label: Text('Balance', style: TextStyle(fontSize: 12.r(context))),
                            onPressed: () => _sendQuick(appState, 'What is my current balance?')),
                        ActionChip(
                            label: Text('Monthly expense', style: TextStyle(fontSize: 12.r(context))),
                            onPressed: () => _sendQuick(appState, 'How much did I spend this month?')),
                        ActionChip(
                            label: Text('Budgets', style: TextStyle(fontSize: 12.r(context))),
                            onPressed: () => _sendQuick(appState, 'What is my budget status?')),
                      ],
                    ),
                    SizedBox(height: 12.r(context)),
                    ..._messages.map((message) => Align(
                          alignment: message.fromUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10.r(context)),
                            padding: EdgeInsets.all(14.r(context)),
                            constraints: BoxConstraints(maxWidth: 300.r(context)),
                            decoration: BoxDecoration(
                              color: message.fromUser
                                  ? AppColors.purple
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20.r(context)),
                              border: message.fromUser
                                  ? null
                                  : Border.all(color: AppColors.darkBorder),
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15.r(context),
                                height: 1.3,
                              ),
                            ),
                          ),
                        )),
                    if (_loading)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10.r(context)),
                          padding: EdgeInsets.all(14.r(context)),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20.r(context)),
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: SizedBox(
                            width: 18.r(context),
                            height: 18.r(context),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.purple),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!hasKey)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 8.r(context)),
                  child: FinanceCard(
                    padding: EdgeInsets.all(16.r(context)),
                    child: Column(
                      children: [
                        Text(
                          'Gemini API Key is not configured. Please add your key in Settings to start chatting.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceMono(
                              color: AppColors.textSecondary,
                              fontSize: 14.r(context)),
                        ),
                        SizedBox(height: 12.r(context)),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.purple,
                            padding: EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 12.r(context)),
                          ),
                          onPressed: () => Navigator.of(context).pushNamed('/settings'),
                          icon: Icon(Icons.settings, size: 20.r(context)),
                          label: Text('Go to Settings', style: TextStyle(fontSize: 14.r(context))),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.r(context), 8.r(context), 16.r(context), 16.r(context)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: hasKey && !_loading,
                        style: TextStyle(fontSize: 14.r(context), color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: hasKey ? 'Ask about your finance...' : 'Configure API Key in settings',
                          labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14.r(context)),
                          filled: true,
                          fillColor: AppColors.darkCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.r(context)),
                            borderSide: const BorderSide(color: AppColors.darkBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.r(context)),
                            borderSide: const BorderSide(color: AppColors.darkBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.r(context)),
                            borderSide: const BorderSide(color: AppColors.purple),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20.r(context), vertical: 14.r(context)),
                        ),
                        onSubmitted: (_) => _send(appState),
                      ),
                    ),
                    SizedBox(width: 8.r(context)),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.all(12.r(context)),
                      ),
                      onPressed: hasKey && !_loading ? () => _send(appState) : null,
                      icon: Icon(Icons.send, size: 20.r(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendQuick(AppStateModel appState, String text) {
    if (_loading) return;
    _controller.text = text;
    _send(appState);
  }

  Future<void> _send(AppStateModel appState) async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: prompt, fromUser: true));
      _controller.clear();
      _loading = true;
    });

    final apiKey = appState.aiApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _messages.add(_ChatMessage(
          text: 'API Key is not configured. Please add it in Settings.',
          fromUser: false,
        ));
        _loading = false;
      });
      return;
    }

    try {
      final systemInstruction = '''
You are an expert AI personal finance advisor.
The user has the following categories: ${appState.categories.map((c) => '{"id": "${c.id}", "name": "${c.name}"}').join(', ')}
The user has the following sources: ${appState.sources.map((s) => '{"id": "${s.id}", "name": "${s.name}"}').join(', ')}
The user has the following recent transactions: ${appState.transactions.take(20).map((t) => '{"id": "${t.id}", "amount": ${t.amount}, "type": "${t.type}", "category": "${t.category}", "description": "${t.description}", "date": "${t.date}"}').join(', ')}

Important Guidelines:
1. When asked about spending, analyze the transactions and provide actionable insights or summaries. Use simple bullet points (-) for readability.
2. Keep your answers concise but highly valuable. Point out any trends you see.
3. If the user asks to add or delete a transaction, call the appropriate function using the strictly correct IDs.
''';

      final addTransactionParams = Schema.object(
        properties: {
          'amount': Schema.number(description: 'Amount of the transaction'),
          'type': Schema.enumString(enumValues: ['expense', 'income', 'borrow', 'lend'], description: 'Type of transaction'),
          'categoryId': Schema.string(description: 'Category ID. Must strictly match one of the available category IDs.'),
          'sourceId': Schema.string(description: 'Source ID. Must strictly match one of the available source IDs.'),
          'description': Schema.string(description: 'Short note or description'),
        },
        requiredProperties: ['amount', 'type', 'categoryId', 'sourceId', 'description'],
      );

      final deleteTransactionParams = Schema.object(
        properties: {
          'id': Schema.string(description: 'ID of the transaction to delete.'),
        },
        requiredProperties: ['id'],
      );

      final tools = [
        Tool(
          functionDeclarations: [
            FunctionDeclaration(
              'addTransaction',
              'Add a new transaction (expense, income, etc) to the database.',
              addTransactionParams,
            ),
            FunctionDeclaration(
              'deleteTransaction',
              'Delete a transaction by its ID.',
              deleteTransactionParams,
            ),
          ],
        )
      ];

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(systemInstruction),
        tools: tools,
      );

      final history = _messages
          .skip(1)
          .take(_messages.length - 2)
          .map((m) {
            return Content(
              m.fromUser ? 'user' : 'model',
              [TextPart(m.text)],
            );
          })
          .toList();

      final chat = model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(prompt));

      String aiTextResponse = '';
      Iterable<FunctionCall> functionCalls = [];
      try {
        functionCalls = response.functionCalls;
      } catch (_) {
        if (response.candidates.isNotEmpty) {
          functionCalls = response.candidates.first.content.parts.whereType<FunctionCall>();
        }
      }

      if (functionCalls.isNotEmpty) {
        final call = functionCalls.first;
        if (call.name == 'addTransaction') {
          final args = call.args;
          final amount = (args['amount'] as num).toDouble();
          final type = args['type'] as String;
          final categoryId = args['categoryId'] as String;
          final sourceId = args['sourceId'] as String;
          final description = args['description'] as String;

          await appState.addTransaction(TransactionModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            amount: amount,
            category: categoryId,
            source: sourceId,
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            description: description,
            type: type,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ));

          aiTextResponse = 'I have successfully added the transaction: $type of $amount for $description.';
        } else if (call.name == 'deleteTransaction') {
          final args = call.args;
          final id = args['id'] as String;
          await appState.removeTransaction(id);
          aiTextResponse = 'I have deleted the transaction with ID $id.';
        }
      } else {
        aiTextResponse = response.text ?? 'I could not generate a response.';
      }

      setState(() {
        _messages.add(_ChatMessage(text: aiTextResponse, fromUser: false));
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          text: 'Sorry, I encountered an error. Please check your API Key and internet connection. ($e)',
          fromUser: false,
        ));
        _loading = false;
      });
    }
  }
}

class _ChatMessage {
  final String text;
  final bool fromUser;

  _ChatMessage({required this.text, required this.fromUser});
}
