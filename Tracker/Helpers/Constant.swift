import Foundation

enum Constant {
    static let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪",
    ]
    
    static let weekDays: [String: String] = [
        "1": NSLocalizedString("mon", comment: ""),
        "2": NSLocalizedString("tue", comment: ""),
        "3": NSLocalizedString("wed", comment: ""),
        "4": NSLocalizedString("thu", comment: ""),
        "5": NSLocalizedString("fri", comment: ""),
        "6": NSLocalizedString("sat", comment: ""),
        "7": NSLocalizedString("sun", comment: ""),
    ]
    
    // Onboarding
    static let onboardingButtonTitle = NSLocalizedString("onboardingButtonTitle", comment: "")
    static let onboardingLabelBlue = NSLocalizedString("onboardingLabelBlue", comment: "")
    static let onboardingLabelRed = NSLocalizedString("onboardingLabelRed", comment: "")
    
    // TabBar
    static let leftTabBarTitle = NSLocalizedString("trackers", comment: "")
    static let rightTabBarTitle = NSLocalizedString("statistics", comment: "")
    
    // TrackersViewController
    static let trackersVCSearchBarPlaceholder = NSLocalizedString("search", comment: "")
    static let trackersVCEmptyLabelText = NSLocalizedString("trackersVCEmptyLabelText", comment: "")
    static let trackersVCErrorLabelText = NSLocalizedString("trackersVCErrorLabelText", comment: "")
    static let trackersVCPinnedCategory = NSLocalizedString("pinned", comment: "")
    static let trackersVCPin = NSLocalizedString("pin", comment: "")
    static let trackersVCUnpin = NSLocalizedString("unpin", comment: "")
    static let trackersVCDelete = NSLocalizedString("delete", comment: "")
    static let trackersVCEdit = NSLocalizedString("edit", comment: "")
    static let trackersVCAlertTitle = NSLocalizedString("trackersVCAlertTitle", comment: "")
    
    // TrackerCreationViewController
    static let trackerCreationVCTitle = NSLocalizedString("trackerCreationVCTitle", comment: "")
    static let trackerCreationVCHabitButton = NSLocalizedString("habit", comment: "")
    static let trackerCreationVCEventButton = NSLocalizedString("event", comment: "")
    
    // NewTrackerViewController
    static let newHabitTitle = NSLocalizedString("newHabit", comment: "")
    static let newHabitTableTitles = [NSLocalizedString("category", comment: ""),
                                      NSLocalizedString("schedule", comment: "")]
    
    static let newEventTitle = NSLocalizedString("newEvent", comment: "")
    static let newEventTableTitles = [NSLocalizedString("category", comment: "")]
    
    static let collectionViewTitles = [NSLocalizedString("emoji", comment: ""),
                                       NSLocalizedString("color", comment: "")]
    
    static let textFieldPlaceholder = NSLocalizedString("textFieldPlaceholder", comment: "")
    static let errorLabel = NSLocalizedString("errorLabel", comment: "")
    static let cancelButton = NSLocalizedString("cancel", comment: "")
    static let createButton = NSLocalizedString("create", comment: "")
    static let saveButton = NSLocalizedString("save", comment: "")
    static let editTrackerTitle = NSLocalizedString("editTrackerTitle", comment: "")
    
    // CategoryViewController
    static let categoryVCTitle = NSLocalizedString("category", comment: "")
    static let categoryVCButton = NSLocalizedString("categoryVCButton", comment: "")
    static let categoryVCPlaceholder = NSLocalizedString("categoryVCPlaceholder", comment: "")
    static let categoryVCReuseIdentifier = "CategoryTableViewCell"
    
    // NewCategoryViewController
    static let newCategoryVCTitle = NSLocalizedString("newCategory", comment: "")
    static let newCategoryVCButton = NSLocalizedString("ready", comment: "")
    static let newCategoryVCTextFieldPlaceholder = NSLocalizedString("newCategoryVCTextFieldPlaceholder", comment: "")
    static let newCategoryVCErrorLabel = NSLocalizedString("newCategoryVCErrorLabel", comment: "")
    
    // ScheduleViewController
    static let scheduleVCTitle = NSLocalizedString("schedule", comment: "")
    static let scheduleVCReuseIdentifier = "ScheduleTableViewCell"
    
    static let scheduleVCTableTitles = [NSLocalizedString("monday", comment: ""),
                                        NSLocalizedString("tuesday", comment: ""),
                                        NSLocalizedString("wednesday", comment: ""),
                                        NSLocalizedString("thursday", comment: ""),
                                        NSLocalizedString("friday", comment: ""),
                                        NSLocalizedString("saturday", comment: ""),
                                        NSLocalizedString("sunday", comment: "")]
    
    static let scheduleVCEverydayDescription = NSLocalizedString("everyDay", comment: "")
    static let scheduleVCButton = NSLocalizedString("ready", comment: "")
}
