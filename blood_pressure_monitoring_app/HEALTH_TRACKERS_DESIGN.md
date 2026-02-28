# Health Trackers Feature Design Document

## Overview
This document outlines the design for three separate mini-questionnaires (trackers) for monitoring patient health: Sleep Tracker, Blood Pressure Tracker, and Symptom Tracker.

---

## 🎯 Three Tracker Types

### 1. Sleep Tracker 🛌
**Purpose:** Track sleep quality and morning fatigue levels

**Questions:**
1. Today's Date (auto-filled, editable)
2. Yesterday's Last Meal Time (date/time picker)
3. Yesterday's Bed Time (time picker)
4. Today's Wake-up Time (time picker)
5. Sleep Quality Score (0-10 scale)
6. Fatigue Score Within 1 Hour of Waking (1-7 rating with labels)
7. Notes (optional text input)

**Entry Point:** Card on home screen
**Skip Functionality:** No skip buttons (all required except notes)

---

### 2. Blood Pressure Tracker 🩺
**Purpose:** Record blood pressure measurements with clinical guidelines support (2-3 readings)

**Questions:**
1. Date and Time (auto-filled with current, editable)
2. Arm Used (Left/Right - multiple choice)
3. Posture (Lying down/Sitting/Standing - multiple choice)
4. **Multiple BP Measurements** (dynamic add/remove):
   - Systolic (mmHg)
   - Diastolic (mmHg)
   - Heart Rate (bpm)
   - Minimum: 1 reading (required)
   - Maximum: 3 readings
   - [+ Add Another Reading] button
   - [Delete] button for each reading (except first)
5. Notes (optional text input)

**Entry Point:** Card on home screen
**Skip Functionality:** No skip buttons (all required except notes)

---

### 3. Symptom Tracker ❤️
**Purpose:** Log daily symptoms and check-ins

**Questions (ALL OPTIONAL/SKIPPABLE):**
1. Date and Time (auto-filled with current, editable)
2. Postural Symptoms (0-10 scale)
   - Same wording: "Dizziness/lightheadedness, feeling faint or like you might blackout, vision problems (blurry, tunnel vision, diminished vision, seeing spots, etc.), weakness, fatigue, trouble concentrating, pain or discomfort in shoulders/back of neck, nausea (0 = None, 10 = Worst possible)"
3. Current Fatigue Level (1-7 rating with labels)
4. Other Symptoms (text input for notes)
5. Last Meal Time (date/time picker with date toggle - default to current date)

**Entry Point:** Green "Daily Health Check-In" card on home screen (PRIORITIZED)
**Skip Functionality:** ALL questions have skip button
**Notification:** 7:00 PM daily reminder (only for Symptom Tracker)

---

## 🎨 UI/UX Design Decisions

### Home Screen Layout
```
┌─────────────────────────────────┐
│     Live Monitoring Header       │
├─────────────────────────────────┤
│  Connection Status Widget        │
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ ❤️ Daily Health Check-In    │ │ <- PRIORITIZED (Green gradient)
│ │ Tap to record symptoms      │ │    Symptom Tracker
│ │                             │ │
│ └─────────────────────────────┘ │
├─────────────────────────────────┤
│ ┌────────────┐ ┌──────────────┐│
│ │🛌 Sleep    │ │🩺 BP         ││ <- Side by side cards
│ │  Tracker   │ │  Tracker     ││
│ │            │ │              ││
│ └────────────┘ └──────────────┘│
├─────────────────────────────────┤
│     Current BP Reading Card      │
├─────────────────────────────────┤
│     Live Trend Chart             │
└─────────────────────────────────┘
```

**Card Hierarchy:**
1. **Priority 1:** Symptom Tracker (large green card, full width)
2. **Priority 2:** Sleep & BP Trackers (smaller cards, side-by-side below)
3. Maintains existing home screen elements (connection status, live monitoring)

---

### Bottom Navigation
**Keep Current Structure:**
```
┌─────┬─────────┬─────────┬──────────┐
│Home │ History │ Alerts  │ Settings │
└─────┴─────────┴─────────┴──────────┘
```

**Note:** "Check-In" navigation is replaced by the three tracker cards on home screen

---

### History Screen Design
**Option A Selected: Combined History with Tabs**

```
┌────────────────────────────────────┐
│      History                       │
├────────────────────────────────────┤
│  Statistics Card                   │
│  (Total, This Week, This Month)    │
├────────────────────────────────────┤
│ [All] [Sleep] [BP] [Symptoms]      │ <- Filter tabs
├────────────────────────────────────┤
│ ┌────────────────────────────────┐│
│ │ ❤️ Symptom Check-In            ││
│ │ Jan 22, 2026 - 7:30 PM         ││
│ │ Completed                      ││
│ └────────────────────────────────┘│
│ ┌────────────────────────────────┐│
│ │ 🩺 BP Measurement              ││
│ │ Jan 22, 2026 - 2:15 PM         ││
│ │ 3 readings                     ││
│ └────────────────────────────────┘│
│ ┌────────────────────────────────┐│
│ │ 🛌 Sleep Log                   ││
│ │ Jan 22, 2026 - 8:00 AM         ││
│ │ Sleep quality: 7/10            ││
│ └────────────────────────────────┘│
└────────────────────────────────────┘
```

**Features:**
- Unified list sorted by date/time (most recent first)
- Tab filters to show specific tracker type
- Icons differentiate tracker types
- Tap card to view full details
- Statistics include all tracker types

---

## 🔧 Technical Architecture

### Models (Following OOP, SRP)
**Existing models support all requirements:**
- `Question` model already supports all question types
- `QuestionnaireTemplate` for each tracker type
- `QuestionnaireResponse` with timestamps
- **NEW:** `BPMeasurement` model for dynamic BP readings

### Controllers (Following SRP)
**Reuse existing `QuestionnaireController`:**
- Already handles any template type
- No changes needed - follows Open/Closed Principle

### Repositories (Following OCP)
**Update `MockQuestionnaireRepository`:**
- Add three new templates:
  - `sleep_tracker`
  - `bp_tracker`
  - `symptom_tracker`
- Remove old `orthostatic_assessment` template

### New UI Components
1. **`MultipleBPMeasurementWidget`** (StatefulWidget)
   - Dynamic list of BP reading entries
   - Add/Remove reading functionality
   - Validation (1-3 readings)
   - Large input fields for elderly accessibility

2. **`TrackerCard`** (Reusable widget)
   - Used for all three tracker types on home
   - Takes: icon, title, subtitle, color, onTap
   - Consistent design with existing cards

3. **Update `question_widgets.dart`**
   - Add skip button support to all question widgets
   - Conditional rendering based on question.required flag

### Views
1. **`home_screen.dart`** - Update layout:
   - Add three tracker cards (prioritize symptom tracker)
   - Remove old check-in card
   
2. **`questionnaire_screen.dart`** - Update:
   - Add skip button to each question (when not required)
   - Skip updates answer to null/empty
   - Validation ignores skipped questions

3. **`questionnaire_history_screen.dart`** - Update:
   - Add tab bar for filtering
   - Update list to show mixed tracker types
   - Add icons for visual differentiation
   - Update FAB to show tracker selection dialog

### Services
**Notification Service:**
- Keep existing 7 PM daily reminder
- Update notification text: "Time for your daily symptom check-in"
- Notification payload: `symptom_tracker` (not `questionnaire`)

---

## 📱 Question Type Mapping

### Question Types Used:

| Tracker | Question | Type | Required |
|---------|----------|------|----------|
| **Sleep** | Today's Date | dateTime | Yes |
| **Sleep** | Last Meal Time | dateTime | Yes |
| **Sleep** | Bed Time | dateTime (time only) | Yes |
| **Sleep** | Wake-up Time | dateTime (time only) | Yes |
| **Sleep** | Sleep Quality | scale (0-10) | Yes |
| **Sleep** | Fatigue Score | ratingWithLabels (1-7) | Yes |
| **Sleep** | Notes | textInput | No |
| **BP** | Date/Time | dateTime | Yes |
| **BP** | Arm | multipleChoice | Yes |
| **BP** | Posture | multipleChoice | Yes |
| **BP** | Measurements | **NEW: multipleBPReadings** | Yes (1-3) |
| **BP** | Notes | textInput | No |
| **Symptom** | Date/Time | dateTime | No |
| **Symptom** | Postural Symptoms | scale (0-10) | No |
| **Symptom** | Fatigue Level | ratingWithLabels (1-7) | No |
| **Symptom** | Other Symptoms | textInput | No |
| **Symptom** | Last Meal Time | dateTime | No |

---

## 🎯 User Flows

### Sleep Tracker Flow
1. User taps "Sleep Tracker" card on home
2. Opens full-screen questionnaire
3. 7 questions displayed page-by-page
4. No skip buttons (all required except notes)
5. Progress bar shows 1/7, 2/7, etc.
6. Submit saves to history
7. Success message + return to home

### BP Tracker Flow
1. User taps "BP Tracker" card on home
2. Opens full-screen questionnaire
3. First 3 questions standard (date, arm, posture)
4. BP Measurements screen:
   - Shows 1 reading row (required)
   - "+ Add Another Reading" button (max 3 total)
   - Each row: Systolic, Diastolic, Heart Rate
   - Delete button on rows 2 & 3
5. Notes (optional)
6. Submit saves all readings
7. Success message + return to home

### Symptom Tracker Flow (Priority)
1. User taps green "Daily Health Check-In" card OR
2. User receives 7 PM notification and taps it
3. Opens full-screen questionnaire
4. Each question has "Skip" button in top-right
5. Can skip any/all questions
6. Submit enabled even if all skipped
7. Success message + return to home

---

## 📊 Data Storage

### QuestionnaireResponse Structure
```json
{
  "id": "uuid",
  "templateId": "symptom_tracker", // or sleep_tracker, bp_tracker
  "userId": "default_user",
  "startedAt": "2026-01-22T19:00:00.000Z",
  "completedAt": "2026-01-22T19:05:30.000Z",
  "isComplete": true,
  "answers": [
    {
      "questionId": "postural_symptoms",
      "value": 3,
      "answeredAt": "2026-01-22T19:02:00.000Z"
    },
    {
      "questionId": "bp_measurements",
      "value": [
        {"systolic": 120, "diastolic": 80, "heartRate": 72},
        {"systolic": 118, "diastolic": 78, "heartRate": 70}
      ],
      "answeredAt": "2026-01-22T14:15:00.000Z"
    }
  ]
}
```

---

## 🚀 Implementation Plan

### Phase 1: Models & Data Layer
1. Create `BPMeasurement` model
2. Add new question type: `multipleBPReadings`
3. Update repository with 3 new templates
4. Remove old orthostatic template

### Phase 2: UI Components
1. Create `MultipleBPMeasurementWidget`
2. Create `TrackerCard` widget
3. Add skip button support to question widgets

### Phase 3: Screen Updates
1. Update `home_screen.dart` with three tracker cards
2. Update `questionnaire_screen.dart` for skip functionality
3. Update `questionnaire_history_screen.dart` with tabs

### Phase 4: Integration
1. Update notification text/payload
2. Update navigation routes
3. Test all three tracker flows
4. Update existing unit tests

### Phase 5: Testing
1. Test all question types
2. Test skip functionality
3. Test multiple BP readings (add/remove)
4. Test history filtering
5. Test notifications

---

## ✅ Accessibility Considerations (Elderly Users)

- **Large touch targets:** Minimum 60x60px for all buttons
- **High contrast:** All text clearly visible
- **Large text:** 18-24px for body text
- **Clear labels:** No ambiguous language
- **Simple navigation:** One question per page
- **Skip option:** Reduce cognitive load for optional questions
- **Progress indicator:** Clear visual feedback
- **Confirmation messages:** Success/error feedback
- **No time pressure:** No auto-advance or timeouts

---

## 🔔 Notification Strategy

**Single Daily Reminder:**
- **Time:** 7:00 PM daily
- **Title:** "🩺 Time for Your Daily Health Check-In"
- **Message:** "Complete your symptom tracker to help monitor your health."
- **Action:** Opens Symptom Tracker directly
- **User Control:** Can enable/disable in Settings
- **Respect:** Opt-in only (not auto-scheduled)

**No notifications for:**
- Sleep Tracker (user initiates in morning)
- BP Tracker (user initiates when taking readings)

---

## 📝 Future Enhancements

1. **Data Visualization:**
   - Sleep quality trends over time
   - BP readings chart with multiple measurements
   - Symptom frequency heatmap

2. **Smart Suggestions:**
   - Recommend BP measurement based on last reading time
   - Morning notification for sleep tracker if not completed

3. **Export Functionality:**
   - PDF reports for each tracker type
   - Share with healthcare provider

4. **Integration:**
   - Link BP readings with concurrent symptom reports
   - Correlate sleep quality with next-day symptoms

---

## 🎨 Design System Consistency

**Colors:**
- Symptom Tracker: Green gradient (existing)
- Sleep Tracker: Purple/Blue
- BP Tracker: Red/Orange (medical theme)

**Icons:**
- Sleep: 🛌 `Icons.bedtime`
- BP: 🩺 `Icons.favorite` or `Icons.monitor_heart`
- Symptom: ❤️ `Icons.assignment` or `Icons.health_and_safety`

**Typography:** (Existing - no changes)
- Heading1: 32px bold
- Heading2: 28px bold
- Heading3: 24px bold
- BodyLarge: 18px
- BodyMedium: 16px

---

## 🔒 Privacy & Data

- All data stored locally (MockRepository)
- Firebase-ready models with JSON serialization
- User consent required for notifications
- No automatic data collection
- User can delete any tracker entry from history

---

## ✨ Success Criteria

- [ ] All three trackers accessible from home screen
- [ ] Symptom tracker prioritized (largest card)
- [ ] BP tracker supports 1-3 readings with add/remove
- [ ] All symptom tracker questions skippable
- [ ] History shows all trackers with filtering
- [ ] 7 PM notification works for symptom tracker only
- [ ] No linter errors or warnings
- [ ] Follows SOLID principles (OOP, OCP, SRP)
- [ ] Accessible for elderly users
- [ ] Clean, maintainable code

---

**Document Version:** 1.0  
**Last Updated:** January 22, 2026  
**Status:** Ready for Implementation

