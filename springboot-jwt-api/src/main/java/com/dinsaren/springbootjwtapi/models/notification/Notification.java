package com.dinsaren.springbootjwtapi.models.notification;

public class Notification{
	private String sound;
	private String body;
	private String title;

	public void setSound(String sound){
		this.sound = sound;
	}

	public String getSound(){
		return sound;
	}

	public void setBody(String body){
		this.body = body;
	}

	public String getBody(){
		return body;
	}

	public void setTitle(String title){
		this.title = title;
	}

	public String getTitle(){
		return title;
	}

	@Override
 	public String toString(){
		return 
			"Notification{" + 
			"sound = '" + sound + '\'' + 
			",body = '" + body + '\'' + 
			",title = '" + title + '\'' + 
			"}";
		}
}
