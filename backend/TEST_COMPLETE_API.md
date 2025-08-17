# Complete API Test Guide

## Prerequisites

Before testing, ensure you have:

1. **PostgreSQL** running
2. **Database** created and **migrations** run:
```bash
# Create database
createdb attendkal_db

# Run migrations  
npx prisma migrate dev --name initial_schema
```

3. **Server** running:
```bash
npm run dev
```

## Authentication Setup

### 1. Register a test user
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@university.edu",
    "password": "SecurePass123",
    "username": "teststudent",
    "timezone": "Europe/Istanbul"
  }'
```

### 2. Login and get token
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@university.edu", 
    "password": "SecurePass123"
  }'
```

**Important**: Copy the `token` from the response for subsequent requests.

## Course Management

### 3. Create a course
```bash
export TOKEN="YOUR_JWT_TOKEN_HERE"

curl -X POST http://localhost:3000/api/courses \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Computer Networks",
    "code": "CS301",
    "teacher": "Dr. Smith",
    "location": "Room 101",
    "color": "#3B82F6",
    "note": "Important course for graduation",
    "maxAbsences": 3
  }'
```

### 4. Get all courses
```bash
curl -X GET http://localhost:3000/api/courses \
  -H "Authorization: Bearer $TOKEN"
```

### 5. Get course details
```bash
export COURSE_ID="COURSE_ID_FROM_STEP_4"

curl -X GET http://localhost:3000/api/courses/$COURSE_ID \
  -H "Authorization: Bearer $TOKEN"
```

## Meeting Management

### 6. Add meeting to course
```bash
curl -X POST http://localhost:3000/api/courses/$COURSE_ID/meetings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "weekday": 2,
    "startHHmm": "14:30",
    "durationMin": 90,
    "location": "Computer Lab",
    "note": "Bring laptop"
  }'
```

## Session Management

### 7. Generate sessions from meetings
```bash
curl -X POST http://localhost:3000/api/sessions/generate \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "courseId": "'$COURSE_ID'",
    "from": "2025-08-20T00:00:00.000Z",
    "to": "2025-09-20T23:59:59.000Z"
  }'
```

### 8. Get sessions
```bash
curl -X GET "http://localhost:3000/api/sessions?courseId=$COURSE_ID&from=2025-08-20T00:00:00.000Z&to=2025-09-20T23:59:59.000Z" \
  -H "Authorization: Bearer $TOKEN"
```

### 9. Create manual session
```bash
curl -X POST http://localhost:3000/api/sessions/$COURSE_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "startUtc": "2025-08-21T14:30:00.000Z",
    "durationMin": 90,
    "source": "MANUAL"
  }'
```

## Attendance Management

### 10. Mark attendance
```bash
export SESSION_ID="SESSION_ID_FROM_STEP_8"

curl -X POST http://localhost:3000/api/attendance/$SESSION_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "status": "PRESENT",
    "note": "Attended full session"
  }'
```

### 11. Mark absence (to test limits)
```bash
curl -X POST http://localhost:3000/api/attendance/$SESSION_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "status": "ABSENT",
    "note": "Was sick"
  }'
```

### 12. Get attendance details
```bash
curl -X GET http://localhost:3000/api/attendance/$SESSION_ID \
  -H "Authorization: Bearer $TOKEN"
```

## Reminder Management

### 13. Create course reminder
```bash
curl -X POST http://localhost:3000/api/reminders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "courseId": "'$COURSE_ID'",
    "title": "CS301 Class Reminder",
    "morningOfClass": true,
    "minutesBefore": 30,
    "thresholdAlerts": true,
    "enabled": true
  }'
```

### 14. Create general reminder
```bash
curl -X POST http://localhost:3000/api/reminders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Study for midterm exams",
    "morningOfClass": false,
    "minutesBefore": 1440,
    "thresholdAlerts": false,
    "cron": "0 9 * * 1",
    "enabled": true
  }'
```

### 15. Get all reminders
```bash
curl -X GET http://localhost:3000/api/reminders \
  -H "Authorization: Bearer $TOKEN"
```

### 16. Update reminder
```bash
export REMINDER_ID="REMINDER_ID_FROM_STEP_15"

curl -X PUT http://localhost:3000/api/reminders/$REMINDER_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Updated CS301 Class Reminder",
    "minutesBefore": 60,
    "enabled": false
  }'
```

## Testing Business Rules

### 17. Test absence limits
Create multiple sessions and mark them as absent to test the `remainingAbsences` and `lastStrike` logic:

```bash
# Check course statistics after marking absences
curl -X GET http://localhost:3000/api/courses/$COURSE_ID \
  -H "Authorization: Bearer $TOKEN"
```

The response should show:
- `stats.absentCount`: Number of absences
- `stats.remainingAbsences`: Calculated as `maxAbsences - absentCount`
- `stats.lastStrike`: `true` when `remainingAbsences === 1`

## Expected Results

### Successful API Responses
- All endpoints should return `{ "success": true, "data": {...} }`
- HTTP status codes: 200 (GET/PUT), 201 (POST), appropriate error codes
- Proper attendance statistics calculation
- JWT token authentication working

### Error Cases to Test
- Invalid tokens (401)
- Non-existent resources (404)  
- Validation errors (400)
- Rate limiting (429)

## Database Verification

You can also verify data using Prisma Studio:
```bash
npx prisma studio
```

This opens a web interface at http://localhost:5555 to browse your data.
