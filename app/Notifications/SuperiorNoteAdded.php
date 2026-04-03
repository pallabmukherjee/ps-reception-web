<?php

namespace App\Notifications;

use App\Channels\FcmChannel;
use App\Models\Complaint;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification as FirebaseNotification;
use Kreait\Firebase\Messaging\AndroidConfig;

class SuperiorNoteAdded extends Notification
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
    public function toFcm(object $notifiable): CloudMessage
    {
        return CloudMessage::new()
            ->withNotification(FirebaseNotification::create(
                '📝 New Official Note Added',
                "Superior added a note to complaint #{$this->complaint->id}."
            ))
            ->withAndroidConfig(AndroidConfig::fromArray([
                'notification' => [
                    'channel_id' => 'high_importance_channel',
                    'icon' => 'ic_launcher',
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                ],
            ]))
            ->withData([
                'complaint_id' => (string) $this->complaint->id,
                'type' => 'note_added',
                'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
            ]);
    }
}
