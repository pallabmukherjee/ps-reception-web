<?php

namespace App\Notifications;

use App\Channels\FcmChannel;
use App\Models\Complaint;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\AndroidConfig;
use Kreait\Firebase\Messaging\Notification as FcmNotification;

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
        return ['database', FcmChannel::class];
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray(object $notifiable): array
    {
        $message = $this->complaint->action_taken ?? 'No action specified';

        return [
            'complaint_id' => $this->complaint->id,
            'title' => '✅ Official Action Updated',
            'message' => $message,
            'type' => 'action_updated',
            'action_taken' => $this->complaint->action_taken,
            'action_details' => $this->complaint->action_details,
        ];
    }

    /**
     * Get the FCM representation of the notification.
     */
    public function toFcm(object $notifiable): CloudMessage
    {
        $message = $this->complaint->action_taken ?? 'No action specified';

        return CloudMessage::new()
            ->withNotification(FcmNotification::create('✅ Official Action Updated', $message))
            ->withAndroidConfig(AndroidConfig::fromArray([
                'priority' => 'high',
            ]))
            ->withApnsConfig(\Kreait\Firebase\Messaging\ApnsConfig::fromArray([
                'payload' => [
                    'aps' => [
                        'sound' => 'crunchy_beeps.mp3',
                        'badge' => 1,
                    ],
                ],
            ]))
            ->withData([
                'title' => '✅ Official Action Updated',
                'message' => $message,
                'complaint_id' => (string) $this->complaint->id,
                'complainant_name' => $this->complaint->complainant_name,
                'phone' => $this->complaint->phone,
                'type' => 'action_updated',
                'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
            ]);
    }
}
