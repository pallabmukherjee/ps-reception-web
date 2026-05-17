<?php

namespace App\Channels;

use Illuminate\Notifications\Notification;
use Kreait\Laravel\Firebase\Facades\Firebase;
use Kreait\Firebase\Messaging\RawMessageFromArray;

class FcmChannel
{
    /**
     * Send the given notification.
     *
     * @param  mixed  $notifiable
     * @param  \Illuminate\Notifications\Notification  $notification
     * @return void
     */
    public function send($notifiable, Notification $notification)
    {
        try {
            $token = $notifiable->routeNotificationForFcm($notification);

            if (!$token) {
                \Log::warning("FCM: No token found for user ID: " . ($notifiable->id ?? 'unknown'));
                return;
            }

            $fcmNotification = $notification->toFcm($notifiable);

            $messageData = json_decode(json_encode($fcmNotification), true);

            $messageData['token'] = (string) $token;
            $messageData['fcm_options'] = ['analytics_label' => 'emergency-alert'];

            // Ensure notification payload is always present so Android shows
            // system notification when app is in background / terminated
            $notifArray = $notification->toArray($notifiable);
            $messageData['notification'] = [
                'title' => $notifArray['title'] ?? 'Alert',
                'body' => $notifArray['message'] ?? 'New notification',
            ];

            $fullPayload = json_encode(['message' => $messageData]);
            \Log::info("FCM FULL REQUEST: " . ($fullPayload ?: 'null'));
            \Log::info("FCM HAS NOTIFICATION: " . (isset($messageData['notification']) ? 'yes' : 'no'));

            try {
                $sendResult = Firebase::messaging()->send(new RawMessageFromArray($messageData));
                \Log::info("FCM HANDOVER: Sent successfully to User {$notifiable->id}. Result: " . json_encode($sendResult));
            } catch (\Kreait\Firebase\Exception\Messaging\InvalidMessage $e) {
                \Log::error("FCM InvalidMessage: " . $e->getMessage());
                \Log::error("FCM InvalidMessage errors: " . json_encode($e->errors()));
            } catch (\Kreait\Firebase\Exception\Messaging\NotFound $e) {
                \Log::warning("FCM Token not found (unregistered), clearing for User {$notifiable->id}");
                $notifiable->update(['fcm_token' => null]);
            } catch (\Throwable $sendError) {
                \Log::error("FCM Send Error: " . $sendError->getMessage());
                \Log::error("FCM Send Error Class: " . get_class($sendError));
                \Log::error("FCM Send Error Trace: " . $sendError->getTraceAsString());
            }
        } catch (\Throwable $e) {
            \Log::error("FCM Channel Error: " . $e->getMessage());
        }
    }
}
