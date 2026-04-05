<?php

namespace App\Channels;

use Illuminate\Notifications\Notification;
use Kreait\Laravel\Firebase\Facades\Firebase;
use Kreait\Firebase\Messaging\CloudMessage;

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

            $message = $notification->toFcm($notifiable);

            // Ensure the message has the target token
            if ($message instanceof CloudMessage) {
                $message = $message->withChangedTarget('token', $token);
                Firebase::messaging()->send($message);
                \Log::info("FCM: Notification sent successfully to user ID: " . ($notifiable->id ?? 'unknown'));
            }
        } catch (\Exception $e) {
            \Log::error("FCM Error for user ID " . ($notifiable->id ?? 'unknown') . ": " . $e->getMessage());
            throw $e;
        }
    }
}
