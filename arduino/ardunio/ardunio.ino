// Include required libraries
#include <TinyGPSPlus.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <addons/TokenHelper.h>
#include <SoftwareSerial.h>

// Define WiFi credentials
#define WIFI_SSID "Enter wifi name"
#define WIFI_PASSWORD "Enter wifi password"

// Define Firebase API Key, Project ID, and user credentials
#define API_KEY "put your Firebase API Key"
#define FIREBASE_PROJECT_ID "Enter your FIREBASE_PROJECT_ID"
#define USER_EMAIL "Enter email made in autehtication section"
#define USER_PASSWORD "Enter its password"

// Define Firebase Data object, Firebase authentication, and configuration
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
TinyGPSPlus gps; // The TinyGPS++ object

SoftwareSerial mygps(4, 2); // Tx, Rx

void setup() {
  Serial.begin(9600);
  mygps.begin(9600);
  Serial.println(F("Arduino - GPS module"));

  // Connect to Wi-Fi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  // Print Firebase client version
  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

  // Assign the API key
  config.api_key = API_KEY;

  // Assign the user sign-in credentials
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  // Assign the callback function for the long-running token generation task
  config.token_status_callback = tokenStatusCallback;  // see addons/TokenHelper.h

  // Begin Firebase with configuration and authentication
  Firebase.begin(&config, &auth);

  // Reconnect to Wi-Fi if necessary
  Firebase.reconnectWiFi(true);
}

void loop() {
  // Ensure that there is data available from the GPS module
  while (mygps.available() > 0) {
    gps.encode(mygps.read());
  }

  // Define the path to the Firestore document
  String documentPath = "Users/adetunji@gmail.com/location_data/data/";

  // Create a FirebaseJson object for storing data
  FirebaseJson content;

  // Read Longitude, Latitude and Date from the GPS module
  if (gps.location.isUpdated()) {
    float latitude = gps.location.lat();
    float longitude = gps.location.lng();

    // Get UTC time from GPS
    int year = gps.date.year();
    int month = gps.date.month();
    int day = gps.date.day();
    int hour = gps.time.hour();
    int minute = gps.time.minute();
    int second = gps.time.second();

    // Adjust time for GMT +1
    hour += 1;
    if (hour >= 24) {
      hour -= 24;
      day += 1;

      // Handle end of month
      if ((month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) && day > 31) {
        day = 1;
        month += 1;
      } else if ((month == 4 || month == 6 || month == 9 || month == 11) && day > 30) {
        day = 1;
        month += 1;
      } else if (month == 2) {
        // Check for leap year
        if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
          if (day > 29) {
            day = 1;
            month += 1;
          }
        } else {
          if (day > 28) {
            day = 1;
            month += 1;
          }
        }
      }

      // Handle end of year
      if (month > 12) {
        month = 1;
        year += 1;
      }
    }

    // Construct the date-time string
    String date_time = String(year) + "-" + String(month) + "-" + String(day) + " " + String(hour) + ":" + String(minute) + ":" + String(second);

    // Print Latitude, Longitude, and adjusted Date-Time values
    Serial.print("Latitude: ");
    Serial.println(latitude, 6);
    Serial.print("Longitude: ");
    Serial.println(longitude, 6);
    Serial.print("Date and Time: ");
    Serial.println(date_time);

    // Check if the values are valid (not NaN)
    if (!isnan(latitude) && !isnan(longitude)) {
      // Set the 'Latitude' and 'Longitude' fields in the FirebaseJson object
      content.set("fields/Latitude/doubleValue", latitude);
      content.set("fields/Longitude/doubleValue", longitude);
      content.set("fields/date_time/stringValue", date_time);

      Serial.print("Update/Add GPS Data... ");

      // Use the patchDocument method to update the Firestore document
      if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str(), content.raw(), "Latitude,Longitude,date_time")) {
        Serial.printf("ok\n%s\n\n", fbdo.payload().c_str());
      } else {
        Serial.println(fbdo.errorReason());
      }
    } else {
      Serial.println("Invalid GPS data.");
    }
  } else {
    Serial.println("No valid GPS data available.");
  }

  // Delay before the next reading
  //delay(5000);

  if (millis() > 5000 && gps.charsProcessed() < 10) {
    Serial.println(F("No GPS data received: check wiring"));
  }
}
