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

  @override
  String get projectOverviewRepository => 'रिपॉज़िटरी';

  @override
  String get repositoryTitle => 'रिपॉज़िटरी';

  @override
  String get repositoryError => 'यह डायरेक्टरी लोड नहीं हो सकी।';

  @override
  String get repositoryEmpty => 'यह डायरेक्टरी खाली है।';

  @override
  String get fileError => 'यह फ़ाइल लोड नहीं हो सकी।';

  @override
  String get fileNotFound => 'यह फ़ाइल नहीं मिली।';

  @override
  String get fileBinary =>
      'यह एक बाइनरी फ़ाइल है और इसे टेक्स्ट के रूप में नहीं दिखाया जा सकता।';

  @override
  String get projectOverviewBranches => 'ब्रांच';

  @override
  String get projectOverviewCommits => 'कमिट';

  @override
  String get branchesTitle => 'ब्रांच';

  @override
  String get branchesError => 'ब्रांच लोड नहीं हो सकीं।';

  @override
  String get branchesEmpty => 'इस रिपॉज़िटरी में कोई ब्रांच नहीं है।';

  @override
  String get branchDefault => 'डिफ़ॉल्ट ब्रांच';

  @override
  String get commitsTitle => 'कमिट';

  @override
  String get commitsError => 'कमिट लोड नहीं हो सके।';

  @override
  String get commitsEmpty => 'इस ब्रांच पर अभी कोई कमिट नहीं है।';

  @override
  String get commitTitle => 'कमिट';

  @override
  String get commitError => 'यह कमिट लोड नहीं हो सका।';

  @override
  String get projectOverviewIssues => 'इशू';

  @override
  String get issuesTitle => 'इशू';

  @override
  String get issuesFilterOpen => 'खुले';

  @override
  String get issuesFilterClosed => 'बंद';

  @override
  String get issuesError => 'इशू लोड नहीं हो सके।';

  @override
  String get issuesEmpty => 'यहाँ कोई इशू नहीं है।';

  @override
  String get issueError => 'यह इशू लोड नहीं हो सका।';

  @override
  String get issueStateOpen => 'खुला';

  @override
  String get issueStateClosed => 'बंद';

  @override
  String get issueNoDescription => 'कोई विवरण नहीं दिया गया।';

  @override
  String issueOpenedBy(String username) {
    return '$username द्वारा खोला गया';
  }

  @override
  String get projectOverviewMergeRequests => 'मर्ज रिक्वेस्ट';

  @override
  String get mergeRequestsTitle => 'मर्ज रिक्वेस्ट';

  @override
  String get mrFilterOpen => 'खुले';

  @override
  String get mrFilterMerged => 'मर्ज किए गए';

  @override
  String get mrFilterClosed => 'बंद';

  @override
  String get mergeRequestsError => 'मर्ज रिक्वेस्ट लोड नहीं हो सकीं।';

  @override
  String get mergeRequestsEmpty => 'यहाँ कोई मर्ज रिक्वेस्ट नहीं है।';

  @override
  String get mergeRequestError => 'यह मर्ज रिक्वेस्ट लोड नहीं हो सकी।';

  @override
  String get mergeRequestNoDescription => 'कोई विवरण नहीं दिया गया।';

  @override
  String get mrStateOpen => 'खुला';

  @override
  String get mrStateMerged => 'मर्ज किया गया';

  @override
  String get mrStateClosed => 'बंद';

  @override
  String get mrDraft => 'ड्राफ़्ट';

  @override
  String get changesTitle => 'परिवर्तन';

  @override
  String get changesError => 'परिवर्तन लोड नहीं हो सके।';

  @override
  String get changesEmpty => 'कोई परिवर्तन नहीं।';

  @override
  String get changesBinary => 'बाइनरी फ़ाइल — नहीं दिखाई गई।';

  @override
  String get commitViewChanges => 'परिवर्तन देखें';

  @override
  String get mrViewChanges => 'परिवर्तन देखें';

  @override
  String get changesOmitted =>
      'diff बहुत बड़ा है या संक्षिप्त है, इसलिए नहीं दिखाया गया।';

  @override
  String get commentsHeading => 'टिप्पणियाँ';

  @override
  String get commentsError => 'टिप्पणियाँ लोड नहीं हो सकीं।';

  @override
  String get commentsEmpty => 'अभी तक कोई टिप्पणी नहीं।';

  @override
  String get commentComposerHint => 'एक टिप्पणी लिखें…';

  @override
  String get commentComposerSubmit => 'टिप्पणी करें';

  @override
  String get commentPostForbidden =>
      'आपको यहाँ टिप्पणी करने की अनुमति नहीं है। जाँचें कि आपके टोकन में api स्कोप है।';

  @override
  String get commentPostError =>
      'आपकी टिप्पणी पोस्ट नहीं हो सकी। कृपया पुनः प्रयास करें।';
}
