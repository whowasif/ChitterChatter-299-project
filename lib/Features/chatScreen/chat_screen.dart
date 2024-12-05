import 'dart:io';
import 'dart:convert';
import 'package:chitter_chatter/Features/chatScreen/message_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:chitter_chatter/common_utils/widgets/colors.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final String userId;

  const ChatScreen({super.key, required this.userId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final String senderId = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool _isEmojiPickerVisible = false;
  bool _isInChatScreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeChatStatus();
    _initializeChatListEntry();
  }

  Future<void> _initializeChatStatus() async {
    _isInChatScreen = true;
    await _updateUserChatStatus(true);
  }

  Future<void> _updateUserChatStatus(bool isInChat) async {
    if (senderId.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .update({
        'isOnline': isInChat,
        'lastSeen': FieldValue.serverTimestamp(),
        'currentChatWith': isInChat ? widget.userId : null,
      });
    } catch (e) {
      print("Error updating chat status: $e");
    }
  }

  ///////////////////////////////////////////////Updating contacts list logic/////////////////////////
  Future<void> _initializeChatListEntry() async {
    try {
      final recipientChatListRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('chatList')
          .where('userId', isEqualTo: senderId)
          .limit(1);

      final senderChatListRef = FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .collection('chatList')
          .where('userId', isEqualTo: widget.userId)
          .limit(1);

      // Initialize recipient's chat list entry
      final recipientSnapshot = await recipientChatListRef.get();
      if (recipientSnapshot.docs.isEmpty) {
        final currentUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(senderId)
            .get();

        final currentUserData = currentUserDoc.data();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('chatList')
            .add({
          'userId': senderId,
          'name': currentUserData?['name'] ?? 'Unknown',
          'profilePic': currentUserData?['profilePicture'] ?? '',
          'hasUnreadMessages': false,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else if (!recipientSnapshot.docs.first
          .data()
          .containsKey('hasUnreadMessages')) {
        await recipientSnapshot.docs.first.reference.set({
          'hasUnreadMessages': false,
        }, SetOptions(merge: true));
      }

      // Initialize sender's chat list entry
      final senderSnapshot = await senderChatListRef.get();
      if (senderSnapshot.docs.isEmpty) {
        final recipientDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();

        final recipientData = recipientDoc.data();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(senderId)
            .collection('chatList')
            .add({
          'userId': widget.userId,
          'name': recipientData?['name'] ?? 'Unknown',
          'profilePic': recipientData?['profilePicture'] ?? '',
          'hasUnreadMessages': false,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else if (!senderSnapshot.docs.first
          .data()
          .containsKey('hasUnreadMessages')) {
        await senderSnapshot.docs.first.reference.set({
          'hasUnreadMessages': false,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error initializing chat list entries: $e");
    }
  }

  Future<void> _updateRecipientChatList() async {
    try {
      final recipientChatListRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('chatList')
          .where('userId', isEqualTo: senderId)
          .limit(1);

      final snapshot = await recipientChatListRef.get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'hasUnreadMessages': true,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        // If chat list entry doesn't exist, create it with initialization
        await _initializeChatListEntry();
        // Then update it with unread message
        final newSnapshot = await recipientChatListRef.get();
        if (newSnapshot.docs.isNotEmpty) {
          await newSnapshot.docs.first.reference.update({
            'hasUnreadMessages': true,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print("Error updating recipient chat list: $e");
    }
  }

  //////////////////////////////////////////Ends here/////////////////////////////
  @override
  void dispose() {
    _isInChatScreen = false;
    _updateUserChatStatus(false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _updateUserChatStatus(false);
    } else if (state == AppLifecycleState.resumed && _isInChatScreen) {
      _updateUserChatStatus(true);
    }
  }

  Stream<DocumentSnapshot> userStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  Future<dynamic> decodeBase64Image(String base64Image) async {
    try {
      return base64Decode(base64Image);
    } catch (e) {
      print("Error decoding image: $e");
      return null;
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final timestamp = Timestamp.now();
    final chatId = widget.userId;

    try {
      await FirebaseFirestore.instance.collection('chats').add({
        'senderId': senderId,
        'receiverId': chatId,
        'message': message.trim(),
        'timestamp': timestamp,
        'participants': [senderId, chatId],
      });
      await _updateRecipientChatList();
      _messageController.clear();
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  void toggleEmojiPicker() {
    setState(() {
      _isEmojiPickerVisible = !_isEmojiPickerVisible;
    });
  }

  String _formatLastSeen(Timestamp lastSeen) {
    final now = DateTime.now();
    final lastSeenDate = lastSeen.toDate();
    final difference = now.difference(lastSeenDate);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastSeenDate.day}/${lastSeenDate.month}/${lastSeenDate.year}';
    }
  }

  Future<void> sendPhoto() async {
    try {
      Uint8List? imageBytes;

      if (kIsWeb) {
        // Use FilePicker for web
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result == null || result.files.isEmpty) return;
        imageBytes = result.files.single.bytes; // Get the bytes directly
      } else {
        // Use ImagePicker for mobile
        final XFile? pickedFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile == null) return;

        // Read the file
        final File file = File(pickedFile.path);
        imageBytes = await file.readAsBytes(); // Read file as bytes
      }

      if (imageBytes == null) return;

      // Encode the image to base64
      final String base64Image = base64Encode(imageBytes);

      // Send the base64 image as a message
      await FirebaseFirestore.instance.collection('chats').add({
        'senderId': senderId,
        'receiverId': widget.userId,
        'message': 'photo',
        'base64Image': base64Image,
        'timestamp': Timestamp.now(),
        'participants': [senderId, widget.userId],
      });
      await _updateRecipientChatList();
    } catch (e) {
      print("Error sending photo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _updateUserChatStatus(false);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          leading: BackButton(
            color: Colors.grey,
            onPressed: () async {
              await _updateUserChatStatus(false);
              Navigator.pop(context);
            },
          ),
          title: StreamBuilder<DocumentSnapshot>(
            stream: userStream(widget.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Text("User not found");
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final bool isOnline = userData['isOnline'] ?? false;
              final String? chatWith = userData['currentChatWith'];
              final bool isChattingWithMe = chatWith == senderId;
              final String base64ProfilePic = userData['profilePicture'] ?? '';
              final Timestamp? lastSeen = userData['lastSeen'] as Timestamp?;

              // Determine real-time status
              final bool isActiveInChat = isOnline && isChattingWithMe;

              return Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: base64ProfilePic.isEmpty
                        ? const NetworkImage(
                            'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                          )
                        : MemoryImage(base64Decode(base64ProfilePic))
                            as ImageProvider,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userData['name']?.toString() ?? 'Unknown',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    isActiveInChat ? Colors.green : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isActiveInChat
                                  ? "online"
                                  : lastSeen != null
                                      ? "last seen ${_formatLastSeen(lastSeen)}"
                                      : "offline",
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isActiveInChat ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MessageSearch(currentUserId: senderId)),
                      );
                    },
                    icon: const Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                  ),
                ],
              );
            },
          ),
          elevation: 1,
        ),
        body: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/chatbg2.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!.docs.where((message) {
                        final participants =
                            message['participants'] as List<dynamic>;
                        return participants.contains(senderId) &&
                            participants.contains(widget.userId);
                      }).toList();

                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final bool isSender = message['senderId'] == senderId;

                          if (message['message'] == 'photo' &&
                              message['base64Image'] != null) {
                            return Align(
                              alignment: isSender
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 8.0,
                                ),
                                child: Image.memory(
                                  base64Decode(message['base64Image']),
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }

                          // Display text messages
                          return Align(
                            alignment: isSender
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 8.0,
                              ),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: isSender
                                    ? Colors.green.shade600
                                    : Colors.purple.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['message'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('hh:mm a').format(
                                      (message['timestamp'] as Timestamp)
                                          .toDate(),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: mobileChatBoxColor,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: mobileChatBoxColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Emoji Picker Icon
                            IconButton(
                              onPressed: toggleEmojiPicker,
                              icon: const Icon(
                                Icons.emoji_emotions,
                                color: Colors.grey,
                              ),
                            ),
                            // File Attachment Icon
                            IconButton(
                              onPressed:
                                  sendPhoto, // Calls the function to attach/send files
                              icon: const Icon(
                                Icons.attach_file,
                                color: Colors.grey,
                              ),
                            ),
                            // Message Input Field
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: const InputDecoration(
                                  hintText: "Type a message here",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                cursorColor: Colors.grey,
                              ),
                            ),
                            // Send Icon
                            IconButton(
                              onPressed: () =>
                                  sendMessage(_messageController.text),
                              icon: const Icon(
                                Icons.send,
                                color: tabColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Emoji Picker Display
                      if (_isEmojiPickerVisible)
                        Container(
                          color: Colors.white,
                          child: SizedBox(
                            height: 250,
                            child: EmojiPicker(
                              onEmojiSelected: (category, emoji) {
                                setState(() {
                                  _messageController.text += emoji.emoji;
                                });
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
