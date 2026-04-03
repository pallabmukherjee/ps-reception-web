<?php

namespace App\Notifications;

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
        return ['database', 'fcm'];
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        $this->complaint->loadMissing('subCategory.category');
        
        return [
            'complaint_id' => $this->complaint->id,
            'complainant_name' => $this->complaint->complainant_name,
            'phone' => $this->complaint->phone,
            'category_name' => $this->complaint->subCategory->category->name ?? 'Unknown',
            'sub_category_name' => $this->complaint->subCategory->name ?? 'Unknown',
            'title' => '🚨 EMERGENCY HIGH ALERT 🚨',
            'message' => "New {$this->complaint->subCategory->name} registered.",
            'type' => 'high_priority',
            'complaint_created_at' => $this->complaint->created_at->toIso8601String(),
        ];
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
            ->withData([
                'complaint_id' => (string) $this->complaint->id,
                'type' => 'high_priority',
                'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
            ]);
    }
}
