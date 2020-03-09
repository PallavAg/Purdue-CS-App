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
1) **Organization + CS events**
    - Subscribing to organizations
    - Viewing org events
    - Uses GCal to parse events
2) **Announcements/Events**
    - Oppurtunity Update with date prioritization (Including Companies)
    - Ping website ever 24(?) hours and if there is a change, send a notification and add it
        - https://www.cs.purdue.edu/corporate/opportunity_update.html
3) **Resources**
    - Get Key Fob
    - Get CS Merch
    - Key Resources
    - Lawson Map
    - CS News Link
    - CS Concern Form

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

**Flow Navigation** (Screen to Screen)

* **Announcements**
   * Detail view of a webview with information about the announcement
* **Organizations**
   * Tab bar button showing the settings page to subscribe to more orgs

## Wireframes
[Add picture of your hand sketched wireframes in this section]
<img src="YOUR_WIREFRAME_IMAGE_URL" width=600>

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
<b>under construction... ⚠️</b>

### Networking
<!-- - [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp] -->
- purdue.io API to parse classes
- WKWebView for displaying websites https://developer.apple.com/documentation/webkit/wkwebview

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
