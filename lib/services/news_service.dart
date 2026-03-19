import 'dart:math';
import '../models/news_model.dart';

class NewsService {
  static final List<String> _categories = [
    'Технологии', 'Спорт', 'Экономика', 'Культура', 'Наука', 'Политика', 'Медицина', 'Авто'
  ];

  static final List<String> _titlePrefixes = [
    'Новый прорыв:', 'Сенсация:', 'Неожиданный поворот:', 'Главное за день:',
    'Важное заявление:', 'Аналитика:', 'Эксклюзив:', 'Срочно:'
  ];

  static final List<String> _titleSubjects = [
    'Искусственный интеллект', 'Крупный инвестор', 'Известный бренд',
    'Научный институт', 'Мировой рынок', 'Передовой стартап',
    'Государственный регулятор', 'Популярный сервис'
  ];

  static final List<String> _titleActions = [
    'меняет правила игры', 'показывает рекордный рост', 'сталкивается с проблемами',
    'открывает новые горизонты', 'вызывает споры', 'анонсирует масштабные изменения',
    'отчитывается о результатах', 'заключает стратегическое партнерство'
  ];

  static final List<String> _descStarts = [
    'Эксперты предсказывают, что', 'Аналитики уверены:', 'Недавние события показали, как',
    'Многие ожидали этого, но', 'Ситуация развивается стремительно:'
  ];

  static final List<String> _descEnds = [
    'последствия будут масштабными.', 'это затронет каждого из нас.',
    'рынок уже отреагировал.', 'остается еще много нерешенных вопросов.',
    'это только начало больших перемен.'
  ];

  static final List<String> _contentSentences = [
    'Ситуация вызвала широкий резонанс в обществе.',
    'Мнения экспертов по этому вопросу кардинально разделились.',
    'Аналитики прогнозируют дальнейшее развитие этого тренда в ближайшие кварталы.',
    'Многие крупные компании уже начали адаптировать свои внутренние стратегии.',
    'Официальные представители пока отказываются давать подробные комментарии.',
    'Это решение может необратимо повлиять на всю отрасль в целом.',
    'Источники, близкие к руководству, подтверждают обоснованность этих слухов.',
    'Инвесторы по всему миру внимательно следят за каждым шагом.',
    'Критики отмечают возможные негативные последствия в долгосрочной перспективе.',
    'Данное событие уже успело стать главным информационным поводом этой недели.',
    'Стоит отметить, что подобные прецеденты ранее не встречались в мировой практике.',
    'Технические специалисты активно изучают предоставленные данные для формирования отчета.'
  ];

  static final List<String> _firstNames = ['Александр', 'Елена', 'Дмитрий', 'Мария', 'Иван', 'Анна', 'Сергей', 'Ольга', 'Виктор', 'Екатерина'];
  static final List<String> _lastNames = ['Смирнов', 'Иванов', 'Кузнецов', 'Соколов', 'Попов', 'Лебедев', 'Новиков', 'Морозов', 'Волков', 'Алексеев'];

  static Future<List<NewsModel>> fetchNews({int page = 1, int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final random = Random();

    return List.generate(limit, (index) {
      final id = (page - 1) * limit + index;

      final category = _categories[random.nextInt(_categories.length)];
      final prefix = _titlePrefixes[random.nextInt(_titlePrefixes.length)];
      final subject = _titleSubjects[random.nextInt(_titleSubjects.length)];
      final action = _titleActions[random.nextInt(_titleActions.length)];

      final dStart = _descStarts[random.nextInt(_descStarts.length)];
      final dEnd = _descEnds[random.nextInt(_descEnds.length)];

      final fName = _firstNames[random.nextInt(_firstNames.length)];
      String lName = _lastNames[random.nextInt(_lastNames.length)];
      if (['Елена', 'Мария', 'Анна', 'Ольга', 'Екатерина'].contains(fName)) {
        lName += 'а';
      }

      _contentSentences.shuffle(random);
      final generatedContent = _contentSentences.take(random.nextInt(4) + 4).join(' ');

      return NewsModel(
        id: id,
        title: '$prefix $subject $action.',
        description: '$dStart $subject $action. $dEnd',
        content: '$dStart $subject $action. $generatedContent $dEnd',
        imageUrl: 'https://picsum.photos/seed/inf_news_$id/800/600',
        author: '$fName $lName',
        authorId: 'system_$id',
        category: category,
        date: DateTime.now().subtract(Duration(minutes: id * 25 + random.nextInt(60))),
        likes: random.nextInt(9000) + 100,
        comments: random.nextInt(800) + 5,
        tags: [category, 'Актуальное', 'Тренды'],
      );
    });
  }
}