package com.dinsaren.springbootjwtapi.models.notification;

public class PushNotificationRequest{
	private Notification notification;
	private NotificationData data;
	private String to;

	public void setNotification(Notification notification){
		this.notification = notification;
	}

	public Notification getNotification(){
		return notification;
	}

	public void setData(NotificationData data){
		this.data = data;
	}

	public NotificationData getData(){
		return data;
	}

	public void setTo(String to){
		this.to = to;
	}

	public String getTo(){
		return to;
	}

	@Override
 	public String toString(){
		return 
			"PushNotificationRequest{" + 
			"notification = '" + notification + '\'' + 
			",data = '" + data + '\'' + 
			",to = '" + to + '\'' + 
			"}";
		}
}
