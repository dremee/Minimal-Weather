It is  a simple clone of original ios weather application. 
I chose to use https://openweathermap.org api. I had several limitations In its free version, but, in general, i had enough for demonstration my skills.

I started from simple. I created simple view controller, that get? weather with current location data. I added network in it own class called WeatherInfoController.

Then, i make uitableiviewcontroller class. I embeded it in navigation contoller and add bar button to add new city. Make segue to DetailViewController. 

Next thing what i wanted to do was to save city data. I chose File Manager to keep data. I throught that it best choice for this app. I already have codable data and i needed only save it in plist file. Another way, it was really simple data. I put all save logic in it own class. 

I want the app can keep first row for location search and user can't delete it. I added flag in WeatherDataModel, that controll how data was fetch. If data fetch by location, we keep first row and make it not edditable. All another row are editable. I lost a few days before i find good solution. Then, if user turn off location for app and location row is exist, we delete it. 

In the same time i added ErrorHandling class, that controll Location Auth Status and network error. I added ErrorView, that appear if something going wrong (for example, user write nonexistent city or network connection is lost). I tryed to error view appear at the top of screen, but i  have bad results. It was hard to controll navigation bar in portrait and landscape mode and i chose easy way. I added Error View in the bottom of screen. 

Then i started thinking about detail view controller. i want that would looks like apple weather app. I chose to use table view with statis cell, but i don't want create UITableViewController. I made embeded view controller in view container. I stay weather logo, city name and current time in Detail View Controller. Another data i add in embeded table view. I create delegate to refresh data in embeded table view. 


 



