#CHATGPT POWERED CHATBOT

An application that utilize OpenAI's ChatGPT-3.5 LLM in order to summarize content

Created during Brycen Internship program

 
## Screenshots

|  Home Menu                                  |  Chat Screen                     | Summarize Screen                                 |
|---------------------------------------------|----------------------------------|---------------------------------------------------|
|![Home UI](https://github.com/HuyNNQ-127/chatbot_gpt/blob/master/assets/Screenshot_1692008153.png) |![Chat UI](https://github.com/HuyNNQ-127/chatbot_gpt/blob/master/assets/Screenshot_1692008684.png)  | ![Summarize UI](https://github.com/HuyNNQ-127/chatbot_gpt/blob/master/assets/Screenshot_1692008691.png) |

## Feature!
-Having engaging conversations with OpenAI's ChatGPT 3.5 LLM model

-Summarize key infomation from text files and audio files and ask questions about them!

# HOW TO RUN THIS APP 

## I. Prerequisites

- **INSTALLED:**  [Flutter](https://docs.flutter.dev/get-started/install) (v.3.10.5), [VSCode](https://code.visualstudio.com/) (v1.81.1), [Git](https://git-scm.com/downloads) (v2.41.0)
- **OPENAI API KEY:**  You must have an OpenAI API key in order to use this application. You can obtain a key on this website [OpenAI](http://api.openai.com/v1/models) (Required an OpenAI account)


## II. Setup the application
### 1. Using Git to clone the project into your computer

- Goto the folder where you want to place the app.
- Open git by enter cmd into the address bar of the folder and then type:

```bash
git clone https://github.com/HuyNNQ-127/chatbot_gpt/
```
- Once git have finished pulling the code, open your project terminal in VSCode, then type:
```bash
flutter pub get
```
### 2. Setup Firebase
- Using the link right below to setup flutterfire: 
```bash
https://firebase.google.com/docs/flutter/setup?hl=vi&platform=web
```
## Step 1: Create your Firebase project
![initProject]([https://github.com/HuyNNQ-127/chatbot_gpt/blob/master/assets/Screenshot_1692008691.png](https://github.com/thequang-ntq/Chatbot-Summary-ntq/blob/master/assets/files/createProject.gif))

## Step 2: Setup Firebase CLI
-Install [NodeJS](https://nodejs.org/en) 
-Install the Firebase CLI via npm by running the following command:
```bash
npm install -g firebase-tools
```
-Continue to log in and test the CLI using command:
```bash
firebase login
```

### 3. Setup FlutterFire
-Install the FlutterFire CLI by running the following command from any directory:
```bash
dart pub global activate flutterfire_cli
```
-From your Flutter project directory, run the following command to start the app configuration workflow:
```bash
flutterfire configure
```
-From your Flutter project directory, run the following command to install the core plugin:
```bash
flutter pub add firebase_core
```
-From your Flutter project directory, run the following command to ensure that your Flutter app's Firebase configuration is up-to-date:
```bash
flutterfire configure
```

## Acknowledgements

This application was built using the following open-source libraries and tools:

* [Flutter](https://flutter.dev/)
* [Dart](https://dart.dev/)
* [Dart openAi](https://pub.dev/packages/dart_openai)
* [Text To Speech](https://pub.dev/packages/flutter_tts)
* [Speech To Text](https://pub.dev/packages/speech_to_text)
* [LangChain](https://pub.dev/packages/langchain)
* [LangChain OpenAI](https://pub.dev/packages/langchain_openai/versions)
* [File Picker](https://pub.dev/packages/file_picker)
