import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/data/mutationsOperations.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/types/boolean_message.dart';
import 'package:memorare/types/error_reason.dart';
import 'package:memorare/types/quotes_list.dart';
import 'package:memorare/types/try_response.dart';
import 'package:provider/provider.dart';

class Mutations {
  static Future<BooleanMessage> addUniqToList(
    BuildContext context,
    String listId,
    String quoteId,
  ) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
        documentNode: MutationsOperations.addUniqToList,
        variables: {'listId': listId, 'quoteId': quoteId},
      )
    ).then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.first.message
        );
      }

      return BooleanMessage(boolean: true);

    }).catchError((error) {
      return BooleanMessage(boolean: false, message: error.toString());
    });
  }

  static Future<QuotesList> createList({
    BuildContext context,
    String name,
    String description = '',
    String quoteId,
  }) {

    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
      documentNode: MutationsOperations.createList,
      variables: {
        'name': name,
        'description': description,
        'quoteId': quoteId,
      },
    ))
    .then((queryResult) {
      return QuotesList.fromJSON(queryResult.data['createList']);
    });
  }

  static Future<TryResponse> deleteAccount(BuildContext context, String password) {
    return Provider.of<HttpClientsModel>(context).defaultClient.value
    .mutate(MutationOptions(
      documentNode: MutationsOperations.deleteAccount,
      variables: {'password': password},
    ))
    .then((queryResult) {
      if (queryResult.hasException) {
        return TryResponse(hasErrors: true, reason: ErrorReason.unknown);
      }

      return TryResponse(hasErrors: false, reason: ErrorReason.none);
    })
    .catchError((error) {
      return TryResponse(hasErrors: true, reason: ErrorReason.unknown);
    });
  }

  static Future<BooleanMessage> deleteList(BuildContext context, String id) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(MutationOptions(
      documentNode: MutationsOperations.deleteList,
      variables: {'id': id},
    ))
    .then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.first.message
        );
      }

      return BooleanMessage(boolean: true);
    })
    .catchError((error) {
      return BooleanMessage(boolean: false, message: error.toString());
    });
  }

  static Future<BooleanMessage> deleteTempQuote(BuildContext context, String id) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(MutationOptions(
      documentNode: MutationsOperations.deleteTempQuote,
      variables: {'id': id},
    ))
    .then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.first.message
        );
      }

      return BooleanMessage(boolean: true);
    })
    .catchError((error) {
      return BooleanMessage(boolean: false, message: error.toString());
    });
  }

  static Future<BooleanMessage> star(BuildContext context, String quoteId) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
        documentNode: MutationsOperations.star,
        variables: {'quoteId': quoteId},
      )
    )
    .then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.first.message
        );
      }

      return BooleanMessage(boolean: true);
    })
    .catchError((error) {
      return BooleanMessage(boolean: false, message: error.toString());
    });
  }

  static Future<BooleanMessage> unstar(BuildContext context, String quoteId) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
        documentNode: MutationsOperations.unstar,
        variables: {'quoteId': quoteId},
      )
    )
    .then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.first.message
        );
      }

      return BooleanMessage(boolean: true);
    })
    .catchError((error) {
      return BooleanMessage(boolean: false, message: error.toString());
    });
  }

  static Future<BooleanMessage> removeFromList(
    BuildContext context,
    String listId,
    String quoteId,
  ) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
        documentNode: MutationsOperations.removeFromList,
        variables: {'listId': listId, 'quoteId': quoteId},
      )
    ).then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.first.message
        );
      }

      return BooleanMessage(boolean: true);

    }).catchError((error) {
      return BooleanMessage(boolean: false, message: error.toString());
    });
  }

  static Future<TryResponse> updateImgUrl(
    BuildContext context,
    String imgUrl,
  ) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
        documentNode: MutationsOperations.updateImgUrl,
        variables: {'imgUrl': imgUrl},
      )
    ).then((queryResult) {
      Map<String, dynamic> jsonMap = queryResult.data['updateImgUrl'];

      final String imgUrl = jsonMap['imgUrl'];

      var userDataModel = Provider.of<UserDataModel>(context);

      userDataModel.setImgUrl(imgUrl);

      return TryResponse(hasErrors: false, reason: ErrorReason.none);

    }).catchError((error) {
      return TryResponse(hasErrors: true, reason: ErrorReason.unknown);
    });
  }

  static Future<BooleanMessage> updateList(
    BuildContext context,
    String id,
    String name,
    String description,
  ) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(
      MutationOptions(
        documentNode: MutationsOperations.updateList,
        variables: {'id': id, 'name': name, 'description': description},
      )
    ).then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.first.message
        );
      }

      return BooleanMessage(boolean: true);

    }).catchError((error) {
      return BooleanMessage(boolean: false, message: error.toString());
    });
  }

  static Future<BooleanMessage> updatePassword(
    BuildContext context,
    String oldPassword,
    String confirmPassword,
  ) {

    return Provider.of<HttpClientsModel>(context).defaultClient.value
    .mutate(
      MutationOptions(
        documentNode: MutationsOperations.updatePassword,
        variables: {
          'oldPassword': oldPassword,
          'newPassword': confirmPassword,
        },
      )
    )
    .then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.first.message
        );
      }

      return BooleanMessage(boolean: true);
    })
    .catchError((error) {
      return BooleanMessage(
        boolean: false,
        message: error.toString()
      );
    });
  }

  static Future<BooleanMessage> validateTempQuote(
    BuildContext context, String id
  ) {
    final httpClientModel = Provider.of<HttpClientsModel>(context);

    return httpClientModel.defaultClient.value.mutate(MutationOptions(
      documentNode: MutationsOperations.validateTempQuote,
      variables: {'id': id, 'ignoreStatus':  true},
    ))
    .then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.first.message
        );
      }

      return BooleanMessage(boolean: true);
    })
    .catchError((error) {
      return BooleanMessage(boolean: false, message: error.toString());
    });
  }
}
