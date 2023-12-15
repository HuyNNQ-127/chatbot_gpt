// ignore_for_file: non_constant_identifier_names
import 'package:chatbot_gpt/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:chatbot_gpt/widgets/chat_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:langchain/langchain.dart';
import 'package:collection/collection.dart';
import 'package:mime/mime.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:dart_openai/dart_openai.dart' as openai;

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
    var collection = FirebaseFirestore.instance.collection('ChatGPT');
    var docSnapshot = await collection.doc('test_instance').get();
    Map<String, dynamic> data = docSnapshot.data()!;

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
      RetrievalQAChain test;
      test = await readFile(data["FilePath"], data["API_Key"], data["Content"]);
      setState(() {
        retrieverQA = test;
      });

      final response = await retrieverQA(msg);
      FirebaseFirestore.instance
          .collection("ChatGPT")
          .doc("test_instance")
          .update({"Document": response.toString()});

      FirebaseFirestore.instance.collection("Summarize").add({
        "text": response["result"].toString(),
        "Index": 1,
        "Timestamp": Timestamp.now(),
      });

      _isTyping = false;
    } catch (error) {
      if (error.toString().endsWith("statusCode: 429}")) {
        if (error is openai.RequestFailedException) {
          FirebaseFirestore.instance.collection("Summarize").add({
            "text": error.message,
            "Index": 1,
            "Timestamp": Timestamp.now(),
          });
        }
      } else {
        final response = await retrieverQA(msg);
        FirebaseFirestore.instance.collection("Summarize").add({
          "text": response["result"].toString(),
          "Index": 1,
          "Timestamp": Timestamp.now(),
        });
      }

      _isTyping = false;
    }
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

  Future<void> uploadFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null) {
      return;
    }

    PlatformFile file = result.files.first;

    final TypePath = lookupMimeType(file.path!);

    var collection = FirebaseFirestore.instance.collection('ChatGPT');
    var docSnapshot = await collection.doc('test_instance').get();
    Map<String, dynamic> data = docSnapshot.data()!;

    await FirebaseFirestore.instance
        .collection("ChatGPT")
        .doc("test_instance")
        .update(
      {
        "_textCorpus": "",
        "Document": "",
      },
    );
    openai.OpenAI.apiKey = data["API_Key"];
    if (TypePath == ("text/plain")) {
      String convertedValue = utf8.decode(file.bytes!);
      await FirebaseFirestore.instance
          .collection("ChatGPT")
          .doc("test_instance")
          .update({"Content": formatString(convertedValue)});
    }

    if (TypePath == "audio/mpeg") {
      openai.OpenAIAudioModel transcription =
          await openai.OpenAI.instance.audio.createTranscription(
        file: File(file.path!),
        model: "whisper-1",
        responseFormat: openai.OpenAIAudioResponseFormat.json,
      );
      await FirebaseFirestore.instance
          .collection("ChatGPT")
          .doc("test_instance")
          .update({"Content": formatString(transcription.text)});
    }

    var document = await collection.doc('test_instance').get();
    Map<String, dynamic> embed = document.data()!;

    retrieverQA =
        await readFile(file.path!, embed["API_Key"], embed["Content"]);
  }

  void _newHomeScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const HomeScreen()));
  }

  Future<RetrievalQAChain> readFile(
      String Path, String API, String content) async {
    FirebaseFirestore.instance
        .collection("ChatGPT")
        .doc("test_instance")
        .update({"FilePath": Path});
    List<Document> documents = [];
    if (content.isNotEmpty) {
      documents.add(
          Document(pageContent: content, metadata: const {"source": "local"}));
    }

    const textSplitter = CharacterTextSplitter(
      chunkSize: 500,
      chunkOverlap: 0,
    );
    final texts = textSplitter.splitDocuments(documents);
    final textsWithSources = texts
        .mapIndexed(
          (final index, final doc) => doc.copyWith(
            metadata: {
              ...doc.metadata,
              'source': '$index-pl',
            },
          ),
        )
        .toList(growable: false);
    final embeddings = OpenAIEmbeddings(apiKey: API);
    final docSearch = await MemoryVectorStore.fromDocuments(
      documents: textsWithSources,
      embeddings: embeddings,
    );

    final chatgpt = ChatOpenAI(
      apiKey: API,
      model: 'gpt-3.5-turbo-0613',
      temperature: 1,
    );

    final qaChain = OpenAIQAWithSourcesChain(llm: chatgpt);
    final docPrompt = PromptTemplate.fromTemplate('content: {page_content}');
    final finalQAChain = StuffDocumentsChain(
      llmChain: qaChain,
      documentPrompt: docPrompt,
    );

    return RetrievalQAChain(
      retriever: docSearch.asRetriever(),
      combineDocumentsChain: finalQAChain,
    );
  }

  String formatString(String input) {
    List<String> sentences = input.split(RegExp(r'(?<=[.!?])'));
    List<String> lines = [];
    String currentLine = '';

    for (String sentence in sentences) {
      String updatedSentence = sentence.trim();

      if (currentLine.isEmpty) {
        currentLine = updatedSentence;
      } else if ((currentLine.length + 1 + updatedSentence.length) <= 1650) {
        currentLine += ' ' + updatedSentence;
      } else {
        lines.add(currentLine);
        currentLine = updatedSentence;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }
    return lines.join('\n\n');
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
                          uploadFile();
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
