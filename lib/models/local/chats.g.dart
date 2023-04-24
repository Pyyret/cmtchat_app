// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chats.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChatCollection on Isar {
  IsarCollection<Chat> get chats => this.collection();
}

const ChatSchema = CollectionSchema(
  name: r'Chats',
  id: -2831617567442464876,
  properties: {
    r'chatName': PropertySchema(
      id: 0,
      name: r'chatName',
      type: IsarType.string,
    ),
    r'unread': PropertySchema(
      id: 1,
      name: r'unread',
      type: IsarType.long,
    ),
    r'webChatId': PropertySchema(
      id: 2,
      name: r'webChatId',
      type: IsarType.string,
    )
  },
  estimateSize: _chatEstimateSize,
  serialize: _chatSerialize,
  deserialize: _chatDeserialize,
  deserializeProp: _chatDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'owner': LinkSchema(
      id: -7444163814384527797,
      name: r'owner',
      target: r'Users',
      single: true,
      linkName: r'allChats',
    ),
    r'allMessages': LinkSchema(
      id: 7066281433005845276,
      name: r'allMessages',
      target: r'Messages',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _chatGetId,
  getLinks: _chatGetLinks,
  attach: _chatAttach,
  version: '3.1.0',
);

int _chatEstimateSize(
  Chat object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.chatName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.webChatId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _chatSerialize(
  Chat object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.chatName);
  writer.writeLong(offsets[1], object.unread);
  writer.writeString(offsets[2], object.webChatId);
}

Chat _chatDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Chat(
    chatName: reader.readStringOrNull(offsets[0]),
    webChatId: reader.readStringOrNull(offsets[2]),
  );
  object.id = id;
  object.unread = reader.readLongOrNull(offsets[1]);
  return object;
}

P _chatDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _chatGetId(Chat object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _chatGetLinks(Chat object) {
  return [object.owner, object.allMessages];
}

void _chatAttach(IsarCollection<dynamic> col, Id id, Chat object) {
  object.id = id;
  object.owner.attach(col, col.isar.collection<User>(), r'owner', id);
  object.allMessages
      .attach(col, col.isar.collection<LocalMessage>(), r'allMessages', id);
}

extension ChatQueryWhereSort on QueryBuilder<Chat, Chat, QWhere> {
  QueryBuilder<Chat, Chat, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ChatQueryWhere on QueryBuilder<Chat, Chat, QWhereClause> {
  QueryBuilder<Chat, Chat, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Chat, Chat, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Chat, Chat, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Chat, Chat, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ChatQueryFilter on QueryBuilder<Chat, Chat, QFilterCondition> {
  QueryBuilder<Chat, Chat, QAfterFilterCondition> chatNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'chatName',
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> chatNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'chatName',
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> chatNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chatName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> chatNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chatName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> chatNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chatName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> chatNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chatName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> chatNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chatName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> chatNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chatName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> chatNameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chatName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> chatNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chatName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> chatNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chatName',
        value: '',
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> chatNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chatName',
        value: '',
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> unreadIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unread',
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> unreadIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unread',
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> unreadEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unread',
        value: value,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> unreadGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unread',
        value: value,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> unreadLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unread',
        value: value,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> unreadBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unread',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> webChatIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'webChatId',
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> webChatIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'webChatId',
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> webChatIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'webChatId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> webChatIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'webChatId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> webChatIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'webChatId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> webChatIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'webChatId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> webChatIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'webChatId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> webChatIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'webChatId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> webChatIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'webChatId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> webChatIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'webChatId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> webChatIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'webChatId',
        value: '',
      ));
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> webChatIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'webChatId',
        value: '',
      ));
    });
  }
}

extension ChatQueryObject on QueryBuilder<Chat, Chat, QFilterCondition> {}

extension ChatQueryLinks on QueryBuilder<Chat, Chat, QFilterCondition> {
  QueryBuilder<Chat, Chat, QAfterFilterCondition> owner(FilterQuery<User> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'owner');
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> ownerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'owner', 0, true, 0, true);
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> allMessages(
      FilterQuery<LocalMessage> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'allMessages');
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> allMessagesLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'allMessages', length, true, length, true);
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> allMessagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'allMessages', 0, true, 0, true);
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> allMessagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'allMessages', 0, false, 999999, true);
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> allMessagesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'allMessages', 0, true, length, include);
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> allMessagesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'allMessages', length, include, 999999, true);
    });
  }

  QueryBuilder<Chat, Chat, QAfterFilterCondition> allMessagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'allMessages', lower, includeLower, upper, includeUpper);
    });
  }
}

extension ChatQuerySortBy on QueryBuilder<Chat, Chat, QSortBy> {
  QueryBuilder<Chat, Chat, QAfterSortBy> sortByChatName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatName', Sort.asc);
    });
  }

  QueryBuilder<Chat, Chat, QAfterSortBy> sortByChatNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatName', Sort.desc);
    });
  }

  QueryBuilder<Chat, Chat, QAfterSortBy> sortByUnread() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unread', Sort.asc);
    });
  }

  QueryBuilder<Chat, Chat, QAfterSortBy> sortByUnreadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unread', Sort.desc);
    });
  }

  QueryBuilder<Chat, Chat, QAfterSortBy> sortByWebChatId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webChatId', Sort.asc);
    });
  }

  QueryBuilder<Chat, Chat, QAfterSortBy> sortByWebChatIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webChatId', Sort.desc);
    });
  }
}

extension ChatQuerySortThenBy on QueryBuilder<Chat, Chat, QSortThenBy> {
  QueryBuilder<Chat, Chat, QAfterSortBy> thenByChatName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatName', Sort.asc);
    });
  }

  QueryBuilder<Chat, Chat, QAfterSortBy> thenByChatNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatName', Sort.desc);
    });
  }

  QueryBuilder<Chat, Chat, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Chat, Chat, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Chat, Chat, QAfterSortBy> thenByUnread() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unread', Sort.asc);
    });
  }

  QueryBuilder<Chat, Chat, QAfterSortBy> thenByUnreadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unread', Sort.desc);
    });
  }

  QueryBuilder<Chat, Chat, QAfterSortBy> thenByWebChatId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webChatId', Sort.asc);
    });
  }

  QueryBuilder<Chat, Chat, QAfterSortBy> thenByWebChatIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webChatId', Sort.desc);
    });
  }
}

extension ChatQueryWhereDistinct on QueryBuilder<Chat, Chat, QDistinct> {
  QueryBuilder<Chat, Chat, QDistinct> distinctByChatName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chatName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Chat, Chat, QDistinct> distinctByUnread() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unread');
    });
  }

  QueryBuilder<Chat, Chat, QDistinct> distinctByWebChatId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'webChatId', caseSensitive: caseSensitive);
    });
  }
}

extension ChatQueryProperty on QueryBuilder<Chat, Chat, QQueryProperty> {
  QueryBuilder<Chat, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Chat, String?, QQueryOperations> chatNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chatName');
    });
  }

  QueryBuilder<Chat, int?, QQueryOperations> unreadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unread');
    });
  }

  QueryBuilder<Chat, String?, QQueryOperations> webChatIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'webChatId');
    });
  }
}