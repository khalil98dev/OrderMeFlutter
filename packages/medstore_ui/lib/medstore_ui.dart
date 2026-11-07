/// MedStore design system: tokens, the Cupertino theme, components and the ar/fr strings.
///
/// Drawing only: no state management, no API calls. Screens in the apps connect these widgets to Cubits.
/// Every component documents its usage in its own file; the gallery app (`example/`) shows them all.
library;

// Buttons
export 'src/components/buttons/app_button.dart';
export 'src/components/buttons/app_icon_button.dart';
// Display
export 'src/components/display/app_avatar.dart';
export 'src/components/display/app_badge.dart';
export 'src/components/display/app_cover_image.dart';
export 'src/components/display/app_info_row.dart';
export 'src/components/display/app_logo.dart';
export 'src/components/display/app_metric_card.dart';
export 'src/components/display/app_money.dart';
// Feedback
export 'src/components/feedback/app_dialog.dart';
export 'src/components/feedback/app_dialogs.dart';
export 'src/components/feedback/app_empty_state.dart';
export 'src/components/feedback/app_error_state.dart';
export 'src/components/feedback/app_load_view.dart';
export 'src/components/feedback/app_message.dart';
export 'src/components/feedback/app_skeleton.dart';
export 'src/components/feedback/app_text_prompt.dart';
export 'src/components/feedback/app_toast.dart';
// Inputs
export 'src/components/inputs/app_checkbox.dart';
export 'src/components/inputs/app_date_field.dart';
export 'src/components/inputs/app_field_box.dart';
export 'src/components/inputs/app_field_label.dart';
export 'src/components/inputs/app_quantity_stepper.dart';
export 'src/components/inputs/app_search_field.dart';
export 'src/components/inputs/app_segmented_control.dart';
export 'src/components/inputs/app_select_field.dart';
export 'src/components/inputs/app_select_popup.dart';
export 'src/components/inputs/app_switch_row.dart';
export 'src/components/inputs/app_text_field.dart';
export 'src/components/inputs/language_switch.dart';
// Lists
export 'src/components/lists/app_list_tile.dart';
export 'src/components/lists/app_section.dart';
export 'src/components/lists/app_table.dart';
// Motion
export 'src/components/motion/app_bounce_target.dart';
export 'src/components/motion/fly_to_target.dart';
// Navigation
export 'src/components/navigation/app_page_header.dart';
export 'src/components/navigation/app_sidebar.dart';
// Surfaces
export 'src/components/surfaces/app_card.dart';
export 'src/components/surfaces/pressable.dart';
// Strings, formatting, shared feature widgets
export 'src/failure_text.dart';
export 'src/features/login_form.dart';
export 'src/features/products/product_widgets.dart';
export 'src/formatting/app_localizations.dart';
export 'src/formatting/date_format.dart';
export 'src/formatting/money_format.dart';
export 'src/l10n/app_strings.dart';
// Tokens and theme
export 'src/theme/app_theme.dart';
export 'src/tokens/app_colors.dart';
export 'src/tokens/app_icons.dart';
export 'src/tokens/app_metrics.dart';
export 'src/tokens/app_tone.dart';
export 'src/tokens/app_typography.dart';
