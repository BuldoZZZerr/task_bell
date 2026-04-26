import 'package:flutter/material.dart';

/// Строки приложения в зависимости от локали.
class AppStrings {
  AppStrings(this.locale);
  final Locale locale;

  bool get isEn => locale.languageCode == 'en';

  // Навигация
  String get tabToday => isEn ? 'Today' : 'Сегодня';
  String get tabWeek => isEn ? 'Week' : 'Неделя';
  String get tabCalendar => isEn ? 'Calendar' : 'Календарь';
  String get tabSettings => isEn ? 'Settings' : 'Настройки';

  // Общие
  String get appTitle => 'Task Bell';
  String get settings => isEn ? 'Settings' : 'Настройки';
  String get darkTheme => isEn ? 'Dark theme' : 'Тёмная тема';
  String get language => isEn ? 'Language' : 'Язык';
  String get languageRussian => isEn ? 'Russian' : 'Русский';
  String get languageEnglish => isEn ? 'English' : 'Английский';
  String get addSchedule => isEn ? 'Add schedule' : 'Добавить расписание';
  String get addScheduleSubtitle => isEn
      ? 'Weekly lesson schedule, repeats every week'
      : 'Расписание уроков на неделю, повторяется каждую неделю';
  String get birthdays => isEn ? 'Birthdays' : 'Дни рождения';
  String get cancel => isEn ? 'Cancel' : 'Отмена';
  String get save => isEn ? 'Save' : 'Сохранить';
  String get add => isEn ? 'Add' : 'Добавить';

  // Пустые состояния
  String get noScheduleForDay =>
      isEn ? 'No schedule for this day' : 'Нет расписания на этот день';

  // Карточка задания
  String get taskNotesHint => isEn ? 'Notes field' : 'Поле для заметок';
  String get deleteTask => isEn ? 'Delete task' : 'Удалить задание';
  String get deleteTaskConfirm => isEn
      ? 'Delete this task? This cannot be undone.'
      : 'Удалить это задание? Действие нельзя отменить.';
  String get delete => isEn ? 'Delete' : 'Удалить';
  String get taskDeleted => isEn ? 'Task deleted' : 'Задача удалена';

  // Добавить/редактировать задачу
  String get newTask => isEn ? 'New task' : 'Новое задание';
  String get taskNameHint => isEn ? 'Task name' : 'Название задачи';
  String get enterTaskName => isEn ? 'Enter task name' : 'Введите название задачи';
  String get time => isEn ? 'Time' : 'Время';
  String get start => isEn ? 'Start' : 'Начало';
  String get end => isEn ? 'End' : 'Конец';
  String get description => isEn ? 'Description' : 'Описание';
  String get note => isEn ? 'Note' : 'Заметка';
  String get recurrence => isEn ? 'Recurrence' : 'Периодичность';
  String get noRepeat => isEn ? 'No repeat' : 'Без повтора';
  String get everyDay => isEn ? 'Every day' : 'Каждый день';
  String get everyWeek => isEn ? 'Every week' : 'Каждую неделю';
  String get everyMonth => isEn ? 'Every month' : 'Раз в месяц';
  String get everyYear => isEn ? 'Every year' : 'Раз в год';

  // Добавить задачу (диалог)
  String get addTask => isEn ? 'Add task' : 'Добавить задачу';
  String get editTask => isEn ? 'Edit task' : 'Редактировать задачу';
  String get subject => isEn ? 'Subject' : 'Предмет';
  String get enterSubjectHint => isEn ? 'Enter subject name' : 'Введите название предмета';
  String get enterDescriptionHint => isEn ? 'Enter description' : 'Введите описание';

  // Дни рождения
  String get addBirthday => isEn ? 'Add birthday' : 'Добавить день рождения';
  String get name => isEn ? 'Name' : 'Имя';
  String get selectDate => isEn ? 'Select date' : 'Выберите дату';
  String get date => isEn ? 'Date' : 'Дата';
  String get addBirthdaysHint => isEn
      ? 'Add birthdays to remember\nto congratulate'
      : 'Добавьте дни рождения,\nчтобы не забыть поздравить';
  String birthdayLabel(String name) =>
      isEn ? 'Birthday: $name' : 'День рождения: $name';
  String dateLabel(String dateStr) => isEn ? 'Date: $dateStr' : 'Дата: $dateStr';

  // Расписание уроков
  String get scheduleTitle => isEn ? 'Lesson schedule' : 'Расписание уроков';
  String get scheduleSubtitle => isEn
      ? 'Fill each day with lessons and times. After "Apply" the schedule will repeat every week.'
      : 'Заполните каждый день недели уроками и временем. После «Применить» расписание будет повторяться каждую неделю.';
  String get addLesson => isEn ? 'Add lesson' : 'Добавить урок';
  String get editLesson => isEn ? 'Edit lesson' : 'Редактировать урок';
  String get noLessons => isEn ? 'No lessons' : 'Нет уроков';
  String get applySchedule => isEn ? 'Apply schedule' : 'Применить расписание';
  String get applying => isEn ? 'Applying...' : 'Применяем...';
  String get addOneLesson => isEn ? 'Add at least one lesson' : 'Добавьте хотя бы один урок';
  String get scheduleApplied => isEn
      ? 'Schedule applied. Lessons repeat every week.'
      : 'Расписание применено. Уроки повторяются каждую неделю.';
  String get enterSubjectName => isEn ? 'Enter subject name' : 'Введите название предмета';
  String get subjectHint => isEn ? 'e.g. Mathematics' : 'Например: Математика';
  String get weekdayLabel => isEn ? 'Weekday' : 'День недели';
  String get noTitle => isEn ? 'Untitled' : 'Без названия';

  // Дни недели (полные)
  List<String> get weekdayNames => isEn
      ? ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
      : ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];

  // Дни недели (короткие для календаря)
  List<String> get weekdayShort => isEn
      ? ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
      : ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];

  // Месяцы (родительный падеж: 15 января)
  List<String> get monthsGenitive => isEn
      ? ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
      : ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'];

  // Месяцы (именительный: Январь 2025)
  List<String> get monthsNominative => isEn
      ? ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
      : ['Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'];

  static AppStrings of(BuildContext context) {
    return AppStrings(Localizations.localeOf(context));
  }
}
