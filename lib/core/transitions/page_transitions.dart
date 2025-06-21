// 1. Create a custom transitions file: lib/core/transitions/page_transitions.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageTransitions {
  // Fade transition
  static CustomTransitionPage fadeTransition(
      BuildContext context,
      GoRouterState state,
      Widget child,
      ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Slide from right transition (like iOS)
  static CustomTransitionPage slideFromRightTransition(
      BuildContext context,
      GoRouterState state,
      Widget child,
      ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 400),
    );
  }

  // Slide from left transition
  static CustomTransitionPage slideFromLeftTransition(
      BuildContext context,
      GoRouterState state,
      Widget child,
      ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 400),
    );
  }

  // Slide from bottom transition
  static CustomTransitionPage slideFromBottomTransition(
      BuildContext context,
      GoRouterState state,
      Widget child,
      ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 400),
    );
  }

  // Scale transition
  static CustomTransitionPage scaleTransition(
      BuildContext context,
      GoRouterState state,
      Widget child,
      ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: 0.8, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 350),
    );
  }

  // Combined slide and fade transition
  static CustomTransitionPage slideAndFadeTransition(
      BuildContext context,
      GoRouterState state,
      Widget child,
      ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.1, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var slideTween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 400),
    );
  }

  // Rotation transition
  static CustomTransitionPage rotationTransition(
      BuildContext context,
      GoRouterState state,
      Widget child,
      ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;
        var rotationTween = Tween(begin: 0.1, end: 0.0).chain(
          CurveTween(curve: curve),
        );

        return RotationTransition(
          turns: animation.drive(rotationTween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 500),
    );
  }
}


// 3. Alternative: If you want to apply the same transition to all routes,
// you can create a wrapper function:

class AppTransitions {
  static CustomTransitionPage buildPageWithTransition<T extends Object?>(
      BuildContext context,
      GoRouterState state,
      Widget child, {
        TransitionType transitionType = TransitionType.slideAndFade,
      }) {
    switch (transitionType) {
      case TransitionType.fade:
        return PageTransitions.fadeTransition(context, state, child);
      case TransitionType.slideRight:
        return PageTransitions.slideFromRightTransition(context, state, child);
      case TransitionType.slideLeft:
        return PageTransitions.slideFromLeftTransition(context, state, child);
      case TransitionType.slideBottom:
        return PageTransitions.slideFromBottomTransition(context, state, child);
      case TransitionType.scale:
        return PageTransitions.scaleTransition(context, state, child);
      case TransitionType.slideAndFade:
        return PageTransitions.slideAndFadeTransition(context, state, child);
      case TransitionType.rotation:
        return PageTransitions.rotationTransition(context, state, child);
    }
  }
}

enum TransitionType {
  fade,
  slideRight,
  slideLeft,
  slideBottom,
  scale,
  slideAndFade,
  rotation,
}

// 4. Example of how to use in your routes with the wrapper:

/*
GoRoute(
  path: signInPath,
  pageBuilder: (context, state) => AppTransitions.buildPageWithTransition(
    context,
    state,
    const SignInScreen(),
    transitionType: TransitionType.slideAndFade,
  ),
),
*/