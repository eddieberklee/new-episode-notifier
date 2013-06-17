require 'rubygems'
require 'mechanize'

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

url = "http://www.crunchyroll.com/attack-on-titan"
a.get(url) do |page|
  episodes = page.search '.portrait-element'
  listEpisodes = []
  episodes.each do |episode|
    t = episode.text.strip.split("\n").each { |textpart| textpart.strip! }
    title = t[0]
    description = t[-1]
    # puts "Title: #{title} Description: #{description}"
    if title.include? 'Episode'
      listEpisodes.push(title + "|||" + description)
    end
  end
  # puts listEpisodes
  episodes = {}
  listEpisodes.each do |episodeInfo|
    parts = episodeInfo.strip.split('|||')

    episodeNumber = parts[0].strip.split(' ')[1]
    description = parts[1]
    episodes[episodeNumber] = description
  end

  puts episodes
end








