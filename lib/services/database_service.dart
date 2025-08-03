import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'chat_history.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Conversations table
    await db.execute('''
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        metadata TEXT
      )
    ''');

    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL,
        text TEXT NOT NULL,
        is_user INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        status INTEGER NOT NULL,
        type INTEGER NOT NULL,
        metadata TEXT,
        FOREIGN KEY (conversation_id) REFERENCES conversations (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_messages_conversation_id ON messages(conversation_id)');
    await db.execute('CREATE INDEX idx_messages_timestamp ON messages(timestamp)');
    await db.execute('CREATE INDEX idx_conversations_updated_at ON conversations(updated_at)');
  }

  // Conversation methods
  Future<String> createConversation(String title) async {
    final db = await database;
    final conversation = Conversation(title: title);
    
    await db.insert('conversations', {
      'id': conversation.id,
      'title': conversation.title,
      'created_at': conversation.createdAt.millisecondsSinceEpoch,
      'updated_at': conversation.updatedAt.millisecondsSinceEpoch,
      'metadata': null,
    });
    
    return conversation.id;
  }

  Future<List<Conversation>> getConversations({int? limit, int? offset}) async {
    final db = await database;
    
    String query = '''
      SELECT c.*, COUNT(m.id) as message_count
      FROM conversations c
      LEFT JOIN messages m ON c.id = m.conversation_id
      GROUP BY c.id
      ORDER BY c.updated_at DESC
    ''';
    
    if (limit != null) {
      query += ' LIMIT $limit';
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }
    
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    
    final List<Conversation> conversations = [];
    for (final map in maps) {
      final messages = await getMessagesForConversation(map['id']);
      conversations.add(Conversation(
        id: map['id'],
        title: map['title'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
        messages: messages,
      ));
    }
    
    return conversations;
  }

  Future<Conversation?> getConversation(String id) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    
    final map = maps.first;
    final messages = await getMessagesForConversation(id);
    
    return Conversation(
      id: map['id'],
      title: map['title'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      messages: messages,
    );
  }

  Future<void> updateConversation(Conversation conversation) async {
    final db = await database;
    
    await db.update(
      'conversations',
      {
        'title': conversation.title,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [conversation.id],
    );
  }

  Future<void> deleteConversation(String id) async {
    final db = await database;
    
    await db.transaction((txn) async {
      await txn.delete('messages', where: 'conversation_id = ?', whereArgs: [id]);
      await txn.delete('conversations', where: 'id = ?', whereArgs: [id]);
    });
  }

  // Message methods
  Future<void> insertMessage(ChatMessage message) async {
    final db = await database;
    
    await db.insert('messages', {
      'id': message.id,
      'conversation_id': message.conversationId,
      'text': message.text,
      'is_user': message.isUser ? 1 : 0,
      'timestamp': message.timestamp.millisecondsSinceEpoch,
      'status': message.status.index,
      'type': message.type.index,
      'metadata': null,
    });

    // Update conversation's updated_at timestamp
    if (message.conversationId != null) {
      await db.update(
        'conversations',
        {'updated_at': message.timestamp.millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [message.conversationId],
      );
    }
  }

  Future<List<ChatMessage>> getMessagesForConversation(String conversationId) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );
    
    return maps.map((map) => ChatMessage(
      id: map['id'],
      text: map['text'],
      isUser: map['is_user'] == 1,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      status: MessageStatus.values[map['status']],
      type: MessageType.values[map['type']],
      conversationId: map['conversation_id'],
    )).toList();
  }

  Future<void> updateMessage(ChatMessage message) async {
    final db = await database;
    
    await db.update(
      'messages',
      {
        'text': message.text,
        'status': message.status.index,
      },
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  Future<void> deleteMessage(String id) async {
    final db = await database;
    
    await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  // Utility methods
  Future<int> getConversationCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM conversations');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getMessageCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM messages');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> clearAllData() async {
    final db = await database;
    
    await db.transaction((txn) async {
      await txn.delete('messages');
      await txn.delete('conversations');
    });
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
