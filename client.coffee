Db = require 'db'
Dom = require 'dom'
Modal = require 'modal'
Obs = require 'obs'
Plugin = require 'plugin'
Page = require 'page'
Server = require 'server'
Ui = require 'ui'

exports.render = !->
	Dom.h2 "Hacker News"

	unread = Db.personal.peek("unread") || {}
	for k of unread
		Obs.onTime 2000, !->
			Server.send "read"
		break

	Ui.list !->
		Db.shared.ref("stories").iterate (story) !->
			Ui.item !->
				Dom.style minHeight: '45px'
				if unread[story.key()]
					Dom.style background: '#ff6600'

				Dom.div !->
					Dom.style _boxFlex: 1
					Dom.text story.get("title")

				Dom.div !->
					story.iterate "votes", (vote) !->
						userId = vote.key()
						Ui.avatar Plugin.userAvatar(userId), !->
							Dom.style display: 'inline-block'

				Dom.onTap !->
					Server.call "vote", story.key()


		, (story) ->
			log "sort call for", story.key()
			votes = story.peek("votes")
			i = 0
			--i for x of votes
			i

exports.renderSettings = !->
	Ui.bigButton "update", !->
		Server.call "update"