// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'LabFox';

  @override
  String get homeTitle => 'होम';

  @override
  String homeSignedInAs(String username) {
    return '$username के रूप में साइन इन';
  }

  @override
  String get homeEmptyWork =>
      'आपके इशू, मर्ज रिक्वेस्ट और पाइपलाइन यहाँ दिखाई देंगे।';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get signInTitle => 'GitLab खाता कनेक्ट करें';

  @override
  String get signInInstanceLabel => 'GitLab इंस्टेंस URL';

  @override
  String get signInInstanceRequired => 'अपना GitLab इंस्टेंस URL दर्ज करें।';

  @override
  String get signInInstanceInvalid =>
      'एक मान्य https URL दर्ज करें, उदाहरण के लिए https://gitlab.com';

  @override
  String get signInTokenLabel => 'पर्सनल एक्सेस टोकन';

  @override
  String get signInTokenHelp => 'api और read_user स्कोप आवश्यक हैं।';

  @override
  String get signInTokenToggle => 'टोकन दिखाएँ या छिपाएँ';

  @override
  String get signInTokenRequired => 'पर्सनल एक्सेस टोकन दर्ज करें।';

  @override
  String get signInSubmit => 'साइन इन';

  @override
  String get signInErrorToken =>
      'टोकन अस्वीकृत हो गया। जाँचें कि यह सही है और समाप्त नहीं हुआ है।';

  @override
  String get signInErrorScope =>
      'टोकन में आवश्यक स्कोप नहीं है। इसे api और read_user चाहिए।';

  @override
  String get signInErrorUnreachable =>
      'उस इंस्टेंस तक नहीं पहुँच सके। URL, अपना नेटवर्क और प्रमाणपत्र भरोसे की जाँच करें।';

  @override
  String get signInErrorGeneric => 'साइन इन विफल रहा। कृपया पुनः प्रयास करें।';

  @override
  String get homeMyWork => 'मेरा काम';

  @override
  String get homeProjects => 'प्रोजेक्ट';

  @override
  String get projectsTitle => 'प्रोजेक्ट';

  @override
  String get projectsEmpty => 'आप अभी तक किसी प्रोजेक्ट के सदस्य नहीं हैं।';

  @override
  String get projectsError => 'आपके प्रोजेक्ट लोड नहीं हो सके।';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get projectOverviewTitle => 'प्रोजेक्ट';

  @override
  String get projectOverviewError => 'यह प्रोजेक्ट लोड नहीं हो सका।';

  @override
  String get projectOverviewNoReadme => 'इस प्रोजेक्ट में कोई README नहीं है।';
}
