# **MEALTION — MOBILE APPLICATION FUNCTIONAL SPECIFICATION**

Version: MVP  
Platforms: iOS and Android  
Suggested Framework: Flutter  
Figma: `AajKYbyFqmK1lJuNvFHcgP` — UI Design page (1:3), Design System page (0:1)  
Note: Developer may determine the final architecture, database, infrastructure, libraries, and supporting tools.

\========================================================================================

# **1\. PRODUCT SCOPE**

\========================================================================================

Mealtion is a private Food Memory Journal with friend-based social features.

The application allows users to:  
\- Record meals with photos and meal information.  
\- Browse personal meal history through Calendar, Timeline, and Gallery.  
\- Search previous meals.  
\- View monthly meal summaries.  
\- Organize meals with Base and Custom Bookmarks.  
\- Add friends using an exact Username.  
\- View, Like, Comment, and Bookmark meals shared by accepted friends.

Mealtion is not a public social network.

There must be:  
\- No public accounts.  
\- No public discovery feed.  
\- No suggested posts.  
\- No posts from users who are not accepted friends.  
\- No random account recommendations.

\========================================================================================

# **2\. MVP NAVIGATION**

\========================================================================================

Bottom Navigation contains 5 items:

1\. Home  
2\. Friends  
3\. Add Meal  
4\. Gallery  
5\. Profile

Add Meal is the center action and opens as a Bottom Sheet.

\========================================================================================

# **3\. AUTHENTICATION**

\========================================================================================

## **3.1 Sign Up**

Sign Up method:  
\- Email  
\- Password

The user must verify the email address before entering Onboarding.

## **3.2 Login**

Users log in using:  
\- Email  
\- Password

## **3.3 Forgot Password**

\- User submits their email address.  
\- The system sends a password reset link.

## **3.4 Delete Account**

Delete Account requires:  
\- Password confirmation.  
\- A second confirmation dialog.

After confirmation, permanently delete:  
\- Account information  
\- Meals  
\- Uploaded meal photos  
\- Likes  
\- Comments  
\- Friend relationships  
\- Friend requests  
\- Custom Bookmark Collections  
\- Uploaded Bookmark covers/icons  
\- Notification history

\========================================================================================

# **4\. ONBOARDING**

\========================================================================================

Onboarding begins after email verification.

## **Step 1: Profile Identity**

\- Display Name  
\- Username

## **Step 2: Profile Information**

\- Profile Photo  
\- Bio

## **Step 3: Currency**

\- Select the primary currency from a currency list.

## **Step 4: Price Threshold**

\- Set two numerical price thresholds.

## **Step 5: Permissions**

\- Photo Library  
\- Camera  
\- Notifications

## **Required fields:**

\- Display Name  
\- Username  
\- Primary Currency  
\- Price Threshold values

## **Optional/skippable:**

\- Profile Photo  
\- Bio  
\- Permission requests

Users may grant permissions later from device settings.

\========================================================================================

# **5\. USER ACCOUNT RULES**

\========================================================================================

## **5.1 Display Name**

\- Required  
\- Length: 1–30 characters  
\- Supports all languages

## **5.2 Bio**

\- Optional  
\- Maximum length: 150 characters  
\- Supports all languages

## **5.3 Profile Photo**

\- Optional  
\- If absent, display the application's default avatar.

## **5.4 Username**

Rules:  
\- Required  
\- Globally unique  
\- Length: 4–20 characters  
\- Only lowercase English letters and numbers  
\- No spaces  
\- No special characters

Username may be changed once every 30 days.

After a Username is changed:  
\- The previous Username cannot locate the account.  
\- The previous Username is reserved for 30 days.  
\- After 30 days, another user may register it.

\========================================================================================

# **6\. HOME SCREEN** (Figma 1-1)

\========================================================================================

Home contains:

1\. Greeting  
2\. Notification icon  
3\. Meal Calendar  
4\. Monthly Snapshot  
5\. Recap cards  
6\. Recent Meals

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **6.1 Meal Calendar**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

The Calendar displays only the signed-in user's meals, including Private Meals.

Calendar controls:  
\- Previous month  
\- Next month  
\- Current selected month/year  
\- Indicator filter

Tapping the month/year opens a Month and Year selection popup.

Available Calendar indicator filters:  
\- Price  
\- Heaviness  
\- Feeling

Color mapping:

Price:  
\- Green: Affordable  
\- Yellow: Moderate  
\- Red: Expensive  
\- Gray: No price data

Heaviness:  
\- Green: Light  
\- Yellow: Satisfying  
\- Red: Heavy  
\- Gray: No heaviness data

Feeling:  
\- Green: Like  
\- Yellow: Neutral  
\- Red: Dislike  
\- Gray: No feeling data

Each meal is represented by one dot.

If a date contains up to 3 meals:  
● ● ●

If a date contains more than 3 meals:  
● ● ●  
  \+2

The first 3 dots follow meal time order.  
The number after “+” represents the remaining meals.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **6.2 Calendar Meal Popup**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

Tapping a date opens a Meal Card Popup.

Behavior:  
\- Open the first meal of that date based on meal time.  
\- Swipe up to view the next meal.  
\- Swipe down to view the previous meal.  
\- Part of the next card must remain visible below the current card to communicate vertical swiping.  
\- Vertical meal navigation is available only when opening meals from the Calendar.

If a meal contains multiple photos:  
\- Swipe left/right inside the photo area.  
\- Display photo pagination, such as dots or “1/5”.

Popup information:  
\- Date  
\- Time  
\- Photos  
\- Meal names  
\- Restaurant and Branch, when applicable  
\- Actual Price, when available  
\- Heaviness, when available  
\- Feeling, when available  
\- Note, when available  
\- Edit button for the owner  
\- Close button

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **6.3 Monthly Snapshot**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

Monthly Snapshot follows the month selected in the Calendar.

Metrics:

Meals  
\- Number of successfully published meals in the selected month.

Foods  
\- Number of unique Food names in the selected month.

Places  
\- Number of unique Restaurant and Branch combinations.  
\- Home meals are not counted as Places.

Spent  
\- Sum of meals containing Price.  
\- Drafts are excluded.  
\- All prices are converted to the user's selected primary currency.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **6.4 Recap**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

Display cards for:  
\- Monthly Wrapped  
\- Yearly Wrapped

For MVP:  
\- Cards are visible.  
\- Opening them displays a “Coming Soon” state.  
\- Full Wrapped calculation is a future feature.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **6.5 Recent Meals**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

Display the user's latest 3 successfully published meals.

Order:  
\- Meal Date and Time, newest first.

Include:  
\- Public-to-friends meals  
\- Private Meals

Each card displays:  
\- Cover photo  
\- Meal names  
\- Restaurant and Branch when applicable  
\- Actual Price when available  
\- Heaviness when available  
\- Feeling when available  
\- Bookmark state

Meal names:  
\- Display all Food names separated by spaces.  
\- Maximum 2 lines.  
\- Truncate overflowing text with “...”.

“View All” opens the user's full meal Timeline.

\========================================================================================

# **7\. ADD MEAL** (Figma 3-1)

\========================================================================================

Add Meal opens as a Bottom Sheet.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **7.1 Add Meal Header**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

Header contains:  
\- Title: Add Meal  
\- Close button  
\- Draft button, only when at least one Draft exists

Tapping Draft opens the Draft Meals screen.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **7.2 Meal Photos**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

Photos are required.

Rules:  
\- Minimum: 1 photo  
\- Maximum: 10 photos  
\- Sources:  
  \- Camera  
  \- Photo Library  
\- Multiple photos may be selected from the Photo Library at once.  
\- The first photo is the meal cover.  
\- Long press and drag to reorder photos.  
\- The photo in the first position becomes the new cover.  
\- Photos may be removed before saving.

The cover photo is used in:  
\- Feed  
\- Home Recent  
\- Timeline  
\- Gallery  
\- Profile  
\- Search results  
\- Bookmark grids  
\- Initial Place/Food item icon

If permission is denied:  
\- Other application features remain usable.  
\- Add Meal explains that at least one photo is required.  
\- Display an “Open Settings” action.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **7.3 Date and Time**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

\- Automatically obtain Date and Time from the first photo's metadata.  
\- The user may edit both fields.  
\- Future Date or Time is not allowed.  
\- If metadata contains a future value, use the current Date and Time and notify the user.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **7.4 Meal Names**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

\- Required  
\- A meal may contain multiple Food names.  
\- Each Food name is displayed as an individual editable chip/block.  
\- Users may add, edit, or remove individual Food names.  
\- At least one Food name is required before publishing.  
\- Duplicate Food names within the same meal are not allowed.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **7.5 Source**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

Source is required.

Options:  
\- Restaurant  
\- Delivery  
\- Home

Default:  
\- Restaurant

Restaurant:  
\- Restaurant is required.  
\- Branch is optional.

Delivery:  
\- Restaurant is required.  
\- Branch is optional.

Home:  
\- Restaurant and Branch fields are disabled.  
\- Existing Restaurant and Branch values are cleared.

There is no “Other” Source option.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **7.6 Restaurant and Branch**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

Restaurant:  
\- Search from restaurants previously created by the user.  
\- If no result exists, create a new Restaurant immediately.

Branch:  
\- Display branches belonging to the selected Restaurant.  
\- Search existing branches.  
\- Create a new Branch immediately if no result exists.

Prevent duplicate Restaurant and Branch combinations for the same user.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **7.7 Tags**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

\- Optional  
\- Multiple Tags allowed  
\- Search the user's existing Tags while typing  
\- Create a new Tag immediately if no result exists  
\- Prevent duplicate Tags in the same meal  
\- Tags belong to each user's personal Tag collection

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **7.8 Price**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

Price is optional.

\- One total Price per meal.  
\- Price is not assigned separately to each Food item.  
\- If no Price is entered, do not display a Price Level.  
\- If Price is entered, calculate Price Level automatically.  
\- The user cannot manually override the calculated level.

Price Levels:  
\- Affordable  
\- Moderate  
\- Expensive

The level is calculated from the user's Price Threshold settings.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **7.9 Heaviness**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

Optional, single selection.

Options:  
\- Light — Green  
\- Satisfying — Yellow  
\- Heavy — Red

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **7.10 Feeling**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

Optional, single selection.

Options:  
\- Like — Green  
\- Neutral — Yellow  
\- Dislike — Red

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **7.11 Note**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

\- Optional  
\- Plain text  
\- Supports all languages  
\- Displayed in Feed and Meal Detail

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **7.12 Private Meal**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

A Private Meal toggle is displayed near the bottom of Add Meal.

Default:  
\- OFF

When OFF:  
\- Accepted friends can view the meal.

When ON:  
\- Only the owner can view the meal.  
\- Do not display the meal in Friends Feed or Friend Profile.

Every new Add Meal screen starts with Private Meal OFF.  
Do not remember the previous selection.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **7.13 Publishing**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

Save requirements:  
\- At least 1 photo  
\- At least 1 Meal/Food name  
\- Valid Date and Time  
\- Source  
\- Restaurant when Source is Restaurant or Delivery

Optional:  
\- Tags  
\- Branch  
\- Price  
\- Heaviness  
\- Feeling  
\- Note

When successfully saved:  
\- Add to Calendar  
\- Add to Gallery  
\- Add to Profile  
\- Add to Home statistics  
\- Add to Friends Feed if not Private  
\- Update Base Bookmark data

If publishing fails because the user is offline:  
\- Automatically save the meal as Draft.  
\- Display:  
  “You're offline. This meal has been saved to Drafts. Check your connection and try again.”

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **7.14 Closing Add Meal**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

If no data has changed:  
\- Close immediately.

If unsaved data exists:  
\- Display a centered confirmation popup.

Popup:

“Do you want to leave this meal?  
Unsaved information will be lost.”

Actions:  
\- Discard — destructive/red  
\- Save as Draft  
\- Cancel

\========================================================================================

# **8\. DRAFT MEALS**

\========================================================================================

Draft behavior:  
\- May be saved even if required fields are incomplete.  
\- Does not appear in Calendar.  
\- Does not appear in Gallery.  
\- Does not appear in Profile.  
\- Does not appear in Feed.  
\- Does not affect statistics.  
\- Does not expire automatically.

Draft button:  
\- Display beside the Add Meal title only if at least one Draft exists.

Draft list:  
\- Grid layout  
\- 3 images per row  
\- Use the first photo as cover  
\- If no photo exists, use a default Draft placeholder  
\- Tapping a Draft opens Add Meal with its saved data

Draft menu:  
\- “…” button at the top-right  
\- Select  
\- Multi-select Drafts  
\- Delete  
\- Confirmation required before permanent deletion

\========================================================================================

# **9\. EDIT AND DELETE MEAL**

\========================================================================================

Owners may edit their meals.

If Save fails while editing:  
\- Keep the user on the Edit screen.  
\- Preserve currently entered information while the screen remains open.  
\- Display:  
  “You're offline. Check your connection and try again.”  
\- Do not create an automatic Draft.  
\- Do not use an offline synchronization queue.

If leaving Edit Meal with unsaved changes:  
\- Display:  
  \- Discard Changes  
  \- Continue Editing

When changing a published meal to Private:  
\- Immediately hide it from Friends Feed.  
\- Immediately hide it from Friend Profiles.  
\- Hide it from friends' Custom Bookmark screens.  
\- Preserve existing Like and Comment data.  
\- If changed back to non-Private while the friendship still exists, restore access.

Deleting a Meal:  
\- Requires confirmation.  
\- Remove the Meal from:  
  \- Calendar  
  \- Gallery  
  \- Profile  
  \- Feed  
  \- Statistics  
  \- Search  
  \- Custom Bookmark display  
\- Delete Likes and Comments belonging to that Meal.

Base Bookmark rules after deletion:  
\- Keep Place/Food if another Meal references it.  
\- If no Meals reference it, delete the item automatically.  
\- If its automatic icon used the deleted Meal, use the first image of another related Meal.

\========================================================================================

# **10\. FRIENDS**

\========================================================================================

Friends screen contains two tabs:  
\- Feed  
\- Friends

Header includes an Add Friend icon.  
Display an unread badge for pending received Friend Requests.

\========================================================================================

# **11\. ADD FRIEND / CONNECT**

\========================================================================================

Users add friends using an exact Username.

Search behavior:  
\- User must type the complete Username.  
\- No partial matching.  
\- No suggested accounts.  
\- No contact matching.  
\- No QR Code in MVP.  
\- No search by Display Name.  
\- If no exact account exists, display a no-result state.

Search result displays:  
\- Profile Photo  
\- Display Name  
\- Username  
\- Relationship action/status:  
  \- Add Friend  
  \- Requested  
  \- Friends

Before friendship is accepted, the searching user may see only:  
\- Profile Photo  
\- Display Name  
\- Username  
\- Send Request action

Do not expose:  
\- Meals  
\- Statistics  
\- Friends list  
\- Collections  
\- Badges

\========================================================================================

# **12\. FRIEND REQUESTS**

\========================================================================================

Friend Requests screen contains:

Received  
\- Accept  
\- Delete

Sent  
\- Pending status  
\- Cancel Request

Rules:  
\- The sender may cancel a pending request.  
\- A duplicate request cannot be sent while one is pending.  
\- Requests do not expire automatically.  
\- Friendship begins only after acceptance.

\========================================================================================

# **13\. FRIENDS LIST** (Figma 2-4 Connect, 2-5 User Search)

\========================================================================================

Display:  
\- Profile Photo  
\- Display Name  
\- Username  
\- Friends status button  
\- Remove/X action

Search:  
\- Search accepted friends by partial Display Name or Username.  
\- Search is limited to the user's existing Friends list.

Unfriend:  
\- Requires a confirmation popup.  
\- Example:  
  “Unfriend @username?”  
\- Actions:  
  \- Cancel  
  \- Unfriend

After Unfriend:  
\- Both users immediately lose access to each other's shared Meals.  
\- Previously saved Meals are hidden from Custom Bookmark screens.  
\- Historical Bookmark references may remain in backend storage.  
\- Inaccessible references must not be displayed in the UI.  
\- If the users become friends again and the Meal is still shareable, the saved Bookmark may become visible again.  
\- Previous Likes and Comments remain stored but inaccessible until access is restored.

\========================================================================================

# **14\. FRIENDS FEED** (Figma 2-1)

\========================================================================================

Feed contains only meals belonging to accepted friends.

Do not include:  
\- The signed-in user's own meals  
\- Private Meals  
\- Meals from non-friends  
\- Suggested posts  
\- Advertisements  
\- Public content

Sort order:  
1\. Meal Date and Time, newest first  
2\. If Date and Time are equal, latest published Meal first

Editing a Meal does not change its Feed position unless its Meal Date or Time changes.

Loading:  
\- Initial load: 20 posts  
\- Infinite scroll  
\- Load 20 additional posts per batch  
\- Pull to Refresh  
\- Opening the application starts Feed at the newest post  
\- When no more posts exist, display:  
  “You're all caught up”

Empty states:

No friends:  
“Add friends to share your food memories”  
Action: Find Friends

Friends exist but no available posts:  
“No meals shared yet”

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **14.1 Feed Card**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

Display:  
\- Friend Profile Photo  
\- Display Name/Username  
\- Relative or meal time  
\- Meal photos  
\- Meal names  
\- Restaurant and Branch  
\- Price or Price Level according to the owner's privacy setting  
\- Heaviness  
\- Feeling  
\- Note  
\- Like action and count  
\- Comment action and count  
\- Bookmark action

Hide any field without data.

Meal names:  
\- Display all names separated by spaces.  
\- Maximum 2 lines.  
\- Truncate with “...”.

A “…” menu must not be displayed on another user's post.

Owner-only Edit/Delete actions are available from the owner's personal Meal Detail, Gallery, Profile, or Calendar—not from Friends Feed because the Feed excludes the owner's posts.

\========================================================================================

# **15\. FEED DETAIL**

\========================================================================================

Tapping a Feed image/card opens Feed Detail.

Display:  
\- User information  
\- Meal photos  
\- Meal information  
\- Like action and count  
\- Bookmark action  
\- Comments  
\- Add Comment field fixed near the bottom

Multiple photos:  
\- Swipe left/right  
\- Display pagination

Do not support vertical swiping to another Meal from Feed Detail.

\========================================================================================

# **16\. LIKES**

\========================================================================================

\- Users can Like and Unlike a Meal.  
\- One Like state per user per Meal.  
\- Users may Like their own Meals.  
\- Own Like counts normally.  
\- Do not notify a user when they Like their own Meal.  
\- Display only Like count.  
\- Like count is not clickable.  
\- Users cannot view the list of people who Liked a Meal.  
\- Notify the owner when another user Likes.  
\- Do not notify on Unlike.

Grouped Like Notification example:  
“Alex and 4 others liked your meal.”

\========================================================================================

# **17\. COMMENTS** (Figma 2-2 Comment sheet)

\========================================================================================

\- Plain text only  
\- No images  
\- No Replies  
\- No Comment editing  
\- No Mentions in MVP  
\- Display oldest Comment first  
\- New Comments appear at the bottom

Permissions:  
\- A user may delete their own Comment.  
\- A Meal owner may delete any Comment on their Meal.  
\- Users may Comment on their own Meals.  
\- Do not notify users about their own Comments.

\========================================================================================

# **18\. GALLERY** (Figma 4-1 Timeline, 4-2 Grid)

\========================================================================================

Gallery is Bottom Navigation item 4\.

Default screen:  
\- Timeline view

Components:  
\- Search bar  
\- Selected Month and Year  
\- Previous month  
\- Next month  
\- Timeline/Grid toggle  
\- Bookmark icon

Tapping Month/Year:  
\- Open Month and Year selection popup.

When no meals exist in the selected month:  
\- Display an Empty State.  
\- Month navigation remains available.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **18.1 Timeline View**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

\- Group Meals by Date.  
\- Sort Date and Time newest first.  
\- Display Meal cards.

Each card includes:  
\- Cover photo  
\- Meal names  
\- Restaurant and Branch  
\- Actual Price  
\- Heaviness  
\- Feeling  
\- Bookmark state

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **18.2 Grid View**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

\- 3 columns  
\- Cover photo only  
\- Sort newest first  
\- If a Meal contains multiple photos, display a multiple-photo icon

Tapping a Grid item:  
\- Open that Meal Popup/Detail.  
\- Swipe left/right to view photos within that Meal.  
\- Do not swipe vertically to another Meal.  
\- The user must close the Popup and select another Grid item.

\========================================================================================

# **19\. GALLERY SEARCH** (Figma 4-3)

\========================================================================================

Tapping the Search bar opens the dedicated Search screen.

Search only the signed-in user's Meals.

Searchable fields:  
\- Food/Meal names  
\- Restaurant  
\- Branch  
\- Tags

Behavior:  
\- Partial text matching  
\- Case-insensitive where applicable  
\- Supports all languages  
\- No Filter button  
\- No advanced filtering in MVP

Results:  
\- Grid layout  
\- 3 columns  
\- Cover photo  
\- Newest Meal first

Tapping a result:  
\- Open that Meal.  
\- Swipe left/right between photos within the Meal.  
\- No vertical navigation to another Meal.

\========================================================================================

# **20\. BOOKMARK OVERVIEW** (Figma 4-4 Collections, 4-5 Base detail, 4-6 Custom detail)

\========================================================================================

Bookmark is accessed from the Bookmark icon in Gallery.

Bookmark contains:

Base:  
\- Place  
\- Food

Your:  
\- User-created Custom Bookmark Collections

Base and Custom Collections must be visually separated.

\========================================================================================

# **21\. BASE BOOKMARK**

\========================================================================================

Base Bookmark categories are generated automatically from published Meal data.

Categories:  
\- Place  
\- Food

The cover artwork for Base “Place” and “Food” categories:  
\- Is supplied by the application.  
\- Cannot be changed by the user.  
\- May support purchasable themes in the future.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **21.1 Place**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

A Place item represents:  
\- Restaurant \+ Branch

Rules:  
\- Same Restaurant with different Branches creates separate Place items.  
\- Home meals do not create Place items.

Place list:  
\- Group/sort alphabetically.  
\- Display an icon beside each Place.  
\- Display Restaurant and Branch.

Tapping a Place:  
\- Open a 3-column Grid of all related Meals.  
\- Sort newest first.  
\- Tapping a Meal opens that Meal.  
\- Only left/right photo navigation is available.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **21.2 Food**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

A Food item represents one Food name.

Rules:  
\- The same Food name is combined across different Restaurants.  
\- Each Meal may belong to multiple Food items.  
\- Users may later edit names or merge duplicated Food items caused by different spelling.

Food list:  
\- Group/sort alphabetically.  
\- Display an icon beside each Food.

Tapping a Food:  
\- Open a 3-column Grid of all Meals containing that Food.  
\- Sort newest first.  
\- Tapping a Meal opens that Meal.  
\- Only left/right photo navigation is available.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **21.3 Place/Food Item Icon**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

The icon for an individual Place or Food item may use:  
\- The first photo of a related Meal  
\- Another photo from a previously recorded Meal  
\- A new external image uploaded from the device, such as:  
  \- Restaurant logo  
  \- Country flag  
  \- Illustration

Default:  
\- Use the first photo of the first related Meal.

Automatic icon behavior:  
\- If the first photo changes, use the new first photo.  
\- If the first photo is deleted, use the next photo.  
\- If the source Meal is deleted, use the first photo of another related Meal.

Manual icon behavior:  
\- Once the user manually selects or uploads an icon, do not replace it automatically.  
\- Uploaded external images remain stored even if all related Meals are deleted.  
\- Remove or replace them only through explicit user action.

\========================================================================================

# **22\. CUSTOM BOOKMARK COLLECTIONS**

\========================================================================================

Users may create Custom Bookmark Collections.

Collection fields:  
\- Collection Name  
\- Cover Image

Cover behavior:  
\- Empty Collection uses the application's default cover.  
\- When the first Meal is added, use that Meal's cover by default.  
\- User may replace the cover with:  
  \- A photo from a recorded Meal  
  \- An external image uploaded from the device  
\- External cover images remain stored independently from Meals.

Saving Meals:  
\- Users may save their own Meals.  
\- Users may save friends' accessible Meals.  
\- One Meal may be saved to multiple Collections.  
\- Tapping Bookmark opens a Collection selection popup.  
\- If no Custom Collection exists, the popup provides a Create Collection action.

Collection screen:  
\- 3-column Grid  
\- Sort by most recently saved item first  
\- Tapping an item opens the original Meal

Collection “…” menu:  
\- Edit Collection  
\- Select Items  
\- Remove selected items  
\- Delete Collection

Deleting a Collection:  
\- Requires confirmation.  
\- Does not delete original Meals.

Saved friend Meal behavior:  
\- The Bookmark is a reference to the original Meal.  
\- Display the latest Meal information.  
\- If the owner deletes the Meal, hide it.  
\- If the owner changes it to Private, hide it.  
\- If friendship ends, hide it.  
\- The backend may retain the reference.  
\- Do not expose inaccessible items in the UI.  
\- If access is restored later, the item may become visible again.

\========================================================================================

# **23\. PROFILE** (Figma 5-1)

\========================================================================================

Profile displays:  
\- Header/cover area  
\- Profile Photo  
\- Display Name  
\- Bio  
\- Username  
\- Friendship status when viewing a friend  
\- Statistics  
\- Timeline/Grid selector  
\- Month selector  
\- Badges tab

Do not display Calendar in Profile.

Profile statistics:  
\- Meals  
\- Foods  
\- Places  
\- Friends

Owner view:  
\- Count all of the owner's Meals, including Private Meals.

Friend view:  
\- Count only Meals visible to that friend.  
\- Foods and Places are calculated only from visible Meals.  
\- Friend-visible totals may differ from owner totals.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **23.1 Owner Profile**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

Owner actions:  
\- Edit Profile  
\- Settings

Do not show a “…” menu.

Owner meal cards display:  
\- Actual Price only  
\- Do not display both Price and Price Level simultaneously.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **23.2 Friend Profile**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

Before friendship:  
\- Meal content and statistics are hidden.

After friendship:  
\- Display only non-Private Meals.  
\- Display statistics based only on visible Meals.

Friend button:  
\- Shows friendship status.  
\- Tapping it allows Unfriend.  
\- Unfriend requires confirmation.

Do not show a “…” menu.  
Block and Report are not included in MVP.

\------------------------------------------------------------------------------------------------------------------------------------------------------------

## **23.3 Profile Meal Views**

\------------------------------------------------------------------------------------------------------------------------------------------------------------

Available views:  
\- Timeline  
\- Grid  
\- Badges

Timeline and Grid:  
\- Previous month  
\- Next month  
\- Month/Year popup selector  
\- Default to current month  
\- Owner view includes all owner Meals.  
\- Friend view includes only accessible Meals.

Timeline:  
\- Group by Date  
\- Newest first

Grid:  
\- 3 columns  
\- Cover photos  
\- Tapping opens the selected Meal  
\- No vertical navigation between Meals

Badges:  
\- Tab is visible in MVP.  
\- Display “Coming Soon”.  
\- Badge earning logic is a future feature.

\========================================================================================

# **24\. PRICE THRESHOLDS**

\========================================================================================

The user sets two values:

Example:  
\- First threshold: 100  
\- Second threshold: 500

Classification:  
\- Affordable: Price ≤ first threshold  
\- Moderate: Price \> first threshold and ≤ second threshold  
\- Expensive: Price \> second threshold

Validation:  
\- No negative values  
\- Second threshold must be greater than first threshold

Users may edit thresholds in Settings.

When thresholds change:  
\- Recalculate the Price Level of all historical Meals.  
\- Do not change stored original Price amounts.  
\- Update Calendar colors and statistics accordingly.

\========================================================================================

# **25\. PRICE DISPLAY PRIVACY**

\========================================================================================

Users select how friends see Price:

Options:  
\- Actual Price — default  
\- Price Level

Actual Price example:  
\- 450฿

Price Level example:  
\- Moderate

Rules:  
\- Account-level setting  
\- Applies to all existing and future shared Meals  
\- Changes apply retrospectively  
\- Does not require editing each Meal  
\- If no Price exists, display neither Actual Price nor Price Level

Owner's personal screens:  
\- Display Actual Price only.  
\- Do not display both Price and Level together.

\========================================================================================

# **26\. CURRENCY**

\========================================================================================

Settings contains a currency list.

\- English is the only UI language in MVP.  
\- User-generated content supports all languages.  
\- Multiple currencies are supported.  
\- Currency symbols and thresholds follow the selected primary currency.

Price storage must retain:  
\- Original amount entered  
\- Original currency  
\- Exchange rate used  
\- Exchange-rate timestamp/date  
\- Converted amount in the user's primary currency

When saving a Meal:  
\- Use the latest available exchange rate at the time of saving.  
\- Freeze that rate for the Meal.  
\- If the date is a holiday/non-rate date, use the latest available previous rate.  
\- If rate retrieval fails, retain the original Price and calculate later.

When changing primary currency:  
\- Convert historical Meals using the exchange rate available when the currency setting is changed.  
\- Preserve the original entered amount and currency.  
\- Recalculate Monthly Spent.  
\- Recalculate Price Levels using thresholds in the new primary currency.

Monthly Spent:  
\- Convert all included Meals to the selected primary currency.  
\- Combine converted values into one total.

Meal Detail may provide an action on Price to view:  
“Originally \[amount\] \[currency\]”

Exchange-rate provider:  
\- Developer may choose the implementation.  
\- MVP recommendation: Frankfurter-compatible exchange-rate data.  
\- Provider must support the currencies offered by the application.  
\- Application logic must not be tightly coupled to a single provider.

\========================================================================================

# **27\. NOTIFICATIONS**

\========================================================================================

Notification types:  
\- Received Friend Request  
\- Friend Request accepted  
\- Meal Like  
\- Meal Comment

Delivery:  
\- In-app Notification Center  
\- Push Notifications

Users may enable/disable Push Notifications by type in Settings.

Notification destinations:  
\- Friend Request → Friend Requests screen  
\- Accepted Request → Friend Profile  
\- Like → Feed/Meal Detail  
\- Comment → Meal Detail and scroll to the relevant Comment

Unavailable content:  
“This meal is no longer available.”

Notification Center:  
\- Sort newest first  
\- Initial load: 20  
\- Infinite scroll in batches of 20  
\- Badge counts unread notifications only  
\- Mark All as Read  
\- Keep history for 90 days

Like grouping:  
\- Group multiple Likes on the same Meal.  
\- Example:  
  “Alex and 4 others liked your meal.”

Comments remain separate notifications.

\==================================================

# **28\. SETTINGS**

\==================================================

Settings contains:

Account:  
\- Edit Profile  
\- Email Address  
\- Change Email  
\- Change Password  
\- Change Username

Meal Preferences:  
\- Primary Currency  
\- Price Thresholds  
\- Friend Price Display

Application:  
\- Language  
\- Notification Preferences  
\- App Permissions

Support and Legal:  
\- Help & Support  
\- Privacy Policy  
\- Terms of Service  
\- App Version

Session and Account:  
\- Log Out  
\- Delete Account

Email change:  
\- New email must be verified.

Language:  
\- Setting is present.  
\- English is the only selectable language in MVP.  
\- Additional languages are future features.

App Permissions:  
\- Camera status  
\- Photo Library status  
\- Notification status  
\- Link to device settings

\========================================================================================

# **29\. GENERAL MEAL POPUP RULES**

\========================================================================================

Calendar:  
\- Left/right changes photos.  
\- Up/down changes Meals of the selected date.

All other entry points:  
\- Gallery  
\- Search  
\- Profile  
\- Base Bookmark  
\- Custom Bookmark  
\- Feed

Behavior:  
\- Left/right changes photos within the selected Meal.  
\- Up/down must not change Meals.  
\- User closes the Popup and selects another Meal manually.

\==================================================

# **30\. PRIVACY AND ACCESS RULES**

\==================================================

A Meal is accessible to another user only when:  
\- They are accepted friends.  
\- The Meal is not Private.  
\- The Meal still exists.

When access is lost:  
\- Hide the Meal from Feed.  
\- Hide it from Friend Profile.  
\- Hide it from Custom Bookmark UI.  
\- Direct links show “This meal is no longer available.”  
\- Backend references may remain for possible future restoration.  
\- Do not expose hidden Meal information, photo, title, Price, or metadata.

\========================================================================================

# **31\. LOADING, ERROR, AND EMPTY STATES**

\========================================================================================

Every data-driven screen must support:  
\- Loading state  
\- Empty state  
\- Error state  
\- Retry action where appropriate

User-friendly offline message:  
“You're offline. Check your connection and try again.”

Do not show:  
\- Raw server messages  
\- Database errors  
\- Stack traces  
\- Technical error codes without a user-readable explanation

Prevent duplicate submission when:  
\- Publishing a Meal  
\- Sending a Friend Request  
\- Posting a Comment  
\- Creating a Collection  
\- Accepting a Friend Request

\========================================================================================

# **32\. FUTURE FEATURES / OUT OF MVP**

\========================================================================================

\- Badge earning system  
\- Monthly Wrapped content  
\- Yearly Wrapped content  
\- Public profiles  
\- Public Feed  
\- Suggested users  
\- Suggested posts  
\- QR Code friend adding  
\- Contact synchronization  
\- Report and Block  
\- Reply to Comment  
\- Comment editing  
\- Image Comments  
\- Mentions  
\- Advanced Gallery filters  
\- Tablet application  
\- Web application  
\- Additional UI languages  
\- Export Data  
\- Theme marketplace  
\- Purchasable Base Bookmark themes

\========================================================================================

# **33\. MVP ACCEPTANCE SUMMARY**

\========================================================================================

The MVP is considered functionally complete when a user can:

1\. Register and verify an email.  
2\. Complete required Onboarding.  
3\. Configure currency and Price Thresholds.  
4\. Create a Meal with 1–10 photos.  
5\. Save incomplete Meals as Drafts.  
6\. Publish public-to-friends or Private Meals.  
7\. Browse personal Meals through Calendar, Timeline, Grid, and Search.  
8\. View Monthly Snapshot statistics.  
9\. Automatically organize Meals into Place and Food.  
10\. Create and manage Custom Bookmark Collections.  
11\. Find another user using an exact Username.  
12\. Send, receive, accept, delete, and cancel Friend Requests.  
13\. View only accepted friends' shared Meals in Feed.  
14\. Like, Comment, and Bookmark accessible Meals.  
15\. Hide inaccessible bookmarked Meals without necessarily deleting their backend references.  
16\. Edit, privatize, and delete owned Meals.  
17\. Receive and manage Notifications.  
18\. Configure Profile, Price privacy, Currency, Notifications, and Account settings.