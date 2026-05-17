<?php

namespace App\Notifications;

use App\Channels\FcmChannel;
use App\Models\Complaint;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\AndroidConfig;
use Kreait\Firebase\Messaging\Notification as FcmNotification;

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
        return ['database', FcmChannel::class];
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray(object $notifiable): array
    {
        $this->complaint->loadMissing('subCategory.category');

        $categoryName = $this->complaint->subCategory->category->name ?? 'Unknown';
        $message = "{$categoryName} complaint received.";

        return [
            'complaint_id' => $this->complaint->id,
            'title' => '🚨 EMERGENCY HIGH ALERT 🚨',
            'message' => $message,
            'type' => 'high_priority',
        ];
    }

    /**
     * Get the FCM representation of the notification.
     */
    public function toFcm(object $notifiable): CloudMessage
    {
        $this->complaint->loadMissing('subCategory.category');
        $categoryName = $this->complaint->subCategory->category->name ?? 'High Priority';

        return CloudMessage::new()
            ->withNotification(FcmNotification::create('🚨 EMERGENCY HIGH ALERT 🚨', "{$categoryName} complaint received."))
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
                'title' => '🚨 EMERGENCY HIGH ALERT 🚨',
                'message' => "{$categoryName} complaint received.",
                'complaint_id' => (string) $this->complaint->id,
                'complainant_name' => $this->complaint->complainant_name,
                'phone' => $this->complaint->phone,
                'category_name' => $categoryName,
                'sub_category_name' => $this->complaint->subCategory->name ?? 'Unknown',
                'type' => 'high_priority',
                'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
            ]);
    }
}
