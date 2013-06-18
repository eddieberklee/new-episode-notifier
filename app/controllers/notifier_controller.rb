class NotifierController < ApplicationController
  def check
    @knownEpisodes = Episode.all

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

      @scrapedEpisodes = episodes
    end

    knownNumbers = []
    @knownEpisodes.each do |e|
      knownNumbers.push e.number
    end

    @firstSpotted = Episode.map(&:number).sort()[-1].created_at

    # Twilio API
    f = File.new("twilio.password","r")
    account_sid, auth_token = f.read.split("\n")
    @client = Twilio::REST::Client.new account_sid, auth_token

    # newEpisodes = scrapedEpisodes - knownEpisodes
    @newEpisodes = []

    @scrapedEpisodes.each do |number, title|
      number = number.to_i
      unless knownNumbers.include? number
        @newEpisodes.push number
        Episode.create(title: title, number: number)
        @client.account.sms.messages.create(
            :from => '+15103435046',
            :to => '+12486223852',
            :body => "New Attack on Titan Episode #{number}!"
        )
      end
    end

    @latestEpisode = Episode.all.map(&:number).sort()[-1]
  end
end
