<?php

namespace App\Channels;

use Illuminate\Notifications\Notification;
use Kreait\Laravel\Firebase\Facades\Firebase;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification as FirebaseNotification;
use Kreait\Firebase\Messaging\AndroidConfig;

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

            $fcmMessage = $notification->toFcm($notifiable);
            $data = $fcmMessage->toArray();

            $message = CloudMessage::withTarget('token', $token);

            if (isset($data['notification'])) {
                $message = $message->withNotification(FirebaseNotification::fromArray($data['notification']));
            }

            if (isset($data['data'])) {
                $message = $message->withData($data['data']);
            }

            if (isset($data['android'])) {
                $message = $message->withAndroidConfig(AndroidConfig::fromArray($data['android']));
            }

            Firebase::messaging()->send($message);
            
            \Log::info("FCM: Notification sent successfully to user ID: " . ($notifiable->id ?? 'unknown'));
        } catch (\Exception $e) {
            \Log::error("FCM Error for user ID " . ($notifiable->id ?? 'unknown') . ": " . $e->getMessage());
            throw $e;
        }
    }
}
