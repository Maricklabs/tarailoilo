// All Terms and Conditions text lives here, separate from the UI, so it can be
// edited (or later loaded from a backend / CMS) without touching any widget.

const String kTermsHeading = 'Terms and conditions';

/// Shown under a checkbox when the user tries to continue without agreeing.
const String kTermsRequiredMessage = 'Accept the Terms and Conditions to continue.';

enum TermsBlockType { paragraph, bullets, subheading }

/// One piece of a section: a paragraph, a bullet list, or a small sub-heading.
class TermsBlock {
  const TermsBlock.paragraph(String text)
      : type = TermsBlockType.paragraph,
        text = text,
        items = const [];
  const TermsBlock.subheading(String text)
      : type = TermsBlockType.subheading,
        text = text,
        items = const [];
  const TermsBlock.bullets(List<String> items)
      : type = TermsBlockType.bullets,
        text = '',
        items = items;

  final TermsBlockType type;
  final String text;
  final List<String> items;
}

class TermsSection {
  const TermsSection({required this.number, required this.title, required this.blocks});
  final int number;
  final String title;
  final List<TermsBlock> blocks;
}

class TermsPage {
  const TermsPage({
    required this.subtitle,
    required this.footerNote,
    required this.actionLabel,
    required this.sections,
    this.intro = const [],
    this.outro = const [],
  });

  /// Small line under the heading, e.g. "PAGE 1 OF 2 · Using Tara Ilo".
  final String subtitle;

  /// Line above the bottom button.
  final String footerNote;

  /// Label of the bottom button ("Continue" on page 1, "Agree" on page 2).
  final String actionLabel;

  /// Text shown before the first section (effective date and welcome).
  final List<TermsBlock> intro;
  final List<TermsSection> sections;

  /// Closing lines shown after the last section.
  final List<TermsBlock> outro;
}

const List<TermsPage> kTermsPages = [
  /* ------------------------------------------------------------ PAGE 1 */
  TermsPage(
    subtitle: 'PAGE 1 OF 2 · Using Tara Ilo',
    footerNote: 'Next: privacy, content and your rights',
    actionLabel: 'Continue',
    intro: [
      TermsBlock.subheading('Effective Date: December 1, 2026'),
      TermsBlock.paragraph(
          'Welcome to TARA ILOILO! These Terms and Conditions explain the rules, responsibilities, and guidelines for using the TARA ILOILO mobile application. Please read them carefully before creating an account or using the application.'),
      TermsBlock.paragraph(
          'By accessing or using TARA ILOILO, you acknowledge that you have read and understood these Terms and agree to follow them.'),
    ],
    sections: [
      TermsSection(
        number: 1,
        title: 'Welcome to TARA ILO',
        blocks: [
          TermsBlock.paragraph(
              'TARA ILOILO is a digital travel and cultural discovery application designed to help users explore the beauty, history, culture, food, and attractions of Iloilo.'),
          TermsBlock.paragraph(
              "Through the application, users can discover historical landmarks, explore local delicacies, view upcoming events, access travel information, and learn more about the city's cultural heritage."),
          TermsBlock.paragraph(
              'The application may also provide interactive features such as maps, image recognition, language support, and an AI-powered chatbot to help users navigate and discover information about Iloilo.'),
          TermsBlock.paragraph(
              'Our goal is to make exploring Iloilo more accessible, informative, and enjoyable for residents, tourists, and anyone interested in discovering the city.'),
          TermsBlock.paragraph(
              'By creating an account, accessing the application as a guest, or using any of its available features, you agree to comply with these Terms and Conditions.'),
          TermsBlock.paragraph('If you do not agree with these terms, you should discontinue using the application.'),
        ],
      ),
      TermsSection(
        number: 2,
        title: 'Your Account',
        blocks: [
          TermsBlock.paragraph(
              'Some features of TARA ILOILO may require users to create an account or provide personal information.'),
          TermsBlock.paragraph(
              'When registering, you agree to provide accurate, complete, and up-to-date information. This may include your name, age, gender, nationality, contact number, email address, and profile picture, depending on the registration options available.'),
          TermsBlock.paragraph(
              'You are responsible for maintaining the confidentiality of your login credentials and protecting access to your account.'),
          TermsBlock.paragraph(
              "You are also responsible for activities performed through your account. If you believe that someone has accessed your account without your permission, you should take appropriate steps to secure it and contact the application's support team."),
          TermsBlock.paragraph(
              "Users must not impersonate another person, provide misleading account information, or use another person's account without authorization."),
          TermsBlock.paragraph(
              'Guest users may access selected application features without creating a registered account. However, certain features may only be available to registered users.'),
          TermsBlock.paragraph(
              'TARA ILOILO reserves the right to restrict access to accounts involved in misuse, suspicious activities, or violations of these Terms, subject to applicable laws and regulations.'),
        ],
      ),
      TermsSection(
        number: 3,
        title: 'Respectful Use',
        blocks: [
          TermsBlock.paragraph('Users are expected to use TARA ILOILO responsibly, respectfully, and lawfully.'),
          TermsBlock.paragraph('You agree not to:'),
          TermsBlock.bullets([
            'Upload, share, or distribute harmful, offensive, misleading, or unlawful content.',
            "Misuse another person's personal information, photographs, or account details.",
            'Impersonate individuals, organizations, or other users.',
            'Attempt to access restricted accounts, systems, or application resources without permission.',
            "Interfere with the application's normal operation, security, or services.",
            'Use the application to distribute malicious software or perform unauthorized activities.',
            'Exploit application features for fraudulent, abusive, or harmful purposes.',
          ]),
          TermsBlock.paragraph(
              'Users must respect the privacy, rights, and property of other individuals and organizations when using the application.'),
          TermsBlock.paragraph(
              'Any content or activity that violates these guidelines may result in restrictions or suspension of access, where appropriate and permitted by law.'),
        ],
      ),
      TermsSection(
        number: 4,
        title: 'Explore Responsibly',
        blocks: [
          TermsBlock.paragraph(
              'TARA ILOILO provides travel-related information to help users discover places, food, attractions, and events throughout Iloilo.'),
          TermsBlock.paragraph(
              'Although we aim to provide useful and accurate information, some details may be incomplete, outdated, or subject to change.'),
          TermsBlock.paragraph('Information displayed in the application may include:'),
          TermsBlock.bullets([
            'Historical descriptions and cultural information about landmarks.',
            'Restaurant and local food information.',
            'Business details, opening hours, and prices.',
            'Event schedules and announcements.',
            'Directions, routes, and location information.',
            'Image recognition results and chatbot-generated responses.',
          ]),
          TermsBlock.paragraph(
              'Users should independently verify important information with the relevant establishments, event organizers, local authorities, or service providers before making travel arrangements or visiting a location.'),
          TermsBlock.paragraph(
              'Opening hours, prices, availability, event schedules, and other details may change without prior notice.'),
          TermsBlock.paragraph(
              'When visiting unfamiliar places, users should follow local rules, respect cultural and historical sites, observe safety precautions, and remain aware of their surroundings.'),
          TermsBlock.paragraph(
              'TARA ILOILO is intended as a discovery and information tool and should not replace personal judgment, official announcements, or professional guidance when necessary.'),
        ],
      ),
    ],
  ),

  /* ------------------------------------------------------------ PAGE 2 */
  TermsPage(
    subtitle: 'PAGE 2 OF 2 · Your rights & responsibilities',
    footerNote: 'By tapping agree, you accept these terms',
    actionLabel: 'Agree',
    sections: [
      TermsSection(
        number: 5,
        title: 'Privacy & Permissions',
        blocks: [
          TermsBlock.paragraph(
              'TARA ILOILO respects the privacy of its users and aims to handle personal information responsibly.'),
          TermsBlock.paragraph(
              'Personal information collected through the application will be handled in accordance with the applicable Privacy Policy and relevant data protection laws.'),
          TermsBlock.paragraph(
              'Depending on the features you choose to use, the application may request permission to access certain device features, including:'),
          TermsBlock.subheading('Camera Access'),
          TermsBlock.paragraph(
              'Camera permission may be requested to support features such as capturing or uploading profile pictures and using image recognition functionality.'),
          TermsBlock.subheading('Location Access'),
          TermsBlock.paragraph(
              'Location permission may be requested to support map-related features, location-based recommendations, and navigation assistance.'),
          TermsBlock.subheading('Photos and Media'),
          TermsBlock.paragraph(
              'Access to photos or media may be required when uploading a custom profile picture or selecting images from your device.'),
          TermsBlock.paragraph(
              'Users may choose whether to grant certain permissions. You can manage or revoke these permissions through your device settings.'),
          TermsBlock.paragraph(
              'Disabling specific permissions may affect the availability or functionality of features that depend on them.'),
          TermsBlock.paragraph(
              'For additional information about the collection, use, storage, and protection of personal information, please refer to the TARA ILOILO Privacy Policy.'),
        ],
      ),
      TermsSection(
        number: 6,
        title: 'Availability & Third Parties',
        blocks: [
          TermsBlock.paragraph(
              'TARA ILOILO aims to provide accessible and useful travel discovery features. However, we cannot guarantee that all application features, services, or information will always be available without interruption.'),
          TermsBlock.paragraph(
              'Certain features may occasionally become unavailable due to maintenance, technical issues, updates, connectivity problems, or other circumstances beyond our control.'),
          TermsBlock.paragraph(
              'The application may also display information, links, recommendations, or services provided by third parties, including restaurants, tourism establishments, event organizers, and other external platforms.'),
          TermsBlock.paragraph(
              'These third-party services operate independently and may have their own terms, conditions, policies, and privacy practices.'),
          TermsBlock.paragraph(
              'TARA ILOILO does not control all third-party content, services, schedules, prices, or availability. Users are encouraged to verify information directly with the relevant provider before relying on it.'),
          TermsBlock.paragraph(
              'Accessing external links or using third-party services is subject to the terms and policies of those providers.'),
          TermsBlock.paragraph(
              'Nothing in these Terms and Conditions is intended to remove, limit, or override any rights or protections granted to users under applicable laws.'),
        ],
      ),
      TermsSection(
        number: 7,
        title: 'Changes & Acceptance',
        blocks: [
          TermsBlock.paragraph(
              'TARA ILOILO may update these Terms and Conditions from time to time to reflect changes in application features, services, policies, or applicable requirements.'),
          TermsBlock.paragraph(
              'When material changes are made, users will be notified through appropriate channels within the application or other available communication methods.'),
          TermsBlock.paragraph(
              'Users are encouraged to review the updated Terms and Conditions whenever changes are announced.'),
          TermsBlock.paragraph(
              'Continued use of the application following applicable updates will be subject to the revised terms, to the extent permitted by law.'),
          TermsBlock.paragraph(
              'By selecting the Agree button on the Terms and Conditions page, you confirm that you have read, understood, and accepted these Terms and Conditions.'),
          TermsBlock.paragraph(
              'If you do not agree with these terms, you should not proceed with the use of the application or its services.'),
        ],
      ),
    ],
    outro: [
      TermsBlock.subheading('Thank you for being part of TARA ILOILO!'),
      TermsBlock.paragraph('Explore Iloilo. Discover its stories. Experience its culture.'),
    ],
  ),
];
