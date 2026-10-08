library thamizhi_keyboard;

export 'src/engine/tamil_engine.dart';
export 'src/state/keyboard_controller.dart';
export 'src/state/keyboard_state.dart';
export 'src/ui/components/key_widget.dart';
export 'src/ui/keyboard_layout.dart';
export 'src/ui/keyboard_mode.dart'
    show KeyboardMode, kDesktopKeyboardBreakpoint;
export 'src/ui/theme/keyboard_theme.dart';

// Note: The previous monolithic UI components (`VesaipalagaiVadivam`, `Vesaipalagai`, etc.) 
// are purposefully excluded from exports in the new architecture as they are deprecated 
// in favor of the new scalable `ThamizhiKeyboard` wrapper.
