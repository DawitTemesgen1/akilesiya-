import 'package:flutter/material.dart';

/// A global ValueNotifier that acts as a simple signal to trigger a refresh
/// on the private home page feed.
///
/// When an admin creates, updates, or deletes a post, they will increment
/// this notifier's value. The PrivateHomePage listens to this change and
/// re-fetches its data.
final ValueNotifier<int> privateFeedRefresher = ValueNotifier<int>(0);
