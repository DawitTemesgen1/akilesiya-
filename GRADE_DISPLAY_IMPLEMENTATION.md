# Grade Display Issue - Implementation Summary

## Problem
The grade display in the profile screen is showing placeholders ("Subject N/A/100") or no grades at all, even though the grade management system has dynamic courses and assessments.

## Root Cause
The API endpoint `/profile/my-grades` is either:
1. Not returning any data
2. Returning data in a different format than expected
3. Not implemented on the backend

## Current Implementation

### Frontend (Profile Screen)
**File:** `lib/users screen/profile_screen.dart` (lines 725-871)

The `_buildGradesCard` method expects grades in this format:
```dart
{
  "success": true,
  "data": {
    "grades": [
      {
        "course_name": "Mathematics",
        "assessment_name": "Midterm",
        "score": 85,
        "max_score": 100
      },
      ...
    ]
  }
}
```

Or organized by year:
```dart
{
  "success": true,
  "data": {
    "2017": [...],
    "2016": [...]
  }
}
```

### How Grade Management Works
**File:** `lib/role based/grade_management_screen.dart`

The grade management screen uses:
- `GradeService.getStudentsWithGrades(spiritualClass, year)` - Returns students with embedded grades
- `GradeService.getCourses(spiritualClass)` - Returns courses for a class
- `GradeService.getAssessmentsForCourse(courseId)` - Returns assessments for a course

**Data Structure:**
```dart
Student {
  "student_id": "123",
  "full_name": "John Doe",
  "grades": [
    {
      "course_id": 1,
      "course_name": "Mathematics",
      "assessment_id": 1,
      "assessment_name": "Midterm",
      "score": 85,
      "max_score": 100
    },
    ...
  ],
  "average_score": 87.5
}
```

## Required Backend Implementation

The `/profile/my-grades` endpoint should:

1. Get the current user's ID from the authenticated session
2. Query the `student_grades` table (or equivalent) for all grades belonging to this user
3. Join with `courses` and `assessments` tables to get names
4. Group by year (Ethiopian calendar year from the grade record)
5. Return in the format shown above

### SQL Query Example:
```sql
SELECT 
  sg.year,
  c.name as course_name,
  a.assessment_name,
  sg.score,
  a.max_score
FROM student_grades sg
JOIN courses c ON sg.course_id = c.id
JOIN assessments a ON sg.assessment_id = a.id
WHERE sg.student_id = :current_user_id
ORDER BY sg.year DESC, c.name, a.assessment_name
```

## Frontend Updates Made

### 1. Spiritual Class Dropdown (✅ Complete)
**File:** `lib/users screen/edit_profile_sheet.dart`
- Added dropdown with classes 1-12
- Integrated with profile save/load
- Matches grade management screen options

### 2. Grade Display Logic (✅ Complete)
**File:** `lib/users screen/profile_screen.dart`
- Groups grades by course
- Calculates total scores and percentages
- Handles multiple assessments per course
- Removes duplicates
- Shows year dropdown if multiple years exist

### 3. Removed Errors (✅ Complete)
- Fixed localization key (`attendanceHistory` → `attendanceHistoryTitle`)
- Fixed image display errors
- Removed unused imports
- Fixed syntax errors

## Next Steps

### Backend (Required)
1. Implement `/profile/my-grades` endpoint
2. Ensure it returns grades with course and assessment names
3. Group by Ethiopian calendar year
4. Include all assessments for each course

### Testing
1. Add a student to a class with grades
2. Verify grades appear in profile screen
3. Test with multiple years
4. Test with multiple courses
5. Test with multiple assessments per course

## API Contract

### Request
```
GET /profile/my-grades
Headers: Authorization: Bearer <token>
```

### Response
```json
{
  "success": true,
  "data": {
    "grades": [
      {
        "year": 2017,
        "course_id": 1,
        "course_name": "ሂሳብ (Mathematics)",
        "assessment_id": 1,
        "assessment_name": "የመካከለኛ ፈተና",
        "score": 85,
        "max_score": 100
      }
    ],
    "average_score": 87.5
  }
}
```

Or grouped by year:
```json
{
  "success": true,
  "data": {
    "2017": [
      {
        "course_name": "ሂሳብ",
        "assessment_name": "የመካከለኛ ፈተና",
        "score": 85,
        "max_score": 100
      }
    ],
    "2016": [...]
  }
}
```
