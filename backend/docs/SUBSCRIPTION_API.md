# Subscription API Documentation

## Overview

The subscription system currently allows users to freely switch between FREE, PRO, and PREMIUM plans without payment requirements. Payment integration will be added in a future update.

## Endpoints

### GET /api/subscriptions/plans
Get available subscription plans (public endpoint - no authentication required)

**Response:**
```json
{
  "status": "success",
  "data": [
    {
      "id": "FREE",
      "name": "Free",
      "price": 0,
      "priceNote": "Always free",
      "features": [
        "Up to 2 courses",
        "Basic attendance tracking",
        "Email support"
      ],
      "courseLimit": 2,
      "attendanceLimit": null,
      "isRecommended": false
    },
    {
      "id": "PREMIUM",
      "name": "Premium",
      "price": 19.99,
      "priceNote": "Free during beta (payment coming soon)",
      "features": [
        "Unlimited courses",
        "Advanced analytics",
        "Priority support",
        "Export reports",
        "Custom integrations"
      ],
      "courseLimit": null,
      "attendanceLimit": null,
      "isRecommended": true
    }
  ]
}
```

### GET /api/subscriptions/
Get current user's subscription (requires authentication)

**Response:**
```json
{
  "status": "success",
  "data": {
    "id": "subscription_id",
    "userId": "user_id",
    "plan": "PREMIUM",
    "status": "ACTIVE",
    "startDate": "2024-01-01T00:00:00.000Z",
    "endDate": "2034-01-01T00:00:00.000Z",
    "user": {
      "id": "user_id",
      "name": "John Doe",
      "email": "john@example.com"
    },
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

### POST /api/subscriptions/change-plan
Change user's subscription plan (requires authentication)

**Request Body:**
```json
{
  "plan": "PREMIUM"
}
```

**Valid plans:** `FREE`, `PREMIUM`

**Response:**
```json
{
  "status": "success",
  "message": "Successfully switched to PREMIUM plan",
  "data": {
    "id": "subscription_id",
    "userId": "user_id",
    "plan": "PREMIUM",
    "status": "ACTIVE",
    "startDate": "2024-01-01T00:00:00.000Z",
    "endDate": "2034-01-01T00:00:00.000Z",
    "user": {
      "id": "user_id",
      "name": "John Doe",
      "email": "john@example.com"
    },
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

### POST /api/subscriptions/upgrade
Legacy endpoint for upgrading subscription (requires authentication)

Same as `/change-plan` endpoint for backward compatibility.

### POST /api/subscriptions/cancel
Cancel user's subscription (requires authentication)

**Response:**
```json
{
  "status": "success",
  "message": "Subscription cancelled successfully",
  "data": {
    "id": "subscription_id",
    "userId": "user_id",
    "plan": "FREE",
    "status": "CANCELLED",
    "startDate": "2024-01-01T00:00:00.000Z",
    "endDate": "2024-01-01T12:00:00.000Z",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

## Plan Features

### FREE Plan
- Up to 2 courses
- Basic attendance tracking
- Email support
- Always free

### PREMIUM Plan (Free during beta)
- Unlimited courses
- Advanced analytics
- Priority support
- Export reports
- Custom integrations
- Free during beta period

## Error Responses

### 400 Bad Request
```json
{
  "status": "error",
  "message": "Plan is required"
}
```

```json
{
  "status": "error",
  "message": "Invalid plan type. Must be one of: FREE, PREMIUM"
}
```

### 401 Unauthorized
```json
{
  "status": "error",
  "message": "Authentication required"
}
```

### 404 Not Found
```json
{
  "status": "error",
  "message": "Subscription not found"
}
```

## Notes

- All subscription plan changes are currently free during the beta period
- Users can switch between any plans without restrictions
- Payment integration will be added in a future update
- Course limits are enforced based on the user's current plan
- New users automatically get a FREE subscription if they don't have one 