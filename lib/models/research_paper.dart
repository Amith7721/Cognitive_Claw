class ResearchPaper {
  final String title;
  final String summary;
  final String link;
  final String published;

  ResearchPaper({
    required this.title,
    required this.summary,
    required this.link,
    required this.published,
  });

  factory ResearchPaper.fromMap(Map<String, dynamic> map) {
    return ResearchPaper(
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      link: map['link'] ?? '',
      published: map['published'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'summary': summary,
      'link': link,
      'published': published,
    };
  }
}
