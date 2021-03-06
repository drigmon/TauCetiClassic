/proc/send2slack(var/channel, var/msg, var/attachment_msg, var/name, var/icon)
	if(!config.use_slack_bot || !config.slack_team || !channel || !msg)
		return 0

	//more info here: https://api.slack.com/docs/formatting
	msg = html_decode(revert_ja(msg))
	
	var/script_args = "\"[channel]\" \"[msg]\""
	
	if(attachment_msg)
		script_args += " --attachment_message \"[attachment_msg]\""
	if(name)
		script_args += " --name \"[name]\""
	if(icon)
		script_args += " --icon \"[icon]\""
	
	//required positional args: channel, text
	//optional: --attachment_message TEXT, --name NAME, --icon EMOJI
	ext_python("slackbot_message.py", script_args)

/proc/send2slack_service(var/msg)
	if(!msg)
		return
	var/server_name = config.server_name ? config.server_name : "Noname server"
	msg = server_name + " reports: " + msg

	send2slack("service", msg)

/proc/send2slack_admincall(var/msg, var/amsg)
	if(!amsg)
		return
	
	/* to prevent abuse @mentions */
	amsg = replacetext(amsg, "@channel", "_channel")
	amsg = replacetext(amsg, "@group", "_group")
	amsg = replacetext(amsg, "@everyone", "_everyone")
	
	var/server_name = config.server_name ? config.server_name : "Noname server"
	var/name = server_name + " player report"

	send2slack("modcomm", msg, amsg, name, ":scream_cat:")

/proc/slack_startup()
	send2slack_service("server starting up")

/proc/slack_roundstart()
	send2slack_service("round is started, gamemode - [master_mode]")

/proc/slack_roundend()
	send2slack_service("round is over")
