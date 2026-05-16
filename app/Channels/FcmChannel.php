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

            $fullPayload = json_encode(['message' => $messageData]);
            \Log::info("FCM FULL REQUEST: " . ($fullPayload ?: 'null'));

            try {
                $result = Firebase::messaging()->send(new RawMessageFromArray($messageData));
                \Log::info("FCM HANDOVER: Sent successfully to User {$notifiable->id}. Response: " . json_encode($result));
            } catch (\Throwable $sendError) {
                \Log::error("FCM Send Error: " . $sendError->getMessage());
                \Log::error("FCM Send Error Class: " . get_class($sendError));

                if (str_contains($sendError->getMessage(), 'registration-token-not-registered')) {
                    $notifiable->update(['fcm_token' => null]);
                    \Log::warning("FCM: Cleared invalid token for User {$notifiable->id}");
                }
            }
        } catch (\Throwable $e) {
            \Log::error("FCM Channel Error: " . $e->getMessage());
        }
    }
}
