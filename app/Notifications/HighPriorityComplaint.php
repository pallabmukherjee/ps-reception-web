<?php

namespace App\Notifications;

use App\Channels\FcmChannel;
use App\Models\Complaint;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Kreait\Laravel\Firebase\Messages\FirebaseMessage;

class HighPriorityComplaint extends Notification
{
    use Queueable;

    protected $complaint;

    /**
     * Create a new notification instance.
     */
    public function __construct(Complaint $complaint)
    {
        $this->complaint = $complaint;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return [FcmChannel::class];
    }

    /**
     * Get the FCM representation of the notification.
     */
    public function toFcm(object $notifiable): FirebaseMessage
    {
        $this->complaint->loadMissing('subCategory.category');
        
        return FirebaseMessage::create()
            ->withNotification([
                'title' => '🚨 EMERGENCY HIGH ALERT 🚨',
                'body' => "New {$this->complaint->subCategory->name} registered at station.",
            ])
            ->withAndroidConfig([
                'notification' => [
                    'channel_id' => 'high_importance_channel',
                    'icon' => 'ic_launcher',
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                ],
            ])
            ->withData([
                'complaint_id' => (string) $this->complaint->id,
                'type' => 'high_priority',
                'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
            ]);
    }
}
