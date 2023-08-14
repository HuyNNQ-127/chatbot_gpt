// ignore_for_file: non_constant_identifier_names
import 'package:chatbot_gpt/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:chatbot_gpt/widgets/chat_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:langchain/langchain.dart';
import 'package:collection/collection.dart';
import 'package:langchain_openai/langchain_openai.dart';

class SummarizeScreen extends StatefulWidget {
  const SummarizeScreen({super.key});

  @override
  State<SummarizeScreen> createState() {
    return _SummarizeScreenState();
  }
}

class _SummarizeScreenState extends State<SummarizeScreen> {
  bool _isTyping = false;
  bool _speaking = false;
  late SpeechToText _speechTransform;
  String _checkconnect = "true";
  late RetrievalQAChain retrieverQA;
  late TextEditingController textEditingController;
  dynamic textsWithSources = {};

  @override
  void initState() {
    textEditingController = TextEditingController();
    _speechTransform = SpeechToText();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    String msg = textEditingController.text;

    if (textEditingController.text.trim().isEmpty) {
      return;
    }
    if (_speaking) {
      setState(() {
        _speaking = false;
        _speechTransform.stop();
      });
    }

    _isTyping = true;
    textEditingController.clear();

    FirebaseFirestore.instance.collection("Summarize").add({
      "text": msg,
      "Index": 0,
      "Timestamp": Timestamp.now(),
    });

    try {
      final res = await retrieverQA(msg);
      FirebaseFirestore.instance
          .collection("ChatGPT")
          .doc("test_instance")
          .update({"_textCorpus": res.toString()});

      FirebaseFirestore.instance.collection("Summarize").add({
        "text": res["result"].toString(),
        "Index": 1,
        "Timestamp": Timestamp.now(),
      });

      _isTyping = false;
    } catch (e) {
      if (e.toString().endsWith("statusCode: 429}")) {
        FirebaseFirestore.instance.collection("chatSummarize").add({
          "text":
              "Giới hạn câu hỏi 3 câu hỏi / 1 phút. Vui lòng thêm thanh toán hoặc đợi 20 giây.",
          "createdAt": Timestamp.now(),
          "Index": 1,
        });
      } else {
        FirebaseFirestore.instance.collection("chatSummarize").add({
          "text": "Câu hỏi của bạn không có trong tài liệu",
          "createdAt": Timestamp.now(),
          "Index": 1,
        });
      }

      _isTyping = false;
    }

    var collection_1 = FirebaseFirestore.instance.collection('Conversation');
    var docSnapshot_1 = await collection_1.doc('Chatbox').get();
    Map<String, dynamic> summary = docSnapshot_1.data()!;

    String conversation = summary["Total_conversation"].toString();
  }

  void _Listen() async {
    var collection = FirebaseFirestore.instance.collection('ChatGPT');
    var docSnapshot = await collection.doc('test_instance').get();
    Map<String, dynamic> data = docSnapshot.data()!;
    _checkconnect = data["_isConnect"];
    if (!_speaking) {
      bool availability = await _speechTransform.initialize(
        onStatus: (value) {
          print("OnStatus: $value");
          if (value == "done") {
            setState(() {
              _speaking = false;
              _speechTransform.stop();
            });
          }
        },
        onError: (value) => print("error: $value"),
      );

      if (availability) {
        setState(() {
          _speaking = true;
        });

        _speechTransform.listen(
          localeId: "vi_VN",
          listenFor: const Duration(seconds: 60),
          onResult: (value) => setState(() {
            textEditingController.text = value.recognizedWords;
            if (_isTyping == true) {
              textEditingController.clear();
            }
          }),
        );
      } else {
        setState(() {
          _speaking = false;
          _speechTransform.stop();
        });
      }
    }
  }

  void _newHomeScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Summarize")
          .orderBy(
            "Timestamp",
            descending: true,
          )
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting &&
            _checkconnect == "true") {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final loadedMessages = chatSnapshots.data!.docs;
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                if (loadedMessages.isEmpty)
                  Expanded(
                    child: Center(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          var collection_1 =
                              FirebaseFirestore.instance.collection('ChatGPT');
                          var docSnapshot_1 =
                              await collection_1.doc('test_instance').get();
                          Map<String, dynamic> data_1 = docSnapshot_1.data()!;

                          final result = await FilePicker.platform
                              .pickFiles(withData: true);

                          if (result == null) {
                            return;
                          }

                          PlatformFile file = result.files.first;
                          TextLoader loader = TextLoader(file.path!);
                          final docs = await loader.load();

                          const splittingText = CharacterTextSplitter(
                            chunkSize: 500,
                            chunkOverlap: 0,
                          );
                          final texts = splittingText.splitDocuments(docs);
                          textsWithSources = texts
                              .mapIndexed(
                                (final i, final d) => d.copyWith(
                                  metadata: {
                                    ...d.metadata,
                                    'source': '$i-pl',
                                  },
                                ),
                              )
                              .toList();

                          dynamic embedding =
                              OpenAIEmbeddings(apiKey: data_1["API_Key"]);
                          dynamic docSearch =
                              await MemoryVectorStore.fromDocuments(
                            documents: textsWithSources,
                            embeddings: embedding,
                          );
                          final chatgpt = ChatOpenAI(
                            model: "gpt-3.5-turbo",
                            temperature: 1.0,
                            apiKey: data_1["API_Key"],
                          );

                          final qaChain =
                              OpenAIQAWithSourcesChain(llm: chatgpt);

                          final docPrompt = PromptTemplate.fromTemplate(
                            'You will be given a text document\n Answer based on the language of the question \n If you cannot find an answer related to the text, answer:"Không có dữ liệu về câu hỏi trong tài liệu!". ',
                            //'content: {page_content}\nSource: {source}',
                          );

                          final finalQAChain = StuffDocumentsChain(
                            llmChain: qaChain,
                            documentPrompt: docPrompt,
                          );

                          retrieverQA = RetrievalQAChain(
                            retriever: docSearch.asRetriever(),
                            combineDocumentsChain: finalQAChain,
                          );
                        },
                        icon: const Icon(
                          Icons.upload_file_outlined,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Upload File",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      reverse: true,
                      itemCount: loadedMessages.length,
                      itemBuilder: (context, index) {
                        final chatMessage = loadedMessages[index].data();
                        return ChatWidget(
                          message: chatMessage["text"],
                          chatIndex: chatMessage["Index"],
                        );
                      },
                    ),
                  ),
                if (_isTyping) ...[
                  const SpinKitThreeBounce(
                    color: Colors.white,
                    size: 18,
                  ),
                ],
                const SizedBox(
                  height: 15,
                ),
                Material(
                  color: const Color(0xFF444654),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            controller: textEditingController,
                            onSubmitted: (value) {
                              _submitMessage();
                            },
                            maxLines: null,
                            decoration: const InputDecoration.collapsed(
                                hintText: "Enter text here!",
                                hintStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _Listen(),
                          icon: Icon(
                            _speaking ? Icons.mic : Icons.mic_off,
                            color: _speaking
                                ? const Color.fromARGB(255, 19, 164, 232)
                                : Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: _submitMessage,
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
