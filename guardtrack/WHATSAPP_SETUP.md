# WhatsApp Cloud API Setup Guide

## Current Configuration Status

✅ **Access Token**: Configured  
❌ **Phone Number ID**: Needs to be configured  

## Steps to Complete Setup

### 1. Get Your Phone Number ID

1. Go to [Meta for Developers](https://developers.facebook.com/)
2. Navigate to your WhatsApp Business app
3. Go to **WhatsApp > Getting Started**
4. Find your **Phone Number ID** (it looks like: `123456789012345`)

### 2. Update the Configuration

Replace `YOUR_PHONE_NUMBER_ID` in the file:
`guardtrack/lib/shared/services/whatsapp_cloud_api_service.dart`

```dart
// Replace this line:
static const String _phoneNumberId = 'YOUR_PHONE_NUMBER_ID';

// With your actual Phone Number ID:
static const String _phoneNumberId = '123456789012345'; // Your actual ID
```

### 3. Test the Integration

1. Open the GuardTrack app
2. Go to **WhatsApp Bot > Settings**
3. Use the **"Send Now"** button to test
4. Check the app logs for success/error messages

## Current Message Configuration

- **Sender (WhatsApp Business Number)**: +254792823173
- **Receiver**: +254792823173 (same number)
- **Message**: "hello mbugua from app"
- **Recipient Name**: Mbugua

**Note**: This configuration sends a WhatsApp message from +254792823173 to itself. This is useful for testing and self-notifications.

## API Endpoints Used

- **Send Message**: `https://graph.facebook.com/v17.0/{phone-number-id}/messages`
- **Get Account Info**: `https://graph.facebook.com/v17.0/{phone-number-id}`

## Troubleshooting

### Common Issues

1. **"Phone Number ID not configured"**
   - Update the `_phoneNumberId` constant as described above

2. **"Access token expired"**
   - Generate a new permanent access token from Meta for Developers

3. **"Message not delivered"**
   - Ensure the recipient number is registered with WhatsApp
   - Check if your WhatsApp Business account is approved

### Debug Information

The app will show configuration status in the Settings tab:
- ✅ Green: Properly configured
- ❌ Red: Needs configuration

## Message Flow

1. **App Startup**: Automatically sends message (once per day)
2. **Manual Send**: Use "Send Now" button in Settings
3. **Fallback**: If Cloud API fails, falls back to opening WhatsApp app

## Security Notes

- Access tokens are embedded in the app (consider server-side implementation for production)
- Phone Number ID is not sensitive but should be correct
- Monitor API usage to avoid rate limits

## Next Steps

1. Get your Phone Number ID from Meta for Developers
2. Update the configuration file
3. Test the integration
4. Monitor logs for successful delivery
