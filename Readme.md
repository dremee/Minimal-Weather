It is  a simple clone of original ios weather application. 
I chose to use https://openweathermap.org api. I had several limitations In its free version, but, in general, i had enough for demonstration my skills.

I started from simple. I created view controller, that fetch weather with current location data. I added network in its own class called WeatherInfoController.

Then, i make uitableiviewcontroller class. I embeded it in navigation contoller and add bar button to add new city. Make segue to DetailViewController. 

Next thing what i wanted to do was to save city data. I chose File Manager to keep data. I throught that it best choice for this app. I already have codable data and i needed only save it in plist file. Another way, it was really simple data. I put all save logic in it own class. 

I want the app can keep first row for location search and user can't delete it. I added flag in WeatherDataModel, that controll how data was fetch. If data fetch by location, we keep first row and make it not edditable. All another row are editable. I lost a few days before i find good solution. Then, if user turn off location for app and location row is exist, we delete it. 

In the same time i added ErrorHandling class, that controll Location Auth Status and network error (later i refactored that and make it just enums). I added ErrorView, that appear if something going wrong (for example, user write nonexistent city or network connection is lost). I made it like youtube show network error. In the bottom of Screen.

Then i started thinking about detail view controller. i want that would looks like apple weather app. I chose to use table view with statis cell, but i don't want create UITableViewController. I made embeded view controller in view container. I stay weather logo, city name and current time in Detail View Controller. Another data i was added in embeded table view. I created delegate to refresh data in embeded table. view.

In the end, i created MainLogicViewController like parent Controller for both controllers. It keep locationmanager logic and Timer. 


Я начал приложение с создания просто View Controller'a, который отображал погоду по текущей локации. На этом этапе я вынес всю сетевую логику в отдельный класс. Так же создал модель для получения данных. 
Потом я определился, как будет работать приложение в завершенном виде. Я хотел, что бы оно работало по типу стандартного погодного приложения от Apple, т.е. должен быть table view, который хранит список городов, при этом первую строчку занимает геолокация. Обязательным для меня было то, что строка с геолокация была недоступна для изменения пользователю. 

Следующим этапом было сохранение текущих данных. Я выбрал FileManager, т.к. в данном приложении я уже имел готовую codable model. На тот момент мне показалось это наиболее эффективным решением. 

После создания логики для хранения данных, я начал реализовывать логику для контроля строчки с данными, полученными через геолокацию. Попробовав несколько различных вариантов (не задействуя сохраненные данные), я пришел к выводу, что мне необходимо хранить простое bool значение в своей модели, которое будет контролировать, получен ли запрос через геолокацию или же нет. Я сделал его опциональным, т.к. мне нужно было его сохранять, но при этом не нарушить запрос к серверу. Потом я прописал логику в контроллере. Она получилась довольно громоздкой, но рабочей. 

Мне так же нужно было, что бы приложение правильно вело себя при отсутствии интернета и геолокации (прим. если пользователь выключает геолокацию, соответствующая строка исчезает из списка). Я сделал класс  ErrorHandling, который имел enum   LocationAuthStatus (потом я зарефакторил и убрал класс). Через него я смог контролировать значение Геолокации на устройстве. 

Вместе с этим, я хотел уведомлять пользователя об ошибках, которые возникают с интернетом или с запросом. Для этого я сделал NetworkError, а так-же статичную переменную, к которой мог получить доступ в любой части приложения (Позже мне объяснили, почему это не правильно и показали, как это реализовать правильно). Вместе с этим, я создал вьюху, которая уведомляет пользователя об ошибки (я взял пример приложения youtube, когда при отсутствие интернета снизу показывается полска с информированием).


В самом конце я хотел  улучшить DetailViewController. В первую очередь я добавил логику для обновления данных, когда пользователь долго находится в нем. Так же, внешний вид я постарался сделать похожим на приложение apple. Для этого я использовал embeded view. Обновление информации в нем я реализовал через delegate.

Потом я решил зарефакторить код и вынести location manager и timer  в отдельный view controller и сделать его родительским контроллером.





 



