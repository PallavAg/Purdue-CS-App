# Purdue CS App

## Table of Contents
1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview
### Description
An app for students enrolled in Computer
Science at Purdue. Allows students to be aware of upcoming events, company recruitment events, and more

### App Evaluation
- **Category:** Education
- **Mobile:** iOS, tab bar controller, uses purdue.io API to fetch classes, GCal to get events, usage of WebViews for viewing certain information, mostly table views
- **Story:** Allows students to stay up to date on current events in CS
- **Market:** Students enrolled in the Computer Science or Data Science programs at Purdue University
- **Habit:** Students could use this app whenever they want - if they need to find more information on upcoming Purdue College of Science events, such as recruitment events or career fairs, they could find out more information through this app when necessary. 
- **Scope:** Currently catering to students in CS to get information about clubs, classes and announcements.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**
- [x] 1) **Announcements/Events**
    - Oppurtunity Update with date prioritization (Including Companies)
    - Ping website on load and add update to table
        - https://www.cs.purdue.edu/corporate/opportunity_update.html
    - The tableview is sectioned off by the headers on the oppurtunity update and can be collapsed by the header
        - The items in the sections are sorted by when they were last added. 
- [x] 2) **Organization + CS events**
    - Subscribing to organizations
    - Viewing org events
    - Uses GCal to parse events

- [x] 3) **Resources**
    - Get Key Fob instructions
    - Get CS Merch
    - Lawson Map
    - CS News Link
    - CS Concern Form (USB website)
    - Purdue.io
    - Oppurtunity update
    - About us

**Optional Nice-to-have Stories**
1) **Classes**
    - Tableview of all the classes
        - Times/Profs and Curriculum
    - CS Tracks
    - Use Purdue.io

### 2. Screen Archetypes

* **Stream 1**
   * View events of subscribed organizations
   * **Settings Subview**
       * Add or remove organizations and choose notification setting
* **Stream 2**
   * Announcements/Events/Opportunity Updates listed in table
   * **Detail View**
       * Link them to another view with description of announcement

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Announcements
* Organizations
* Resources

**Flow Navigation** (Screen to Screen)

* **Announcements**
   * Detail view of a webview with information about the announcement
* **Organizations**
   * Tab bar button showing the settings page to subscribe to more orgs
* **Resources**
   * A page with resources

## Wireframes
<img src="https://i.imgur.com/1U3d4xt.png" width=600>

## Schema 

### Networking
<!-- - [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp] -->
- purdue.io API to parse classes
- WKWebView for displaying websites https://developer.apple.com/documentation/webkit/wkwebview

## Schema 
### Models
#### Post

   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | Title      | String   | Title of opportunity update |
   | Date      | Date   | The date the update was updated|
   | Section      | String   | Which section the update corresponds to|
   | Organization      | String   | unique id for the user post (default field) |
   | Event Title    | String| The title of the event |
   | Event Description         | String     | A description of the event |
   | Event Time       | Time   | The event time in your local time zone, offset by the local time zone offset from UTC|
   | Event Date | Date   | number of comments that has been posted to an image |
   | Resource URL   | URL   | The URL of resources |
   
### Networking
#### List of network requests by screen
   - Announcements
      - (Read/GET) Get info from Opportunity Update site for sections
   - Organizations
      - (Read/GET) Get events from Google Calendar based on existing URLs
   - Resources
      - (Read/GET) Get corresponding websites

#### Existing API Endpoints
##### Oppurtunity Update Website
- Website:

   HTTP Verb | Endpoint| Description
   ----------|----------|------------
    `GET`    | [URL](https://www.cs.purdue.edu/corporate/opportunity_update.html)        | Get all hyperlinks and sections

##### Google Calendar
- Base URL - [https://developers.google.com/calendar](https://developers.google.com/calendar)

   HTTP Verb | Endpoint| Description
   ----------|----------|------------
    `GET`    | /Title | Get event title

## Extra Notes
## Three views
- Admins - the devs
    - Add people who can post for their respective organization
- Head of org/Staff
    - Can write to an org's posts
    - Can create notifications to post to people following the org
    - Allows for special posts for people such as Patricia Morgan who could make notifications for important CS announcements
- Student 
    - Can subscribe to certain notifications from orgs (think Robinhood watchlist)

## Video Walkthrough
### Milestone 1
Milestone 1 implemented user story:

<img src='http://g.recordit.co/KJuLa5O1Yd.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

### Milestone 1
Milestone 1 implemented user story:

<img src='http://g.recordit.co/KJuLa5O1Yd.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

### Milestone 2
Milestone 2 implemented user story:

<img src='http://g.recordit.co/yd2rU9XGfB.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

### Milestone 3
Milestone 3 implemented user story:

<img src='http://g.recordit.co/0lCYF6XVjW.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />
