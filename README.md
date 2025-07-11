<div align="center">
  <img width="300" height="1021" alt="icon_transparent" src="https://github.com/user-attachments/assets/8927d919-9070-45a4-9f51-e29e5e7c11d3" />
</div>

# What is IRIS?
IRIS is an innovative accessibility and communication app, designed to connect and empower users of all abilities. Created as my graduation project, IRIS brings inclusive, real-time connection to everyone.

# *5* Solutions
## 1. [Universal Chat](https://www.canva.com/design/DAGsHMahygk/-_TARObFNUswTgDmMvxL7g/view?utm_content=DAGsHMahygk&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h7569556a9c#4)
More than just basic text messaging, it provides a rich, interactive communication experience with the following options and enhancements:
- Seamless integration between text, audio, video chatting, so that any user can choose whatever methods of communications that suits them.
- Real-time Speech-to-Text option that instantly converts audio sentences to text and displays it on both ends in real-time.
- Real-time Sign-Language-to-Text Option that similarly converts letter-signs to text in real-time and displays it for both users.
- Video & Audio Controls: Direct access to video and audio options from the chat interface, including toggling video, enabling sign language (ASL) mode, enabling Speech-to-Text mode and muting/unmuting audio. 

<img width="246" height="548" alt="width_246" src="https://github.com/user-attachments/assets/26c97106-1ee7-474c-a26b-485fa9d6f4b9"/> <img width="248" height="550" alt="width_248-1" src="https://github.com/user-attachments/assets/0adf0227-4724-41ca-9777-7157b5ddd8e9" />

## 2. [Pulse Alarm](https://www.canva.com/design/DAGsHMahygk/-_TARObFNUswTgDmMvxL7g/view?utm_content=DAGsHMahygk&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h7569556a9c#14)
An alarm feature that communicates through vision and motion instead of sound:
- Visual and Vibration Alerts: When an alarm triggers, the device can flash and vibrate in a pattern selected by the user, ensuring accessibility for users with hearing impairments.
- Custom Alarm Patterns: Choose the vibration and flash pattern for each alarm, making it suitable for different needs and environments.
- Includes other essential alarm features such as creating and editing alarms, setting alarm labels, repeat options.

## 3. [Glass Magnifier](https://www.canva.com/design/DAGsHMahygk/-_TARObFNUswTgDmMvxL7g/view?utm_content=DAGsHMahygk&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h7569556a9c#20)
A tool designed specifically for people with speech difficulties. Write down what you want to say and Glass Magnifier will make it large and clear for you to show it to other people. You can also convert the magnified text to speech using a built-in speaker button.<br>
<img width="250" height="744" alt="image" src="https://github.com/user-attachments/assets/95aa33d5-f3b2-485f-94ac-8689aa2133be" />


## 4. [Sign Learn](https://www.canva.com/design/DAGsHMahygk/-_TARObFNUswTgDmMvxL7g/view?utm_content=DAGsHMahygk&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h7569556a9c#23)
A feature that takes learning sign language to the next level by providing real-time feedback.
<img width="500" height="819" alt="image" src="https://github.com/user-attachments/assets/85bd0d22-81cc-47c3-a9d9-0f7191d257b9" />

## 5. [Sound Guard](https://www.canva.com/design/DAGsHMahygk/-_TARObFNUswTgDmMvxL7g/view?utm_content=DAGsHMahygk&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h7569556a9c#27)
Made to transform your device into an intelligent environmental sound monitor, providing real-time alerts and accessibility for users with hearing impairments:
 - Continuously listens to the environment and displays the detected sounds plus a decibel (dB) level using a live gauge.
 - Optionally triggers the alarm system for critical sounds, with support for vibration and flash triggers.
 - Users can enable or disable alarm triggers for specific sounds such as smoke alarms, fire alarms, doorbells, sirens, buzzers, beeps, and baby cries.<br>
   <img width="300" height="827" alt="image" src="https://github.com/user-attachments/assets/f57e527d-5c7d-4564-9f9f-0d20610be925" />
   <img width="300" height="827" alt="image" src="https://github.com/user-attachments/assets/cf765011-bc8b-421a-976d-b98a623f30a0" />
   <img width="300" height="828" alt="image" src="https://github.com/user-attachments/assets/16314bf7-e681-472b-a0e6-810746636543" />
# Technical notes
## Backend Architecture
The backend for this project was developed using .NET. It follows the following architecture:
- Controllers: Handle HTTP requests and responses.
-	Models: Define data structures and database entities.
-	Services: Contain business logic and external integrations (e.g., Agora).
-	DbContext: Manages database access via Entity Framework Core.
	Request Input Models: Validate and structure incoming data.

## Flutter Architecture
The project follows a Clean Architecture approach, ensuring separation of concerns and scalability. The main layers are:

1. Presentation Layer
- Contains UI code (Flutter widgets, screens, and pages)
- Uses BLoC (Business Logic Component) for state management
- Handles user interaction and displays data
2. Domain Layer
- Contains business logic and entities
- Defines use cases (application-specific operations)
- Repository interfaces are defined here
3. Data Layer
- Implements repositories and data sources
- Handles API calls, local storage, and platform channels
- Integrates with services like Agora (video), MediaPipe (hand tracking), and local notifications

## MediaPipe Hand Tracking:
The real-time sign language detection feature uses Google’s MediaPipe framework, which runs natively on Android for optimal performance. The native Android code processes camera frames and extracts hand landmarks using MediaPipe. These results are then sent to the Flutter side via platform channels, where they are used for gesture recognition and displayed in the app’s UI.

