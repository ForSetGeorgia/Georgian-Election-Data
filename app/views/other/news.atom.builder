atom_feed do |feed|

	feed.title t '.title_feed', :app_name => (t'app.common.app_name')

  feed.updated @news.maximum(:date_posted)

	@news.each do |news|
		feed.entry news, :url => news_show_url(news), :published => news.date_posted do |entry|
			entry.title news.date_posted

			entry.content(simple_format news.description, {}, :sanitize => false, :type => 'html')
		end
	end

end
