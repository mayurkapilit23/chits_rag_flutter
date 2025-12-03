import 'dart:async';
import 'dart:io';

// Helper method to convert technical errors to user-friendly messages
String getUserFriendlyError(dynamic error) {
  if (error is SocketException ||
      error.toString().contains('SocketException')) {
    return 'No internet connection. Please check your network and try again.';
  } else if (error is TimeoutException ||
      error.toString().contains('Timeout')) {
    return 'Request timed out. The server is taking too long to respond. Please try again.';
  } else if (error.toString().toLowerCase().contains('unauthorized') ||
      error.toString().toLowerCase().contains('401')) {
    return 'Session expired. Please log in again to continue.';
  } else if (error.toString().toLowerCase().contains('rate limit') ||
      error.toString().toLowerCase().contains('429')) {
    return 'Too many requests. Please wait a moment before trying again.';
  } else if (error.toString().toLowerCase().contains('server error') ||
      error.toString().toLowerCase().contains('5')) {
    return 'Our servers are currently experiencing issues. Please try again in a few minutes.';
  } else if (error.toString().toLowerCase().contains('not found') ||
      error.toString().toLowerCase().contains('404')) {
    return 'Service temporarily unavailable. Please try again later.';
  } else if (error is FormatException ||
      error.toString().contains('FormatException')) {
    return 'Invalid response from server. Please try again.';
  }

  // Default error message
  return 'Something went wrong. Please try again. If the problem persists, contact support.';
}
