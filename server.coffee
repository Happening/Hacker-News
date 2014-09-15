Plugin = require 'plugin'
Db = require 'db'
Http = require 'http'
Event = require 'event'

exports.client_vote = (storyId) !->
	Db.shared.modify "stories", storyId, "votes", Plugin.userId(), (v) ->
		if v then null else true

exports.client_read = !->
	Db.personal(Plugin.userId()).set("unread", {})

exports.client_update = !->
	Plugin.assertAdmin()
	update()

exports.hourly = !->
	update()

update = !->
	Http.get "https://news.ycombinator.com"

exports.onHttpResponse = (data) !->

	re = /down_([0-9]+)"><\/span><\/center><\/td><td class="title"><a href="([^"]+)">([^<]+)<\/a>/g

	unread = {}
	while m = re.exec(data)
		[all, id, url, title] = m

		if !Db.shared.get("stories", id)
			unread[id] = true
			Event.create
				unit: "new"
				text: "New HN article: #{title}"

		Db.shared.merge "stories", id,
			title: title
			url: url

	for userId in Plugin.userIds()
		Db.personal(userId).merge("unread", unread)