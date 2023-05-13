import Foundation

enum Constant {
    static let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪",
    ]
    
    // TabBar
    static let leftTabBarTitle = "Трекеры"
    static let rightTabBarTitle = "Статистика"
    
    // TrackersViewController
    static let trackersVCSearchBarPlaceholder = "Поиск"
    static let trackersVCEmptyLabelText = "Что будем отслеживать?"
    static let trackersVCErrorLabelText = "Ничего не найдено"
    
    // TrackerCreationViewController
    static let trackerCreationVCTitle = "Создание трекера"
    static let trackerCreationVCHabitButton = "Привычка"
    static let trackerCreationVCEventButton = "Нерегулярные событие"
    
    // NewHabitViewController
    static let newHabitVCTitle = "Новая привычка"
    static let newHabitVCTableTitles = ["Категория", "Расписание"]
    
    // NewEventViewController
    static let newEventVCTitle = "Новое нерегулярное событие"
    static let newEventVCTableTitles = ["Категория"]
    
    // NewHabitViewController + NewEventViewController
    static let textFieldPlaceholder = "Введите название трекера"
    static let errorLabel = "Ограничение 38 символов"
    static let cancelButton = "Отменить"
    static let createButton = "Создать"
    
    // CategoryViewController
    static let categoryVCTitle = "Категория"
    static let categoryVCButton = "Добавить категорию"
    static let categoryVCPlaceholder = "Привычки и события можно\nобъединить по смыслу"
    
    // ScheduleViewController
    static let scheduleVCTitle = "Расписание"
    static let scheduleVCReuseIdentifier = "ScheduleTableViewCell"
    static let scheduleVCTableTitles = [
        "Понедельник", "Вторник", "Среда", "Четверг",
        "Пятница", "Суббота", "Воскресенье"
    ]
    static let scheduleVCButton = "Готово"
}
