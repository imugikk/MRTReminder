# MRTReminder

A description of this package.

MRT Reminder is a package that can be used on the MRT App in order to add reminders for the user whenever they arrived on the final station, so that they will not miss their destination. This allows the users to play their phone, view the scenery, put on their headphones, or even sleep without needing to be afraid of missing their destination.

MRT Reminder will also notify the users when they have arrived on the station before the final station, so that they can prepare to get off the train. Other than that, it will also notify them if they missed their final station, and will ask them to immediately get off the train to change their lane. Lastly, it will also notify the user if they take the wrong train that's headed for the opposite direction. In addition to that, there's also the live tracking feature that can used to display the train journey's current progress on the app's user interface, or on the live activity widget on the user's lock screen.

How to get started on using MRT Reminder: 
> Step 1 --> project configuration: 
Go to the app's target, open the signing and capabilities tab, add the background mode capabilities, and check location updates. Aftter that, open the info tab, and add the "Privacy - Location When In Use Usage Description" and the "Privacy - Location Always and When In Use Usage Description" keys. make sure to fill out the value as well.

> Step 2 --> setup permissions: 
Put these two lines in your app's initialization code: 
    MRTReminderCenter.shared.requestLocationPermission()
    MRTReminderCenter.shared.requestNotificationPermission()

> Step 3 --> register station list: 
Fill in the station list with their names and coordinates in your app's initialization flow. 
For example : 
    MRTReminderStationList.register(stations: [
        MRTReminderStation(name: "Ujung Alesha", coordinate: (-6.29365, 106.61697)),
        MRTReminderStation(name: "Alesha", coordinate: (-6.29259, 106.61673)),
        MRTReminderStation(name: "Kosan", coordinate: (-6.29239, 106.61824)),
        MRTReminderStation(name: "Pos Satpam", coordinate: (-6.29376, 106.61814)),
        MRTReminderStation(name: "Pertigaan", coordinate: (-6.29463, 106.61916)),
        MRTReminderStation(name: "Ruko", coordinate: (-6.29379, 106.62028)),
        MRTReminderStation(name: "Anartha", coordinate: (-6.29212, 106.62048)),
        MRTReminderStation(name: "Parkiran", coordinate: (-6.29089, 106.61991)),
    ])  
Note: the stations must be placed in order because the stations that are placed next to each other will be regarded as being neighboring stations

> Step 4 --> on user tap in, create a request, then activate the reminder: 
let request = MRTReminderRequest(
    startingStation: MRTReminderStationList.getStation(withName: "Kosan"),
    destinationStation: MRTReminderStationList.getStation(withName: "Ruko")
)
MRTReminderCenter.shared.activateReminder(request: request)

> Step 5 --> setup the progress delegate on user tap in: 
MRTReminderCenter.shared.progressDelegate = self

> Step 6 --> monitor for train's current progress: 
implement the MRTReminderProgressDelegate on one of your class, and implement the reminderProgressUpdated method on that class, where you can track the progress changes for the train's journey

> Step 7 --> on user tap out, deactivate the reminder: 
MRTReminderCenter.shared.deactivateReminder()
