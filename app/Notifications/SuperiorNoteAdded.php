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
        return ['database', FcmChannel::class];
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray(object $notifiable): array
    {
        return [
            'complaint_id' => $this->complaint->id,
            'complainant_name' => $this->complaint->complainant_name,
            'phone' => $this->complaint->phone,
            'title' => '📝 New Official Note Added',
            'message' => "Superior added a note to complaint record.",
            'type' => 'note_added',
            'note' => $this->complaint->note,
            'complaint_created_at' => $this->complaint->created_at->toIso8601String(),
        ];
    }

    /**
     * Get the FCM representation of the notification.
     */
    public function toFcm(object $notifiable): CloudMessage
    {
        return CloudMessage::new()
            ->withNotification(FirebaseNotification::create(
                '📝 New Official Note Added',
                "Superior added a note to complaint record."
            ))
            ->withAndroidConfig(AndroidConfig::fromArray([
                'notification' => [
                    'channel_id' => 'emergency_channel',
                    'icon' => 'ic_launcher',
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    'sound' => 'crunchy_beeps',
                ],
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
                'complaint_id' => (string) $this->complaint->id,
                'complainant_name' => $this->complaint->complainant_name,
                'phone' => $this->complaint->phone,
                'note' => (string) $this->complaint->note,
                'type' => 'note_added',
                'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
            ]);
    }
}
