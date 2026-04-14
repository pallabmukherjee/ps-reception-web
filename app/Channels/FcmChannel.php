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

            if ($message instanceof CloudMessage) {
                $message = $message->withToken((string) $token);
                
                try {
                    Firebase::messaging()->send($message);
                    \Log::info("FCM: Sent successfully to User {$notifiable->id}");
                } catch (\Throwable $sendError) {
                    \Log::error("FCM Send Error: " . $sendError->getMessage());
                    
                    // If token is invalid, clear it
                    if (str_contains($sendError->getMessage(), 'registration-token-not-registered')) {
                        $notifiable->update(['fcm_token' => null]);
                        \Log::warning("FCM: Cleared invalid token for User {$notifiable->id}");
                    }
                }
            }
        } catch (\Throwable $e) {
            \Log::error("FCM Channel Error: " . $e->getMessage());
        }
    }
}
